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
      PrimaryDraw:IDirectDraw7;              // ddraw ����
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

//����Ƿ��д�����������ʾ���ڴ���,�оͷ���ƥ��
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

//�Ƚ����������Ƿ���ˮƽ��ֱ�ϲ�
function CompareRegion(dRect,sRect:TRect):Boolean;
begin
  Result:=False;
  if (dRect.Left=sRect.Left) and (dRect.Right=sRect.Right) then //��ͬ�Ŀ��
  if (dRect.Top=sRect.Bottom) or (dRect.Bottom=sRect.Top) then  //��������
    begin
    Result:=True;
    exit;
    end;

  if (dRect.Top=sRect.Top) and (dRect.Bottom=sRect.Bottom) then //��ͬ�ĸ߶�
  if (dRect.Left=sRect.Right) or (dRect.Right=sRect.Left) then  //��������
    Result:=True;
end;

//�Ƚ� dRect �Ƿ� sRect ����
function compriseRegion(dRect,sRect:TRect):Boolean;
var
  TmpRect:TRect;
begin
  Result:=false;
  UnionRect(TmpRect,dRect,sRect);
  if not IsRectEmpty(TmpRect) then
    Result:=EqualRect(TmpRect,sRect);
end;

//����ǰ���������ھ��λ����б���кϲ� ���غϲ�����¾��Σ����򷵻ؿ�ֵ
function CalcUnionRegion(TmpRegion:TRect;TmpList:TThreadList):TRect;
var
  Bool:boolean;
  TmpPRegion:PRect;
  i:integer;
begin
  Bool:=false;
  SetRectEmpty(Result);

  //�Ƿ��������ΰ������Ƿ������ͬ����
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

  //�������� ������������ڵľ��� �ϲ�����
  if not Bool then  
  try
  with TmpList.LockList do
    for i:=count downto 1 do
    if CompareRegion(TmpRegion,PRect(items[i-1])^) or compriseRegion(PRect(items[i-1])^,TmpRegion) then
      begin
      UnionRect(Result,TmpRegion,PRect(items[i-1])^); //�ϲ�����
      dispose(PRect(items[i-1]));
      delete(i-1);
      Bool:=true;
      break;
      end;
  finally
  TmpList.UnlockList;
  end;

  if not Bool then  //�޷��ϲ�ֱ�Ӽ��뵽������
    try
    new(TmpPRegion);
    TmpPRegion^:=TmpRegion;
    with TmpList.LockList do
      begin
      if Count>256 then  //�������� 16������
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

//��Ӿ��ε����λ����б�
procedure CalcAddRegion(TmpRegion:TRect;TmpList:TThreadList);
begin
  //����Ƿ��кϲ����µĶ�����������½���ϲ�����
  while not IsRectEmpty(TmpRegion) do
    TmpRegion:=CalcUnionRegion(TmpRegion,TmpList);
end;

//������Ļˢ����Ӧ��������������뵽�����
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

//ȡ�����λ�����ĵ�һ������
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
// �����������߳�
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
// ��Ӧ����
//------------------------------------------------------------------------------
procedure Tdesksource.CaptureScreen(rt:TRect);
var
  SurfaceDC:HDC;
  ddsd:DDSURFACEDESC2;
  PrimarySurface,                        // ����ʾ����
  SecondlySurface:IDirectDrawSurface7;   // ����ʾ����
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
  ddsd.ddsCaps.dwCaps := DDSCAPS_PRIMARYSURFACE;    // ��������ʾ�����־ ����ʾ�ڴ�
  if FAILED(PrimaryDraw.CreateSurface(ddsd, PrimarySurface, nil)) then exit;

  FillMemory(@ddsd,SizeOf(DDSURFACEDESC2),0);
  ddsd.dwSize := sizeof(ddsd);
  ddsd.dwFlags := DDSD_CAPS OR DDSD_WIDTH OR DDSD_HEIGHT;
  ddsd.dwWidth  := TmpRect.Right;
  ddsd.dwHeight := TmpRect.Bottom;

  ddsd.ddsCaps.dwCaps := DDSCAPS_SYSTEMMEMORY;    // ��������ʾ�����־ ��ϵͳ�ڴ�
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
  // ����ddraw����
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
// ����ɫ��
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
// ����
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
// �ͷ�
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

