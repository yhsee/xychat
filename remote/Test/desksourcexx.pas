unit desksource;

interface

uses
  Windows, Messages,SysUtils,Classes,Graphics,Variants,
  DirectDraw,CustomThreadUnt,JPEG;

type
  TCaptureEvent=procedure (TmpStream:TStream;rt:TRect;iCursor:LongWord)of Object;
  Tdesksource=class
      constructor Create;
      destructor  Destroy;override;
    private
      FBackGround,
      FCurBackGround:TBitmap;
      PrimaryDraw:IDirectDraw7;              // ddraw ����
      //------------------------------------------------------------------------
      bStatus,bSwap:boolean;
      //------------------------------------------------------------------------
      FDeskTopRect:TRECT;
      PRectList:TThreadList;
      FAllowCapture:Boolean;
      FPixelFormat:TPixelFormat;
      //------------------------------------------------------------------------
      FCaptureEvent:TCaptureEvent;
      FWorkThread:TCustomThread;
      procedure freeCapture;
      procedure CaptureScreen;overload;      
      procedure CaptureScreen(TmpRect:TRect);overload;
      procedure CaptureWorkProcess(Sender:TObject);
    public
      procedure UpdateRect(TmpRect:TRect);
      procedure SetColorLevel(iLevel:Integer);
      procedure CaptureStart;
      procedure CaptureStop;
    published
      property CaptureRect:TRect Read FDeskTopRect;
      property CaptureEvent:TCaptureEvent Write FCaptureEvent;
      property AllowCapture:Boolean Write FAllowCapture;
    end;

implementation
uses Math;

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

//����ǰ���������ھ��λ����б���кϲ� ���غϲ�����¾��Σ����򷵻ؿ�ֵ
function CalcUnionRegion(TmpRegion:TRect;TmpList:TThreadList):TRect;
var
  Bool:boolean;
  TmpPRegion:PRect;
  i:integer;
begin
  Bool:=false;
  SetRectEmpty(Result);

  try
  with TmpList.LockList do
    for i:=count downto 1 do
    if CompareRegion(TmpRegion,PRect(items[i-1])^) then  
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
    begin
    new(TmpPRegion);
    TmpPRegion^:=TmpRegion;
    TmpList.Add(TmpPRegion);
    end;
end;

//��Ӿ��ε����λ����б�
procedure CalcAddRegion(TmpRegion:TRect;TmpList:TThreadList);
begin
 if not IsRectEmpty(TmpRegion) then
   repeat
   TmpRegion:=CalcUnionRegion(TmpRegion,TmpList);
   until IsRectEmpty(TmpRegion); //����Ƿ��кϲ����µĶ�����������½���ϲ�����
end;

//ͳ�Ʋ���ͬ���������������Ӧ�� ����
procedure CalcRegion(TmpArr:Variant;x,y,W,H,g:Integer;TmpList:TThreadList);
var
  i,j,m,n,
  xSize,ySize:Integer;
  bSame:Boolean;
  TmpRegion:TRect;
begin
  bSame:=False;  //��ʼ��־λ
  m:=0;n:=0;
  for i:=1 to y do
  for j:=1 to x do
    begin
    if not bSame then  //����־λ
      begin
      if TmpArr[i-1,j-1]=1 then //����в�ͬ�Ŀ�
        begin
        m:=j;              //�ÿ��
        n:=i;              //��ʼλ��
        bSame:=True; //�ñ�־λ
        end;
      end else begin  //�����һ���������ͬ����ת�����н�����ǰ���ң������ñ�־λ.��������������ƴ��һ�������
      if (j=x) or (TmpArr[i-1,j-1]=0) then
        begin
        bSame:=False;
        xSize:=min(g,W-(j-1)*g);
        ySize:=min(g,H-(i-1)*g);
        TmpRegion.Left:=(m-1)*g;
        TmpRegion.Top:=(n-1)*g;
        TmpRegion.Right:=(j-1)*g+xSize;
        TmpRegion.Bottom:=(i-1)*g+ySize;
        CalcAddRegion(TmpRegion,TmpList);
        end;
      end
    end;
end;

//ͼ���������������ݱȽ�
procedure CompareGridding(dBmp,sBmp:TBitmap;x,y,w,h,g:Integer;var TmpArr:variant);
var
  i,j,k,
  xPointer,yPointer,
  xSize,ySize,iBit:Integer;
begin
  //ÿ������λ�Ŀ��
  iBit:=1;
  case dBmp.PixelFormat of
     pf16bit:iBit:=2;
     pf24bit:iBit:=3;
     pf32bit:iBit:=4;
     end;

  for i:=1 to y do
  for j:=1 to x do
    begin

    //��������ͼƬ��ͬ����λ�õ� ˮƽ���������ߵ������Ƿ���ͬ
    xSize:=min(g,w-(j-1)*g)*iBit;
                                 // ����      �������λ��
    xPointer:=Integer(dBmp.ScanLine[(i-1)*g])+(j-1)*g*iBit;
    yPointer:=Integer(sBmp.ScanLine[(i-1)*g])+(j-1)*g*iBit;

    if not CompareMem(Pointer(xPointer),Pointer(yPointer),xSize) then
      begin
      TmpArr[i-1,j-1]:=1; //Ϊ��ǰ�������������ڵĸ��������
      if i>1 then TmpArr[i-2,j-1]:=1;
      end;

    //��������ͼƬ��ͬ����λ�õ� ��ֱ���������ߵ������Ƿ���ͬ
    ySize:=min(g,h-(i-1)*g);
    for k:=0 to (ySize div 2)-1 do
      begin
                                     // ����      �������λ��
      xPointer:=Integer(dBmp.ScanLine[(i-1)*g+k*2])+(j-1)*g*iBit;
      yPointer:=Integer(sBmp.ScanLine[(i-1)*g+k*2])+(j-1)*g*iBit;

      if not CompareMem(Pointer(xPointer),Pointer(yPointer),iBit) then
        begin
        TmpArr[i-1,j-1]:=1;  //Ϊ��ǰ�������������ڵĸ��������
        if j>1 then TmpArr[i-1,j-2]:=1;
        break;
        end;
      end;
    end;
end;

//�Ƚ�����ͼ��Ĳ�ͬ�� Ҫ�� ͼ��תΪ 256ɫ��
procedure CompareBitmap(DestBmp,SrcBmp:TBitmap;TmpList:TThreadList);
var
  i,x,y,w,h,g:Integer;
  TmpVar:Variant;
  TmpArr:Array of Array of byte;
begin
  g:=32; //���������δ�С
  w:=DestBmp.Width;
  h:=DestBmp.Height;
  x:=w div g;  y:=h div g;
  if w mod g>0 then inc(x);
  if h mod g>0 then inc(y);

  SetLength(TmpArr,y);
  for i:=1 to y do
    begin
    SetLength(TmpArr[i-1],x);
    FillMemory(@TmpArr[i-1][0],x,0);
    end;
  TmpVar:=TmpArr;
  CompareGridding(DestBmp,SrcBmp,x,y,w,h,g,TmpVar);
  CalcRegion(TmpVar,x,y,w,h,g,TmpList);
end;


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

//������Ļˢ����Ӧ������
procedure Tdesksource.UpdateRect(TmpRect:TRect);
begin

//TmpRect

end;

//------------------------------------------------------------------------------
// �����������߳�
//------------------------------------------------------------------------------
procedure Tdesksource.CaptureWorkProcess(Sender:TObject);
var
  TmpRect:TRect;
begin
  if not bStatus then
    begin
    Sleep(10);
    exit;
    end;

  if FAllowCapture then
    begin
    FAllowCapture:=false;
    if GetNextRect(TmpRect,PRectList) then
      CaptureScreen(TmpRect);
    end;
end;

//------------------------------------------------------------------------------
// ��Ӧ����
//------------------------------------------------------------------------------
procedure Tdesksource.CaptureScreen(TmpRect:TRect);
var
  TmpStream:TMemoryStream;
  TmpBitmap:TBitmap;
  ww,hh:integer;
begin
  if not assigned(FCaptureEvent) then exit;

  try
  TmpBitmap:=TBitmap.Create;
  TmpStream:=TMemoryStream.Create;
  TmpBitmap.ReleaseHandle;
  ww:=TmpRect.Right-TmpRect.Left;
  hh:=TmpRect.Bottom-TmpRect.Top;

  if bSwap then
    TmpBitmap.PixelFormat:=FCurBackGround.PixelFormat
    else TmpBitmap.PixelFormat:=FBackGround.PixelFormat;
  TmpBitmap.Width:=ww;
  TmpBitmap.Height:=hh;

  if bSwap then
    begin
    if not BitBlt(TmpBitmap.Canvas.Handle,0,0,ww,hh,FCurBackGround.Canvas.Handle,TmpRect.Left,TmpRect.Top,SRCCOPY) then exit;
    end else begin
    if not BitBlt(TmpBitmap.Canvas.Handle,0,0,ww,hh,FBackGround.Canvas.Handle,TmpRect.Left,TmpRect.Top,SRCCOPY) then exit;
    end;


  TmpBitmap.SaveToStream(TmpStream);
  if TmpStream.Size>0 then
    FCaptureEvent(TmpStream,TmpRect,GetCursor);
 { With TJpegImage.Create do
    try
      Assign(TmpBitmap);
      CompressionQuality:=40;
      Compress;
      TmpStream.Size:=0;
      SaveToStream(TmpStream);
      if TmpStream.Size>0 then
        FCaptureEvent(TmpStream,TmpRect,GetCursor);
    finally
    free;
    end;  }

  finally
  freeandnil(TmpStream);
  freeandnil(TmpBitmap);
  end;
end;

//------------------------------------------------------------------------------
// �������������
//------------------------------------------------------------------------------
procedure Tdesksource.CaptureScreen;
var
  ww,hh:Integer;
  SurfaceDC:HDC;
  ddsd:DDSURFACEDESC2;
  PrimarySurface,                        // ����ʾ����
  SecondlySurface:IDirectDrawSurface7;   // ����ʾ����
begin
  try
  ww:=FDeskTopRect.Right-FDeskTopRect.Left;
  hh:=FDeskTopRect.Bottom-FDeskTopRect.Top;

  FCurBackGround.Width:=ww;
  FCurBackGround.Height:=hh;
  FBackGround.Width:=ww;
  FBackGround.Height:=hh;
  FBackGround.PixelFormat:=FPixelFormat;
  FCurBackGround.PixelFormat:=FPixelFormat;

  FillMemory(@ddsd,SizeOf(DDSURFACEDESC2),0);
  ddsd.dwSize := sizeof(ddsd);
  ddsd.dwFlags := DDSD_CAPS;
  ddsd.ddsCaps.dwCaps := DDSCAPS_PRIMARYSURFACE;    // ��������ʾ�����־ ����ʾ�ڴ�
  if FAILED(PrimaryDraw.CreateSurface(ddsd, PrimarySurface, nil)) then exit;

  FillMemory(@ddsd,SizeOf(DDSURFACEDESC2),0);
  ddsd.dwSize := sizeof(ddsd);
  ddsd.dwFlags := DDSD_CAPS OR DDSD_WIDTH OR DDSD_HEIGHT;
  ddsd.dwWidth  := ww;
  ddsd.dwHeight := hh;

  ddsd.ddsCaps.dwCaps := DDSCAPS_SYSTEMMEMORY;    // ��������ʾ�����־ ��ϵͳ�ڴ�
  if FAILED(PrimaryDraw.CreateSurface(ddsd, SecondlySurface, nil)) then exit;

  if FAILED(SecondlySurface.BltFast(0,0,PrimarySurface,@FDeskTopRect,DDBLTFAST_NOCOLORKEY OR DDBLTFAST_WAIT)) then exit;

  if FAILED(SecondlySurface.GetDC(SurfaceDC)) then exit;

  bSwap:=not bSwap;
  if bSwap then
   begin
   if not BitBlt(FCurBackGround.Canvas.Handle,0,0,ww,hh,SurfaceDC,0,0,SRCCOPY) then exit;
   end else begin
   if not BitBlt(FBackGround.Canvas.Handle,0,0,ww,hh,SurfaceDC,0,0,SRCCOPY) then exit;
   end;

  CompareBitmap(FCurBackGround,FBackGround,PRectList);

  finally
  DeleteDC(SurfaceDC);
  PrimarySurface:=nil;
  SecondlySurface:=nil;
  end;
end;

procedure Tdesksource.CaptureStart;
begin
  // ����ddraw����
  if not assigned(PrimaryDraw) then
  if FAILED(DirectDrawCreateEx(nil,PrimaryDraw,IID_IDirectDraw7,nil)) then exit;

  PrimaryDraw.SetCooperativeLevel(GetDeskTopWindow,DDSCL_NORMAL);

  FDeskTopRect:=Rect(0,0,GetDeviceCaps(GetDC(0), HORZRES),GetDeviceCaps(GetDC(0), VERTRES));

  FPixelFormat:=pf8bit;
  bSwap:=False;
  FAllowCapture:=true;
  bStatus:=true;
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
end;

//------------------------------------------------------------------------------
// ����
//------------------------------------------------------------------------------
constructor Tdesksource.Create;
begin
  inherited Create;
  PRectList:=TThreadList.Create;
  FBackGround:=TBitmap.Create;
  FCurBackGround:=TBitmap.Create;

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
  freeandnil(FCurBackGround);
  freeandnil(FBackGround);
  freeandnil(PRectList);
  if assigned(FWorkThread) then
    FWorkThread.OverThread;
  inherited Destroy;
end;

end.
