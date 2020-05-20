unit UDPStreamUnt;

interface

{*******************************************************}
{                                                       }
{       UDP 数据传输组件                                }
{                                                       }
{	           email: yihuas@163.com                      }
{		         2012.11.7                                  }
{                                                       }
{*******************************************************}

uses
  Windows, Messages, Sysutils, Classes,TntClasses,TntSysutils,
  UDPCommonUnt,UDPServerUnt,MultiTimerUnt,MultiTimerCommonUnt;

type
  TUDPStream = class(TUDPServer)
    constructor Create;
    destructor Destroy; override;
  private
    FReserve:String;  //保留字串
    FCTmpFileName:WideString; //断点临时文件
    FSpeedState:Byte;  //0 慢启动  1 拥塞控制

    iSCompleteBlock, // 已经完成的块数量
    iRCompleteBlock, // 已经完成的块数量
    iRTmpComplete, // 单位时间内完成量用来核算速度
    iSTmpComplete:LongWord;  // 单位时间内完成量用来核算速度

    iLastCompleteDt,// 上一次完成时间
    iCurWindowSize,//当前确认的滑窗
    iWindowSize,   //当前滑窗大小
    iBlockSize: Word; // 块尺寸大小

    FSendBlock,                 //发送块状态
    FRecvBlock: Array of Byte; // 接收块状态

    OnProcessThread,         //速度，进度，时钟    
    RecvOutTimeThread: Pointer; //接收超时时钟

    ThreadReviceStream,           //接收流
    ThreadSendStream: TStream;    //发送流
    TranBreakPoint:TTntFileStream; //保存断点信息临时文件
    //--------------------------------------------------------------------------    
    function SendUDPStream(Const sReserve:String=''):Boolean;
    //--------------------------------------------------------------------------
    procedure AdjustSlowWindow;
    procedure RecvOutTimeCheck(Sender: TObject);
    
    procedure InitSendBlock(iSize: Int64);
    procedure InitRecvBlock(iSize: Int64);
    function  LastUnRecvBlock:LongWord;
    procedure BlockProcess(TmpData: PUDataPack);
    procedure RequestProcess(iNumber:LongWord);
    procedure StartProcess(TmpData: PUDataPack);

    procedure SendProcess(TmpData: PUDataPack);
    procedure RecvProcess(TmpData: PUDataPack);

    procedure RecvOverProcess(TmpData: PUDataPack);
    procedure SendOverProcess(TmpData: PUDataPack);
  protected
    //--------------------------------------------------------------------------
    FOnUDPSendComplete: TNotifyEvent;
    FOnUDPRecvReady:TRecvReadyEvent;
    FOnUDPRecvComplete: TRecvCompleteEvent;
    FOnSendProcessEvent,
    FOnRecvProcessEvent: TSpeedProcessEvent;
    FOnUDPSendTranEvent,
    FOnUDPRecvTranEvent: TUDPTranEvent;
    //--------------------------------------------------------------------------
    procedure UDPServerOnUDPRead(TmpData: PUDataPack);override;
    procedure OnProcessCheck(Sendder: TObject);
  public
    procedure CloseConnect; override;
    function SendStream(TmpStream: TStream;Const sReserve:String=''):Boolean;
    function SendFile(sFileName:WideString;Const sReserve:WideString=''):Boolean;
    function CheckFileBreakPoint(var sFileName:WideString):Boolean;
  published
    property OnUDPRecvReady: TRecvReadyEvent Write FOnUDPRecvReady;
    property OnUDPSendComplete: TNotifyEvent Write FOnUDPSendComplete;
    property OnUDPRecvComplete: TRecvCompleteEvent Write FOnUDPRecvComplete;
    property OnSendProcessEvent: TSpeedProcessEvent Write FOnSendProcessEvent;
    property OnRecvProcessEvent: TSpeedProcessEvent Write FOnRecvProcessEvent;
    property OnSendTranEvent: TUDPTranEvent Write FOnUDPSendTranEvent;
    property OnRecvTranEvent: TUDPTranEvent Write FOnUDPRecvTranEvent;
    property sReserve:String Read FReserve;
  end;

implementation

uses Math;

// ------------------------------------------------------------------------------
// Create
// ------------------------------------------------------------------------------
constructor TUDPStream.Create;
begin
  inherited Create;
  iBlockSize := 1024-40;
  RecvOutTimeThread := TmpTimer.RegTimer(300, RecvOutTimeCheck);
  OnProcessThread := TmpTimer.RegTimer(500, OnProcessCheck);
end;

// ------------------------------------------------------------------------------
// Destroy
// ------------------------------------------------------------------------------
destructor TUDPStream.Destroy;
begin
  CloseServer;
  if assigned(TranBreakPoint) then
    freeandnil(TranBreakPoint);
  if assigned(ThreadReviceStream) then
    freeandnil(ThreadReviceStream);
  if assigned(ThreadSendStream) then
    freeandnil(ThreadSendStream);
  FSendBlock := nil;
  FRecvBlock := nil;
  inherited Destroy;
end;


procedure TUDPStream.CloseConnect;
begin
  TmpTimer.ActiveTime(RecvOutTimeThread,False);
  Inherited;
end;

// ------------------------------------------------------------------------------
// 数据接收过程
// ------------------------------------------------------------------------------
procedure TUDPStream.UDPServerOnUDPRead(TmpData: PUDataPack);
begin
  case TmpData^.DataHead.iAction of
    // --------------------------------------------------------------------------
    UD_Block:
      BlockProcess(TmpData); // 接收块信息
    UD_Start:
      StartProcess(TmpData); // 开始发送
    UD_RecvOver:
      RecvOverProcess(TmpData); // 结束发送
    UD_SendOver:
      SendOverProcess(TmpData); // 结束接收
    // --------------------------------------------------------------------------
    UD_Send:
      SendProcess(TmpData); // 发送数据
    UD_Recv:
      RecvProcess(TmpData); // 确认发送
  end;
end;

// ------------------------------------------------------------------------------
// 响应用户进度与速度事件
// ------------------------------------------------------------------------------
procedure TUDPStream.OnProcessCheck(Sendder: TObject);
var
  m,n:Int64;
begin
  m:=(High(FSendBlock) div High(Word))+1;
  n:=(High(FRecvBlock) div High(Word))+1;
  if assigned(FOnSendProcessEvent) then
    FOnSendProcessEvent(nil,iSCompleteBlock div m ,High(FSendBlock) div m,iSTmpComplete * iBlockSize * 2);

  if assigned(FOnRecvProcessEvent) then
    FOnRecvProcessEvent(nil,iRCompleteBlock div n ,High(FRecvBlock) div n, iRTmpComplete * iBlockSize * 2);

  iRTmpComplete := 0;
  iSTmpComplete := 0;
end;

// ------------------------------------------------------------------------------
// 结束发送数据
// ------------------------------------------------------------------------------
procedure TUDPStream.SendOverProcess(TmpData: PUDataPack);
begin
  TmpTimer.ActiveTime(OnProcessThread, False);
  SendUBuffer(UD_RecvOver);
  if assigned(ThreadSendStream) then
    begin
    if not (ThreadSendStream is TMemoryStream) then
      begin
      freeandnil(ThreadSendStream);
      ThreadSendStream:=nil;
      end else TMemoryStream(ThreadSendStream).SetSize(0);
      
    if assigned(FOnUDPSendComplete) then
      FOnUDPSendComplete(self);
    end;
end;


// ------------------------------------------------------------------------------
// 结束接收数据
// ------------------------------------------------------------------------------
procedure TUDPStream.RecvOverProcess(TmpData: PUDataPack);
begin
  TmpTimer.ActiveTime(OnProcessThread, False);
  TmpTimer.ActiveTime(RecvOutTimeThread,False);
  if Assigned(TranBreakPoint) then
    begin
    freeandnil(TranBreakPoint);
    WideDeleteFile(FCTmpFileName);
    end;
  if assigned(ThreadReviceStream) then
    begin
    if not (ThreadReviceStream is TMemoryStream) then
      begin
      freeandnil(ThreadReviceStream);
      ThreadReviceStream:=nil;
      end else TMemoryStream(ThreadReviceStream).SetSize(0);

    if assigned(FOnUDPRecvComplete) then
      FOnUDPRecvComplete(self, ThreadReviceStream);
    end;
end;

// ------------------------------------------------------------------------------
// 开始请求数据
// ------------------------------------------------------------------------------
procedure TUDPStream.RequestProcess(iNumber:LongWord);
var
  TmpData: PUDataPack;
begin
  try
    TmpTimer.ActiveTime(RecvOutTimeThread);

    NewUDataPack(TmpData);
    TmpData^.DataHead.iAction := UD_Start;
    TmpData^.DataHead.iLen:=6;
    CopyMemory(@TmpData^.Data[0],@iWindowSize,2);  //窗口尺寸
    CopyMemory(@TmpData^.Data[2],@iNumber,4);
    SendUBuffer(TmpData);
  finally
    FreeUDataList.Add(TmpData);
  end;
end;

// ------------------------------------------------------------------------------
// 开始发送数据
// ------------------------------------------------------------------------------
procedure TUDPStream.StartProcess(TmpData: PUDataPack);
var
  iNumber,iDegree,iSize:Word;
  iCurBlock:LongWord;
  TmpDataEx: PUDataPack;
begin
  if not Connected then exit; //连接断开退出数据发送

  CopyMemory(@iDegree,@TmpData^.Data[0],2);
  CopyMemory(@iCurBlock,@TmpData^.Data[2],4);
  if (iSCompleteBlock=0) and (iCurBlock>0) then
    iSCompleteBlock:=iCurBlock;

  iNumber:=0;
  while iNumber<iDegree do
  try
    NewUDataPack(TmpDataEx);
    FillMemory(TmpDataEx, SizeOf(TUDataPack), 0);

    if iCurBlock > LongWord(High(FSendBlock)) then exit;

    if FSendBlock[iCurBlock]=Block_Complete then
      begin
      inc(iCurBlock);
      continue;
      end;

    inc(iNumber);

    FSendBlock[iCurBlock] := Block_Sending;

    TmpDataEx^.DataHead.iAction := UD_Send;
    TmpDataEx^.DataHead.iLen := Min(iBlockSize, ThreadSendStream.Size -
      iCurBlock * iBlockSize)+4;

    CopyMemory(@TmpDataEx^.Data[0],@iCurBlock,4);

    iSize:=TmpDataEx^.DataHead.iLen-4;
    ThreadSendStream.Position := iCurBlock * iBlockSize;
    ThreadSendStream.ReadBuffer(TmpDataEx^.Data[4],iSize);
    //加密回调函数
    if Assigned(FOnUDPSendTranEvent) then
      FOnUDPSendTranEvent(nil,TmpDataEx^.Data[4],iSize);

    TmpDataEx^.DataHead.iLen:=iSize+4;

    SendUBuffer(TmpDataEx);
    inc(iCurBlock);
  finally
    FreeUDataList.Add(TmpDataEx);
  end;
end;

// ------------------------------------------------------------------------------
// 处理接收数据
// ------------------------------------------------------------------------------
procedure TUDPStream.SendProcess(TmpData: PUDataPack);
var
  iSize:Word;
  iLongSize:Int64;
  iNumber:LongWord;
begin
  if not Connected then exit; //连接断开退出

  CopyMemory(@iNumber,@TmpData^.Data[0],4);
  if iNumber > LongWord(High(FRecvBlock)) then exit;

  if FRecvBlock[iNumber] = Block_Ready then
    begin
    inc(iRTmpComplete);
    inc(iRCompleteBlock);
    inc(iCurWindowSize);
    FRecvBlock[iNumber] := Block_Complete;
    ThreadReviceStream.Position := iNumber * iBlockSize;
    iSize:=TmpData^.DataHead.iLen-4;
    //解密回调函数
    if assigned(FOnUDPRecvTranEvent) then
      FOnUDPRecvTranEvent(nil,TmpData^.Data[4],iSize);
    ThreadReviceStream.WriteBuffer(TmpData^.Data[4],iSize);
    if Assigned(TranBreakPoint) then //更新断点数据
      begin
      iLongSize:=iRCompleteBlock*iBlockSize;
      TranBreakPoint.Seek(0,0);
      TranBreakPoint.WriteBuffer(iLongSize,SizeOf(Int64));
      end;
    end;

  TmpData^.DataHead.iAction := UD_Recv;
  TmpData^.DataHead.iLen := 4;
  SendUBuffer(TmpData);
  // --------------------------------------------------------------------------
  // 响应接收完成事件
  // --------------------------------------------------------------------------
  if (iRCompleteBlock = LongWord(High(FRecvBlock)) + 1) then
    begin
    TmpTimer.ActiveTime(RecvOutTimeThread);
    SendUBuffer(UD_SendOver);
    end else AdjustSlowWindow;
end;

// ------------------------------------------------------------------------------
// 处理回应数据
// ------------------------------------------------------------------------------
procedure TUDPStream.RecvProcess(TmpData: PUDataPack);
var
  iNumber:LongWord;
begin
  if not Connected then exit; //连接断开退出

  CopyMemory(@iNumber,@TmpData^.Data[0],4);
  if iNumber > LongWord(High(FSendBlock)) then
    begin
    WriteLogEvent(nil,0,Format('send ok Out %d %d',[iNumber,LongWord(High(FSendBlock))]));
    exit;
    end;

  if FSendBlock[iNumber] in [Block_Sending,Block_Pause] then
    begin
    inc(iSTmpComplete);
    inc(iSCompleteBlock);
    FSendBlock[iNumber]:=Block_Complete;
    end;
end;


// ------------------------------------------------------------------------------
// 窗口慢启动控制
// ------------------------------------------------------------------------------
procedure TUDPStream.AdjustSlowWindow;
var
  iCompleteDt:LongWord;
begin
  if iCurWindowSize=iWindowSize then  //本次窗口数据结束
    begin
    iCompleteDt:=GetTickCount-PSingleTime(RecvOutTimeThread).iStartTick;
    iCurWindowSize:=0;
    case FSpeedState of
      0:begin //慢启动乘法
        iWindowSize:=iWindowSize*2;
        end;

      1:begin //慢启动加法
        inc(iWindowSize);
        end;

      2:begin //拥塞控制
        if (iCompleteDt+100)<iLastCompleteDt then FSpeedState:=1;
        iLastCompleteDt:=iCompleteDt;        
        end;
      end;
    RequestProcess(iRCompleteBlock);
    end;
end;

// ------------------------------------------------------------------------------
// 数据接收超时处理过程
// ------------------------------------------------------------------------------
procedure TUDPStream.RecvOutTimeCheck(Sender: TObject);
var
  iOutBlock: LongWord;
begin
  if not Connected then exit; //连接断开退出
  iCurWindowSize:=0;
  if (iRCompleteBlock < LongWord(High(FRecvBlock)) + 1) then //任务未完成
    begin
    iOutBlock:=LastUnRecvBlock;
    case FSpeedState of
      0:begin //慢启动乘法过程中发生丢包
        iWindowSize:=Max(1,iWindowSize div 2);
        FSpeedState:=1; //慢启动加法
        end;

      1:begin //慢启动加法过程中发生丢包
        iWindowSize:=Max(1,iWindowSize div 2);
        iLastCompleteDt:=0;
        FSpeedState:=2; //拥塞控制
        end;

      2:begin //拥塞控制过程中发生丢包
        iWindowSize:=Max(1,iWindowSize-2);
        end;
      end;
    RequestProcess(iOutBlock);
    end else begin
    TmpTimer.ActiveTime(RecvOutTimeThread);
    SendUBuffer(UD_SendOver);
    end;
end;

function  TUDPStream.LastUnRecvBlock:LongWord;
var
  i:Integer;
begin
  Result:=iRCompleteBlock;
  for i:=iRCompleteBlock-iWindowSize to iRCompleteBlock do
    begin
    if FRecvBlock[i]=Block_Ready then
      begin
      Result:=i;
      break;
      end;
    end;
end;

// ------------------------------------------------------------------------------
// 初始化发送块状态
// ------------------------------------------------------------------------------
procedure TUDPStream.InitSendBlock(iSize: Int64);
var
  iLength: LongWord;
begin
  iSCompleteBlock := 0;

  iLength := iSize div iBlockSize;
  if iSize mod iBlockSize > 0 then
    inc(iLength);

  FSendBlock := nil;
  SetLength(FSendBlock, iLength);
  FillMemory(@FSendBlock[0],iLength,Block_Ready);
  TmpTimer.ActiveTime(OnProcessThread);
end;

// ------------------------------------------------------------------------------
// 初始化接收块状态
// ------------------------------------------------------------------------------
procedure TUDPStream.InitRecvBlock(iSize: Int64);
var
  iLength: LongWord;
begin
  iRCompleteBlock := 0;

  iWindowSize:=1;
  iCurWindowSize:=0;
  iLastCompleteDt:=0;
  FSpeedState:=0;

  iLength := iSize div iBlockSize;
  if iSize mod iBlockSize > 0 then
    inc(iLength);
  FRecvBlock := nil;
  SetLength(FRecvBlock, iLength);
  FillMemory(@FRecvBlock[0],iLength,Block_Ready);
  TmpTimer.ActiveTime(OnProcessThread);
end;

// ------------------------------------------------------------------------------
// 发送文件过程
// ------------------------------------------------------------------------------
function TUDPStream.SendFile(sFileName:WideString;Const sReserve:WideString=''):Boolean;
var
  sTmpStr:String;
begin
  try
  Result:=False;
   // 当前发送未能完成，直接抛弃发送流
  if assigned(ThreadSendStream) then
  if ThreadSendStream is TMemoryStream then
    begin
    if ThreadSendStream.Size=0 then
      freeandnil(ThreadSendStream) else exit;
    end else exit;

  ThreadSendStream:=TTntFileStream.Create(sFileName,fmOpenRead or fmShareDenyNone);
  sTmpStr:=UTF8Encode(ConCat(sReserve,WideExtractFileName(sFileName)));

  ThreadSendStream.Seek(0, 0);

  Result:=SendUDPStream(sTmpStr);
  except
  Result:=False;
  end;
end;

// ------------------------------------------------------------------------------
// 检测文件断点续传过程
// ------------------------------------------------------------------------------
function TUDPStream.CheckFileBreakPoint(var sFileName:WideString):Boolean;
  procedure MakeNewFileName(var sNewFileName:WideString);
  var
    n:Integer;
    sExt,sHead:WideString;
  begin
    n:=1;
    sExt:=WideExtractFileExt(sNewFileName);
    sHead:=WideChangeFileExt(sNewFileName,'');
    while WideFileExists(sNewFileName) or WideFileExists(ConCat(sNewFileName,'!')) do
      begin
      sNewFileName:=ConCat(sHead,'(',IntToStr(n),')',sExt);
      inc(n);
      end;
  end;
var
  iSize:Int64;
  iLength:LongWord;
begin
  Result:=False;
  FCTmpFileName:=ConCat(sFileName,'!');
  if not WideFileExists(sFileName) then  //如果文件不存新建断点临时文件
    begin
    TranBreakPoint:=TTntFileStream.Create(FCTmpFileName,fmCreate or fmOpenWrite);
    exit;
    end;

  if not WideFileExists(FCTmpFileName) then
    begin
    TranBreakPoint:=TTntFileStream.Create(FCTmpFileName,fmCreate or fmOpenWrite);   
    Result:=True;
    exit;
    end;

  Result:=True;
  TranBreakPoint:=TTntFileStream.Create(FCTmpFileName,fmOpenReadWrite);
  if TranBreakPoint.Size=SizeOf(Int64) then
    begin
    TranBreakPoint.Seek(0,0);
    TranBreakPoint.ReadBuffer(iSize,SizeOf(Int64));

    iLength := iSize div iBlockSize;
    if iLength>LongWord(High(FRecvBlock)) + 1 then exit;

    iRCompleteBlock:=iLength;
    end;
end;

// ------------------------------------------------------------------------------
// 发送流过程
// ------------------------------------------------------------------------------
function TUDPStream.SendStream(TmpStream: TStream;Const sReserve:String=''):Boolean;
begin
  Result:=False;
  if not assigned(ThreadSendStream) then
    ThreadSendStream:=TMemoryStream.Create;
   // 当前发送未能完成，直拉抛弃发送流
  if ThreadSendStream.Size>0 then exit;

  TmpStream.Seek(0, 0);

  TMemoryStream(ThreadSendStream).SetSize(0);
  TMemoryStream(ThreadSendStream).LoadFromStream(TmpStream);

  Result:=SendUDPStream(sReserve);
end;

function TUDPStream.SendUDPStream(Const sReserve:String=''):Boolean;
var
  iSize: Int64;
  TmpData: PUDataPack;
begin
  Result:=False;
  if Connected then
    try
      iSize := ThreadSendStream.Size;
      if iSize>High(LongWord)*iBlockSize then
        begin
        WriteLogEvent(nil,UD_Send_Error,'file is too big.');
        exit;
        end;

      if Length(sReserve)>(iBlockSize-SizeOf(Int64)-SizeOf(Word)) then
        begin
        WriteLogEvent(nil,UD_Send_Error,'Reserve is too long.');
        exit;
        end;

      InitSendBlock(iSize);
      try
        NewUDataPack(TmpData);
        FillMemory(TmpData, SizeOf(TUDataPack), 0);
        TmpData^.DataHead.iAction := UD_Block;
        TmpData^.DataHead.iLen := SizeOf(Int64)+SizeOf(Word)+Length(sReserve);
        CopyMemory(@TmpData^.Data[0], @iSize, SizeOf(Int64));
        CopyMemory(@TmpData^.Data[SizeOf(Int64)], @iBlockSize, SizeOf(Word));
        CopyMemory(@TmpData^.Data[SizeOf(Int64)+SizeOf(Word)],@sReserve[1],Length(sReserve));
        SendUBuffer(TmpData);
        Result:=True;
      finally
        FreeUDataList.Add(TmpData);
      end;
    except
      on e: exception do
        WriteLogEvent(nil,UD_Send_Error,e.Message);
    end;
end;
// ------------------------------------------------------------------------------
// 处理信息块
// ------------------------------------------------------------------------------
procedure TUDPStream.BlockProcess(TmpData: PUDataPack);
var
  iLen: Word;
  iSize: Int64;
  sNewFileName:WideString;
begin
  if (iRCompleteBlock = LongWord(High(FRecvBlock)) + 1) then RecvOverProcess(nil);

  CopyMemory(@iSize, @TmpData^.Data[0], SizeOf(Int64));
  CopyMemory(@iBlockSize, @TmpData^.Data[SizeOf(Int64)], SizeOf(Word));
  InitRecvBlock(iSize);

  iLen:=TmpData^.DataHead.iLen-SizeOf(Int64)-SizeOf(Word);
  SetLength(FReserve,iLen);
  CopyMemory(@FReserve[1],@TmpData^.Data[SizeOf(Int64)+SizeOf(Word)],iLen);

  if not assigned(FOnUDPRecvReady) then
    begin
    if not assigned(ThreadReviceStream) then
      ThreadReviceStream:=TMemoryStream.Create;
    TMemoryStream(ThreadReviceStream).SetSize(iSize);
    end else begin
    if assigned(ThreadReviceStream) then freeandnil(ThreadReviceStream);
    if Assigned(TranBreakPoint) then freeandnil(TranBreakPoint);
    FOnUDPRecvReady(nil,sNewFileName,iSize);
    ThreadReviceStream:=TTntFileStream.Create(sNewFileName,fmCreate or fmOpenWrite);
    end;
  //发起请求第一个数据包.
  if iSize>0 then
    RequestProcess(iRCompleteBlock)
    else SendUBuffer(UD_SendOver);
end;

end.


