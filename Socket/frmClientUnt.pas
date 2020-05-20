unit frmClientUnt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UDPCommonUnt,UDPStreamUnt, ComCtrls;

const
  Refresh_Status   = wm_user + 1001;

  Refresh_Speed   =            1000;
  Refresh_Process =            1001;

type
  TfrmClient = class(TForm)
    Button2: TButton;
    ProgressBar1: TProgressBar;
    Memo1: TMemo;
    Button4: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    ProgressBar2: TProgressBar;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    Button3: TButton;
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    iTime: LongWord;
    UdpServer: TUDPStream;
    procedure UdpOnConnect(Sender: TObject);
    procedure UdpOnDisconnect(Sender: TObject);
    procedure UdpServerOnSendComplete(Sender: TObject);
    procedure UdpServerOnRecvReady(Sender:TObject;var sNewFileName:WideString; iSize:Int64);
    procedure UdpServerOnRecvComplete(Sender: TObject; AData: TStream);
    procedure UdpServerOnUDPSimpleRead(Sender: TObject; var buf;bufSize:Word;ABinding: TSocketHandle);
    procedure UdpClientOnLog(Sender:TObject;iErrorCode:Integer;sLog:WideString);
    procedure UdpCleintOnProcess(Sender:TObject;iPosition,iCount:LongWord;iSize:Int64);
    procedure UdpServerOnProcess(Sender:TObject;iPosition,iCount:LongWord;iSize:Int64);
    procedure CustomMessage(var msg: tmessage); message Refresh_Status;
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

function GetOpenFileName(var sFileName:String):Boolean;
begin
  Result:=False;
  with TOpenDialog.Create(nil) do
    try
    if execute then
      begin
      Result:=True;
      sFileName:=FileName;
      end;
    finally
    free;
    end;
end;

procedure TfrmClient.FormCreate(Sender: TObject);
begin
  UdpServer := TUDPStream.Create;
  UdpServer.OnUDPRecvComplete := UdpServerOnRecvComplete;
  UdpServer.OnUDPSendComplete := UdpServerOnSendComplete;
  UdpServer.OnSendProcessEvent := UdpCleintOnProcess;
  UdpServer.OnUDPRecvReady:=UdpServerOnRecvReady;
  UdpServer.OnUDPSimpleRead:=UdpServerOnUDPSimpleRead;
  UdpServer.onConnect := UdpOnConnect;
  UdpServer.onDisconnect := UdpOnDisconnect;
  UdpServer.OnRecvProcessEvent := UdpServerOnProcess;
  UdpServer.LogEvent := UdpClientOnLog;
  UdpServer.InitialUdpTransfers('0.0.0.0', 0);
  Edit2.Text := IntToStr(UdpServer.LocalPort);
  Label1.Caption := IntToStr(UdpServer.LocalPort);
end;

procedure TfrmClient.FormDestroy(Sender: TObject);
begin
  UdpServer.CloseServer;
  if assigned(UdpServer) then
    freeandnil(UdpServer);
end;

procedure TfrmClient.Button2Click(Sender: TObject);
begin
  UdpServer.Connect(Edit1.Text, StrToIntDef(Edit2.Text, 4455));
end;

procedure TfrmClient.UdpOnConnect(Sender: TObject);
begin
  Memo1.Lines.Add('Connect');
end;

procedure TfrmClient.UdpOnDisconnect(Sender: TObject);
begin
  Memo1.Lines.Add('Disconnect');
end;

procedure TfrmClient.UdpServerOnRecvReady(Sender:TObject;var sNewFileName:WideString; iSize:Int64);
begin
  sNewFileName:=ConCat('c:\',UdpServer.sReserve);
end;


procedure TfrmClient.UdpServerOnSendComplete(Sender: TObject);
begin
  Memo1.Lines.Add(ConCat('Send Complete:',IntToStr(GetTickCount - iTime)));
end;

procedure TfrmClient.UdpServerOnRecvComplete(Sender: TObject; AData: TStream);
begin
  Memo1.Lines.Add('Recv Complete.');
end;

procedure TfrmClient.UdpClientOnLog(Sender:TObject;iErrorCode:Integer;sLog:WideString);
begin
  Memo1.Lines.Add(Format('%d: %s',[getTickCount,sLog]));
end;

procedure TfrmClient.UdpServerOnUDPSimpleRead(Sender: TObject; var buf;bufSize:Word;ABinding: TSocketHandle);
var
  sTmpStr:String;
begin
  SetLength(sTmpStr,bufSize);
  CopyMemory(@sTmpStr[1],@buf,bufSize);
  Memo1.Lines.Add(Format('%s: %d',[ABinding.PeerIP,ABinding.PeerPort]));
  Memo1.Lines.Add(Format('%d: %s',[getTickCount,sTmpStr]));
end;

procedure TfrmClient.CustomMessage(var msg: tmessage);
begin
  case msg.WParamHi of
    Refresh_Speed:
      begin
        if msg.WParamLo = 1 then
          Label3.Caption := ConCat('Speed:',
            IntToStr(msg.LParam div (1024*1024)), 'MB/√Î');
        if msg.WParamLo = 2 then
          Label2.Caption := ConCat('Speed:',
            IntToStr(msg.LParam div (1024*1024)), 'MB/√Î');
      end;

    Refresh_Process:
      begin
        if msg.WParamLo = 1 then
        begin
          ProgressBar1.Max := msg.LParamHi;
          ProgressBar1.Position := msg.LParamLo;
        end;
        if msg.WParamLo = 2 then
        begin
          ProgressBar2.Max := msg.LParamHi;
          ProgressBar2.Position := msg.LParamLo;
        end;
      end;
  end;
end;

procedure TfrmClient.UdpCleintOnProcess(Sender: TObject;
  iPosition, iCount: LongWord; iSize: Int64);
var
  TmpParam: tmessage;
begin
  TmpParam.WParamHi := Refresh_Process;
  TmpParam.WParamLo := 1;
  TmpParam.LParamLo := iPosition;
  TmpParam.LParamHi := iCount;
  PostMessage(handle, Refresh_Status, TmpParam.WParam, TmpParam.LParam);
  TmpParam.WParamHi := Refresh_Speed;
  PostMessage(handle, Refresh_Status, TmpParam.WParam, iSize);
end;

procedure TfrmClient.UdpServerOnProcess(Sender: TObject;
  iPosition, iCount: LongWord; iSize: Int64);
var
  TmpParam: tmessage;
begin
  TmpParam.WParamHi := Refresh_Process;
  TmpParam.WParamLo := 2;
  TmpParam.LParamLo := iPosition;
  TmpParam.LParamHi := iCount;
  PostMessage(handle, Refresh_Status, TmpParam.WParam, TmpParam.LParam);
  TmpParam.WParamHi := Refresh_Speed;
  PostMessage(handle, Refresh_Status, TmpParam.WParam, iSize);
end;

procedure TfrmClient.Button4Click(Sender: TObject);
var
  sFileName:String;
begin
  if GetOpenFileName(sFileName) then
   begin
    UdpServer.SendFile(sFileName);
    iTime := GetTickCount();
  end;
end;

procedure TfrmClient.Button1Click(Sender: TObject);
begin
  UdpServer.PullServer(Edit1.Text, StrToIntDef(Edit2.Text, 4455));
end;

procedure TfrmClient.Button3Click(Sender: TObject);
var
  sTmpStr:String;
begin
  sTmpStr:='dageqsa4wag4aw4hgraw≤‚ ‘';
  UdpServer.SendSimple(sTmpStr[1],Length(sTmpStr));
end;

procedure TfrmClient.Button5Click(Sender: TObject);
begin
  UdpServer.CloseConnect;
end;

procedure TfrmClient.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  UdpServer.CloseConnect;
end;

end.
