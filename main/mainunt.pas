unit mainunt;

interface

uses Windows, SysUtils,Classes,messages,forms,ComCtrls,Graphics,
     ExtCtrls,Menus, Controls,Dialogs, StdCtrls,Buttons,
     Gifimage,pngimage,jpeg,CoolTrayIcon,activex,ShlObj,

     constunt,structureunt,
     SunIMTreeList, SunNewlyList,EventCommonUnt,
     {Tnt_Unicode}
     TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
     TntClasses, TntStdCtrls, TntExtCtrls,TntButtons,TntDialogs,
     {Frame Unit}
     MainFramefrms,FrameCenter, TntMenus;


type
  TMainForm = class(TFrmMain)
    UserListPopup: TTntPopupMenu;
    FlashStatusTime: TTimer;
    StatusPopup: TTntPopupMenu;
    MainTrayIcon: TCoolTrayIcon;
    MainPopup: TTntPopupMenu;
    ITEM_SendMutilfile: TTntMenuItem;
    ITEM_AVideo: TTntMenuItem;
    ITEM_DelUser: TTntMenuItem;
    ITEM_SendMsg: TTntMenuItem;
    ITEM_Online: TTntMenuItem;
    ITEM_Hideline: TTntMenuItem;
    ITEM_Break04: TTntMenuItem;
    ITEM_UserInfo: TTntMenuItem;
    ITEM_Downline: TTntMenuItem;
    ITEM_Outline: TTntMenuItem;
    ITEM_SearchUser: TTntMenuItem;
    ITEM_MsgManage: TTntMenuItem;
    ITEM_Break02: TTntMenuItem;
    ITEM_Help: TTntMenuItem;
    ITEM_About: TTntMenuItem;
    ITEM_Break03: TTntMenuItem;
    ITEM_Exit: TTntMenuItem;
    ITEM_OnDownHint: TTntMenuItem;
    ITEM_Break05: TTntMenuItem;
    ITEM_AddGroup: TTntMenuItem;
    ITEM_ReNameGroup: TTntMenuItem;
    ITEM_DelGroup: TTntMenuItem;
    ITEM_MoveBlackList: TTntMenuItem;
    ITEM_FindUser: TTntMenuItem;
    ITEM_MySpace: TTntMenuItem;
    ITEM_Break01: TTntMenuItem;
    ITEM_Firend: TTntMenuItem;
    ITEM_Break06: TTntMenuItem;
    ITEM_RequestRemote: TTntMenuItem;
    ITEM_MoveUser: TTntMenuItem;
    ITEM_ShowHide: TTntMenuItem;
    ITEM_ReNameUser: TTntMenuItem;
    ITEM_HistoryMsg: TTntMenuItem;
    ITEM_MoveNewly: TTntMenuItem;
    ITEM_Break07: TTntMenuItem;
    ITEM_Break08: TTntMenuItem;
    ITEM_Break09: TTntMenuItem;
    ITEM_Break10: TTntMenuItem;
    ITEM_Config: TTntMenuItem;
    ITEM_Break11: TTntMenuItem;
    ITEM_ShortCustom: TTntMenuItem;
    ITEM_OnlyOnline: TTntMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure ITEM_HelpClick(Sender: TObject);
    procedure ITEM_ExitClick(Sender: TObject);
    procedure FlashStatusTimeTimer(Sender: TObject);
    procedure ITEM_AboutClick(Sender: TObject);
    procedure MainTrayIconDblClick(Sender: TObject);
    procedure ITEM_UserInfoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StatusPopupPopup(Sender: TObject);
    procedure ITEM_SendMsgClick(Sender: TObject);
    procedure ITEM_OnlineClick(Sender: TObject);
    procedure ITEM_DelUserClick(Sender: TObject);
    procedure ITEM_SendMutilfileClick(Sender: TObject);
    procedure ITEM_AVideoClick(Sender: TObject);
    procedure ITEM_OnDownHintClick(Sender: TObject);
    procedure UserListPopupPopup(Sender: TObject);
    procedure ITEM_AddGroupClick(Sender: TObject);
    procedure ITEM_ReNameGroupClick(Sender: TObject);
    procedure ITEM_DelGroupClick(Sender: TObject);
    procedure DeleteGroupNotify(Sender: TObject;swGroup:WideString;bCanDelete:Boolean);
    procedure RenameGroupNotify(Sender: TObject;swOldGroup, swNewGroup:WideString;var bCanRename:Boolean);
    procedure DeleteUserNotify(Sender: TObject;swID, swNickName:WideString;bCanDelete:Boolean);
    procedure RenameUserNotify(Sender: TObject;swID, swOldNickName,swNewNickName:WideString);
    procedure ContactChangeGroup(Sender: TObject);
    procedure ITEM_SearchUserClick(Sender: TObject);
    procedure ITEM_MoveBlackListClick(Sender: TObject);
    procedure ITEM_MsgManageClick(Sender: TObject);
    procedure ITEM_ConfigClick(Sender: TObject);
    procedure ITEM_ReNameUserClick(Sender: TObject);
    procedure ITEM_MoveNewlyClick(Sender: TObject);
    procedure TntFormDestroy(Sender: TObject);
    procedure ITEM_RequestRemoteClick(Sender: TObject);
    procedure ITEM_ShortCustomClick(Sender: TObject);
    procedure MainTrayIconClick(Sender: TObject);
    procedure ITEM_ShowHideClick(Sender: TObject);
    procedure ITEM_HistoryMsgClick(Sender: TObject);
    procedure ITEM_OnlyOnlineClick(Sender: TObject);
  private
    FClipView:HWND;
    FlashFirend_List:TStringList;
    cur_status_auto:boolean;
    fControlCenter:TFrame_ControlCenter;
    { Private declarations }
    procedure CHANGE_CB_CHAIN(var msg:Tmessage);message WM_CHANGECBCHAIN;
    procedure DRAW_CLIPBOARD(var msg:Tmessage);message WM_DRAWCLIPBOARD;
    procedure WMQueryEndsession(Var Msg:TMessage);Message WM_QueryEndSession;
    procedure DropFileProcess(Sender:TObject;const sParams: Widestring);
    //--------------------------------------------------------------------------
    procedure EventProcess(Sender:TObject;TmpEvent:TEventData);
    //--------------------------------------------------------------------------
    procedure InitializeMainFrame;
    //--------------------------------------------------------------------------
    function UserSelected:Boolean;
    function GetSelectUserID:WideString;
    function GroupSelected:Boolean;
    function GetSelectGroupID:WideString;
    function ISNewly:Boolean;
    function ISIMUser:Boolean;
    //--------------------------------------------------------------------------
    procedure createheader(groupid:WideString);
    procedure createbutton(firendinfo:Tfirendinfo);
    procedure deletebutton(sUserSign:String);
    procedure show_myinfor;
    procedure refreshlist_userbar;
    procedure refresh_latelylist;
    procedure PopupAtCursor(TmpMenu:TTntPopupMenu);
    procedure initclientfrom;
    procedure checkstatusouttime;
    procedure flashtoicon(sUserSign:String;bool:boolean);
    procedure stopflash;
    procedure checkflashicon;
    procedure clear_status_item;
    //--------------------------------------------------------------------------
    procedure Finitialframe;
    procedure LoginComplete;
  protected
    procedure Ed_KeyKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Ed_SearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Lab_SearchClick(Sender:TObject);
    procedure Ed_SearchKeyChange(Sender:TObject);
    procedure NickNameAndStateClick(Sender: TObject);
    procedure ITEM_MySpaceClick(Sender: TObject);
    procedure UserListClick(Sender: TObject);
    procedure Ed_KeyExit(Sender: TObject);
    procedure MainMenuClick(Sender: TObject);
    procedure IdiographClick(Sender: TObject);
    procedure IdiographDbClick(Sender: TObject);
    procedure LabMinClick(Sender: TObject);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  
implementation

{$R *.DFM}
uses  udpcores,ShareUnt,About,Math,eventunt,frmMessageUnt,
      shellapi,reginfor,SimpleXmlUnt,userunt,hookunt,ImageOleUnt,chatrec;

//------------------------------------------------------------------------------
// 拦截Windows关闭消息
//------------------------------------------------------------------------------
procedure TMainForm.WMQueryEndsession(var Msg: TMessage);
begin
  Msg.Result := 1;
  allow_application_quit:=true;
  Perform(WM_SYSCOMMAND,SC_CLOSE,0);
end;

procedure tMainForm.LabMinClick(Sender: TObject);
begin
  MainTrayIcon.HideMainForm;
end;

procedure TMainForm.PopupAtCursor(TmpMenu:TTntPopupMenu);
var
  CursorPos: TPoint;
begin
  if Assigned(TmpMenu) then
    if TmpMenu.AutoPopup then
      if GetCursorPos(CursorPos) then
      begin
        Application.ProcessMessages;
        SetForegroundWindow(handle);
        if Owner is TWinControl then
          SetForegroundWindow((Owner as TWinControl).Handle);
        TmpMenu.PopupComponent := Self;
        TmpMenu.Popup(CursorPos.X, CursorPos.Y);
        if Owner is TWinControl then
         PostMessage((Owner as TWinControl).Handle, WM_NULL, 0, 0)
      end;
end;

//------------------------------------------------------------------------------
// 事件分发消息处理
//------------------------------------------------------------------------------
procedure TMainForm.EventProcess(Sender:TObject;TmpEvent:TEventData);
var
  TmpNode:TTntTreeNode;
  TmpInfor:TFirendInfo;
begin
  case TmpEvent.iEvent of
  //------------------------------------------------------------------------------
  // 刷新要改变状态的用户
  //------------------------------------------------------------------------------
  Refresh_UserStatus_Event:
    begin
    if CompareText(TmpEvent.UserSign,LoginUserSign)=0 then   //如果是用户自己更新
      show_myinfor;

    if user.Find(TmpEvent.UserSign,TmpInfor) then  //如果是其它用户就更新状态标签
      begin
      createheader(TmpInfor.gname);
      createbutton(TmpInfor);
      end;
    end;

  //------------------------------------------------------------------------------
  // 弹出主窗口
  //------------------------------------------------------------------------------
  ShowMainForm_Event:
    begin
    MainTrayIcon.IconVisible:=true;
    MainTrayIcon.ShowMainForm;
    end;

  //------------------------------------------------------------------------------
  // 闪烁小图标
  //------------------------------------------------------------------------------
  ShowIconFlash_Event:
    begin
    if FlashFirend_List.IndexOf(TmpEvent.UserSign)<0 then
      FlashFirend_List.Add(TmpEvent.UserSign);
    end;

  //------------------------------------------------------------------------------
  // 隐藏主窗口
  //------------------------------------------------------------------------------
  HideMainForm_Event:
    begin
    if MainTrayIcon.IconVisible then
      begin
      MainTrayIcon.HideMainForm;
      MainTrayIcon.IconVisible:=false;
      end else begin
      MainTrayIcon.IconVisible:=true;
      MainTrayIcon.ShowMainForm;
      end;
    end;

  //------------------------------------------------------------------------------
  // 刷新用户列表
  //------------------------------------------------------------------------------
  Refresh_UserList_Event:
    begin
    if user.Find(TmpEvent.UserSign,TmpInfor) then
      begin
      createheader(TmpInfor.gname);
      createbutton(TmpInfor);
      end;
    end;
  //------------------------------------------------------------------------------
  // 刷新最近联系人
  //------------------------------------------------------------------------------
  Refresh_Latelylist_Event:
    begin
    if assigned(fControlCenter) then
    with fControlCenter do
      begin
      TmpNode:=Si_IMUserList.GetUserNodeWithID(TmpEvent.UserSign);
      if assigned(TmpNode) then Sn_IMNewlyList.AddNewlyUser(TmpNode);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// 处理窗口关闭
//------------------------------------------------------------------------------
procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (not allow_application_quit) and closetomin then
  begin
    Action := caNone;
    LabMinClick(nil);
  end
  else
  begin
    mainfrm_top := Top;
    mainfrm_left := Left;
    udpcore.UserOutStatus;
    udpcore.user_logout_process;
  end;
end;

//通知事件
procedure TMainForm.DeleteGroupNotify(Sender: TObject;swGroup:WideString;bCanDelete:Boolean);
begin
  sleep(0);
end;

procedure TMainForm.RenameUserNotify(Sender: TObject;swID, swOldNickName,swNewNickName:WideString);
var
  TmpInfor:Tfirendinfo;
begin
  if user.Find(swID,TmpInfor) then
    begin
    WStrCopy(TmpInfor.uname,PWideChar(swNewNickName));
    user.Update(TmpInfor);
    createbutton(TmpInfor);
    end;
end;

procedure TMainForm.RenameGroupNotify(Sender: TObject;swOldGroup, swNewGroup:WideString;var bCanRename:Boolean);
var
  sParams:WideString;
begin
  if not(swNewGroup = SysSearchList) then
    begin
    bCanRename:=True;
   { user.modifygroup(swOldGroup,swNewGroup);
    AddValueToNote(sParams,'msgid',xy_group);
    AddValueToNote(sParams,'funid',xy_rename);
    AddValueToNote(sParams,'oldgroup',swOldGroup);
    AddValueToNote(sParams,'newgroup',swNewGroup);
    AddValueToNote(sParams,'userid',loginuser);   }
    udpcore.SendServer(sParams);
    end else begin
    bCanRename:=False;
    MessageBox(Handle, PChar(Format(GROUP_CONFIG_DEF, [swNewGroup])), PChar(MSGBOX_TYPE_ERROR), MB_ICONERROR);
    end;
end;

procedure TMainForm.DeleteUserNotify(Sender: TObject;swID, swNickName:WideString;bCanDelete:Boolean);
begin
  Sleep(0);
end;

procedure TMainForm.createheader(groupid:WideString);
begin
  if assigned(fControlCenter) then
  with fControlCenter.Si_IMUserList do
    AddGroup(groupid,false,GetGroupNode(SysBlacklist));
end;

function TMainForm.UserSelected:Boolean;
begin
  result:=False;
  if assigned(fControlCenter) then
  with fControlCenter do
     begin
     case _CUR_PAGE of
       0:if assigned(Si_IMUserList.Selected) then
            Result:=Si_IMUserList.Selected.Level=1;
       1:result:=assigned(Sn_IMNewlyList.Selected);
       end;
     end;
end;

function TMainForm.GetSelectUserID:WideString;
begin
  Result:='';
  if assigned(fControlCenter) then
  with fControlCenter do
     begin
      case _CUR_PAGE of
       0:if assigned(Si_IMUserList.Selected) then
         if Si_IMUserList.Selected.Level=1 then
            Result:=Si_IMUserList.GetSelectedUserInfo(Si_IMUserList.Selected).ID;
       1:if assigned(Sn_IMNewlyList.Selected) then
           Result:=Sn_IMNewlyList.GetSelectedUserID(Sn_IMNewlyList.Selected);
       end;
     end;
end;

function TMainForm.GroupSelected:Boolean;
var
  swGroup:String;
begin
  result:=False;
  if assigned(fControlCenter) then
  with fControlCenter do
     begin
     case _CUR_PAGE of
       0:if assigned(Si_IMUserList.Selected) then
         if Si_IMUserList.Selected.Level=0 then
            begin
            swGroup:=Si_IMUserList.GetSelectedGroup(Si_IMUserList.Selected);
            Result:=(swGroup<>SysFirendlist)and(swGroup<>SysBlacklist);
            end;
       end;
     end;
end;

function TMainForm.GetSelectGroupID:WideString;
var
  tmp:TTntTreeNode;
begin
  Result:=SysFirendlist;
  if assigned(fControlCenter) then
  with fControlCenter do
    begin
    case _CUR_PAGE of
      0:if assigned(Si_IMUserList.Selected) then
        if Si_IMUserList.Selected.Level=0 then
         Result:=Si_IMUserList.GetSelectedGroup(Si_IMUserList.Selected)
         else begin
         tmp:=Si_IMUserList.GetUserNodeWithID(GetSelectUserId);
         if assigned(tmp) then
            result:=Si_IMUserList.GetSelectedUserInfo(Tmp).Group;
         end;
      end;
    end;
end;

function TMainForm.ISNewly:Boolean;
begin
  result:=false;
  if assigned(fControlCenter) then
  with fControlCenter do
  case _CUR_PAGE of
    1:result:=assigned(Sn_IMNewlyList.Selected);
    end;
end;

function TMainForm.ISIMUser:Boolean;
begin
  result:=false;
  if assigned(fControlCenter) then
  with fControlCenter do
    case _CUR_PAGE of
     0:if assigned(Si_IMUserList.Selected) then
       Result:=Si_IMUserList.Selected.Level=1;
     end;
end;
//------------------------------------------------------------------------------
// 建立 userbar  指定 header 下的 button
//------------------------------------------------------------------------------
procedure TMainForm.createbutton(firendinfo:Tfirendinfo);
var
  uiUserInfo : TUserInfo;
begin
  //插入联系人
  if assigned(fControlCenter) then
     begin
      fControlCenter.Si_IMUserList.ClearTUserInfo(uiUserInfo);//这里修正一个错误，就是插入记录时要先做记录初始化
      uiUserInfo.ID := firendinfo.UserSign;
      uiUserInfo.NickName := firendinfo.uname;
      uiUserInfo.State :=firendinfo.status;
      if firendinfo.HideIsVisable=1 then
      if firendinfo.status=2 then uiUserInfo.State :=0;
      uiUserInfo.Reserved := firendinfo.signing;
      if firendinfo.sex='女' then uiUserInfo.Sex := 1 else uiUserInfo.Sex:=0;
      fControlCenter.Si_IMUserList.AddUser(firendinfo.gname, uiUserInfo);
      fControlCenter.Si_IMUserList.Repaint;
     end;
end;

//------------------------------------------------------------------------------
// 删除 button
//------------------------------------------------------------------------------
procedure tMainForm.deletebutton(sUserSign:String);
var
 TmpNode:TTntTreeNode;
begin
  if assigned(fControlCenter) then
  with fControlCenter,Si_IMUserList do
    begin
    TmpNode:=GetUserNodeWithID(sUserSign);
    if assigned(TmpNode) then
       begin
       DeleteUserWithNode(TmpNode);
       if GroupExists(SysSearchList) then
         Lab_SearchClick(nil);
       end;
    end;
end;

//------------------------------------------------------------------------------
// 显示我的昵称图标,在线状态.
//------------------------------------------------------------------------------
procedure tMainForm.show_myinfor;
var
  sFileName:WideString;
  icon:ticon;
  TmpInfor:Tfirendinfo;
begin
  if user.Find(LoginUserSign,TmpInfor) then
  if not ImageOle.GetImageFileName(TmpInfor.visualize,sFileName) then sFileName:=userdefpic;
  if assigned(fControlCenter) then
     begin
      try
      fControlCenter.Image_UserImg.Picture.LoadFromFile(sFileName);
      except
        on EInvalidGraphic do
           fControlCenter.Image_UserImg.Picture:= nil;
      end;

     fControlCenter.Lab_UserNickNameAndState.Caption:=format('%s [%s]',[TmpInfor.uname,statustostr(TmpInfor.status)]);
     if Length(TmpInfor.signing)=0 then
        fControlCenter.Lab_Idiograph.Caption:='点击输入个性签名'
        else fControlCenter.Lab_Idiograph.Caption:=TmpInfor.signing;
     end;
  clear_status_item;
  if TmpInfor.status=0 then ITEM_Online.Checked:=true;
  if TmpInfor.status=1 then ITEM_Outline.Checked:=true;
  if TmpInfor.status=2 then ITEM_Hideline.Checked:=true;
  if TmpInfor.status=3 then ITEM_Downline.checked:=true;

  MainTrayIcon.Hint := Format(TRAYICON_INFO, [LoginUser, StatustoStr(TmpInfor.Status)]);

  try
  icon:=Ticon.Create;
  with udpcore do
    begin
    systray.Delete(0);
    main_small_list.GetIcon(TmpInfor.status,icon);
    systray.InsertIcon(0,icon);
    end;
  MainTrayIcon.IconIndex:=0;
  finally
  freeandnil(icon);
  end;
end;

//------------------------------------------------------------------------------
// 显示我的用户列表
//------------------------------------------------------------------------------
procedure tMainForm.refreshlist_userbar;
var
  TmpInfor:Tfirendinfo;
begin
  user.First;
  while not user.Eof do
    try
    if user.GetCurUserInfo(TmpInfor) then
      begin
      CreateHeader(TmpInfor.gname);
      CreateButton(TmpInfor);
      end;
    finally
    user.Next;
    end;
end;

//------------------------------------------------------------------------------
// 显示最近的用户列表 限二十人
//------------------------------------------------------------------------------
procedure TMainForm.refresh_latelylist;
var
  i:integer;
  sTmpStr:string;
  Tmplist:TStringList;
  Tmp:TTntTreeNode;
begin
  try
  Tmplist:=TStringList.create;
  chat.Getlatelylist(Tmplist);
  if Tmplist.count>0 then
  for i:=1 to Tmplist.count do
    begin
    sTmpStr:=Tmplist.Strings[i-1];
    if CompareText(sTmpStr,LoginUserSign)=0 then continue;
    if assigned(fControlCenter) then
       begin
       Tmp:=fControlCenter.Si_IMUserList.GetUserNodeWithID(sTmpStr);
       if assigned(tmp) then fControlCenter.Sn_IMNewlyList.AddNewlyUser(Tmp);
       end;
    end;
  finally
  freeandnil(Tmplist);
  end;
end;

//------------------------------------------------------------------------------
// 初始化窗口
//------------------------------------------------------------------------------
procedure TMainForm.Initclientfrom;
begin
  try
  show_myinfor;
  refreshlist_userbar;
  refresh_latelylist;
  udpcore.UserLoginStatus;
  if not starting_mini then
     Event.CreateMainEvent(ShowMainForm_Event,'','');
  finally
  if assigned(fControlCenter) then
     fControlCenter.Si_IMUserList.Items[0].Expanded := True;
  end;
end;

procedure TMainForm.LoginComplete;
begin
  try
    LockwindowUpdate(Self.Handle);
    InitializeMainFrame;
    initclientfrom;
  finally
    LockwindowUpdate(0);
  end;
end;

//------------------------------------------------------------------------------
// 建立
//------------------------------------------------------------------------------
procedure TMainForm.FormCreate(Sender: TObject);
begin
  inherited;
  FlashFirend_List:=TStringList.Create;
  Event.CreateEventProcess(EventProcess,Event_Main);
  MainTrayIcon.PopupMenu := StatusPopup;
  MainTrayIcon.PopupMenuEx := MainPopup;
  Main_Hwnd := Handle;
  //进入剪贴板 事件链
  FClipView:=SetClipboardViewer(Main_Hwnd);
  //------------------------------------------------------------------------------
  Lab_Min.OnClick := LabMinClick;
  top := max(10, mainfrm_top);
  mainfrm_left := max(0, mainfrm_left);
  if mainfrm_left=0 then left := screen.Width-width-10
    else left := min(screen.Width-width-10,mainfrm_left);
  udpcore.SysHotKey.Active := True;
  udpcore.recreate_hotkey;
  udpcore.user_login_process;
  LoginComplete;
end;

//------------------------------------------------------------------------------
// 缩放
//------------------------------------------------------------------------------
procedure TMainForm.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if newwidth<266 then newwidth:=266;
  if newheight<466 then newheight:=466;
end;

//------------------------------------------------------------------------------
// 退出应用
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_ExitClick(Sender: TObject);
begin
  Allow_Application_Quit := True;
  Perform(WM_SYSCOMMAND,SC_CLOSE,0);
end;

//------------------------------------------------------------------------------
// 打开帮助
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_HelpClick(Sender: TObject);
begin
  opencmd(ConCat(extractfilepath(application_name),Soft_Name,'.chm'));
end;

//------------------------------------------------------------------------------
// 关于
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_AboutClick(Sender: TObject);
begin
  with taboutbox.create(nil) do
    try
    showmodal;
    finally
    free;
    end;
end;


procedure TMainForm.clear_status_item;
begin
  ITEM_Online.Checked:=false;
  ITEM_Outline.Checked:=false;
  ITEM_Hideline.Checked:=false;
  ITEM_Downline.Checked:=false;
end;

//------------------------------------------------------------------------------
//  检查是否状态超时
//------------------------------------------------------------------------------
procedure TMainForm.checkstatusouttime;
var
  TmpInfor:Tfirendinfo;
begin
  if allow_auto_status then
    begin
    if not User.Find(LoginUserSign,TmpInfor) then exit;

    if hook.GetSilenceStatus(status_outtime) then
      begin
      if TmpInfor.status=0 then  // 开始转换状态
        begin
        cur_status_auto:=true;
        TmpInfor.status:=auto_status;
        User.Update(TmpInfor);
        show_myinfor;
        udpcore.UserChangeStatus;
        end;
      end else begin
      if cur_status_auto then
        begin
        cur_status_auto:=false;
        TmpInfor.status:=0;
        user.Update(TmpInfor); 
        show_myinfor;
        udpcore.UserChangeStatus;
        end;
      end;
   end;
end;

//------------------------------------------------------------------------------
//  userbar trayicon 闪烁过程
//------------------------------------------------------------------------------
procedure TMainForm.flashtoicon(sUserSign:String;bool:boolean);
var
  TmpInfor:Tfirendinfo;
begin
  if user.Find(sUserSign,TmpInfor) then
    begin
    MainTrayIcon.CycleIcons:=Bool;
    if assigned(fControlCenter) then
       fControlCenter.Si_IMUserList.SetUserFlashState(sUserSign,bool);
    if bool then
      begin
      MainTrayIcon.md5name:=sUserSign;
      end else begin
      MainTrayIcon.IconIndex:=0;
      MainTrayIcon.md5name:='';
      end;
    end;
end;

//------------------------------------------------------------------------------
//  停止flash 闪烁过程
//------------------------------------------------------------------------------
procedure TMainForm.stopflash;
var
  sUserSign:string;
begin
  if MainTrayIcon.CycleIcons then
    begin
    sUserSign:=MainTrayIcon.md5name;
    flashtoicon(sUserSign,false);
    CreateUserDialog(sUserSign);
    FlashFirend_List.Delete(0);
    end;
end;

//------------------------------------------------------------------------------
//  检查flash 闪烁过程
//------------------------------------------------------------------------------
procedure TMainForm.checkflashicon;
var
  sUserSign:String;
begin
  if not MainTrayIcon.CycleIcons then
    begin
    if FlashFirend_List.Count>0 then
      begin
      sUserSign:=FlashFirend_List.Strings[0];
      flashtoicon(sUserSign,true);
      end;
    end;
end;

//------------------------------------------------------------------------------
//  状态和闪烁过程
//------------------------------------------------------------------------------
procedure TMainForm.FlashStatusTimeTimer(Sender: TObject);
begin
  checkstatusouttime;
  checkflashicon;
end;

//------------------------------------------------------------------------------
// 任务栏图标处理过程
//------------------------------------------------------------------------------
procedure TMainForm.MainTrayIconDblClick(Sender: TObject);
begin
  if MainTrayIcon.CycleIcons then
    begin
    stopflash;
    end else begin
    MainTrayIcon.ShowMainForm;
    left:=min(screen.Width-width,left);
    left:=max(0,left);
    top:=max(0,top);
    SetForegroundWindow(main_hwnd);
    end;
end;

//------------------------------------------------------------------------------
// 主菜单
//------------------------------------------------------------------------------
procedure TMainForm.MainMenuClick(Sender: TObject);
begin
  PopupAtCursor(MainPopup);
end;

//------------------------------------------------------------------------------
// 探测在线用户,并自动添加好友,
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_SearchUserClick(Sender: TObject);
begin
  UdpCore.SendfinderBroadcast;
end;

//------------------------------------------------------------------------------
//  显示好友资料
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_UserInfoClick(Sender: TObject);
begin
  if UserSelected then
    udpcore.showfirendinfo(GetSelectUserID);
end;

//------------------------------------------------------------------------------
// 打开聊天窗口
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_SendMsgClick(Sender: TObject);
var
  sUserSign:WideString;
begin
  if UserSelected then
    begin
    sUserSign:=GetSelectUserID;
    if MainTrayIcon.CycleIcons and (CompareText(MainTrayIcon.md5name,sUserSign)=0) then
      stopflash else CreateUserDialog(sUserSign);
    end;
end;

//------------------------------------------------------------------------------
//  初始化 自动回复语
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_OnlineClick(Sender: TObject);
var
  TmpInfor:Tfirendinfo;
  CurStatus:Integer;
begin
  CurStatus:=1;
  clear_status_item;
  TMenuItem(sender).Checked:=true;
  if not user.Find(LoginUserSign,TmpInfor) then exit;

  if sender=ITEM_Online then CurStatus:=0;
  if sender=ITEM_Hideline then CurStatus:=2;
  if sender=ITEM_Downline then CurStatus:=3;
  if CurStatus<>TmpInfor.status then
     begin
     TmpInfor.status:=CurStatus;
     user.Update(TmpInfor); 
      if CurStatus=1 then
         begin
         ITEM_Outline.Checked:=true;
         revertmsg:=Tmenuitem(sender).hint;
         end;
      show_myinfor;
      udpcore.UserChangeStatus;
     end;
end;

procedure TMainForm.StatusPopupPopup(Sender: TObject);
var
  tmp:tmenuitem;
  i:integer;
begin
  StatusPopup.Items.Items[1].Clear;
  if AutoReplymemo.count>0 then
  for i:=AutoReplymemo.count downto 1 do
    begin
    tmp:=tmenuitem.create(nil);
    tmp.RadioItem:=true;
    tmp.GroupIndex:=1;
    tmp.hint:=AutoReplymemo.Strings[i-1];
    tmp.caption:=AutoReplymemo.Strings[i-1];
    if tmp.Hint=revertmsg then tmp.Checked:=true;
    tmp.OnClick:=ITEM_OnlineClick;
    StatusPopup.Items.Items[1].add(tmp);
    end;
  tmp:=tmenuitem.create(nil);
  tmp.RadioItem:=true;
  tmp.GroupIndex:=1;
  tmp.hint:='';
  tmp.caption:='无回复消息...';
  if tmp.Hint=revertmsg then tmp.Checked:=true;
  tmp.OnClick:=ITEM_OnlineClick;
  StatusPopup.Items.Items[1].add(tmp);
end;

procedure TMainForm.NickNameAndStateClick(Sender: TObject);
begin
  PopupAtCursor(StatusPopup);
end;

//------------------------------------------------------------------------------
// 删除用户
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_DelUserClick(Sender: TObject);
var
  swUser,msg:WideString;
  TmpInfor:tfirendinfo;
begin
  if UserSelected then
    begin
    swUser:=GetSelectUserID;
    if user.find(swUser,TmpInfor) then
      begin
       if messagebox(handle,pchar(Format('您确认要将联系人 %S(%S) 删除吗？', [TmpInfor.uname,swUser])),
          pchar('删除联系人'),MB_OKCANCEL or MB_ICONINFORMATION)=1 then
          begin
          deletebutton(swUser);
          user.deluser(swUser);
        {  AddValueToNote(msg,'msgid',xy_firend);
          AddValueToNote(msg,'funid',xy_remove);
          AddValueToNote(msg,'firendid',swUser);
          AddValueToNote(msg,'userid',loginuser);}
          udpcore.sendserver(msg);
          end;
      end;
    end;
end;

//------------------------------------------------------------------------------
// 发送多个文件
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_SendMutilfileClick(Sender: TObject);
begin
  if UserSelected then
    udpcore.sendmutilfile(GetSelectUserID);
end;

procedure TMainForm.ITEM_AVideoClick(Sender: TObject);
begin
  if UserSelected then
    udpcore.createavfrom(GetSelectUserID);
end;


//------------------------------------------------------------------------------
// 状态设置
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_OnDownHintClick(Sender: TObject);
begin
  ITEM_OnDownHint.Checked:=not ITEM_OnDownHint.Checked;
  showupdownhint:=ITEM_OnDownHint.Checked;
end;

procedure TMainForm.UserListPopupPopup(Sender: TObject);
var
  TmpItem:TTntMenuItem;
  TmpList:TTntStringList;

  TmpInfor:tfirendinfo;

  i:integer;

  userid,
  swGetSelectGroupid,
  TmpStr:Widestring;

  bISNewly,bISIMUser,
  bGroupSelected:Boolean;
begin
  try
  tmplist:=TTntStringList.Create;
  if assigned(fControlCenter) then
  case _CUR_PAGE of
   0: begin
      bISIMUser:=ISIMUser;
      bGroupSelected:=GroupSelected;
      swGetSelectGroupid:=GetSelectGroupid;
      with fControlCenter do
        begin
        TmpList.Text:=Si_IMUserList.GetGroupList;
        ITEM_OnDownHint.Visible:=not bISIMUser;
        ITEM_OnlyOnline.Visible:=not bISIMUser;
        ITEM_Break05.Visible:=not bISIMUser;
        ITEM_AddGroup.Visible:=not bISIMUser;
        if not bISIMUser then
           begin
           ITEM_DelGroup.Visible:=True;
           ITEM_ReNameGroup.Visible:=True;
           ITEM_DelGroup.Enabled:=bGroupSelected;
           ITEM_ReNameGroup.Enabled:=bGroupSelected;
           end else begin
           ITEM_DelGroup.Visible:=False;
           ITEM_ReNameGroup.Visible:=False;
           end;
        ITEM_FindUser.Visible:=not bISIMUser;
      //------------------------------------------------------------------------------
        ITEM_SendMsg.Visible:=bISIMUser;
        ITEM_AVideo.Visible:=bISIMUser;
        ITEM_SendMutilfile.Visible:=bISIMUser;
        ITEM_RequestRemote.Visible:=bISIMUser;
        ITEM_MoveUser.Visible:=bISIMUser and (TmpList.Count>2);
        ITEM_MoveUser.Clear;
        if bISIMUser and (TmpList.Count>2)then
        for i:=TmpList.Count downto 1 do
          begin
          TmpStr:=Tmplist.Strings[i-1];
          if (TmpStr<>SysBlacklist)and
             (TmpStr<>SysSearchList)and
             (TmpStr<>swGetSelectGroupid) then
             begin
             TmpItem:=TTntMenuItem.Create(UserListPopup);
             TmpItem.Caption:=TmpStr;
             TmpItem.Hint:=TmpStr;
             TmpItem.OnClick:=ContactChangeGroup;
             ITEM_MoveUser.Add(TmpItem);
             end;
          end;
        ITEM_MoveBlackList.Visible:=bISIMUser;
        if bISIMUser then
        if swGetSelectGroupid=SysBlacklist then
           ITEM_MoveBlackList.Caption:='移出黑名单'
           else ITEM_MoveBlackList.Caption:='移至黑名单';
        ITEM_DelUser.Visible:=bISIMUser;
        ITEM_MoveNewly.Visible:=False;

        ITEM_ShowHide.Visible:=bISIMUser;
        if bISIMUser then
           begin
           userid:=GetSelectUserID;
           if user.find(userid,TmpInfor)then
              begin
              ITEM_ShowHide.Checked:=TmpInfor.HideIsVisable=1;
              end;
           end;

        ITEM_ReNameUser.Visible:=bISIMUser;
        ITEM_HistoryMsg.Visible:=bISIMUser;
        ITEM_UserInfo.Visible:=bISIMUser;
        end;
      end;
    
   1: begin
      bISNewly:=ISNewly;
      swGetSelectGroupid:=GetSelectGroupid;
      with fControlCenter do
        begin
        TmpList.Text:=Si_IMUserList.GetGroupList;
        ITEM_OnDownHint.Visible:=False;
        ITEM_OnlyOnline.Visible:=False;
        ITEM_Break05.Visible:=False;
        ITEM_AddGroup.Visible:=False;
        ITEM_DelGroup.Visible:=False;
        ITEM_ReNameGroup.Visible:=False;
        ITEM_FindUser.Visible:=False;
        ITEM_SendMsg.Visible:=bISNewly;
        ITEM_AVideo.Visible:=bISNewly;
        ITEM_SendMutilfile.Visible:=bISNewly;
        ITEM_RequestRemote.Visible:=bISNewly;
        ITEM_MoveUser.Visible:=bISNewly and (TmpList.Count>2);
        ITEM_MoveUser.Clear;
        if bISNewly and (TmpList.Count>2)then
        for i:=TmpList.Count downto 1 do
          begin
          TmpStr:=Tmplist.Strings[i-1];
          if (TmpStr<>SysBlacklist)and
             (TmpStr<>SysSearchList)and
             (TmpStr<>swGetSelectGroupid) then
             begin
             TmpItem:=TTntMenuItem.Create(UserListPopup);
             TmpItem.Caption:=TmpStr;
             TmpItem.Hint:=TmpStr;
             TmpItem.OnClick:=ContactChangeGroup;
             ITEM_MoveUser.Add(TmpItem);
             end;
          end;
        ITEM_MoveBlackList.Visible:=bISNewly;
        if bISNewly then
        if swGetSelectGroupid=SysBlacklist then
           ITEM_MoveBlackList.Caption:='移出黑名单'
           else ITEM_MoveBlackList.Caption:='移至黑名单';
        ITEM_DelUser.Visible:=False;
        ITEM_MoveNewly.Visible:=bISNewly;
        ITEM_ShowHide.Visible:=False;
        ITEM_ReNameUser.Visible:=False;
        ITEM_HistoryMsg.Visible:=bISNewly;
        ITEM_UserInfo.Visible:=bISNewly;
        end;
      end;
   end;

  finally
  freeandnil(tmplist);
  end;
end;

//------------------------------------------------------------------------------
// 新建好友组
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_AddGroupClick(Sender: TObject);
begin
  if assigned(fControlCenter) then
  with fControlCenter.Si_IMUserList do
    AddGroupWithInput(GetGroupNode(SysBlacklist));
end;

//------------------------------------------------------------------------------
// 修改好友组
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_ReNameGroupClick(Sender: TObject);
begin
  if GroupSelected then
    fControlCenter.Si_IMUserList.RenameGroup;
end;

//------------------------------------------------------------------------------
// 删除好友组
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_DelGroupClick(Sender: TObject);
var
  sParams,
  swOldGroup,
  swNewGroup:WideString;
begin
 if GroupSelected then
   begin
   swOldGroup:=GetSelectGroupid;
   swNewGroup:=SysFirendlist;
   if messagebox(handle,pchar(Format('您确认要将组 %S 删除吗？', [swOldGroup])),
      pchar('删除组'),MB_OKCANCEL or MB_ICONINFORMATION)=1 then
      begin
    {  AddValueToNote(sParams,'msgid',xy_group);
      AddValueToNote(sParams,'funid',xy_rename);
      AddValueToNote(sParams,'oldgroup',swOldGroup);
      AddValueToNote(sParams,'newgroup',swNewGroup);
      AddValueToNote(sParams,'userid',loginuser); }
      udpcore.SendServer(sParams);
      user.modifygroup(swOldGroup,swNewGroup);
      fControlCenter.Si_IMUserList.DeleteGroupWithName(swOldGroup,swNewGroup);
      end;
   end;
end;

procedure TMainForm.ContactChangeGroup(Sender: TObject);
var
  TmpInfor:Tfirendinfo;
  swUserID,swNewGroup:WideString;
begin
  if UserSelected then
    begin
    swUserID:=GetSelectUserID;
    swNewGroup:=TMenuItem(Sender).Hint;
    if user.Find(swUserID,TmpInfor) then
      begin
      WStrPCopy(TmpInfor.gname,swNewGroup);
      user.update(TmpInfor);
      if assigned(fControlCenter) then
        fControlCenter.Si_IMUserList.UserMoveing(swUserID,swNewGroup);
      end;
    end;
end;

procedure TMainForm.ITEM_RequestRemoteClick(Sender: TObject);
begin
  if UserSelected then
    udpcore.createRemotefrom(GetSelectUserID);
end;

//初始化 Frame 面板
procedure TMainForm.InitializeMainFrame;
begin
  fControlCenter := TFrame_ControlCenter.Create(Panel_Frame);
  fControlCenter.Parent := Panel_Frame;
  fControlCenter.Align := alClient;
  fControlCenter.InitializeControlCenter;
  fControlCenter.Lab_UserNickNameAndState.OnClick:=NickNameAndStateClick;
  fControlCenter.Image_Search.OnClick:=ITEM_SearchUserClick;
  fControlCenter.Lab_MainMenu.OnClick:=MainMenuClick;
  fControlCenter.Image_UserImg.OnClick:=ITEM_ConfigClick;
  fControlCenter.Lab_Idiograph.OnClick:=IdiographClick;
  fControlCenter.Lab_Idiograph.OnDblClick:=IdiographDbClick;
  fControlCenter.Ed_Key.OnKeyDown:=Ed_KeyKeyDown;
  fControlCenter.Ed_Key.OnExit:=Ed_KeyExit;
  fControlCenter.Lab_Search.OnClick:=Lab_SearchClick;
  fControlCenter.Ed_SearchKey.OnKeyDown:=Ed_SearchKeyDown;
  fControlCenter.Ed_SearchKey.OnChange:=Ed_SearchKeyChange;
  ITEM_MySpace.OnClick:=ITEM_MySpaceClick;
  //------------------------------------------------------------------------------
  // 初始化列表...
  //------------------------------------------------------------------------------
  fControlCenter.Si_IMUserList.ImageList :=  Udpcore.ImgList;
  fControlCenter.Si_IMUserList.OnDeletingGroup := DeleteGroupNotify;
  fControlCenter.Si_IMUserList.OnDeletingUser := DeleteUserNotify;
  fControlCenter.Si_IMUserList.OnRenameGroup := RenameGroupNotify;
  fControlCenter.Si_IMUserList.OnRenameUser := RenameUserNotify; 
  fControlCenter.Si_IMUserList.IMAGE_GROUP_NONEXPANDED := 0;
  fControlCenter.Si_IMUserList.IMAGE_GROUP_EXPANDED := 1;
  fControlCenter.Si_IMUserList.IMAGE_MAN_ONLINE := 2;
  fControlCenter.Si_IMUserList.IMAGE_MAN_OFFLINE := 3;
  fControlCenter.Si_IMUserList.IMAGE_MAN_LEAVE := 4;
  fControlCenter.Si_IMUserList.IMAGE_WOMEN_ONLINE := 5;
  fControlCenter.Si_IMUserList.IMAGE_WOMEN_OFFLINE := 6;
  fControlCenter.Si_IMUserList.IMAGE_WOMEN_LEAVE := 7;
  fControlCenter.Si_IMUserList.ItemHeigth := 22;

  fControlCenter.Sn_IMNewlyList.ImageList :=  Udpcore.ImgList;
  fControlCenter.Sn_IMNewlyList.ItemHeigth := 22;

  fControlCenter.Si_IMUserList.PopupMenu:=UserListPopup;
  fControlCenter.Sn_IMNewlyList.PopupMenu:=UserListPopup;
  fControlCenter.Si_IMUserList.OnDblClick:=ITEM_SendMsgClick;
  fControlCenter.Si_IMUserList.OnClick:=UserListClick;
  fControlCenter.Sn_IMNewlyList.OnDblClick:=ITEM_SendMsgClick;

    //初始化组
  fControlCenter.Si_IMUserList.AddGroup(SysFirendlist, True);
  fControlCenter.Si_IMUserList.AddGroup(SysBlacklist, True);

  DragAcceptFiles(fControlCenter.Si_IMUserList.Handle, True);
  DragAcceptFiles(fControlCenter.Sn_IMNewlyList.Handle, True);
  fControlCenter.Si_IMUserList.OnDropFile:=DropFileProcess;
  fControlCenter.Sn_IMNewlyList.OnDropFile:=DropFileProcess;
  fControlCenter.Show;//显示面板
  fControlCenter.Si_IMUserList.ItemHeigth := 22;
  fControlCenter.Sn_IMNewlyList.ItemHeigth := 22;
end;

procedure TMainForm.DropFileProcess(Sender:TObject;const sParams: Widestring);
begin
 if UserSelected then
    udpcore.SendDropFile(GetSelectUserID,sParams);
end;

procedure TMainForm.Finitialframe;
begin
  if assigned(fControlCenter) then freeandnil(fControlCenter);
end;

procedure TMainForm.IdiographClick(Sender: TObject);
var
  TmpInfor:tfirendinfo;
begin
  if user.find(loginusersign,TmpInfor) then
  if TmpInfor.signing='' then
  if assigned(fControlCenter) then
    begin
    fControlCenter.Lab_Idiograph.Visible:=False;
    fControlCenter.Image_EditBorder.Visible:=true;
    fControlCenter.Ed_Key.Visible:=true;
    fControlCenter.Ed_Key.SetFocus;
    fControlCenter.Ed_Key.Text:='';
    end;
end;

procedure TMainForm.IdiographDbClick(Sender: TObject);
var
  TmpInfor:tfirendinfo;
begin
  if user.Find(loginusersign,TmpInfor) then
  if assigned(fControlCenter) then
     begin
      fControlCenter.Lab_Idiograph.Visible:=False;
      fControlCenter.Image_EditBorder.Visible:=true;
      fControlCenter.Ed_Key.Visible:=true;
      fControlCenter.Ed_Key.SetFocus;
      fControlCenter.Ed_Key.Text:=TmpInfor.signing;
     end;
end;

procedure TMainForm.Ed_KeyKeyDown(Sender: TObject; var Key: Word;
 Shift: TShiftState);
var
  TmpInfor:Tfirendinfo;
begin
  if assigned(fControlCenter) then
  with fControlCenter do
   begin
   if (key=13)then
    begin
    if (Ed_Key.Text<>'') then
      begin
      Lab_Idiograph.Caption:=Ed_Key.text;
      if user.Find(LoginUserSign,TmpInfor) then
        begin
        WStrPCopy(TmpInfor.signing,Ed_Key.text);
        user.update(TmpInfor);
        udpcore.changemyinfo;
        end;
      end;
    Ed_Key.OnExit(nil);
    end;
   if (key=27) then Ed_Key.OnExit(nil);
   end;
end;

procedure TMainForm.Ed_KeyExit(Sender: TObject);
begin
  if assigned(fControlCenter) then
  with fControlCenter do
    begin
    Ed_Key.Visible:=False;
    Image_EditBorder.Visible:=False;
    Lab_Idiograph.Visible:=true;
    end;
end;

procedure TMainForm.UserListClick(Sender: TObject);
begin
  if assigned(fControlCenter) then
  with fControlCenter,Si_IMUserList do
    if GroupExists(SysSearchList) then
    if not GroupIsExpaned(SysSearchList) then
     begin
     GroupClear(SysSearchList);
     Ed_SearchKey.Text:=SEARCH_KEY_HINT;
     end;
end;

procedure TMainForm.Ed_SearchKeyChange(Sender:TObject);
begin
  if length(fControlCenter.Ed_SearchKey.Text)=0 then
    Lab_SearchClick(nil);
end;

procedure TMainForm.Ed_SearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then Lab_SearchClick(nil);
end;

procedure TMainForm.Lab_SearchClick(Sender:TObject);
var
  keystr:string;
  TmpInfor:Tfirendinfo;
begin
if assigned(fControlCenter) then
  begin
  keystr:=fControlCenter.Ed_SearchKey.Text;
  with fControlCenter.Si_IMUserList do
    begin
    GroupClear(SysSearchList);
    if length(keystr)=0 then exit;
    AddGroup(SysSearchList,true);
    ExpanedGroup(SysSearchList);

    user.First;
    while not user.Eof do
     try
       if user.GetCurUserInfo(TmpInfor) then
         begin
         if (pos(keystr,TmpInfor.userid)>0)or
            (pos(keystr,TmpInfor.uname)>0)or
            (pos(keystr,TmpInfor.sex)>0)or
            (pos(keystr,TmpInfor.age)>0)or
            (pos(keystr,TmpInfor.constellation)>0)or
            (pos(keystr,TmpInfor.signing)>0)or
            (pos(keystr,TmpInfor.mytext)>0)or
            (pos(keystr,TmpInfor.area)>0)or
            (pos(keystr,TmpInfor.Phone)>0)or
            (pos(keystr,TmpInfor.Communication)>0)or
            (pos(keystr,TmpInfor.qqmsn)>0)or
            (pos(keystr,TmpInfor.email)>0) then
         if (TmpInfor.UserSign<>LoginUserSign) then
            AddUserEx(SysSearchList,TmpInfor.UserSign);
         end;
     finally
     user.Next;
     end;
    end;
  end;
end;

procedure TMainForm.ITEM_MySpaceClick(Sender: TObject);
begin

end;


procedure TMainForm.ITEM_MoveBlackListClick(Sender: TObject);
var
  UserID:wideString;
  p:Tfirendinfo;
begin
  if UserSelected then
  if GetSelectGroupid=SysBlacklist then
      begin
       UserID:=GetSelectUserID;
       if user.find(UserID,p) then
           begin
           WStrPCopy(p.gname,SysFirendlist);
           user.update(p);
           if assigned(fControlCenter) then
             fControlCenter.Si_IMUserList.UserMoveing(UserID,SysFirendlist);
           end;
      end else begin
       UserID:=GetSelectUserID;
       if user.find(UserID,p) then
           begin
           WStrPCopy(p.gname,SysBlacklist);
           user.update(p);
           if assigned(fControlCenter) then
             fControlCenter.Si_IMUserList.UserMoveing(UserID,SysBlacklist);
           end;
       end;
end;

//------------------------------------------------------------------------------
// 查看所有聊天记录
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_MsgManageClick(Sender: TObject);
begin
  udpcore.createhisform;
end;

procedure TMainForm.ITEM_ShortCustomClick(Sender: TObject);
begin
  udpcore.ShowSystemConfig(2);
end;

//------------------------------------------------------------------------------
// 个性化设置
//------------------------------------------------------------------------------
procedure TMainForm.ITEM_ConfigClick(Sender: TObject);
begin
  udpcore.ShowSystemConfig(0);
end;

procedure TMainForm.ITEM_ReNameUserClick(Sender: TObject);
begin
  if UserSelected then
    fControlCenter.Si_IMUserList.RenameUser;
end;

procedure TMainForm.ITEM_MoveNewlyClick(Sender: TObject);
var
  userid:string;
  TmpInfor:Tfirendinfo;
begin
 if ISNewly then
    begin
    userid:=getselectuserid;
    if user.find(userid,TmpInfor) then
      begin
      if messagebox(handle,pchar(Format('您确认要将最近联系人 %S(%S) 删除吗？', [TmpInfor.uname,userid])),
         pchar('删除最近联系人'),MB_OKCANCEL or MB_ICONINFORMATION)=1 then
         if assigned(fControlCenter) then
          with fControlCenter.Sn_IMNewlyList do
            DeleteNewlyUser(Selected);
      end;
    end;
end;

procedure TMainForm.TntFormDestroy(Sender: TObject);
begin
  Finitialframe;
  //退出剪贴板 事件链
  ChangeClipboardChain(Main_Hwnd,FClipView);
  SendMessage(FClipView,WM_CHANGECBCHAIN,Main_Hwnd,FClipView);
  Event.RemoveEventProcess(Event_Main);
  if assigned(FlashFirend_List) then freeandnil(FlashFirend_List);
  inherited;  
end;

procedure TMainForm.MainTrayIconClick(Sender: TObject);
begin
  stopflash;
end;

procedure TMainForm.ITEM_ShowHideClick(Sender: TObject);
var
  TmpInfor:tfirendinfo;
  userid:string;
begin
  if UserSelected then
    begin
    userid:=GetSelectUserID;
    if user.find(userid,TmpInfor) then
      begin
       ITEM_ShowHide.Checked:=not ITEM_ShowHide.Checked;

       if ITEM_ShowHide.Checked then
          TmpInfor.HideIsVisable:=1
          else TmpInfor.HideIsVisable:=0;
          
       user.update(TmpInfor);
       createbutton(TmpInfor);
      end;
    end;
end;

procedure TMainForm.ITEM_HistoryMsgClick(Sender: TObject);
begin
  if UserSelected then
    UdpCore.CreateHisForm(GetSelectUserID);
end;

procedure TMainForm.ITEM_OnlyOnlineClick(Sender: TObject);
begin
  ITEM_OnlyOnline.Checked:=not ITEM_OnlyOnline.Checked;
  showonline:=ITEM_OnlyOnline.Checked;
end;

procedure TMainForm.CHANGE_CB_CHAIN(var msg:Tmessage);
begin
  if LongWord(msg.WParam)=FClipView then FClipView:=msg.LParam
  else if FClipView<>0 then
    SendMessage(FClipView,WM_CHANGECBCHAIN,msg.wParam,msg.lParam);
end;

procedure TMainForm.DRAW_CLIPBOARD(var msg:Tmessage);
begin
  event.CreateAllEvent(UserClipboard_Operation,'','');
  if FClipView<>0 then
    SendMessage(FClipView,WM_DRAWCLIPBOARD,msg.wParam,msg.lParam);
end;

end.


