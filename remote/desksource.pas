unit desksource;

interface

uses
  Windows, Messages,SysUtils,Classes,Graphics,Variants,CustomThreadUnt,
  DirectDraw,JPEG;

type
  TCaptureEvent=procedure (TmpStream:TStream;rt:TRect;iCursor:LongWord)of Object;
  Tdesksource=class
      constructor Create;
      destructor  Destroy;override;
    private
      FBackBitmap:TBitmap;
      PrimaryDraw:IDirectDraw7;              // ddraw 对象
      //------------------------------------------------------------------------
      FCapture,
      bStatus:boolean;
      //------------------------------------------------------------------------
      FDeskTopRect:TRECT;
      PRectList:TThreadList;
      FPixelFormat:TPixelFormat;
      //------------------------------------------------------------------------
      FCaptureEvent:TCaptureEvent;
      FWorkThread:TCustomThread;
      procedure freeCapture;
      procedure CaptureScreen(rt:TRect);
      procedure CaptureWorkProcess(Sender:TObject);
    public
      procedure UpdateRect(TmpRect:TRect;const force:Boolean=False);
      procedure SetColorLevel(iLevel:Integer);
      procedure Capture;
      procedure CaptureStart;
      procedure CaptureStop;
    published
      property CaptureRect:TRect Read FDeskTopRect;
      property CaptureEvent:TCaptureEvent Write FCaptureEvent;
    end;

implementation
uses Math;

//检查是否有存在命令行提示窗口存在,有就返其匹域
function GetForegroundRect:TRect;
var
  hFgWin:HWND;
  cname:array[0..23]of char;
begin
  SetRectEmpty(Result);
  hFgWin:=GetForegroundWindow();
  if hFgWin>0 then
    begin
    fillchar(cname, sizeof(cname), 0);
    if GetClassName(hFgWin, cname, sizeof(cname))>0 then
    if (StrPas(cname)='tty')or(StrPas(cname)='ConsoleWindowClass') then
    if not GetWindowRect(hFgWin,result) then SetRectEmpty(result);
    end;
end;

//比较两个矩形是否能水平或垂直合并
function CompareRegion(dRect,sRect:TRect):Boolean;
begin
  Result:=False;
  if (dRect.Left=sRect.Left) and (dRect.Right=sRect.Right) then //相同的宽度
  if (dRect.Top=sRect.Bottom) or (dRect.Bottom=sRect.Top) then  //上下相邻
    begin
    Result:=True;
    exit;
    end;

  if (dRect.Top=sRect.Top) and (dRect.Bottom=sRect.Bottom) then //相同的高度
  if (dRect.Left=sRect.Right) or (dRect.Right=sRect.Left) then  //左右相邻
    Result:=True;
end;

//比较 dRect 是否被 sRect 包含
function compriseRegion(dRect,sRect:TRect):Boolean;
var
  TmpRect:TRect;
begin
  Result:=false;
  UnionRect(TmpRect,dRect,sRect);
  if not IsRectEmpty(TmpRect) then
    Result:=EqualRect(TmpRect,sRect);
end;

//将当前矩形与现在矩形缓冲列表进行合并 返回合并后的新矩形，否则返回空值
function CalcUnionRegion(TmpRegion:TRect;TmpList:TThreadList):TRect;
var
  Bool:boolean;
  TmpPRegion:PRect;
  i:integer;
begin
  Bool:=false;
  SetRectEmpty(Result);

  //是否被其它矩形包含，是否存在相同矩形
  try
  with TmpList.LockList do
    for i:=count downto 1 do
    if EqualRect(TmpRegion,PRect(items[i-1])^) or compriseRegion(TmpRegion,PRect(items[i-1])^) then
      begin
      Bool:=true;
      break;
      end;
  finally
  TmpList.UnlockList;
  end;

  //矩形相邻 或包含缓冲区内的矩形 合并矩形
  if not Bool then  
  try
  with TmpList.LockList do
    for i:=count downto 1 do
    if CompareRegion(TmpRegion,PRect(items[i-1])^) or compriseRegion(PRect(items[i-1])^,TmpRegion) then
      begin
      UnionRect(Result,TmpRegion,PRect(items[i-1])^); //合并矩形
      dispose(PRect(items[i-1]));
      delete(i-1);
      Bool:=true;
      break;
      end;
  finally
  TmpList.UnlockList;
  end;

  if not Bool then  //无法合并直接加入到缓冲列
    try
    new(TmpPRegion);
    TmpPRegion^:=TmpRegion;
    with TmpList.LockList do
      begin
      if Count>256 then  //仅仅保存 16个矩形
        begin
        dispose(PRect(items[0]));
        delete(0);
        end;
      Add(TmpPRegion);
      end;
    finally
    TmpList.UnlockList;
    end;
end;

//添加矩形到矩形缓冲列表
procedure CalcAddRegion(TmpRegion:TRect;TmpList:TThreadList);
begin
  //检查是否有合并出新的短形如果是重新进入合并计算
  while not IsRectEmpty(TmpRegion) do
    TmpRegion:=CalcUnionRegion(TmpRegion,TmpList);
end;

//接收屏幕刷新响应并将更新区域加入到缓冲块
procedure Tdesksource.UpdateRect(TmpRect:TRect;const force:Boolean=False);
var
  xSize,ySize:Word;
begin
  if IsRectEmpty(TmpRect) then exit;
  if not force and EqualRect(TmpRect,FDeskTopRect) then exit;

  xSize:=FDeskTopRect.Right div 16;
  ySize:=FDeskTopRect.Bottom div 16;
  TmpRect.Top:=(TmpRect.Top div ySize)*ySize;
  TmpRect.Left:=(TmpRect.Left div xSize)*xSize;
  TmpRect.Right:=((TmpRect.Right+xSize-1) div xSize)*xSize;
  TmpRect.Bottom:=((TmpRect.Bottom+ySize-1) div ySize)*ySize;

  TmpRect.Right:=min(TmpRect.Right,FDeskTopRect.Right);
  TmpRect.Bottom:=min(TmpRect.Bottom,FDeskTopRect.Bottom);
  CalcAddRegion(TmpRect,PRectList);  
end;

//取出矩形缓冲里的第一个数据
function GetNextRect(var TmpRect:TRect;TmpList:TThreadList):Boolean;
begin
  try
  Result:=False;
  with TmpList.LockList do
    if count>0 then
      begin
      TmpRect:=PRect(items[0])^;
      dispose(PRect(items[0]));
      delete(0);
      Result:=True;
      end;
  finally
  TmpList.UnlockList;
  end;
end;

//------------------------------------------------------------------------------
// 截屏并发送线程
//------------------------------------------------------------------------------
procedure Tdesksource.CaptureWorkProcess(Sender:TObject);
var
  TmpRect:TRect;
begin
  if not bStatus then exit;
  if FCapture then
    begin
    SetRectEmpty(TmpRect);
    UpdateRect(GetForegroundRect);
    if GetNextRect(TmpRect,PRectList) then
    if not IsRectEmpty(TmpRect) then
      CaptureScreen(TmpRect);
    end;
end;

//------------------------------------------------------------------------------
// 响应过程
//------------------------------------------------------------------------------
procedure Tdesksource.CaptureScreen(rt:TRect);
var
  SurfaceDC:HDC;
  ddsd:DDSURFACEDESC2;
  PrimarySurface,                        // 主显示表面
  SecondlySurface:IDirectDrawSurface7;   // 从显示表面
  TmpStream:TMemoryStream;
  TmpBitmap:TBitmap;
  TmpRect:TRect;
begin
  if not bStatus then exit;
  if not assigned(FCaptureEvent) then exit;
  if IsRectEmpty(rt) then exit;

  try
  TmpBitmap:=TBitmap.Create;
  TmpStream:=TMemoryStream.Create;

  TmpRect:=rt;
  OffsetRect(TmpRect,-TmpRect.Left,-TmpRect.Top);
    
  TmpBitmap.PixelFormat:=FPixelFormat;
  TmpBitmap.Width:=TmpRect.Right;
  TmpBitmap.Height:=TmpRect.Bottom;

  FillMemory(@ddsd,SizeOf(DDSURFACEDESC2),0);
  ddsd.dwSize := sizeof(ddsd);
  ddsd.dwFlags := DDSD_CAPS;
  ddsd.ddsCaps.dwCaps := DDSCAPS_PRIMARYSURFACE;    // 创建主显示表面标志 从显示内存
  if FAILED(PrimaryDraw.CreateSurface(ddsd, PrimarySurface, nil)) then exit;

  FillMemory(@ddsd,SizeOf(DDSURFACEDESC2),0);
  ddsd.dwSize := sizeof(ddsd);
  ddsd.dwFlags := DDSD_CAPS OR DDSD_WIDTH OR DDSD_HEIGHT;
  ddsd.dwWidth  := TmpRect.Right;
  ddsd.dwHeight := TmpRect.Bottom;

  ddsd.ddsCaps.dwCaps := DDSCAPS_SYSTEMMEMORY;    // 创建从显示表面标志 从系统内存
  if FAILED(PrimaryDraw.CreateSurface(ddsd, SecondlySurface, nil)) then exit;

  if FAILED(SecondlySurface.BltFast(0,0,PrimarySurface,@rt,DDBLTFAST_NOCOLORKEY)) then exit;

  if FAILED(SecondlySurface.GetDC(SurfaceDC)) then exit;
  try
  BitBlt(TmpBitmap.Canvas.Handle,0,0,TmpRect.Right,TmpRect.Bottom,SurfaceDC,0,0,SRCCOPY);
  finally
  SecondlySurface.ReleaseDC(SurfaceDC);
  end;

  With TJPEGImage.Create do
    try
    Assign(TmpBitmap);
    CompressionQuality:=65;
    Compress;
    SaveToStream(TmpStream);
    finally
    free;
    end;

  if TmpStream.Size>0 then
    begin
    FCapture:=False;
    FCaptureEvent(TmpStream,rt,GetCursor);
    end;

  finally
  PrimarySurface:=nil;
  SecondlySurface:=nil;
  freeandnil(TmpStream);
  freeandnil(TmpBitmap);
  end;
end;

procedure Tdesksource.CaptureStart;
begin
  // 创建ddraw对象
  if not assigned(PrimaryDraw) then
  if FAILED(DirectDrawCreateEx(nil,PrimaryDraw,IID_IDirectDraw7,nil)) then exit;

  PrimaryDraw.SetCooperativeLevel(GetDeskTopWindow,DDSCL_NORMAL);

  FDeskTopRect:=Rect(0,0,GetDeviceCaps(GetDC(0), HORZRES),GetDeviceCaps(GetDC(0), VERTRES));

  FBackBitmap.Width:=FDeskTopRect.Right;
  FBackBitmap.Height:=FDeskTopRect.Bottom;

  UpdateRect(FDeskTopRect,true);
  
  FPixelFormat:=pf16bit;
  bStatus:=true;
end;

procedure Tdesksource.Capture;
begin
  FCapture:=True;
end;

procedure Tdesksource.CaptureStop;
begin
  bStatus:=false;
  PrimaryDraw:=nil;
end;

procedure Tdesksource.freeCapture;
var i:integer;
    TmpList:Tlist;
begin
 try
 TmpList:=PRectList.LockList;
 if TmpList.count>0 then
 for i:=TmpList.count downto 1 do
   begin
   dispose(PRect(TmpList.Items[i-1]));
   TmpList.delete(i-1);
   end;
 finally
 PRectList.UnlockList;
 end;
end;

//------------------------------------------------------------------------------
// 调整色彩
//------------------------------------------------------------------------------
procedure Tdesksource.SetColorLevel(iLevel:Integer);
begin
  Case iLevel of
    0:FPixelFormat:=pf8bit;
    1:FPixelFormat:=pf16bit;
    2:FPixelFormat:=pf24bit;
    3:FPixelFormat:=pf32bit;
    end;
  UpdateRect(FDeskTopRect,true);
end;

//------------------------------------------------------------------------------
// 构建
//------------------------------------------------------------------------------
constructor Tdesksource.Create;
begin
  inherited Create;
  PRectList:=TThreadList.Create;
  FBackBitmap:=TBitmap.Create;

  FWorkThread:=TCustomThread.Create;
  FWorkThread.SynThread:=True;
  FWorkThread.OnExecute:=CaptureWorkProcess;
end;

//------------------------------------------------------------------------------
// 释放
//------------------------------------------------------------------------------
destructor Tdesksource.Destroy;
begin
  if bStatus then CaptureStop;
  freeCapture;
  freeandnil(FBackBitmap);
  freeandnil(PRectList);
  if assigned(FWorkThread) then
    freeandnil(FWorkThread);
  inherited Destroy;
end;

end.

