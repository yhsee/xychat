unit udpcores;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,Forms,
  AppEvnts,ImgList,Dialogs,ExtCtrls,WComp, SysHot,ActiveX,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls,TntButtons,TntDialogs,
  //----------------------------------------------------------------------------
  constunt,ImageOleUnt,userunt,structureunt,desksource,desunt,md5unt,ZLibEx,
  chatrec,hookunt,frmFileTransferUnt,frmMediaUnt,DirectShowUnt,frmRemoteUnt,
  phizmgrunt, ScktComp,analyzerunt,AnalyzerCommonUnt,EventUnt,EventCommonUnt,
  UDPCommonUnt,UDPBaseUnt;
  //----------------------------------------------------------------------------

type
  Tudpcore = class(TDataModule)
    main_small_list: TImageList;
    events: TApplicationEvents;
    systray: TImageList;
    ImgList: TImageList;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestory(Sender: TObject);
    procedure eventsException(Sender: TObject; E: Exception);
    procedure SysHotKeyHotKey(Sender: TObject; Index: Integer);
    procedure eventsMessage(var Msg: tagMSG; var Handled: Boolean);
  private
    { Private declarations }
    ClientRun:Boolean;
    FUDPServer: TUDPBase;
    analyzerThread:TanalyzerThread;
//------------------------------------------------------------------------------
  protected
    procedure UDPServerOnUDPRead(Sender: TObject;var buf;bufSize:Word;ABinding: TSocketHandle);
    procedure reghotkey(s1:String;s2:integer);
    procedure initclient;
    procedure CreateUserPath;
//------------------------------------------------------------------------------
    function GetFileList(var TmpList:TTntStringList):Boolean;
    function GetFilelistSumSize(TmpList:TTntStringList;var sPath:WideString):int64;
//------------------------------------------------------------------------------
    procedure EventProcess(Sender:TObject;TmpEvent:TEventData);
//------------------------------------------------------------------------------
    procedure FirendStatusProcess(iOperation:Integer);
  public
    UDPCoreEvent:Pointer;
    SysHotKey: TSysHotKey;
    desksource:Tdesksource;
    VideoDirectShow:TVideoDirectShow;
    { Public declarations }
//------------------------------------------------------------------------------
    function RegAcount(sUserID:String;sName:WideString):Boolean;
//------------------------------------------------------------------------------
    procedure ShowPhizMgr;
    procedure ShowSystemConfig(iPage:Integer);
    procedure recreate_hotkey;
    procedure playwave(filenames:WideString);overload;
    procedure playwave(iType:Integer);overload;
//------------------------------------------------------------------------------
    procedure SendServer(Params:WideString);overload;
    procedure SendServer(Params:WideString;sHost:String);overload;
    procedure SendServertransfer(Params:WideString;sUserSign:String);
    procedure SendfinderBroadcast(sHost:String);overload;
    procedure SendfinderBroadcast;overload;
//------------------------------------------------------------------------------
    procedure UserLoginStatus;
    procedure UserOutStatus;
    procedure UserChangeStatus;
    procedure changemyinfo;
//------------------------------------------------------------------------------
    procedure ShowFirendHintMessage(sUserSign:String;sMessage:WideString;iType:Integer);
    procedure InsertFirendHintMessage(sUserSign:String;sMessage:WideString);    
//------------------------------------------------------------------------------
    procedure showfirendinfo(sParams:WideString);overload;
    procedure createhisform(sUserSign:String);overload;
    procedure createhisform;overload;
//------------------------------------------------------------------------------
    procedure sendmutilfile(sUserSign:String);
    procedure SendDropFile(sUserSign:String;sFileList:Widestring);
    procedure Createfiletranfrom(sUserSign:String;Params:WideString);overload;
    procedure createfiletranfrom(Params:WideString);overload;
//------------------------------------------------------------------------------
    procedure createavfrom(sUserSign:String);overload;
    procedure createavfrom(sUserSign:String;Params:WideString);overload;
//------------------------------------------------------------------------------
    procedure createRemotefrom(sUserSign:String);overload;
    procedure createRemotefrom(sUserSign:String;Params:WideString);overload;
//------------------------------------------------------------------------------
    procedure user_login_process;
    procedure user_logout_process;
//------------------------------------------------------------------------------
    procedure setwindowstopmost(handle:thandle);overload;
    procedure setwindowstopmost(handle:thandle;Bool:Boolean);overload;
//------------------------------------------------------------------------------
  end;

var
  udpcore: Tudpcore;

implementation
uses shellapi,ShareUnt,reginfor,myfirendinfor,
     frmPMessageUnt,sysconfigunt,MMSystem,
     frmMessageUnt,historyunt,FindFileUnt,
     SimpleXmlUnt;
     
{$R *.DFM}
{$R hand.RES}

//------------------------------------------------------------------------------
// 播放提示声音
//------------------------------------------------------------------------------
procedure Tudpcore.playwave(FileNames:WideString);
begin
  if Widefileexists(FileNames) then
    sndPlaySoundW(PWideChar(FileNames),SND_ASYNC);
end;

procedure Tudpcore.playwave(iType:Integer);
var
  sPath:WideString;
begin
if not Allow_Playwave then exit;
sPath:=ConCat(Wideextractfilepath(application_name),'sound\');
{case itype of
  xy_wave_type_clientmsg:
     begin
     if (length(ClientMsg_WaveFile)=0)or
        (not Widefileexists(ClientMsg_WaveFile)) then
        ClientMsg_WaveFile:=ConCat(sPath,'msg.wav');
     playwave(ClientMsg_WaveFile);
     end;

  xy_wave_type_groupmsg:
     begin
     if (length(GroupMsg_WaveFile)=0)or
        (not Widefileexists(GroupMsg_WaveFile)) then
        GroupMsg_WaveFile:=ConCat(sPath,'system.wav');
     playwave(GroupMsg_WaveFile);
     end;

  xy_wave_type_systemmsg:
     begin
     if (length(SystemMsg_WaveFile)=0)or
        (not Widefileexists(SystemMsg_WaveFile)) then
        SystemMsg_WaveFile:=ConCat(sPath,'system.wav');
     playwave(SystemMsg_WaveFile);
     end;

  xy_wave_type_newfirend:
     begin
     if (length(NewFirend_WaveFile)=0)or
        (not Widefileexists(NewFirend_WaveFile)) then
        NewFirend_WaveFile:=ConCat(sPath,'Global.wav');
     playwave(NewFirend_WaveFile);
     end;
  end;  }
end;

//------------------------------------------------------------------------------
// 软件开始运行的初始化
//------------------------------------------------------------------------------
procedure Tudpcore.DataModuleCreate(Sender: TObject);
begin
  ClientRun:=True;
  Application_Name:=WideParamStr(0);
  Application_Path:=WideExtractFilePath(Application_Name);
  Screen.Cursors[crHandPoint]:= LoadCursor(Hinstance,'MYHAND');
 // SetWindowLong(Application.Handle, GWL_EXSTYLE, WS_EX_TOOLWINDOW);

  hook:=Thook.create;
  user:=Tuser.create;
  chat:=Tchat.create;
  ImageOle:=TImageOle.create;
  desksource:=Tdesksource.Create;
  FUDPServer := TUDPBase.Create;
  FUDPServer.OnUDPBaseRead := UDPServerOnUDPRead;

  Event:=TEvent.Create(self);
  UDPCoreEvent:=Event.CreateEventProcess(EventProcess,Event_Core);
  Event.Status:=ClientRun;

  SysHotKey := TSysHotKey.Create(Self);
  SysHotKey.OnHotKey := SysHotKeyHotKey;

  VideoDirectShow:=TVideoDirectShow.Create;
  analyzerThread:=TanalyzerThread.Create(self);
  analyzerThread.Status:=ClientRun;

  readxml;
  initclient;

  AddToIPBoundList(MyLocalIP);
end;

//------------------------------------------------------------------------------
// 初始化客户端
//------------------------------------------------------------------------------
procedure Tudpcore.initclient;
begin
  try
    FUDPServer.InitServer('0.0.0.0',core_port);
    LoginUser:=MyLocalip;
    RegAcount(MyLocalip,MyComputerName);
  except
    MessageBox(0,PChar('应用程序无法启动，初始化失败。'),PChar('提示'),MB_OK or MB_ICONINFORMATION);
    Application.Terminate;
  end;
end;

//------------------------------------------------------------------------------
// 事件分发消息处理
//------------------------------------------------------------------------------
procedure Tudpcore.EventProcess(Sender:TObject;TmpEvent:TEventData);
var
  TmpInfor:TFirendInfo;
begin
  Application.ProcessMessages;
  case TmpEvent.iEvent of

  //------------------------------------------------------------------------------
  // 用户简单提示信息
  //------------------------------------------------------------------------------
    ShowHintMesssage_Event:
      begin
      if CompareText(TmpEvent.UserSign,LoginUserSign)=0 then exit;
     { if user.Find(TmpEvent.UserSign,TmpInfor) then
        ShowPopupMessage(TmpEvent.UserSign,TmpEvent.UserParams,xy_popup_type_Pass,True)
        else ShowPopupMessage(TmpEvent.UserSign,TmpEvent.UserParams,xy_popup_type_info,True);  }
      end;

//------------------------------------------------------------------------------
// 显示收到的消息到聊天窗口
//------------------------------------------------------------------------------
    ShowFirendMessage_Event:
      begin
      if user.Find(TmpEvent.UserSign,TmpInfor) then
      if Assigned(TmpInfor.chatdlg) then //窗口存在
         begin
         Event.CreateDialogEvent(ShowFirendMessage_Event,TmpEvent.UserSign,TmpEvent.UserParams);
         chat.addusertext(TmpEvent.UserParams,false,true);
         end else begin
         if newmsg_popup then
           begin
           chat.addusertext(TmpEvent.UserParams,false,false);
           CreateUserDialog(TmpEvent.UserSign);
           end else begin
           chat.addusertext(TmpEvent.UserParams,false,false);
           Event.CreateMainEvent(ShowIconFlash_Event,TmpEvent.UserSign,'');
           end;
         end;
      end;

//------------------------------------------------------------------------------
// 处理语音视频请求
//------------------------------------------------------------------------------
    Media_Request_Event:
      begin
      createavfrom(TmpEvent.UserSign,TmpEvent.UserParams);
      end;

//------------------------------------------------------------------------------
// 处理文件请求
//------------------------------------------------------------------------------
    File_Request_Event:
      begin
      Createfiletranfrom(TmpEvent.UserParams);
      end;

//------------------------------------------------------------------------------
// 处理远程协助请求
//------------------------------------------------------------------------------
    Remote_Request_Event:
      begin
      CreateRemotefrom(TmpEvent.UserSign,TmpEvent.UserParams);
      end;
  end;
end;

//------------------------------------------------------------------------------
//  记录异常错误
//------------------------------------------------------------------------------
procedure Tudpcore.eventsException(Sender: TObject;
  E: Exception);
begin
  logmemo.add(ConCat(formatDateTime('hh:mm:ss',Time),' ',e.Message));
end;

//------------------------------------------------------------------------------
// 软件结束运行的释放
//------------------------------------------------------------------------------
procedure Tudpcore.DataModuleDestory(Sender: TObject);
begin
  ClientRun:=False;
  Event.Status:=ClientRun;
  analyzerThread.Status:=ClientRun;
  Event.RemoveEventProcess(UDPCoreEvent);
  if assigned(Event)then freeandnil(Event);
  if Assigned(SysHotKey) then FreeAndNil(SysHotKey);
  if Assigned(desksource) then FreeAndNil(desksource);
  if assigned(FUDPServer) then  freeandnil(FUDPServer);
  if assigned(analyzerThread) then freeandnil(analyzerThread);
  if Assigned(VideoDirectShow) then FreeAndNil(VideoDirectShow);
  if Assigned(ImageOle) then FreeAndNil(ImageOle);
  if Assigned(hook) then FreeAndNil(hook);
  if Assigned(user) then FreeAndNil(user);
  if Assigned(chat) then FreeAndNil(chat);
  writexml;
  Reg_autorun;
end;

//------------------------------------------------------------------------------
// 非同步线程 消息接收
//------------------------------------------------------------------------------
procedure Tudpcore.UDPServerOnUDPRead(Sender: TObject;var buf;bufSize:Word;ABinding: TSocketHandle);
var
  TmpData:PRawData;
begin
  if not ClientRun then exit;

  if Assigned(analyzerThread) then
    try
    analyzerThread.NewRawData(TmpData);
    TmpData.DataLen:=bufSize;
    CopyMemory(@TmpData^.DataBuf[0],@buf,bufSize);
    TmpData^.UserSocket.PeerIP:=ABinding.PeerIP;
    TmpData^.UserSocket.PeerPort:=ABinding.PeerPort;

    analyzerThread.AddRawDataList(TmpData);
    except
    analyzerThread.AddFreeDataList(TmpData);
    end;
end;

//------------------------------------------------------------------------------
// 发送广播
//------------------------------------------------------------------------------
procedure Tudpcore.SendfinderBroadcast;
var
  i:Integer;
begin
  for i:=IPBoundList.Count downto 1 do
    begin
    SendfinderBroadcast(IPBoundList.Strings[i-1]);
    Sleep(100);
    end;
end;

//------------------------------------------------------------------------------
// 发送广播
//------------------------------------------------------------------------------
procedure tudpcore.SendfinderBroadcast(sHost:String);
var
  i:Integer;
  sParams:WideString;
begin
  AddValueToNote(sParams,'function',Firend_Function);
  AddValueToNote(sParams,'operation',FinderBroadCast_Operation);
  for i:=1 to 254 do
  if ClientRun and FUDPServer.Active then
    sendServer(sParams,Format('%s.%d',[sHost,i]));
end;

//------------------------------------------------------------------------------
// 将消息添发送到指定用户
//------------------------------------------------------------------------------
procedure tudpcore.SendServertransfer(Params:WideString;sUserSign:String);
var
  TmpInfor:Tfirendinfo;
begin
  if user.find(sUserSign,TmpInfor) then
    SendServer(params,TmpInfor.LanIP);
end;

//------------------------------------------------------------------------------
// 将消息添发送到所有好友
//------------------------------------------------------------------------------
procedure tudpcore.SendServer(Params:WideString);
var
  TmpInfor:TFirendinfo;
begin
  User.First;
  while not User.Eof do
    try
    if User.GetCurUserInfo(TmpInfor) then
      sendServer(Params,TmpInfor.Lanip);
    finally
    User.Next;
    end;
end;

//------------------------------------------------------------------------------
// 将消息发送到指定的IP 消息发送
//------------------------------------------------------------------------------
procedure tudpcore.sendServer(Params:WideString;sHost:String);
var
  sParams:String;
begin
  if ClientRun and FUDPServer.Active then
    begin
    sParams:=UTF8Encode(Params);
    FUDPServer.SendBuffer(sHost,Core_Port,sParams[1],Length(sParams));
    Sleep(10);
    end;
end;

//------------------------------------------------------------------------------
// 更新用户状态
//------------------------------------------------------------------------------
procedure Tudpcore.FirendStatusProcess(iOperation:Integer);
var
  TmpInfor:Tfirendinfo;
  Params:WideString;
begin
  if User.Find(LoginUserSign,TmpInfor) then
    begin
    AddValueToNote(Params,'function',System_Function);
    AddValueToNote(Params,'operation',iOperation);
    AddValueToNote(Params,'UserSign',LoginUserSign);
    AddValueToNote(Params,'Status',TmpInfor.Status);
    AddValueToNote(Params,'Lastdt',TmpInfor.Lastdt);
    SendServer(Params);
    end; //异常不可能没有用户自己。
end;

procedure Tudpcore.UserLoginStatus;
begin
  FirendStatusProcess(UserLoginStatus_Operation);
end;

procedure Tudpcore.UserOutStatus;
begin
  FirendStatusProcess(UserOutStatus_Operation);
end;

procedure Tudpcore.UserChangeStatus;
begin
  FirendStatusProcess(UserStatus_Operation);
end;

//------------------------------------------------------------------------------
// 系统热键处理
//------------------------------------------------------------------------------
procedure Tudpcore.reghotkey(s1:String;s2:integer);
var items:thotkeyitem;
 function inttochar(n:integer):char;
  begin
  result:=chr(n-16384);
  end;
begin
  if s2>32858 then   // ctrl+alt
    begin
    items.VirtKey:=syshotkey.keytovirtkeys(inttochar(s2-32768));
    items.Modifiers:=[HKCTRL,HKALT];
    end else
  if s2>16474 then  //alt
    begin
    items.VirtKey:=syshotkey.keytovirtkeys(inttochar(s2-16384));
    items.Modifiers:=[HKALT];
    end else
  if s2>16384 then  //ctrl
    begin
    items.VirtKey:=syshotkey.keytovirtkeys(inttochar(s2));
    items.Modifiers:=[HKCTRL];
    end else
  if s2<16384 then // none
     begin
     items.VirtKey:=syshotkey.keytovirtkeys(inttochar(s2+16384));
     items.Modifiers:=[];
     end;
  items.hintString:=s1;
  syshotkey.add(items);
end;

procedure Tudpcore.recreate_hotkey;
begin
  syshotkey.Clear;
  reghotkey('systemhot_key',systemhot_key); //系统呼出 hotkey
  reghotkey('bosshot_key',bosshot_key);  //截取屏幕 hotkey
end;

procedure Tudpcore.SysHotKeyHotKey(Sender: TObject; Index: Integer);
var
  sTmpStr:String;
begin
  sTmpStr:=TSysHotKey(Sender).Get(index).hintString;
  if CompareText(sTmpStr,'bosshot_key')=0 then
    event.CreateMainEvent(HideMainForm_Event,'','');

  if CompareText(sTmpStr,'systemhot_key')=0 then
    event.CreateMainEvent(ShowMainForm_Event,'','');
end;

  //------------------------------------------------------------------------------
// 获取文件大小
//------------------------------------------------------------------------------
function Tudpcore.GetFilelistSumSize(TmpList:TTntStringList;var sPath:WideString):int64;
var
  i:Integer;
  sTmpStr,
  sTmpString:WideString;
begin
  Result:=0;
  if TmpList.Count >0 then
  for i:=1 to TmpList.Count do
    begin
    sTmpStr:=TmpList.Strings[i-1];
    sTmpString:=WideExtractFilePath(sTmpStr);
    Application.ProcessMessages;
    if Length(sPath)>0 then
      begin
      if Length(sPath)>Length(sTmpString) then
        sPath:=sTmpString;
      end else sPath:=sTmpString;
    Result:=Result+Getfilesize(sTmpStr);
    end;
end;

//------------------------------------------------------------------------------
// 发送拖放过来的文件和目录
//------------------------------------------------------------------------------
procedure Tudpcore.SendDropFile(sUserSign:String;sFileList:Widestring);
var
  iSize:Int64;
  sPath,sParams:WideString;
  TmpList:TTntStringlist;
begin
  try
    TmpList:=TTntStringlist.Create;
    TmpList.Text:=sFileList;
    if Tmplist.Count>0 then
      begin
      iSize:=GetFilelistSumSize(TmpList,sPath);
      AddValueToNote(sParams,'iSumSize',iSize);
      AddValueToNote(sParams,'sFileList',Tmplist.Text);
      AddValueToNote(sParams,'sDirectory',sPath);
      CreateFiletranFrom(sUserSign,sParams);
      end;
  finally
    Freeandnil(TmpList);
  end;
end;


function Tudpcore.GetFileList(var TmpList:TTntStringList):Boolean;
begin
  Result:=False;
  with TTntOpenDialog.Create(nil) do
    try
      InitialDir := DefaultOpenDir;
      Options:=Options+[ofAllowMultiSelect];
      if execute then
        begin
        TmpList.Assign(Files);
        Result:=True;
        end;
    finally
      Free;
    end;
end;

//------------------------------------------------------------------------------
// 发送多个文件
//------------------------------------------------------------------------------
procedure Tudpcore.SendMutilFile(sUserSign:String);
var
  TmpList:TTntStringlist;
begin
  try
    TmpList:=TTntStringlist.Create;
    if GetFileList(TmpList) then
      SendDropFile(sUserSign,TmpList.Text);
  finally
    Freeandnil(TmpList);
  end;
end;

//------------------------------------------------------------------------------
// 创建新的文件传输
//------------------------------------------------------------------------------
procedure Tudpcore.Createfiletranfrom(sUserSign:String;Params:WideString);
var
  TmpInfor:Tfirendinfo;
  TmpFileTransfer:TfrmFileTransfer;
begin
  if CompareText(sUserSign,LoginUserSign)=0 then exit;
  CreateUserDialog(sUserSign);
  if user.find(sUserSign,TmpInfor) then
    begin
    if TmpInfor.status=3 then
      begin
      InsertFirendHintMessage(sUserSign, WideString(' 对方已经下线文件传输无法回应！'));
      exit;
      end;

    if assigned(TmpInfor.chatdlg) then
    with TfrmMessage(TmpInfor.chatdlg),FrmSunExpandWorkForm do
      begin
      TmpFileTransfer := TfrmFileTransfer.Create(sbTransfersBox);
      AjustTransfer(TmpFileTransfer);
      TmpFileTransfer.Visible:=True;
      application.ProcessMessages;
      CreateTransfer;
      Main_memo.RollToPageEnd;
      TmpFileTransfer.CreateComplete(sUserSign,Params,True);
      end;
    end;
end;

//------------------------------------------------------------------------------
//  开始接收文件
//------------------------------------------------------------------------------
procedure Tudpcore.createfiletranfrom(Params:WideString);
var
  TmpInfor:Tfirendinfo;
  TmpFileTransfer:TfrmFileTransfer;
  sUserSign:String;
begin
  sUserSign:=GetNoteFromValue(Params,'UserSign');
  if CompareText(sUserSign,LoginUserSign)=0 then exit;  
  CreateUserDialog(sUserSign);
  if user.find(sUserSign,TmpInfor) then
    begin
    if assigned(TmpInfor.chatdlg) then
    with TfrmMessage(TmpInfor.chatdlg),FrmSunExpandWorkForm do
      begin
      TmpFileTransfer := TfrmFileTransfer.Create(sbTransfersBox);
      AjustTransfer(TmpFileTransfer);
      TmpFileTransfer.Visible:=True;
      application.ProcessMessages;
      CreateTransfer;
      Main_memo.RollToPageEnd;
      TmpFileTransfer.CreateComplete(sUserSign,Params);
      end;
    end;
end;

//------------------------------------------------------------------------------
//  语音视频
//------------------------------------------------------------------------------
procedure Tudpcore.createavfrom(sUserSign:String);
var
  TmpMedia:TfrmMedia;
  TmpInfo:Tfirendinfo;
begin
  if CompareText(sUserSign,LoginUserSign)=0 then exit;
  CreateUserDialog(sUserSign);
  if user.find(sUserSign,TmpInfo) then
    begin
    if JustAVideoConnect then
      begin
      InsertFirendHintMessage(sUserSign, WideString(' 语音视频设备正在使用中'));
      exit;
      end;

    if TmpInfo.status=3 then
      begin
      InsertFirendHintMessage(sUserSign, WideString(' 对方已经下线语音视频无法回应'));
      exit;
      end;

    if assigned(TmpInfo.chatdlg) then
    with TfrmMessage(TmpInfo.chatdlg),FrmSunExpandWorkForm do
      begin
      TmpMedia:=TfrmMedia.create(Panel_Page2);
      AdjustVideoSoundPage(TmpMedia);
      TmpMedia.Visible:=True;
      application.ProcessMessages;
      CreateVideoSoundPage;
      Main_memo.RollToPageEnd;
      TmpMedia.CreateComplete(sUserSign,True);
      end;
    end;
end;

procedure Tudpcore.createavfrom(sUserSign:String;Params:WideString);
var
  TmpMedia:TfrmMedia;
  sParams:WideString;
  TmpInfo:tfirendinfo;
begin
  if CompareText(sUserSign,LoginUserSign)=0 then exit;
  CreateUserDialog(sUserSign);
  if user.find(sUserSign,TmpInfo) then
    begin
    if JustAVideoConnect then
      begin
      InsertFirendHintMessage(sUserSign,WideString('语音视频设备正在使用中!'));
      AddValueToNote(sParams,'function',Media_Function);
      AddValueToNote(sParams,'operation',Media_Refuse_Operation);
      AddValueToNote(sParams,'UserSign',LoginUserSign);
      SendServertransfer(sParams,sUserSign);
      exit;
      end;

    if assigned(TmpInfo.chatdlg) then
    with TfrmMessage(TmpInfo.chatdlg),FrmSunExpandWorkForm do
      begin
      TmpMedia:=TfrmMedia.create(Panel_Page2);
      AdjustVideoSoundPage(TmpMedia);
      TmpMedia.Visible:=true;
      application.ProcessMessages;
      CreateVideoSoundPage;
      Main_memo.RollToPageEnd;
      TmpMedia.CreateComplete(sUserSign);
      end;
    end;
end;

//------------------------------------------------------------------------------
//  远程协助
//------------------------------------------------------------------------------
procedure Tudpcore.createRemotefrom(sUserSign:String);
var
  TmpRemote:TfrmRemote;
  TmpInfo:Tfirendinfo;
begin
  if CompareText(sUserSign,LoginUserSign)=0 then exit;
  CreateUserDialog(sUserSign);
  if user.find(sUserSign,TmpInfo) then
    begin
    if JustRemoteConnect then
      begin
      InsertFirendHintMessage(sUserSign, WideString(' 远程协助正在使用中'));
      exit;
      end;

    if TmpInfo.status=3 then
      begin
      InsertFirendHintMessage(sUserSign, WideString(' 对方已经下线远程协助无法回应'));
      exit;
      end;

    if assigned(TmpInfo.chatdlg) then
    with TfrmMessage(TmpInfo.chatdlg),FrmSunExpandWorkForm do
      begin
      TmpRemote:=TfrmRemote.create(Panel_Page3);
      AdjustRemotePage(TmpRemote);
      TmpRemote.Visible:=True;
      application.ProcessMessages;
      CreateRemotePage;
      Main_memo.RollToPageEnd;
      TmpRemote.CreateComplete(sUserSign,True);
      end;
    end;
end;

procedure Tudpcore.createRemotefrom(sUserSign:String;Params:WideString);
var
  TmpRemote:TfrmRemote;
  sParams:WideString;
  TmpInfo:Tfirendinfo;
begin
  if CompareText(sUserSign,LoginUserSign)=0 then exit;
  CreateUserDialog(sUserSign);
  if user.find(sUserSign,TmpInfo) then
    begin
    if JustRemoteConnect then
      begin
      InsertFirendHintMessage(sUserSign,WideString('远程协助正在使用中!'));
      AddValueToNote(sParams,'function',Remote_Function);
      AddValueToNote(sParams,'operation',Remote_Refuse_Operation);
      AddValueToNote(sParams,'UserSign',LoginUserSign);
      SendServertransfer(sParams,sUserSign);
      exit;
      end;

    if assigned(TmpInfo.chatdlg) then
    with TfrmMessage(TmpInfo.chatdlg),FrmSunExpandWorkForm do
      begin
      TmpRemote:=TfrmRemote.create(Panel_Page3);
      AdjustRemotePage(TmpRemote);
      TmpRemote.Visible:=True;
      application.ProcessMessages;
      CreateRemotePage;
      Main_memo.RollToPageEnd;
      TmpRemote.CreateComplete(sUserSign);
      end;
    end;
end;

{procedure Tudpcore.createRefromex(params:String);
var
  ReCltfrm:TReCltfrm;
  sUserSign:String;
begin
  sUserSign:=GetNoteFromValue(params,'UserSign');
  if user.find(sUserSign) then
    begin
    ReCltfrm:=TReCltfrm.create(Application);
    ReCltfrm.sUserSign:=sUserSign;
    ReCltfrm.Remote_md5code:=GetNoteFromValue(params,'md5code');
    ReCltfrm.FDeskTopRect.Right:=Strtointdef(GetNoteFromValue(params,'width'),0);
    ReCltfrm.FDeskTopRect.Bottom:=Strtointdef(GetNoteFromValue(params,'height'),0);
    ReCltfrm.show;
    end;
end; }

procedure Tudpcore.CreateUserPath;
begin
  DefaultUserPath:=ConCat(Application_Path,'UserData\',loginuser,'\');
  ForceCreateDirectorys(DefaultUserPath);
  DefaultCustomImagePath:=ConCat(DefaultUserPath,'images\');
  ForceCreateDirectorys(DefaultCustomImagePath);
end;

//------------------------------------------------------------------------------
//用户上线过程
//------------------------------------------------------------------------------
procedure Tudpcore.user_login_process;
begin
  CreateUserPath;
  ReadMyconfig;
  recreate_hotkey;
  user.clearuserlist;
  user.loadfromfile;
  ImageOle.ClearImageOle;
  ImageOle.LoadImageOle;
  chat.clearchatreclist;
  chat.loadfromfile;
end;

//------------------------------------------------------------------------------
//用户下线过程
//------------------------------------------------------------------------------
procedure Tudpcore.user_logout_process;
begin
  user.savetofile;
  chat.savetofile;
  WriteMyconfig;
end;

//------------------------------------------------------------------------------
// 修改我的帐号资料
//------------------------------------------------------------------------------
procedure Tudpcore.changemyinfo;
var
  sParams:WideString;
  myinfo:Tfirendinfo;
begin
  if not user.Find(loginusersign,myinfo) then exit;
{  AddValueToNote(sParams,'msgid',xy_user);
  AddValueToNote(sParams,'funid',xy_modify);
  AddValueToNote(sParams,'userid',myinfo.userid);
  AddValueToNote(sParams,'uname',Wstrpas(myinfo.uname));
  AddValueToNote(sParams,'mytext',WStrPas(myinfo.mytext));
  AddValueToNote(sParams,'visualize',myinfo.visualize);
  AddValueToNote(sParams,'checklevel',myinfo.checkup);
  AddValueToNote(sParams,'sex',WStrPas(myinfo.sex));
  AddValueToNote(sParams,'age',WStrPas(myinfo.age));
  AddValueToNote(sParams,'area',WStrPas(myinfo.area));
  AddValueToNote(sParams,'constellation',WStrPas(myinfo.constellation));
  AddValueToNote(sParams,'signing',WStrPas(myinfo.signing));
  AddValueToNote(sParams,'Phone',WStrPas(myinfo.Phone));
  AddValueToNote(sParams,'Communication',WStrPas(myinfo.Communication));
  AddValueToNote(sParams,'QQMSN',WStrPas(myinfo.QQMSN));
  AddValueToNote(sParams,'email',WStrPas(myinfo.email));    }
  sendserver(sParams);
end;


procedure Tudpcore.ShowFirendHintMessage(sUserSign:String;sMessage:WideString;iType:Integer);
var
  TmpInfor:Tfirendinfo;
  sParams:WideString;
begin
  if user.Find(sUserSign,TmpInfor) then
  if Assigned(TmpInfor.chatdlg) then
    begin
    AddValueToNote(sParams,'type',iType);
    AddValueToNote(sParams,'msgtxt',sMessage);
    event.CreateDialogEvent(Dialog_HintEx_Message,sUserSign,sParams);
    end;
end;

procedure Tudpcore.InsertFirendHintMessage(sUserSign:String;sMessage:WideString);
var
  TmpInfor:Tfirendinfo;
begin
  if User.Find(sUserSign,TmpInfor) then
  if Assigned(TmpInfor.chatdlg)  then
    event.CreateDialogEvent(Dialog_Hint_Message,sUserSign,sMessage);
end;

//------------------------------------------------------------------------------
// 窗口置顶
//------------------------------------------------------------------------------
procedure Tudpcore.setwindowstopmost(handle:thandle);
begin
  setwindowstopmost(handle,true);
end;

procedure Tudpcore.setwindowstopmost(handle:thandle;Bool:Boolean);
begin
  if Bool then SetWindowPos(handle,HWND_TOPMOST,0,0,0,0,3)
    else SetWindowPos(handle,HWND_NOTOPMOST,0,0,0,0,3)
end;    

procedure Tudpcore.ShowSystemConfig(iPage:Integer);
begin
  with Tsysconfig.Create(nil) do
    try
    ShowPage(iPage);
    showmodal;
    finally
    free;
    end;
end;

procedure Tudpcore.ShowPhizMgr;
begin
  if not assigned(frmphizmgr) then
    frmphizmgr:=Tfrmphizmgr.Create(application);
  frmphizmgr.Show;
end;

//------------------------------------------------------------------------------
// 显示好友的资料
//------------------------------------------------------------------------------
procedure Tudpcore.showfirendinfo(sParams:WideString);
var
  TmpFirendInfo:Tmyfirend_infor;
begin
  TmpFirendInfo:=Tmyfirend_infor.create(nil);
  TmpFirendInfo.UserSign:=sParams;
  TmpFirendInfo.show;
end;

procedure Tudpcore.createhisform(sUserSign:String);
begin
  createhisform;
  HistoryFrm.ShowFirendRecord(sUserSign);
end;

procedure Tudpcore.createhisform;
begin
  if not assigned(historyfrm) then
    historyfrm:=Thistoryfrm.Create(application);
  historyfrm.Show;
end;


//------------------------------------------------------------------------------
// 注册帐号
//------------------------------------------------------------------------------
function Tudpcore.RegAcount(sUserID:String;sName:WideString):Boolean;
var
  TmpInfo:Tfirendinfo;
  datfile:Tdatfile;
  sFileName:WideString;
  TmpStream:TTntFileStream;
begin
  Result:=False;
  sFileName:=ConCat(Application_Path,'UserData\',sUserID,'\UserDB.dat');
  if not WideFileexists(sFileName) then
    try
    ForceCreateDirectorys(WideExtractFilePath(sFileName));
    TmpStream:=TTntFileStream.Create(sFilename,fmCreate or fmOpenReadWrite);

    FillChar(datfile,sizeof(Tdatfile),#0);
    datfile.DatHeader:=DatFile_Header;
    datfile.DatType:=DatType_UserList;
    datfile.Version:=DatVersion;

    TmpStream.WriteBuffer(datfile,sizeof(Tdatfile));//写入文件头

    FillChar(TmpInfo,SizeOF(Tfirendinfo),#0);
    TmpInfo.UserSign:=md5encode(ConCat(sUserID,'@',MyComputerMac));
    TmpInfo.UserID:=sUserID;
    WStrPCopy(TmpInfo.uname,sName);
    WStrPCopy(TmpInfo.GName,SysFirendlist);
    TmpInfo.lanip:=mylocalip;
    TmpInfo.macstr:=MyComputerMac;
    TmpInfo.Lastdt:=now;    

    TmpStream.WriteBuffer(TmpInfo,sizeof(tfirendinfo));
    Result:=True;
    finally
    freeandnil(TmpStream);
    end;
end;

procedure Tudpcore.eventsMessage(var Msg: tagMSG; var Handled: Boolean);
var
  rt:TRect;
begin
  if assigned(hook) then
  if Msg.message=Hook.SCREEN_UPDATE then
    begin
    rt.Left:=Short(LOWORD(Msg.wParam));
    rt.top:=Short(HIWORD(Msg.wParam));
    rt.Right:=Short(LOWORD(Msg.lParam));
    rt.Bottom:=Short(HIWORD(Msg.lParam));
    if assigned(desksource) then
      desksource.UpdateRect(rt);
    Handled:=True;
    end;
end;

initialization
  CoInitialize(nil);

finalization
  CoUninitialize;

end.
