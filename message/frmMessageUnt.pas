unit frmMessageUnt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls,
  ExtCtrls, ComCtrls,Menus, ActnList, Gifimage, PngImage, Jpeg,Dialogs,
  ConstUnt, StructureUnt,EventCommonUnt,downpicunt,RichEditCommUnt,TalkForm,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus,TntButtons, TntDialogs,TntGraphics;

type
  TPopupMenu = class(TTntPopupMenu);
  TMenuItem = class(TTntMenuItem);
  TfrmMessage = class(TTalkForm)
    DialogPopup: TPopupMenu;
    ITEM_Copy: TMenuItem;
    ITEM_SelAll: TMenuItem;
    ITEM_Break0: TMenuItem;
    ITEM_Paste: TMenuItem;
    ITEM_Clear: TMenuItem;
    DlgActionList: TActionList;
    SendKeyAction: TAction;
    SendKeyPopup: TPopupMenu;
    SendKey_Enter: TMenuItem;
    SendKey_EnterCtrl: TMenuItem;
    ITEM_SaveAs: TMenuItem;
    ITEM_Break1: TMenuItem;
    frmFontDialog: TFontDialog;
    ShortCutPopup: TPopupMenu;
    CheckInputTimer: TTimer;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FormCreate(Sender: TObject);
    procedure ITEM_CopyClick(Sender: TObject);
    procedure ITEM_SelAllClick(Sender: TObject);
    procedure ITEM_PasteClick(Sender: TObject);
    procedure ITEM_ClearClick(Sender: TObject);
    procedure ITEM_SaveAsClick(Sender: TObject);
    procedure SendKey_EnterClick(Sender: TObject);
    procedure SendKey_EnterCtrlClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure SendKeyPopupPopup(Sender: TObject);
    procedure ShortCutPopupPopup(Sender: TObject);
    procedure CheckInputTimerTimer(Sender: TObject);
    procedure TntFormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
  private
    FUserSign:String;
    FAllowSendKey,
    JustInput:boolean;
    downpicture:Tdownpic;
    MessageEvent:Pointer;
    procedure EventProcess(Sender:TObject;TmpEvent:TEventData);
    procedure addmsgtomemo(isme:boolean;dt:tdatetime;firendname:WideString;msg:Widestring;TmpFontFormat:TFontFormat);
    procedure PopupAtCursor(popupmenu:tpopupmenu);
    procedure insert_phiz(sTmpStr:string);
    procedure sendmessager;
    procedure showfirendinfo(Request,downpic:boolean);
    procedure loadhistoryrec;
    procedure readnextmsg(sParams:WideString);
    procedure downpicrequest(Sender:TObject;var sFileSign:String);
    procedure downpicclientcomplete(Sender:TObject;sFileSign:String);
    procedure InsertInforMessage(sTmpStr:WideString);
    procedure InitialFrameProcess;
    procedure SendJustInputMsg;
    procedure JustInputimpact(bActive:Boolean);
  protected
    procedure main_memoURLClick(Sender: TObject; const URL: WideString;AStartPos, ALength: Integer);
    procedure main_dropfile(Sender: TObject; const URL: Widestring);
    procedure main_memoContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure send_memoContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure main_memoKeyUp(Sender: TObject; var Key: Word;
          Shift: TShiftState);
    procedure main_memoKeyDown(Sender: TObject; var Key: Word;
          Shift: TShiftState);
    procedure main_memoDbclick(Sender: TObject);
    procedure send_memoChange(Sender: TObject);
    procedure send_memoPaste(Sender: TObject; const URL: WideString);
    procedure SendFileOnClick(Sender: TObject);
    procedure RmtControlOnClick(Sender: TObject);
    procedure VSChatOnClick(Sender: TObject);
    procedure SendMsgOnClick(Sender: TObject);
    procedure SendMsgMenuOnClick(Sender: TObject);
    procedure IconOnClick(Sender: TObject);
    procedure FontOnClick(Sender: TObject);
    procedure SendImageOnClick(Sender: TObject);
    procedure CopyScreenOnClick(Sender: TObject);
    procedure QuickSendOnClick(Sender: TObject);
    procedure ITEM_ShortCutOnClick(Sender: TObject);
    procedure ITEM_ShortCustomClick(Sender: TObject);
    procedure ViewUserInfoClick(Sender: TObject);
    procedure SetUserSign(Value:String);
    { Private declarations }
  public
    { Public declarations }
  published
  end;

procedure CreateUserDialog(UserSign:String);

implementation

uses udpcores,ShareUnt,phizunt,copyscreen,md5unt,shellapi,SimpleXmlUnt,
     userunt,ImageOleUnt,chatrec,eventunt,RichEditOleUnt;

{$R *.DFM}

//------------------------------------------------------------------------------
// 建立聊天窗口
//------------------------------------------------------------------------------
procedure CreateUserDialog(UserSign:String);
var
  TmpDialogFrm:TfrmMessage;
  TmpInfo:Tfirendinfo;
begin
  if CompareText(UserSign,LoginUserSign)=0 then exit;
  if user.Find(UserSign,TmpInfo) then
    begin
    if not Assigned(TmpInfo.chatdlg) then
      begin
      TmpDialogFrm:=TfrmMessage.create(Application);
      TmpDialogFrm.SetUserSign(UserSign);
      TmpInfo.chatdlg:=TmpDialogFrm;
      user.update(TmpInfo);
      TmpDialogFrm.show;
      end;
    SetForegroundWindow(TfrmMessage(TmpInfo.chatdlg).Handle);
    end;
end;

//------------------------------------------------------------------------------
// 窗口事件
//------------------------------------------------------------------------------
procedure TfrmMessage.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent:=GetDeskTopWindow;
end;

procedure TfrmMessage.PopupAtCursor(popupmenu:tpopupmenu);
var
  CursorPos: TPoint;
begin
  if Assigned(PopupMenu) and PopupMenu.AutoPopup then
  if GetCursorPos(CursorPos) then
    begin
    Application.ProcessMessages;
    SetForegroundWindow(handle);
    if Owner is TWinControl then
      SetForegroundWindow((Owner as TWinControl).Handle);
    PopupMenu.PopupComponent := Self;
    PopupMenu.Popup(CursorPos.X, CursorPos.Y);
    Application.ProcessMessages;
    if Owner is TWinControl then
      PostMessage((Owner as TWinControl).Handle, WM_NULL, 0, 0);
    end;
end;


procedure TfrmMessage.FormClose(Sender: TObject; var Action: TCloseAction);
var
  TmpInfor:Tfirendinfo;
begin
  try
    if user.Find(FUserSign,TmpInfor) then
      begin
      TmpInfor.chatdlg:=nil;
      user.Update(TmpInfor);
      end;
    if assigned(FrmSunExpandWorkForm) then freeandnil(FrmSunExpandWorkForm);
    if assigned(downpicture) then freeandnil(downpicture);
  finally
    action:=cafree;
    TfrmMessage(sender):=nil;
  end;
end;

procedure TfrmMessage.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if newwidth<590 then newwidth:=590;
  if assigned(FrmSunExpandWorkForm)and
    (FrmSunExpandWorkForm.ExistsVideoSound) then
     begin
     if newheight<562 then newheight:=562;
     end else begin
     if newheight<512 then newheight:=512;
     end;
end;

//------------------------------------------------------------------------------
// 窗口初始化
//------------------------------------------------------------------------------
procedure TfrmMessage.FormCreate(Sender: TObject);
begin
  inherited;
  downpicture:=Tdownpic.Create;
  InitialFrameProcess;
end;

procedure TfrmMessage.SetUserSign(Value:String);
begin
  FUserSign:=Value;
  downpicture.InitialComplete(FUserSign);
  downpicture.OnRequest:=downpicrequest;
  downpicture.OnComplete:=downpicclientcomplete;
  MessageEvent:=event.CreateEventProcess(EventProcess,Event_Dialog,FUserSign);
end;

procedure TfrmMessage.showfirendinfo(Request,downpic:boolean);
var
  n:integer;
  TmpInfo:Tfirendinfo;
  sFileName:WideString;
begin
  if user.find(FUserSign,TmpInfo) then
    begin
    Lab_FormCaption.Caption:=ConCat(WStrPas(TmpInfo.uname),'(',TmpInfo.userid,')');
    Caption:=ConCat('与 ',WStrPas(TmpInfo.uname),' 交谈中');
    n:=3;
    case TmpInfo.status of
      0:begin
        n:=2;
        HideSInfo;
        end;
      1:begin
        n:=4;
        ShowSInfo(2,'对方离开,可能无法立即回复',false);
        end;
    2,3:begin
        n:=3;
        ShowSInfo(2,'对方不在线,可能无法立即回复',false);
        end;
      end;
    if TmpInfo.sex=SEX_TAG_WOMEN then Inc(n, 3);
    Udpcore.ImgList.GetIcon(n,Icon);
    TitleIcon.Picture:=nil;
    Udpcore.ImgList.GetIcon(n,TitleIcon.Picture.Icon);
    if not ImageOle.GetImageFileName(TmpInfo.visualize,sFileName) then
      begin
      sFileName:=userdefpic;
      if Request then downpicture.StratRequestDownPicture;
      end;
    FrmSunExpandWorkForm.SetUserViewInfo(TmpInfo.uname,TmpInfo.Communication,TmpInfo.Phone,TmpInfo.email,sFileName);
    end;
end;


procedure TfrmMessage.FormShow(Sender: TObject);
begin
  send_memo.SetFontFormat(DefaultFontFormat);
  showfirendinfo(True,False);
  loadhistoryrec;
  downpicture.StratRequestDownPicture;
end;

//------------------------------------------------------------------------------
// 复制菜单设置
//------------------------------------------------------------------------------
procedure TfrmMessage.ITEM_CopyClick(Sender: TObject);
begin
  TRichEdit(DialogPopup.PopupComponent).CopyToClipboard;
end;

procedure TfrmMessage.ITEM_ClearClick(Sender: TObject);
begin
  TRichEdit(DialogPopup.PopupComponent).Clear;
end;

procedure TfrmMessage.ITEM_SelAllClick(Sender: TObject);
begin
  TRichEdit(DialogPopup.PopupComponent).SelectAll
end;

procedure TfrmMessage.ITEM_PasteClick(Sender: TObject);
begin
  TRichEdit(DialogPopup.PopupComponent).PasteFromClipboard;
end;


function GetSaveFileName(var sFileName:WideString):Boolean;
begin
  Result:=False;
  with TTntSaveDialog.Create(nil) do
    try
    Title:='另存图片为';
    Filter:='图片文件|*.bmp;*.jpg;*.jpeg;*.gif';
    InitialDir:=DefaultSaveDir;
    if execute then
      begin
      Result:=True;
      sFileName:=filename;
      end;
    finally
    free;
    end;
end;
//------------------------------------------------------------------------------
// 另存图片
//------------------------------------------------------------------------------
procedure TfrmMessage.ITEM_SaveAsClick(Sender: TObject);
var
  oFileName,
  nFileName:WideString;
begin
  TRichEditOle(DialogPopup.PopupComponent).GetImageFileName;

  if Widefileexists(oFileName) then
  if GetSaveFileName(nFileName) then
    begin
    nFileName:=WideChangeFileExt(nFileName,WideExtractFileExt(oFileName));
    WideCopyFile(oFileName,nFileName,true);
    end;
end;
//------------------------------------------------------------------------------
// 发送键设置
//------------------------------------------------------------------------------
procedure TfrmMessage.SendKeyPopupPopup(Sender: TObject);
begin
  SendKey_Enter.Checked:=pressenter_send;
  SendKey_EnterCtrl.Checked:=not pressenter_send;
end;


procedure TfrmMessage.SendKey_EnterClick(Sender: TObject);
begin
  SendKey_Enter.Checked:=true;
  pressenter_send:=true;
  if pressenter_send then SendKeyAction.ShortCut:=ShortCut(13,[])
    else SendKeyAction.ShortCut:=ShortCut(13,[ssCtrl]);
end;

procedure TfrmMessage.SendKey_EnterCtrlClick(Sender: TObject);
begin
  SendKey_Enter.Checked:=true;
  pressenter_send:=false;
  if pressenter_send then SendKeyAction.ShortCut:=ShortCut(13,[])
    else SendKeyAction.ShortCut:=ShortCut(13,[ssCtrl]);
end;

//------------------------------------------------------------------------------
// 插入图片
//------------------------------------------------------------------------------
procedure TfrmMessage.insert_phiz(sTmpStr:string);
var
  TmpInfor:TImageInfo;
begin
  if ImageOle.Find(sTmpStr,TmpInfor) then
    begin
    send_memo.InsertImageFile(TmpInfor.filename,TmpInfor.md5);
    send_memo.repaint;
    end;
end;

//------------------------------------------------------------------------------
// 事件分发消息处理
//------------------------------------------------------------------------------
procedure TfrmMessage.EventProcess(Sender:TObject;TmpEvent:TEventData);
begin
  Application.ProcessMessages;
  case TmpEvent.iEvent of

    Close_Form_Event:close;
  //------------------------------------------------------------------------------
  // 刷新要改变状态的用户
  //------------------------------------------------------------------------------
    Refresh_UserStatus_Event:
    if CompareText(TmpEvent.UserSign,FUserSign)=0 then
      showfirendinfo(false,false);

  //------------------------------------------------------------------------------
  // 刷新用户的输入状态
  //------------------------------------------------------------------------------
    ShowInputimpact_Event:
      JustInputimpact(GetNoteFromValue(TmpEvent.UserParams,'bActive'));  
  //------------------------------------------------------------------------------
  // 显示用户消息
  //------------------------------------------------------------------------------
    ShowFirendMessage_Event:
      begin
      readnextmsg(TmpEvent.UserParams);
      end;
  //------------------------------------------------------------------------------
  // 显示用户小提示消息
  //------------------------------------------------------------------------------
    Dialog_Hint_Message:
      begin
      InsertInforMessage(TmpEvent.UserParams);
      if GetForegroundWindow<>handle then flashwindow(handle,true);
      end;

  //------------------------------------------------------------------------------
  // 插入表情
  //------------------------------------------------------------------------------
    Dialog_Phiz_Image:
      begin
      insert_phiz(TmpEvent.UserParams);
      end;
  //------------------------------------------------------------------------------
  // 显示用户进阶小提示消息
  //------------------------------------------------------------------------------
    Dialog_HintEx_Message:
      begin
      ShowSInfo(GetNoteFromValue(TmpEvent.UserParams,'type'),GetNoteFromValue(TmpEvent.UserParams,'msgtxt'));
      end;

    UserImage_Request_Event:
      begin
      if assigned(downpicture) then
        downpicture.UserImage_Request(TmpEvent.UserParams);
      end;

    UserImage_Complete_Event:
      begin
      if assigned(downpicture) then
        downpicture.UserImage_Complete(TmpEvent.UserParams);
      end;

    Media_Complete_Event:
      begin
      FrmSunExpandWorkForm.CloseVideoSoundPage;
      Main_Memo.RollToPageEnd;
      end;

    File_Complete_Event:
      begin
      FrmSunExpandWorkForm.ClosePanel(StrToInt(TmpEvent.UserParams));
      Main_Memo.RollToPageEnd;
      end;

    Remote_Complete_Event:
      begin
      FrmSunExpandWorkForm.CloseRemotePage;
      Main_Memo.RollToPageEnd;
      end;
  end;
end;

//------------------------------------------------------------------------------
// 添加消息到 main_memo
//------------------------------------------------------------------------------
procedure TfrmMessage.addmsgtomemo(isme:boolean;dt:tdatetime;firendname:WideString;msg:Widestring;TmpFontFormat:TFontFormat);
var
  startpos:integer;
begin
  startpos:=Length(main_memo.Text);
  main_memo.RichVisibleDraw(True);
  Main_Memo.RollToLineEnd(True);
  Main_Memo.FontUserNameFormat(isMe);;
  main_memo.Lines.add(ConCat(firendname,' ',TimeToStr(dt)));
  Main_Memo.FontMessageFormat(TmpFontFormat);
  main_memo.lines.add(msg);
  main_memo.FormatTextToOle(startpos);
  Main_Memo.RollToLineEnd(False);
  main_memo.RichVisibleDraw(false);
  if not isme then downpicture.StratRequestDownPicture;
end;

procedure TfrmMessage.InsertInforMessage(sTmpStr:WideString);
var
  startpos:integer;
begin
  startpos:=Length(main_memo.Text);
  Main_Memo.RollToLineEnd(True);
  Main_Memo.FontHtmlLinkFormat;
  main_memo.RichVisibleDraw(true);
  main_memo.lines.add(ConCat(inforpic,sTmpStr,EnterCtrl));
  main_memo.FormatTextToOle(startpos);
  main_memo.FormatHtmltext(startpos);
  main_memo.RichVisibleDraw(false);
  Main_Memo.RollToLineEnd(False);
end;

//------------------------------------------------------------------------------
// 发送消息
//------------------------------------------------------------------------------
procedure TfrmMessage.sendmessager;
var
  sParams:WideString;
  msg:widestring;
  tmpinfo,myinfo:Tfirendinfo;
begin
  JustInput:=False;
  CheckInputTimer.Enabled:=False;
  if not user.Find(FUserSign,TmpInfo) then exit;
  if not user.Find(LoginUserSign,myinfo) then exit;
  send_memo.RichVisibleDraw(true);
  msg:=Trim(send_memo.GetOleText);
  send_memo.RichVisibleDraw(false);
  if length(msg)>0 then
    begin
    fixmsgtxt(msg,1968);
    addmsgtomemo(true,now,myinfo.uname,msg,DefaultFontFormat);
    //---------------------------------------------------------------------------
    //发送,并添加到聊天记录 过程
    //---------------------------------------------------------------------------
    AddValueToNote(sParams,'function',Message_Function);
    AddValueToNote(sParams,'operation',UserText_Operation);
    AddValueToNote(sParams,'UserSign',LoginUserSign);
    AddValueToNote(sParams,'MsgText',msg);
    AddValueToNote(sParams,'fontname',DefaultFontFormat.FontName);
    AddValueToNote(sParams,'fontsize',DefaultFontFormat.FontSize);
    AddValueToNote(sParams,'fontcolor',DefaultFontFormat.FontColor);
    AddValueToNote(sParams,'fontstyle',DefaultFontFormat.FontStyle);
    AddValueToNote(sParams,'dt',datetimetostr(now));
    chat.addusertext(FUserSign,sParams,true,true);
    udpcore.SendServertransfer(sParams,FUserSign)
    end;
end;

//------------------------------------------------------------------------------
// 显示收到的消息
//------------------------------------------------------------------------------
procedure TfrmMessage.readnextmsg(sParams:WideString);
var
  Tmpinfo:Tfirendinfo;
  TmpFontFormat:TFontFormat;
begin
  if user.find(FUserSign,Tmpinfo) then
    begin
    JustInputimpact(False);
    TmpFontFormat.FontName:=GetNoteFromValue(sParams,'fontname');
    TmpFontFormat.FontSize:=strtointdef(GetNoteFromValue(sParams,'fontsize'),9);
    TmpFontFormat.FontColor:=GetNoteFromValue(sParams,'fontcolor');
    TmpFontFormat.FontStyle:=GetNoteFromValue(sParams,'fontstyle');
    addmsgtomemo(false,strtodatetime(GetNoteFromValue(sParams,'dt')),
                 tmpinfo.uname,GetNoteFromValue(sParams,'msgtext'),TmpFontFormat);

    if GetForegroundWindow<>handle then flashwindow(handle,true);
    downpicture.StratRequestDownPicture;
    end;
end;

//------------------------------------------------------------------------------
// 回显历史记录
//------------------------------------------------------------------------------
procedure TfrmMessage.loadhistoryrec;
var
  TmpChatRec:TChatRec;
  MyInfo,TmpInfo:Tfirendinfo;
  TmpFontFormat:TFontFormat;
  uname:widestring;
begin
  if User.Find(FUserSign,TmpInfo) and User.Find(LoginUserSign,MyInfo) then
    begin
    TmpFontFormat:=InitFontFormat;
    Chat.First;
    while not chat.eof do
       try
       Chat.GetCurChatRecInfo(TmpChatRec);
       if not TmpChatRec.readok then
       if CompareText(TmpChatRec.UserSign,TmpInfo.UserSign)=0 then
          begin
          TmpChatRec.readok:=true;
          Chat.Update(TmpChatRec);
          if TmpChatRec.sendok then uname:=Wstrpas(MyInfo.uname) else uname:=Wstrpas(TmpInfo.uname);
          addmsgtomemo(TmpChatRec.sendok,TmpChatRec.msgtime,uname,Wstrpas(TmpChatRec.msgtext),TmpFontFormat);
          end;
       finally
       Chat.next;
       end;
    end;
end;

procedure TfrmMessage.downpicrequest(Sender:TObject;var sFileSign:String);
var
 sTmpStr:String;
 TmpInfo:TfirendInfo;
 sFileName:WideString;
begin
  if user.find(FUserSign,TmpInfo) then
  if (Length(TmpInfo.visualize)=34) and (not ImageOle.GetImageFileName(TmpInfo.visualize,sFileName)) then
    begin
    sFileSign:=TmpInfo.visualize;
    end else begin
    if main_memo.GetNeedDownFileSign(sTmpStr) then
      sFileSign:=sTmpStr;
    end;
end;
//------------------------------------------------------------------------------
// 请求方图片完成.
//------------------------------------------------------------------------------
procedure TfrmMessage.downpicclientcomplete(Sender:TObject;sFileSign:String);
begin
  showfirendinfo(false,false);
  main_memo.RichVisibleDraw(true);
  main_memo.ReplacePicture(sFileSign);
  main_memo.RichVisibleDraw(false);
  main_memo.RollToPageEnd;
  downpicture.StratRequestDownPicture;
end;

procedure TfrmMessage.main_memoURLClick(Sender: TObject; const URL: WideString;AStartPos, ALength: Integer);
begin
  if WideFileExists(URL) then opencmd(URL,True) else opencmd(URL);
end;

procedure TfrmMessage.send_memoPaste(Sender: TObject; const URL: WideString);
var
  sTmpStr:String;
begin
  sTmpStr:=ImageOle.AddFileToImageOle(URL,True);
  Send_Memo.InsertImageFile(URL,sTmpStr);
end;

procedure TfrmMessage.main_dropfile(Sender: TObject; const URL: Widestring);
begin
  udpcore.SendDropFile(FUserSign,url);
end;

procedure TfrmMessage.SendFileOnClick(Sender: TObject);
begin
  udpcore.sendmutilfile(FUserSign);
end;

procedure TfrmMessage.RmtControlOnClick(Sender: TObject);
begin
  udpcore.createRemotefrom(FUserSign);
end;

procedure TfrmMessage.VSChatOnClick(Sender: TObject);
begin
  udpcore.createavfrom(FUserSign);
end;

procedure TfrmMessage.SendMsgOnClick(Sender: TObject);
begin
  sendmessager;
end;

procedure TfrmMessage.SendMsgMenuOnClick(Sender: TObject);
var
  mouse:tpoint;
begin
  getcursorpos(mouse);
  SendKeyPopup.Popup(mouse.x,mouse.y);
end;

procedure TfrmMessage.send_memoContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  DialogPopup.PopupComponent:=send_memo;
  ITEM_SaveAs.Enabled:=Handled;
  ITEM_Copy.Enabled:=send_memo.SelLength>0;
  ITEM_Clear.Enabled:=true;
  ITEM_Paste.Enabled:=true;
end;

procedure TfrmMessage.send_memoChange(Sender: TObject);
begin
  send_memo.SetFontFormat(DefaultFontFormat);
  If not JustInput then SendJustInputMsg;
end;

procedure TfrmMessage.main_memoContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  DialogPopup.PopupComponent:=main_memo;
  ITEM_SaveAs.Enabled:=Handled;
  ITEM_Copy.Enabled:=main_memo.SelLength>0;
  ITEM_Clear.Enabled:=false;
  ITEM_Paste.Enabled:=false;
end;

procedure TfrmMessage.main_memoDbclick(Sender: TObject);
begin
  main_memo.RollToPageEnd;
end;

procedure TfrmMessage.main_memoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin   //如果有快捷键,不允许模拟发送键盘.
  if Shift=[] then FAllowSendKey:=True;
end;

procedure TfrmMessage.main_memoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FAllowSendKey then
    begin
    FAllowSendKey:=False;
    Send_Memo.SetFocus;
    keybd_event(key,MapVirtualKey(key,0),0,0);
    keybd_event(key,MapVirtualKey(key,0),KEYEVENTF_KEYUP,0);
    end;
end;
//------------------------------------------------------------------------------
// 表情图标
//------------------------------------------------------------------------------
procedure TfrmMessage.IconOnClick(Sender: TObject);
begin
  if not assigned(phizfrm) then
    phizfrm:=Tphizfrm.Create(Application); 
  phizfrm.ShowIconWindows(FUserSign);
end;

//------------------------------------------------------------------------------
// 设置字体
//------------------------------------------------------------------------------
procedure TfrmMessage.FontOnClick(Sender: TObject);
begin
  ChangeFont(frmFontDialog.Font,DefaultFontFormat);
  if frmFontDialog.Execute then
    begin
    ChangeFontFormat(frmFontDialog.Font,DefaultFontFormat);
    send_memo.SetFontFormat(DefaultFontFormat);
    end;
end;

function GetSelectImageFile(var sFileName:WideString):Boolean;
begin
  Result:=False;
  with TTntOpenDialog.Create(nil) do
    try
    Title:='选择要发送的图片文件';
    Filter:='图片文件|*.bmp;*.jpg;*.jpeg;*.gif;*.png';
    InitialDir:=DefaultOpenDir;
    if execute then
      begin
      Result:=True;
      sFileName:=FileName;
      end;
    finally
    free;
    end;
end;

//------------------------------------------------------------------------------
// 发送图片文件
//------------------------------------------------------------------------------
procedure TfrmMessage.SendImageOnClick(Sender: TObject);
var
  sFileName:Widestring;
  sTmpStr:String;
  TmpPicture:TTntPicture;
begin
  if GetSelectImageFile(sFileName) then
    try
    TmpPicture:=TTntPicture.Create;
    if (getfilesize(sFileName)div 1024)<=2048 then
       begin
        try
        DefaultOpenDir:=WideExtractfilepath(sFileName);
        TmpPicture.LoadFromFile(sFileName);
        sTmpStr:=ImageOle.AddFileToImageOle(sFileName,True);
        send_memo.InsertImageFile(sFileName,sTmpStr);
        send_memo.repaint;
        except
         on EInvalidGraphic do
           TmpPicture:= nil;
        end;
       end else MessageBox(Handle, PChar(MSGBOX_ERROR_IMAGEBIG2MB), PChar(MSGBOX_TYPE_ERROR), MB_ICONERROR);
     finally
       freeandnil(TmpPicture);
     end;
end;

//------------------------------------------------------------------------------
// 截屏
//------------------------------------------------------------------------------
procedure TfrmMessage.CopyScreenOnClick(Sender: TObject);
var
  sTmpStr:String;
  sFilename:WideString;
begin
  if GetCopyScreen(sFilename) then
  if Widefileexists(sFilename) then
    begin
    sTmpStr:=ImageOle.AddFileToImageOle(sFilename);
    send_memo.InsertImageFile(sFilename,sTmpStr);
    end;
end;

//------------------------------------------------------------------------------
// 快捷用语
//------------------------------------------------------------------------------
procedure TfrmMessage.QuickSendOnClick(Sender: TObject);
begin
  PopupAtCursor(ShortCutPopup);
end;

//------------------------------------------------------------------------------
// 快捷回复用语
//------------------------------------------------------------------------------
procedure TfrmMessage.ITEM_ShortCutOnClick(Sender: TObject);
var
  sTmpStr:WideString;
begin
  sTmpStr:=Tmenuitem(sender).hint;
  send_memo.SetFocus;
  JustInput:=True;
  send_memo.Lines.Add(sTmpStr);
  sendmessager;
end;

procedure TfrmMessage.ITEM_ShortCustomClick(Sender: TObject);
begin
  udpcore.ShowSystemConfig(2);
end;

procedure TfrmMessage.ShortCutPopupPopup(Sender: TObject);
var
  i:integer;
  TmpStr:Widestring;
  TmpItem:Tmenuitem;
begin
  ShortCutPopup.Items.Clear;
  if QuickReplymemo.Count>0 then
  for i:=1 to QuickReplymemo.Count do
    begin
    TmpStr:=QuickReplymemo.Strings[i-1];
    TmpItem:=Tmenuitem.Create(nil);
    if length(TmpStr)>16 then
       TmpItem.Caption:=Copy(TmpStr,1,16)+'..'
       else TmpItem.Caption:=TmpStr;
    TmpItem.Hint:=TmpStr;
    TmpItem.OnClick:=ITEM_ShortCutOnClick;
    ShortCutPopup.Items.Add(TmpItem);
    end;
  TmpItem:=Tmenuitem.Create(nil);
  TmpItem.Caption:='-';
  ShortCutPopup.Items.Add(TmpItem);
  TmpItem:=Tmenuitem.Create(nil);
  TmpItem.Caption:='自定义快捷回复信息...';
  TmpItem.OnClick:=ITEM_ShortCustomClick;
  ShortCutPopup.Items.Add(TmpItem);
end;

procedure TfrmMessage.SendJustInputMsg;
var
  sParams:WideString;
begin
 if length(send_memo.Text)>2 then
   begin
   JustInput:=True;
   CheckInputTimer.Enabled:=True;
   //---------------------------------------------------------------------------
   //发送键盘状态
   //---------------------------------------------------------------------------
    AddValueToNote(sParams,'function',Message_Function);
    AddValueToNote(sParams,'operation',UserTextStatus_Operation);
    AddValueToNote(sParams,'UserSign',LoginUserSign);
    AddValueToNote(sParams,'bActive',True);
    udpcore.SendServertransfer(sParams,FUserSign);
   end;
end;

procedure TfrmMessage.JustInputimpact(bActive:Boolean);
var
  TmpInfor:Tfirendinfo;
begin
  if user.find(FUserSign,TmpInfor) then
  if bActive then
     Lab_FormCaption.Caption:=ConCat(WStrPas(TmpInfor.uname),'('+TmpInfor.userid,') 正在输入...')
     else Lab_FormCaption.Caption:=ConCat(WStrPas(TmpInfor.uname),'(',TmpInfor.userid,')');
end;

//------------------------------------------------------------------------------
// Frame 初始化过程
//------------------------------------------------------------------------------
procedure TfrmMessage.InitialFrameProcess;
begin
  Lab_SendFile.OnClick:=SendFileOnClick;
  Lab_RmtControl.OnClick:=RmtControlOnClick;
  Lab_VSChat.OnClick:=VSChatOnClick;
  Lab_SendMsg.OnClick:=SendMsgOnClick;
  Lab_SendMsgMenu.OnClick:=SendMsgMenuOnClick;
  SendKeyAction.OnExecute:=SendMsgOnClick;
  if pressenter_send then SendKeyAction.ShortCut:=ShortCut(13,[])
     else SendKeyAction.ShortCut:=ShortCut(13,[ssCtrl]);
  main_memo.InitRichEditOle(True);
  send_memo.InitRichEditOle(False);
  send_memo.OnContextPopup:=send_memoContextPopup;
  send_memo.OnChange:=send_memoChange;
  send_memo.PopupMenu:=DialogPopup;
  main_memo.PopupMenu:=DialogPopup;
  main_memo.OnContextPopup:=main_memoContextPopup;
  main_memo.OnKeyDown:=main_memoKeyDown;
  main_memo.OnKeyUp:=main_memoKeyUp;
  main_memo.OnURLClick:=main_memoURLClick;
  main_memo.OnDblClick:=main_memoDbclick;
  send_memo.OnPasteImage:=send_memoPaste;
  send_memo.OnChange:=send_memoChange;
  send_memo.OnDropFile:=main_dropfile;
  send_memo.OnURLClick:=main_memoURLClick;
  Tsb_Icon.OnClick:=IconOnClick;
  Tsb_Font.OnClick:=FontOnClick;
  Tsb_SendImage.OnClick:=SendImageOnClick;
  Tsb_CopyScreen.OnClick:=CopyScreenOnClick;
  Tsb_QuickSend.OnClick:=QuickSendOnClick;
  FrmSunExpandWorkForm.Lab_Button_ViewUserInfo.OnClick:= ViewUserInfoClick;
  Lab_FormCaption.OnClick:=ViewUserInfoClick;
end;

//------------------------------------------------------------------------------
// 显示详细资料
//------------------------------------------------------------------------------
procedure TfrmMessage.ViewUserInfoClick(Sender: TObject);
begin
{  AddValueToNote(sParams,'msgid',xy_user);
  AddValueToNote(sParams,'funid',xy_detail);
  AddValueToNote(sParams,'userid',loginuser);
  udpcore.SendServertransfer(sParams,FUserSign);   }
  udpcore.showfirendinfo(FUserSign);
end;

procedure TfrmMessage.CheckInputTimerTimer(Sender: TObject);
var
  sParams:WideString;
begin
  JustInput:=False;
  CheckInputTimer.Enabled:=False;
  //---------------------------------------------------------------------------
  //发送键盘状态
  //---------------------------------------------------------------------------
  AddValueToNote(sParams,'function',Message_Function);
  AddValueToNote(sParams,'operation',UserTextStatus_Operation);
  AddValueToNote(sParams,'UserSign',LoginUserSign);
  AddValueToNote(sParams,'bActive',False);
  udpcore.SendServertransfer(sParams,FUserSign);
end;

procedure TfrmMessage.TntFormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if (length(send_memo.Text)>0)or
    FrmSunExpandWorkForm.ExistsRemotePage or
    FrmSunExpandWorkForm.ExistsVideoSound or
    FrmSunExpandWorkForm.ExistsTransfersPage then
    begin
    if MessageBox(handle,pchar('正在聊天，传输文件或语音视频当中，真的要关闭吗？'),
      pchar('提示'),MB_OKCANCEL or MB_ICONINFORMATION)=1 then
      CanClose:=True else CanClose:=False;
    end else CanClose:=True;
end;

procedure TfrmMessage.FormDestroy(Sender: TObject);
begin
  event.RemoveEventProcess(MessageEvent);
  inherited;  
end;

end.
