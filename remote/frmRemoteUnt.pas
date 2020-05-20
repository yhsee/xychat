unit frmRemoteUnt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,jpeg,constunt,structureunt,UDPCommonUnt,Clipbrd,
  UDPStreamUnt,EventCommonUnt,EventUnt,frmRemoteClientUnt,
    {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus, ExtCtrls, PanelEx;

type
  TfrmRemote = class(TTntForm)
    Lab_Yes: TLabel;
    Lab_Close: TLabel;
    Lab_Info: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TntFormDestroy(Sender: TObject);
    procedure Lab_YesClick(Sender: TObject);
    procedure Lab_CloseClick(Sender: TObject);
  private
    FServer,
    Just_Remoteing,
    InitiativeClose:boolean;

    FUserClipText,
    FUserSign:String;
    RemoteEvent:Pointer;
    FUDPRemote:TUDPStream;
    frmRemoteClient:TfrmRemoteClient;

    procedure InitialUDPConnect(Params:WideString);
    procedure CloseTrans;
    procedure remote_starting;
    procedure remote_Accept(Params:WideString);
    procedure remote_refuse;
    procedure remote_cancel;
    procedure remote_complete;
    //处理自定义消息.
    procedure EventProcess(Sender:TObject;TmpEvent:TEventData);
    procedure UDPRemoteOnRecvComplete(Sender:TObject;AData:TStream);
    procedure UDPRemoteOnSendComplete(Sender:TObject);
    procedure UDPRemoteOnRecvBuffer(Sender:TObject;var buf;iSize:Word;Binding:TSocketHandle);
    procedure UDPRemoteOnDisconnect(Sender:TObject);
    //**************************************************************************
    procedure SendKeyboardAndMouseInfor(Sender:TObject;Params:WideString);
    procedure PressKeyboard(Params:WideString);
    procedure PressMouse(Params:WideString);
    //**************************************************************************
    procedure CaptureScreen(TmpStream:TStream;rt:TRect;iCursor:LongWord);
    procedure UserStatusChange;
    //**************************************************************************
    procedure RemoteClipboardEvent;
    { Private declarations }
  public
    procedure CreateComplete(sUserSign:String;const bServer:boolean=false);
    { Public declarations }
  end;

implementation
uses  math,ShareUnt,udpcores,SimpleXmlUnt,userunt,hookunt;
{$R *.dfm}

//------------------------------------------------------------------------------
// 窗体事件
//------------------------------------------------------------------------------
procedure TfrmRemote.FormCreate(Sender: TObject);
begin
  inherited;
  udpcore.desksource.CaptureEvent:=CaptureScreen;

  FUDPRemote:=TUDPStream.Create;
  FUDPRemote.OnUDPSimpleRead:=UDPRemoteOnRecvBuffer;
  FUDPRemote.onDisconnect:=UDPRemoteOnDisconnect;
  FUDPRemote.OnUDPSendComplete:=UDPRemoteOnSendComplete;
  FUDPRemote.OnUDPRecvComplete:=UDPRemoteOnRecvComplete;
  FUDPRemote.InitialUdpTransfers('0.0.0.0');
  InitiativeClose:=true;
end;

procedure TfrmRemote.FormShow(Sender: TObject);
var
  TmpInforr,
  MyInfor:Tfirendinfo;
begin
  if not user.find(LoginUserSign,MyInfor) then exit;
  if not user.Find(FUserSign,TmpInforr) then exit;
end;

procedure TfrmRemote.CloseTrans;
var
  sParams:WideString;
begin
  if InitiativeClose then
    begin
    if Just_Remoteing then
      begin
      Just_Remoteing:=false;
      AddValueToNote(sParams,'operation',Remote_Complete_Operation);
      udpcore.InsertFirendHintMessage(FUserSign,WideString('您停止了远程协助！'));
      end else begin
      if FServer then
        begin
        AddValueToNote(sParams,'operation',Remote_Cancel_Operation);
        udpcore.InsertFirendHintMessage(FUserSign,WideString('您取消了远程协助！'));
        end else begin
        udpcore.InsertFirendHintMessage(FUserSign,WideString('您拒绝了远程协助！'));
        AddValueToNote(sParams,'operation',Remote_Refuse_Operation);
        end;
      end;
    AddValueToNote(sParams,'function',Remote_Function);
    AddValueToNote(sParams,'UserSign',LoginUserSign);
    udpcore.SendServertransfer(sParams,FUserSign);
    end;
  Just_Remoteing:=false;
end;

procedure TfrmRemote.TntFormDestroy(Sender: TObject);
begin
  if FServer then
    begin
    udpcore.desksource.CaptureStop;
    udpcore.desksource.CaptureEvent:=nil;
    if JustRemoteConnect then
      begin
      JustRemoteConnect:=False;
      hook.StopVNCHook;
      end;
    end;
  CloseTrans;
  if assigned(frmRemoteClient) then freeandnil(frmRemoteClient);
  Event.RemoveEventProcess(RemoteEvent);
  inherited;
end;

procedure TfrmRemote.CreateComplete(sUserSign:String;const bServer:boolean=false);
var
  sParams:WideString;
  TmpInfor,MyInfor:Tfirendinfo;
begin
  FServer:=bServer;
  FUserSign:=sUserSign;
  if not user.Find(LoginUserSign,MyInfor) then exit;
  if not user.Find(FUserSign,TmpInfor) then exit;
  RemoteEvent:=Event.CreateEventProcess(EventProcess,Event_Remote,FUserSign);

  Lab_Info.Caption:=Format('好友 %s 请求您进行远程协助，您确认接受吗？',[TmpInfor.UName]);
  if FServer then
    begin
    Lab_Yes.Visible:=false;
    Lab_Close.Caption:='取消';
    Lab_Info.Caption:=' 远程协助等待对方确认！';

    AddValueToNote(sParams,'function',Remote_Function);
    AddValueToNote(sParams,'operation',Remote_Request_Operation);
    AddValueToNote(sParams,'UserSign',LoginUserSign);
    udpcore.SendServertransfer(sParams,FUserSign);
    end;
end;

procedure TfrmRemote.EventProcess(Sender:TObject;TmpEvent:TEventData);
begin
  Application.ProcessMessages;
  case TmpEvent.iEvent of
  //------------------------------------------------------------------------------
  // 刷新要改变状态的用户
  //------------------------------------------------------------------------------
    Refresh_UserStatus_Event:
      UserStatusChange;

    UserClipboard_Operation:RemoteClipboardEvent;

    Remote_Refuse_Event:Remote_refuse;
    Remote_Accept_Event:Remote_Accept(TmpEvent.UserParams);
    Remote_Cancel_Event:Remote_cancel;
    Remote_complete_Event:Remote_complete;

    Close_Form_Event:Close;
  end;
end;

procedure TfrmRemote.UserStatusChange;
var
  TmpInfor:tfirendinfo;
begin
  if user.Find(FUserSign,TmpInfor) then
  if TmpInfor.status=3 then //用户下线了..
     begin
     InitiativeClose:=false;
     udpcore.InsertFirendHintMessage(FUserSign,WideString('对方下线了，强行中止远程协助！'));
     event.CreateDialogEvent(Remote_Complete_Event,FUserSign,'');
     end;
end;

procedure TfrmRemote.CaptureScreen(TmpStream:TStream;rt:TRect;iCursor:LongWord);
var
  sTmpStr:String;
  sParams:WideString;
  TmpPoint:TPoint;
begin
  if Just_Remoteing then
    begin
    if not GetCursorPos(TmpPoint) then exit;
    AddValueToNote(sParams,'CursorIndex',iCursor);
    AddValueToNote(sParams,'MouseLeft',TmpPoint.X);
    AddValueToNote(sParams,'MouseTop',TmpPoint.Y);
    AddValueToNote(sParams,'UpdateRect',rt,SizeOf(TRect));
    sTmpStr:=UTF8Encode(sParams);
    if not FUDPRemote.SendStream(TmpStream,sTmpStr) then
      UdpCore.desksource.Capture;
    end;
end;

procedure TfrmRemote.UDPRemoteOnRecvComplete(Sender:TObject;AData:TStream);
var
  rt:TRect;
  iCursor:LongWord;
  TmpPoint:TPoint;
  sParams:WideString;
begin
  if Just_Remoteing then
    try
    if (not FServer)and Assigned(frmRemoteClient) then
      begin
      sParams:=UTF8Decode(FUDPRemote.sReserve);
      GetNoteFromValue(sParams,'UpdateRect',@rt);
      iCursor:=GetNoteFromValue(sParams,'CursorIndex');
      TmpPoint.x:=GetNoteFromValue(sParams,'MouseLeft');
      TmpPoint.y:=GetNoteFromValue(sParams,'MouseTop');
      frmRemoteClient.RefreshScreen(AData,rt,iCursor,TmpPoint);
      end;
    except

    end;
end;

procedure TfrmRemote.UDPRemoteOnSendComplete(Sender:TObject);
begin
  if FServer and Just_Remoteing then
    udpcore.desksource.Capture;
end;

procedure TfrmRemote.UDPRemoteOnRecvBuffer(Sender:TObject;var buf;iSize:Word;Binding:TSocketHandle);
var
  sTmpStr,sEvent:String;
  sParams:WideString;
begin
  SetLength(sTmpStr,iSize);
  CopyMemory(@sTmpStr[1],@buf,iSize);
  sParams:=UTF8Decode(sTmpStr);
  sEvent:=GetNoteFromValue(sParams,'Event');
  if CompareText(sEvent,'KeyboardEvent')=0 then PressKeyboard(sParams);
  if CompareText(sEvent,'MouseEvent')=0 then PressMouse(sParams);
  if CompareText(sEvent,'ClipboardEvent')=0 then
    begin
    FUserClipText:=GetNoteFromValue(sParams,'ClipContent');
    Clipboard.AsText:=FUserClipText;
    end;
  if CompareText(sEvent,'SetColorEvent')=0 then
    udpcore.desksource.SetColorLevel(GetNoteFromValue(sParams,'iLevel'));
  if CompareText(sEvent,'RefreshEvent')=0 then
    udpcore.desksource.Capture;
end;

procedure TfrmRemote.RemoteClipboardEvent;
var
  sTmpStr:String;
  sParams:WideString;
begin
  if Clipboard.HasFormat(CF_TEXT) then
    begin
    sTmpStr:=Clipboard.asText;
    if CompareText(FUserClipText,sTmpStr)<>0 then
    if Just_Remoteing then
      begin
      AddValueToNote(sParams,'Event','ClipBoardEvent');
      AddValueToNote(sParams,'ClipContent',sTmpStr);
      SendKeyboardAndMouseInfor(nil,sParams);
      end;
    end;
end;

procedure TfrmRemote.UDPRemoteOnDisconnect(Sender:TObject);
begin
  if Just_Remoteing then
    begin
    InitiativeClose:=false;
    udpcore.InsertFirendHintMessage(FUserSign,WideString('远程协助通道超时断开！'));
    event.CreateDialogEvent(Remote_Complete_Event,FUserSign,'');
    end;
end;

procedure TfrmRemote.Lab_YesClick(Sender: TObject);
begin
  Lab_Yes.Visible:=false;
  Lab_Close.Caption:='取消';

  remote_starting;
end;

procedure TfrmRemote.Lab_CloseClick(Sender: TObject);
begin
  event.CreateDialogEvent(Remote_Complete_Event,FUserSign,'');
end;

procedure TfrmRemote.InitialUDPConnect(Params:WideString);
var
  TmpInfor:Tfirendinfo;
begin
  if not user.find(FUserSign,TmpInfor) then exit;
  Lab_Info.Caption:='远程协助进行中...';  
  FUDPRemote.Connect(TmpInfor.Lanip,GetNoteFromValue(Params,'RemotePort'));
  Sleep(100);
end;

procedure TfrmRemote.remote_starting;
var
  sParams:WideString;
begin
  AddValueToNote(sParams,'function',Remote_Function);
  AddValueToNote(sParams,'operation',Remote_Accept_Operation);
  AddValueToNote(sParams,'UserSign',LoginUserSign);
  AddValueToNote(sParams,'RemotePort',FUDPRemote.LocalPort);
  udpcore.SendServertransfer(sParams,FUserSign);
end;

procedure TfrmRemote.remote_Accept(Params:WideString);
var
  TmpRect:TRect;
  sParams:WideString;
begin
  InitialUDPConnect(Params);
  Just_Remoteing:=True;
  if FServer then
    begin
    JustRemoteConnect:=hook.StartVNCHook;
    udpcore.desksource.CaptureStart;

    TmpRect:=udpcore.desksource.CaptureRect;
    AddValueToNote(sParams,'function',Remote_Function);
    AddValueToNote(sParams,'operation',Remote_Accept_Operation);
    AddValueToNote(sParams,'UserSign',LoginUserSign);
    AddValueToNote(sParams,'RemotePort',FUDPRemote.LocalPort);
    AddValueToNote(sParams,'ScreenRect',TmpRect,SizeOf(TRect));
    udpcore.SendServertransfer(sParams,FUserSign);
    end else begin
    frmRemoteClient:=TfrmRemoteClient.Create(Application);
    frmRemoteClient.SetRemoteUser(FUserSign,Params);
    frmRemoteClient.SendInfor:=SendKeyboardAndMouseInfor;
    frmRemoteClient.Show;

    sParams:='';
    AddValuetoNote(sParams,'Event','RefreshEvent');
    SendKeyboardAndMouseInfor(nil,sParams);
    end;
end;


procedure TfrmRemote.remote_refuse;
begin
  InitiativeClose:=false;
  udpcore.InsertFirendHintMessage(FUserSign,WideString('对方拒绝了您的远程协助！'));
  event.CreateDialogEvent(Remote_Complete_Event,FUserSign,'');
end;

procedure TfrmRemote.remote_cancel;
begin
  InitiativeClose:=false;
  udpcore.InsertFirendHintMessage(FUserSign,WideString('对方取消了远程协助！'));
  event.CreateDialogEvent(Remote_Complete_Event,FUserSign,'');
end;

procedure TfrmRemote.remote_complete;
begin
  InitiativeClose:=false;
  udpcore.InsertFirendHintMessage(FUserSign,WideString('对方停止了远程协助！'));
  event.CreateDialogEvent(Remote_Complete_Event,FUserSign,'');
end;

//------------------------------------------------------------------------------
procedure TfrmRemote.SendKeyboardAndMouseInfor(Sender:TObject;Params:WideString);
var
  sTmpStr:String;
begin
  if Length(Params)=0 then
    begin
    event.CreateDialogEvent(Remote_Complete_Event,FUserSign,'');
    exit;
    end;
  sTmpStr:=UTF8Encode(Params);
  FUDPRemote.SendSimple(sTmpStr[1],Length(sTmpStr));
end;

procedure TfrmRemote.PressKeyboard(Params:WideString);
var
  iKey:Word;
  bDown:Boolean;
begin
  try
  iKey:=GetNoteFromValue(Params,'iKey');
  bDown:=GetNoteFromValue(Params,'bDown');
  if bDown then keybd_event(iKey,MapVirtualKey(iKey,0),0,0)
           else keybd_event(iKey,MapVirtualKey(iKey,0),KEYEVENTF_KEYUP,0);
  except

  end;
end;

procedure TfrmRemote.PressMouse(Params:WideString);
var
  x,y,
  event,
  wheel:integer;
begin
  try
  x:=GetNoteFromValue(Params,'MouseLeft');
  y:=GetNoteFromValue(Params,'MouseTop');
  event:=GetNoteFromValue(Params,'MouseEvent');
  wheel:=GetNoteFromValue(Params,'MouseWheel');
  SetCursorPos(x,y);
  SetCapture(WindowFromPoint(Point(x,y)));
  if event>0 then mouse_event(event,0,0,wheel,0);
  except

  end;
end;

end.
