unit UDPBaseUnt;

interface

{*******************************************************}
{                                                       }
{       UDPSocket实现                                   }
{                                                       }
{	           email: yihuas@163.com                      }
{		         2012.11.7                                  }
{                                                       }
{*******************************************************}

uses
  SysUtils, Classes, Windows,WinSock2,
  CustomThreadUnt,UDPCommonUnt;

type
  TUDPBase = class
    constructor Create;
    destructor Destroy; override;
  private
    bStatus:Boolean;
    FLogEvent:TWriteLogEvent;
    FBindSocket:TSocket;
    FSLock,FRlock:TRTLCriticalSection;
    FRecvThread:TCustomThread;
    procedure SocketOnWorkProc(Sender:TObject);
  protected
    FOnUDPRead:TUDPReadEvent;
    FBinding: TSocketHandle;
    procedure WriteLogEvent(Sender:TObject;iErrorCode:Integer;sLog:String);  
    procedure UDPBaseOnUDPRead(Sender: TObject; var buf;bufSize:Word;ABinding: TSocketHandle);virtual;
  public
    function InitServer(sHost:String;iPort:Word):Boolean;
    procedure SendBuffer(sHost:String;iPort:Word;var buf;bufSize:Word);
    procedure CloseServer;
  published
    property OnUDPRead:TUDPReadEvent Write FOnUDPRead;
    property LogEvent:TWriteLogEvent write FLogEvent;
    property Active:Boolean Read bStatus;
  end;

implementation

{UDP SERVER}
//------------------------------------------------------------------------------
//  Create
//------------------------------------------------------------------------------
constructor TUDPBase.Create;
var
  aWSAData:TWSAData;
begin
  bStatus:=False;
  InitializeCriticalSection(FSLock);
  InitializeCriticalSection(FRLock);
  FRecvThread:=TCustomThread.Create;
  FRecvThread.OnExecute:=SocketOnWorkProc;
  // 加载 Socket 2.2
  if WSAStartup(MakeWord(2,2), aWSAData)<>0 then
    begin
    WSACleanup();
    WriteLogEvent(self,UD_Init_Error,'本程序需要WINSOCK2，该机上版本太低，请升级WINSOCK到WINSOCK2');
    end;
end;

procedure TUDPBase.WriteLogEvent(Sender:TObject;iErrorCode:Integer;sLog:String);
begin
  if assigned(FLogEvent) then FLogEvent(nil,iErrorCode,sLog);
end;
//------------------------------------------------------------------------------
//  Destory
//------------------------------------------------------------------------------
destructor TUDPBase.Destroy;
begin
  CloseServer;
  WSACleanup();
  if assigned(FRecvThread) then
    FreeAndNil(FRecvThread);
  DeleteCriticalSection(FRLock);
  DeleteCriticalSection(FSLock);
end;


//------------------------------------------------------------------------------
//  InitialServer
//------------------------------------------------------------------------------

function TUDPBase.InitServer(sHost:String;iPort:Word):Boolean;
var
  iLen:Integer;
  AddrIn:TSockAddr;
begin
  Result:=False;
  if bStatus then exit;
  //创建 Listen 套节字
	FBindSocket := Socket(AF_INET,SOCK_DGRAM, 0);
	if FBindSocket =INVALID_SOCKET then exit;

	AddrIn.sin_family := AF_INET;
	AddrIn.sin_port:= htons(iPort);
  if CompareText(sHost,'0.0.0.0')=0 then
   	AddrIn.sin_addr.s_addr := INADDR_ANY
    else  AddrIn.sin_addr.s_addr := inet_addr(PChar(sHost));

  //将 Listen 与 指定端口 绑定
	if bind(FBindSocket,@AddrIn, SizeOf(TSockAddr))= SOCKET_ERROR then
	  begin
    CloseSocket(FBindSocket);
    exit;
    end;
    
  iLen:=SizeOf(TSockAddr);
  if getsockname(FBindSocket,@AddrIn,iLen)=SOCKET_ERROR then
    begin
    CloseSocket(FBindSocket);
    exit;
    end;

  iLen:=High(Word);
  Setsockopt(FBindSocket, SOL_SOCKET, SO_RCVBUF, @iLen, SizeOf(Integer));

  FBinding.IP:=inet_ntoa(AddrIn.sin_addr);
  FBinding.Port:=htons(AddrIn.sin_port);
  bStatus:=True;
  
  Result:=bStatus;
end;

//------------------------------------------------------------------------------
//  Close Port Stop Server
//------------------------------------------------------------------------------
procedure TUDPBase.CloseServer;
begin
  if not bStatus then exit;
  bStatus:=False;
  CloseSocket(FBindSocket);
end;

procedure TUDPBase.UDPBaseOnUDPRead(Sender: TObject; var buf;bufSize:Word;ABinding: TSocketHandle);
begin
  if Assigned(FOnUDPRead) then FOnUDPRead(Sender,buf,bufSize,ABinding);
end;

procedure TUDPBase.SocketOnWorkProc(Sender:TObject);
var
  ABind:TSocketHandle;
  AddrIn:TSockAddr;
  iLen,BufSize:Integer;
  Buf:Array[0..High(Word)] of Byte;
begin
  Try
  EnterCriticalSection(FRLock);
  if bStatus then
    try
    iLen:=SizeOf(TSockAddr);
    BufSize:=Recvfrom(FBindSocket,Buf,High(Word),0,@AddrIn,iLen);
    if BufSize>0 then
      begin
      ABind.IP:=inet_ntoa(AddrIn.sin_addr);
      ABind.Port:=htons(AddrIn.sin_port);
      UDPBaseOnUDPRead(nil,Buf,BufSize,ABind);
      end;
    except
    on e:exception do
      WriteLogEvent(nil,UD_Recv_Error,e.Message);
    end;
  finally
  LeaveCriticalSection(FRLock);
  end;
end;

//------------------------------------------------------------------------------
//  User Send  Buffer
//------------------------------------------------------------------------------
procedure TUDPBase.SendBuffer(sHost:String;iPort:Word;var buf;bufSize:Word);
var
  AddrIn:TSockAddr;
begin
  Try
  EnterCriticalSection(FSLock);
  if bStatus then
    try
    AddrIn.sin_port:= htons(iPort);
    AddrIn.sin_family := AF_INET;
    AddrIn.sin_addr.s_addr := inet_addr(PChar(sHost));
    if bufSize>0 then
      Sendto(FBindSocket,buf,bufSize,0,@AddrIn, SizeOf(TSockAddr));
    except
    on e:exception do
      WriteLogEvent(nil,UD_Send_Error,e.Message);
    end;
  finally
  LeaveCriticalSection(FSLock);
  end;
end;


end.


