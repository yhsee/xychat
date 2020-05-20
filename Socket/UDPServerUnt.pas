unit UDPServerUnt;

interface

{*******************************************************}
{                                                       }
{       UDP     ���ݴ������                            }
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
    FIdentifier,            //�����Ψһ��ʶ
    FDestHost,              //����IP
    FRemoteHost: String;    //�Է�IP

    FDestPort,              //���ض˿�
    FRemotePort: Word;      //�Է��˿�

    FConnected:Boolean;     //����״̬

    HeartBeatThread,                //��������ʱ��
    OutHeartBeatThread: Pointer;    //�������ʱ��
    procedure HeartBeatCheck(Sender: TObject);
    procedure OutHeartBeatCheck(Sender: TObject);

    procedure PullHeartbeatProcess(TmpData: PUDataPack; ABinding: TSocketHandle);
    procedure PullResponseProcess(TmpData: PUDataPack);

    procedure HandshakeFirstlyProcess(TmpData: PUDataPack; ABinding: TSocketHandle);
    procedure HandshakeSecondlyProcess(TmpData: PUDataPack);
    procedure HandshakeThirdlyProcess(TmpData: PUDataPack);

    procedure HeartBeatProcess(TmpData: PUDataPack);
    procedure ResponseProcess(TmpData: PUDataPack);

    //��������ݰ�
    procedure RecvSimpleProcess(TmpData: PUDataPack; ABinding: TSocketHandle);
    
    function GetLocalPort: Word;
  protected
    TmpTimer: TMultiTimer; //ʱ�ӹ������
    FreeUDataList: TThreadList;   //���ݰ�ѭ�������б�    
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
    procedure CloseServer; Reintroduce;  //���·���
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

  FIdentifier:=GUIDTOSTRING(GETGUID); //Ψһʶ����
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
// ���ر��ض˿ں�
// ------------------------------------------------------------------------------
function TUDPServer.GetLocalPort: Word;
begin
  Result := FBinding.PeerPort;
end;
// ------------------------------------------------------------------------------
// ����һ���µ����ݰ�
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
// ����һ�����ݰ�����
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
// ���ݽ��չ���
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
     //���ڽ��պͷ������ݿ�ʱ������������ʱ��
    if FConnected then
    if TmpData^.DataHead.iAction in [UD_Start,UD_Block,UD_Send,UD_Recv,UD_SendOver,UD_RecvOver] then
      TmpTimer.ActiveTime(HeartBeatThread);
          
    case TmpData^.DataHead.iAction of
      UD_Pull_Heartbeat:
        PullHeartbeatProcess(TmpData, ABinding);                        //����Pull����
      UD_Pull_Response:
        PullResponseProcess(TmpData);                                   //����Pull������Ӧ
      // --------------------------------------------------------------------------
      UD_Handshake_Firstly:
        HandshakeFirstlyProcess(TmpData, ABinding);  //��һ������
      UD_Handshake_Secondly:
        HandshakeSecondlyProcess(TmpData);           //��Ӧ����
      UD_Handshake_Thirdly:
        HandshakeThirdlyProcess(TmpData);            //ȷ������
      // --------------------------------------------------------------------------
      UD_Heartbeat:
        HeartBeatProcess(TmpData); // ����
      UD_Response:
        ResponseProcess(TmpData); // ������Ӧ
      // --------------------------------------------------------------------------
      UD_Simple:
        RecvSimpleProcess(TmpData,ABinding); //��������ݰ�����

      else UDPServerOnUDPRead(TmpData); //�������ദ��
    end;

  finally
    FreeUDataList.Add(TmpData);
  end;
end;

procedure TUDPServer.UDPServerOnUDPRead(TmpData: PUDataPack);
begin
//
end;

//��������ݰ�
procedure TUDPServer.RecvSimpleProcess(TmpData: PUDataPack; ABinding: TSocketHandle);
begin
  if assigned(FOnUDPSimpleRead) then
    FOnUDPSimpleRead(nil,TmpData.Data,TmpData.DataHead.iLen,ABinding);
end;

// ------------------------------------------------------------------------------
// ��������
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
// ������ʱ
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
// ��������
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
// ��Ӧ����
// ------------------------------------------------------------------------------
procedure TUDPServer.ResponseProcess(TmpData: PUDataPack);
begin
  TmpTimer.ActiveTime(HeartBeatThread);
  TmpTimer.ActiveTime(OutHeartBeatThread, False);
end;

// ------------------------------------------------------------------------------
// ����ȷ��UDP����IP��Port
// ------------------------------------------------------------------------------
procedure TUDPServer.PullServer(sHost:String;iPort:Word);
begin
  SendUBuffer(UD_Pull_Heartbeat,sHost,iPort);
end;

// ------------------------------------------------------------------------------
// ����ȷ��UDP����IP��Port
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
// ����������ȷ��UDP����IP��Port
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
// �����һ������
// ------------------------------------------------------------------------------
procedure TUDPServer.HandshakeFirstlyProcess(TmpData: PUDataPack; ABinding: TSocketHandle);
begin
  FDestHost := ABinding.PeerIP;
  FDestPort := ABinding.PeerPort;
  TmpData^.DataHead.iAction := UD_Handshake_Secondly;
  SendUBuffer(TmpData,FDestHost,FDestPort);
end;

// ------------------------------------------------------------------------------
// ����ڶ�������
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
// �������������
// ------------------------------------------------------------------------------
procedure TUDPServer.HandshakeThirdlyProcess(TmpData: PUDataPack);
begin
  TmpTimer.ActiveTime(HeartBeatThread);
  FConnected := True;
  if assigned(FonConnect) then FonConnect(self);
end;


// ------------------------------------------------------------------------------
// ��ʼ�����
// ------------------------------------------------------------------------------
function TUDPServer.InitialUdpTransfers(sLocalIP: String;
  const iLocalPort: Word = 0):Boolean;
begin
  Result:=False;
  if Active then exit; //�����Ѿ�������Ҫ�ȹرշ���
  Result:=InitServer(sLocalIP,iLocalPort);
end;

// ------------------------------------------------------------------------------
// �����ӹ���
// ------------------------------------------------------------------------------
procedure TUDPServer.Connect(sHost: String; iPort: Word; Const bPull: Boolean = False);
begin
  if not Active then exit; //����û�п���
  if FConnected then exit; // ����Ѿ�������Ҫ�ȶϿ�������������

  FDestHost := sHost;
  FDestPort := iPort;

  if bPull and assigned(FOnServerPull) then
    FOnServerPull(nil);

  SendUBuffer(UD_Handshake_Firstly,FDestHost,FDestPort);
end;

// ------------------------------------------------------------------------------
// �ر����ӹ���
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
