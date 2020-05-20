unit UDPServerUnt;

interface

{*******************************************************}
{                                                       }
{       UDP     数据传输组件                            }
{                                                       }
{	           email: yihuas@163.com                      }
{		         2012.11.7                                  }
{                                                       }
{*******************************************************}

uses
  Windows, Messages, Sysutils, Classes, 
  UDPCommonUnt,UDPBaseUnt,MultiTimerUnt,MultiTimerCommonUnt;

type
  TUDPServer = class(TUDPBase)
    constructor Create;
    destructor Destroy; override;
  private
    FIdentifier,            //组件的唯一标识
    FDestHost,              //本地IP
    FRemoteHost: String;    //对方IP

    FDestPort,              //本地端口
    FRemotePort: Word;      //对方端口

    FConnected:Boolean;     //连接状态

    HeartBeatThread,                //心跳激活时钟
    OutHeartBeatThread: Pointer;    //心跳检测时钟
    procedure HeartBeatCheck(Sender: TObject);
    procedure OutHeartBeatCheck(Sender: TObject);

    procedure PullHeartbeatProcess(TmpData: PUDataPack; ABinding: TSocketHandle);
    procedure PullResponseProcess(TmpData: PUDataPack);

    procedure HandshakeFirstlyProcess(TmpData: PUDataPack; ABinding: TSocketHandle);
    procedure HandshakeSecondlyProcess(TmpData: PUDataPack);
    procedure HandshakeThirdlyProcess(TmpData: PUDataPack);

    procedure HeartBeatProcess(TmpData: PUDataPack);
    procedure ResponseProcess(TmpData: PUDataPack);

    //处理简单数据包
    procedure RecvSimpleProcess(TmpData: PUDataPack; ABinding: TSocketHandle);
    
    function GetLocalPort: Word;
  protected
    TmpTimer: TMultiTimer; //时钟管理对象
    FreeUDataList: TThreadList;   //数据包循环缓冲列表    
    //--------------------------------------------------------------------------
    FOnConnect,
    FOnDisconnect,
    FOnServerPull: TNotifyEvent;
    FOnUDPSendComplete: TNotifyEvent;
    FOnUDPRecvReady:TRecvReadyEvent;
    FOnUDPRecvComplete: TRecvCompleteEvent;
    FOnSendProcessEvent,
    FOnRecvProcessEvent: TSpeedProcessEvent;
    FOnUDPSimpleRead:TUDPReadEvent;
    //--------------------------------------------------------------------------
    procedure NewUDataPack(var TmpData: PUDataPack);
    procedure SendUBuffer(iAction:Byte);overload;
    procedure SendUBuffer(iAction:Byte;sHost:String;iPort:Word);overload;
    procedure SendUBuffer(TmpData: PUDataPack);overload;
    procedure SendUBuffer(TmpData: PUDataPack;sHost:String;iPort:Word);overload;
    //--------------------------------------------------------------------------
    procedure UDPBaseOnUDPRead(Sender: TObject; var buf;bufSize:Word;ABinding: TSocketHandle); override;     
    procedure UDPServerOnUDPRead(TmpData: PUDataPack); virtual;
    //--------------------------------------------------------------------------
    procedure CloseServer; Reintroduce;  //重新发布
    //--------------------------------------------------------------------------
  public
    function InitialUdpTransfers(sLocalIP: String; const iLocalPort: Word = 0):Boolean;
    procedure Connect(sHost: String; iPort: Word; Const bPull: Boolean = False);
    procedure SendSimple(var buf;bufSize:Word);overload;
    procedure SendSimple(sHost: String; iPort: Word; var buf;bufSize:Word);overload;
    procedure PullServer(sHost:String;iPort:Word);
    procedure CloseConnect; virtual;
  published
    property OnConnect: TNotifyEvent read FOnConnect write FOnConnect;
    property OnDisconnect: TNotifyEvent read FOnDisconnect write FOnDisconnect;
    property OnServerPull: TNotifyEvent read FOnServerPull write FOnServerPull;
    property OnUDPSimpleRead:TUDPReadEvent Write FOnUDPSimpleRead;
    property LocalPort: Word Read GetLocalPort;
    property RemotePort: Word Read FRemotePort;
    property RemoteHost:String Read  FRemoteHost;
    property Identifier:String Read FIdentifier;
    property Connected:Boolean Read FConnected;
  end;

implementation

uses Math;

// ------------------------------------------------------------------------------
// Create
// ------------------------------------------------------------------------------
constructor TUDPServer.Create;
  function GETGUID:TGUID;
  begin
    CREATEGUID(RESULT);
  end;
begin
  inherited Create;
  FreeUDataList := TThreadList.Create;

  FIdentifier:=GUIDTOSTRING(GETGUID); //唯一识别码
  FIdentifier:=copy(FIdentifier,2,36);
  FIdentifier:=StringReplace(FIdentifier,'-','',[rfReplaceAll, rfIgnoreCase]);

  TmpTimer := TMultiTimer.Create;
  HeartBeatThread := TmpTimer.RegTimer(5000, HeartBeatCheck);
  OutHeartBeatThread := TmpTimer.RegTimer(1500, OutHeartBeatCheck);
end;

// ------------------------------------------------------------------------------
// Destroy
// ------------------------------------------------------------------------------
destructor TUDPServer.Destroy;
begin
  if assigned(TmpTimer) then
    freeandnil(TmpTimer);
  if FConnected then CloseConnect;
  if Active then CloseServer;
  if assigned(FreeUDataList) then
    freeandnil(FreeUDataList);
  inherited Destroy;
end;

// ------------------------------------------------------------------------------
// 返回本地端口号
// ------------------------------------------------------------------------------
function TUDPServer.GetLocalPort: Word;
begin
  Result := FBinding.PeerPort;
end;
// ------------------------------------------------------------------------------
// 申请一个新的数据包
// ------------------------------------------------------------------------------
procedure TUDPServer.NewUDataPack(var TmpData: PUDataPack);
begin
  try
    with FreeUDataList.LockList do
    begin
      if Count > 0 then
      begin
        TmpData := Items[0];
        Delete(0);
      end else New(TmpData);
    end;
  finally
    FreeUDataList.UnlockList;
  end;
end;

// ------------------------------------------------------------------------------
// 发送一个数据包过程
// ------------------------------------------------------------------------------
procedure TUDPServer.SendUBuffer(iAction:Byte);
begin
  if FConnected then
    SendUBuffer(iAction,FDestHost, FDestPort);
end;

procedure TUDPServer.SendUBuffer(iAction:Byte;sHost:String;iPort:Word);
var
  TmpData: PUDataPack;
begin
  try
    NewUDataPack(TmpData);
    FillMemory(TmpData, SizeOf(TUDataPack), 0);
    TmpData^.DataHead.iAction := iAction;
    SendUBuffer(TmpData,sHost,iPort);
  finally
    FreeUDataList.Add(TmpData);
  end;
end;

procedure TUDPServer.SendUBuffer(TmpData: PUDataPack);
begin
  if FConnected then
    SendUBuffer(TmpData,FDestHost, FDestPort);
end;

procedure TUDPServer.SendUBuffer(TmpData: PUDataPack;sHost:String;iPort:Word);
var
  iLen: LongWord;
begin
  if Active then
    try
    iLen := TmpData^.DataHead.iLen + SizeOf(TUDataHead);
    SendBuffer(sHost, iPort,TmpData^,iLen);
    except
    on e: exception do
      WriteLogEvent(nil,UD_Send_Error,e.Message);
    end;
end;

procedure TUDPServer.SendSimple(var buf;bufSize:Word);
begin
  SendSimple(FDestHost, FDestPort,buf,bufSize);
end;

procedure TUDPServer.SendSimple(sHost:String;iPort:Word;var buf;bufSize:Word);
var
  TmpData: PUDataPack;
begin
  try
    NewUDataPack(TmpData);
    FillMemory(TmpData, SizeOf(TUDataPack), 0);
    TmpData^.DataHead.iAction := UD_Simple;
    TmpData^.DataHead.iLen:=bufSize;
    CopyMemory(@TmpData^.Data[0],@buf,bufSize);
    SendUBuffer(TmpData,sHost,iPort);
  finally
    FreeUDataList.Add(TmpData);
  end;
end;
// ------------------------------------------------------------------------------
// 数据接收过程
// ------------------------------------------------------------------------------
procedure TUDPServer.UDPBaseOnUDPRead(Sender: TObject; var buf;bufSize:Word;ABinding: TSocketHandle);
var
  TmpData: PUDataPack;
begin
  try
    NewUDataPack(TmpData);
    FillMemory(TmpData, SizeOf(TUDataPack), 0);

    CopyMemory(@TmpData^.DataHead,@buf,SizeOf(TUDataHead));
    CopyMemory(@TmpData^.Data[0],Pointer(Integer(@buf)+SizeOf(TUDataHead)),TmpData^.DataHead.iLen);
     //正在接收和发送数据块时重置心跳激活时钟
    if FConnected then
    if TmpData^.DataHead.iAction in [UD_Start,UD_Block,UD_Send,UD_Recv,UD_SendOver,UD_RecvOver] then
      TmpTimer.ActiveTime(HeartBeatThread);
          
    case TmpData^.DataHead.iAction of
      UD_Pull_Heartbeat:
        PullHeartbeatProcess(TmpData, ABinding);                        //处理Pull心跳
      UD_Pull_Response:
        PullResponseProcess(TmpData);                                   //处理Pull心跳回应
      // --------------------------------------------------------------------------
      UD_Handshake_Firstly:
        HandshakeFirstlyProcess(TmpData, ABinding);  //第一次握手
      UD_Handshake_Secondly:
        HandshakeSecondlyProcess(TmpData);           //回应握手
      UD_Handshake_Thirdly:
        HandshakeThirdlyProcess(TmpData);            //确认握手
      // --------------------------------------------------------------------------
      UD_Heartbeat:
        HeartBeatProcess(TmpData); // 心跳
      UD_Response:
        ResponseProcess(TmpData); // 心跳响应
      // --------------------------------------------------------------------------
      UD_Simple:
        RecvSimpleProcess(TmpData,ABinding); //处理简单数据包过程

      else UDPServerOnUDPRead(TmpData); //交给子类处理
    end;

  finally
    FreeUDataList.Add(TmpData);
  end;
end;

procedure TUDPServer.UDPServerOnUDPRead(TmpData: PUDataPack);
begin
//
end;

//处理简单数据包
procedure TUDPServer.RecvSimpleProcess(TmpData: PUDataPack; ABinding: TSocketHandle);
begin
  if assigned(FOnUDPSimpleRead) then
    FOnUDPSimpleRead(nil,TmpData.Data,TmpData.DataHead.iLen,ABinding);
end;

// ------------------------------------------------------------------------------
// 激活心跳
// ------------------------------------------------------------------------------
procedure TUDPServer.HeartBeatCheck(Sender: TObject);
begin
  if FConnected then
    begin
    PSingleTime(OutHeartBeatThread).iCount:=0;
    TmpTimer.ActiveTime(OutHeartBeatThread);
    SendUBuffer(UD_Heartbeat);
    end;
end;

// ------------------------------------------------------------------------------
// 心跳超时
// ------------------------------------------------------------------------------
procedure TUDPServer.OutHeartBeatCheck(Sender: TObject);
begin
  inc(PSingleTime(OutHeartBeatThread).iCount);
  if PSingleTime(OutHeartBeatThread).iCount <3 then
    begin
    TmpTimer.ActiveTime(HeartBeatThread, False);
    SendUBuffer(UD_Heartbeat);
    end else CloseConnect;
end;

// ------------------------------------------------------------------------------
// 处理心跳
// ------------------------------------------------------------------------------
procedure TUDPServer.HeartBeatProcess(TmpData: PUDataPack);
begin
  if FConnected then
    begin
    TmpData^.DataHead.iAction := UD_Response;
    SendUBuffer(TmpData);
    end;
end;

// ------------------------------------------------------------------------------
// 响应心跳
// ------------------------------------------------------------------------------
procedure TUDPServer.ResponseProcess(TmpData: PUDataPack);
begin
  TmpTimer.ActiveTime(HeartBeatThread);
  TmpTimer.ActiveTime(OutHeartBeatThread, False);
end;

// ------------------------------------------------------------------------------
// 发起确认UDP外网IP和Port
// ------------------------------------------------------------------------------
procedure TUDPServer.PullServer(sHost:String;iPort:Word);
begin
  SendUBuffer(UD_Pull_Heartbeat,sHost,iPort);
end;

// ------------------------------------------------------------------------------
// 处理确认UDP外网IP和Port
// ------------------------------------------------------------------------------
procedure TUDPServer.PullHeartbeatProcess(TmpData: PUDataPack; ABinding: TSocketHandle);
var
  sHost:String;
  iPort:Word;
  iLen:Byte;
begin
  sHost := ABinding.PeerIP;
  iPort := ABinding.PeerPort;

  TmpData^.DataHead.iAction := UD_Pull_Response;

  iLen:=Length(sHost);
  CopyMemory(@TmpData^.Data[0],@iPort,SizeOf(Word));
  CopyMemory(@TmpData^.Data[SizeOf(Word)],@sHost[1],iLen);
  
  TmpData.DataHead.iLen:=iLen+SizeOf(Word);
  SendUBuffer(TmpData,sHost,iPort);
end;

// ------------------------------------------------------------------------------
// 借助服务器确认UDP外网IP和Port
// ------------------------------------------------------------------------------
procedure TUDPServer.PullResponseProcess(TmpData: PUDataPack);
var
  iLen:Byte;
begin
  iLen:=TmpData.DataHead.iLen-SizeOf(Word);
  SetLength(FRemoteHost,iLen);
  CopyMemory(@FRemotePort,@TmpData^.Data[0],SizeOf(Word));
  CopyMemory(@FRemoteHost[1],@TmpData^.Data[SizeOf(Word)],iLen);
end;

// ------------------------------------------------------------------------------
// 处理第一次握手
// ------------------------------------------------------------------------------
procedure TUDPServer.HandshakeFirstlyProcess(TmpData: PUDataPack; ABinding: TSocketHandle);
begin
  FDestHost := ABinding.PeerIP;
  FDestPort := ABinding.PeerPort;
  TmpData^.DataHead.iAction := UD_Handshake_Secondly;
  SendUBuffer(TmpData,FDestHost,FDestPort);
end;

// ------------------------------------------------------------------------------
// 处理第二次握手
// ------------------------------------------------------------------------------
procedure TUDPServer.HandshakeSecondlyProcess(TmpData: PUDataPack);
begin
  TmpTimer.ActiveTime(HeartBeatThread);
  FConnected := True;  
  TmpData^.DataHead.iAction := UD_Handshake_Thirdly;
  SendUBuffer(TmpData);
  if assigned(FonConnect) then FonConnect(self);
end;

// ------------------------------------------------------------------------------
// 处理第三次握手
// ------------------------------------------------------------------------------
procedure TUDPServer.HandshakeThirdlyProcess(TmpData: PUDataPack);
begin
  TmpTimer.ActiveTime(HeartBeatThread);
  FConnected := True;
  if assigned(FonConnect) then FonConnect(self);
end;


// ------------------------------------------------------------------------------
// 初始化组件
// ------------------------------------------------------------------------------
function TUDPServer.InitialUdpTransfers(sLocalIP: String;
  const iLocalPort: Word = 0):Boolean;
begin
  Result:=False;
  if Active then exit; //服务已经开启需要先关闭服务
  Result:=InitServer(sLocalIP,iLocalPort);
end;

// ------------------------------------------------------------------------------
// 打开连接过程
// ------------------------------------------------------------------------------
procedure TUDPServer.Connect(sHost: String; iPort: Word; Const bPull: Boolean = False);
begin
  if not Active then exit; //服务没有开启
  if FConnected then exit; // 如果已经连接需要先断开才能重新连接

  FDestHost := sHost;
  FDestPort := iPort;

  if bPull and assigned(FOnServerPull) then
    FOnServerPull(nil);

  SendUBuffer(UD_Handshake_Firstly,FDestHost,FDestPort);
end;

// ------------------------------------------------------------------------------
// 关闭连接过程
// ------------------------------------------------------------------------------
procedure TUDPServer.CloseConnect;
begin
  if Active and FConnected then
    begin
    TmpTimer.ActiveTime(OutHeartBeatThread, False);
    TmpTimer.ActiveTime(HeartBeatThread, False);
    if assigned(FonDisconnect) then
      FonDisconnect(self);
    end;
  FConnected:=False;
end;

procedure TUDPServer.CloseServer; 
begin
  CloseConnect;
  Inherited;
end;

end.
