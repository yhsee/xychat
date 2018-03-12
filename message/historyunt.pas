unit historyunt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, ExtCtrls, StdCtrls,historyframe,SunIMTreeList,
  constunt,structureunt, Menus,RichEditCommUnt,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus,TntButtons,TntDialogs;

type
  TTntForm = class(THistoryframe);
  THistoryFrm = class(TTntForm)
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams);override;
  private
    TotalRecord:Int64; 
    curpage:integer;
    UserSign:string;
    procedure Createuserlist;
    procedure ClearchatLog;
    procedure ShowFirendMsg;
    procedure AddMsgtoMemo(isme:boolean;dt:tdatetime;firendname:string;msg:Widestring);
    procedure SaveChattoLog(filename:widestring);
    procedure IMG_SavelogClick(Sender: TObject);
    procedure IMG_ClearlogClick(Sender: TObject);
    procedure Image_NextClick(Sender: TObject);
    procedure Image_PreviousClick(Sender: TObject);
    procedure Image_StartClick(Sender: TObject);
    procedure Image_OverClick(Sender: TObject);
    procedure Si_IMUserListClick(Sender: TObject);
    procedure createbutton(firendinfo:Tfirendinfo);
    procedure createheader(groupid:WideString);
    { Private declarations }
  public
    procedure showfirendrecord(sfirendid:string);
    { Public declarations }
  end;

var
  HistoryFrm: THistoryFrm;

implementation
uses UdpCores, ShareUnt,userunt,chatrec;
{$R *.DFM}

procedure THistoryFrm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDeskTopWindow;
end;

procedure THistoryFrm.CreateButton(firendinfo:Tfirendinfo);
var uiUserInfo : TUserInfo;
begin
//插入联系人
  Si_IMUserList.ClearTUserInfo(uiUserInfo);//这里修正一个错误，就是插入记录时要先做记录初始化
  uiUserInfo.ID := firendinfo.userid;
  uiUserInfo.NickName := firendinfo.uname;
  uiUserInfo.State := firendinfo.status;
  if firendinfo.Sex=SEX_TAG_WOMEN then uiUserInfo.Sex := 1 else uiUserInfo.Sex:=0;
  Si_IMUserList.AddUser(firendinfo.gname, uiUserInfo);
end;

procedure THistoryFrm.createheader(groupid:WideString);
begin
with Si_IMUserList do
  AddGroup(groupid,false,GetGroupNode(SysBlacklist));
end;

//------------------------------------------------------------------------------
// 建立用户列表
//------------------------------------------------------------------------------
procedure THistoryFrm.createUserList;
var
  TmpInfor:Tfirendinfo;
begin
  user.first;
  while not user.eof do
    try
      if user.GetCurUserInfo(TmpInfor) then
      if CompareText(TmpInfor.userid,loginuser)<>0 then
        begin
        createheader(TmpInfor.gname);
        createbutton(TmpInfor);
        end;
    finally
    user.Next;
    end;
  Image_Start.Enabled:=False;
  Image_Over.Enabled:=False;
  Image_Next.Enabled:=False;
  Image_Previous.Enabled:=False;
  Si_IMUserList.Items[0].Expanded := True;
  Lab_PageInfo.Caption:='(0-0页)';
end;

//------------------------------------------------------------------------------
// 添加消息到 main_memo
//------------------------------------------------------------------------------
procedure THistoryFrm.addmsgtomemo(isme:boolean;dt:tdatetime;firendname:string;msg:Widestring);
var
  iStart:Integer;
  TmpFontFormat:TFontFormat;
begin
  TmpFontFormat:=InitFontFormat;
  iStart:=Length(main_memo.Text);
  main_memo.RollToLineEnd(True);
  main_memo.FontUserNameFormat(isme);
  main_memo.Lines.add(firendname+'('+datetimetostr(dt)+')');
  main_memo.FontMessageFormat(TmpFontFormat);
  main_memo.RichVisibleDraw(true);
  main_memo.lines.add(msg);
  main_memo.FormatTextToOle(iStart);
  main_memo.RichVisibleDraw(false);
  main_memo.RollToLineEnd(False);
end;

//------------------------------------------------------------------------------
// 显示当前用户的聊天记录
//------------------------------------------------------------------------------
procedure THistoryFrm.ShowFirendMsg;
var pPage,cPage:integer;
    tmp:tchatrec;
    p,q:Tfirendinfo;
    uname:WideString;
begin
  TotalRecord := 0;
  if curpage<1 then curpage:=1;
  main_memo.InitRichEditOle(True);
  if user.Find(UserSign,p) and user.Find(loginusersign,q) then  
     begin
     chat.First;
     while not chat.Eof do
       try
        if chat.GetCurChatRecInfo(Tmp) then 
        if (tmp.UserSign=UserSign) then
          begin
          inc(TotalRecord);
          if tmp.sendok then uname:=wstrpas(q.uname) else uname:=wstrpas(p.uname);
          if (TotalRecord>=curpage)and(TotalRecord<curpage+10) then
          addmsgtomemo(tmp.sendok,tmp.msgtime,uname,wstrpas(tmp.msgtext));
          end;
       finally
       chat.Next;
       end;
     end;
  Image_Next.Enabled:=curpage+10<=TotalRecord;
  Image_Previous.Enabled:=Curpage>1;
  Image_Start.Enabled:=Image_Previous.Enabled;
  Image_Over.Enabled:=Image_Next.Enabled;
  pPage:=curpage div 10;
  if TotalRecord>0 then inc(pPage);
  cPage:=TotalRecord div 10;
  if (TotalRecord mod 10)>0 then inc(cPage);
  Lab_PageInfo.Caption:=format('(%d-%d页)',[pPage,cPage]);
end;


//------------------------------------------------------------------------------
// 导出聊天记录
//------------------------------------------------------------------------------
procedure THistoryFrm.savechattolog(filename:widestring);
var
  tmp:tchatrec;
  p:Tfirendinfo;
  TmpList:tTntstringlist;
begin
try
TmpList:=tTntstringlist.create;
if user.Find(UserSign,p) then
  begin
  chat.First;
  while not chat.eof do
     try
     if chat.GetCurChatRecInfo(Tmp) then
     if (tmp.UserSign=UserSign) then
       begin
       TmpList.add(ConCat(Wstrpas(p.uname),'(',datetimetostr(tmp.msgtime),')'));
       TmpList.add(Wstrpas(tmp.msgtext));
       TmpList.add(#13#10);
       end;
     finally
     chat.next;
     end;
  end;
finally
TmpList.SaveToFile(filename);
freeandnil(TmpList);
end;
end;

//------------------------------------------------------------------------------
// 清除聊天记录
//------------------------------------------------------------------------------
procedure Thistoryfrm.clearchatlog;
var TmpStr:String;
    p:Tfirendinfo;
begin

  if user.find(UserSign,p) then
      begin
        TmpStr:=Format(MSGBOX_CONFIG_CLEARCHATHISTORY,[p.uname]);

        if Messagebox(Handle, PChar(TmpStr), PChar(MSGBOX_TYPE_CONFIG), MB_ICONQUESTION+MB_YESNO)=ID_NO then Exit;

        if Chat.ClearChatrecList(UserSign) then
        begin
          Messagebox(Handle, PChar(MSGBOX_INFORMATION_CLEARCHATHISTORYSUCCESS), PChar(MSGBOX_TYPE_INFO), MB_ICONINFORMATION);
          ShowFirendMsg;
        end
        else Messagebox(Handle, PChar(MSGBOX_ERROR_CLEARCHATHISTORY), PChar(MSGBOX_TYPE_ERROR), MB_ICONERROR);
      end;

end;

procedure THistoryFrm.FormShow(Sender: TObject);
begin
Si_IMUserList.ClearAlllist;
Si_IMUserList.AddGroup(SysFirendlist, True);
Si_IMUserList.AddGroup(SysBlacklist, True);
Si_IMUserList.ItemHeigth := 22;
createuserlist;
end;

procedure THistoryFrm.Image_StartClick(Sender: TObject);
begin
curpage:=1;
showfirendmsg;
end;

procedure THistoryFrm.Image_OverClick(Sender: TObject);
begin
curpage:=TotalRecord-9;
if (TotalRecord mod 10)>0 then
   curpage:=(TotalRecord div 10)*10+1;
showfirendmsg;
end;

procedure THistoryFrm.Image_NextClick(Sender: TObject);
begin
inc(curpage,10);
showfirendmsg;
end;

procedure THistoryFrm.Image_PreviousClick(Sender: TObject);
begin
  inc(Curpage, -10);
  ShowFirendMsg;
end;

procedure THistoryFrm.IMG_SavelogClick(Sender: TObject);
var logfilename:widestring;
begin
if UserSign<>'' then
with TTntsavedialog.create(nil) do
   try
   Filter:='文本文件|*.txt';
   InitialDir:=wideextractfilepath(application_name);
   if execute then
      begin
      logfilename:=widechangefileext(filename,'.txt');
      savechattolog(logfilename);
      end;
   finally
   free;
   end;
end;

procedure THistoryFrm.IMG_ClearlogClick(Sender: TObject);
begin
clearchatlog;
end;

procedure THistoryFrm.Si_IMUserListClick(Sender: TObject);
begin
if assigned(Si_IMUserList.Selected) then
if Si_IMUserList.Selected.Level=1 then
   begin
   UserSign:=Si_IMUserList.GetSelectedUserInfo(Si_IMUserList.Selected).ID;
   Image_Next.Enabled:=True;
   Image_Previous.Enabled:=False;
   TotalRecord:=0;
   curpage:=1;
   showfirendmsg;
   end;
end;

procedure THistoryFrm.showfirendrecord(sfirendid:string);
var
  TmpInfor:TFirendInfo;
begin
if user.find(sfirendid,TmpInfor) then
   begin
    UserSign:=sfirendid;
    Image_Next.Enabled:=True;
    Image_Previous.Enabled:=False;
    TotalRecord:=0;
    curpage:=1;
    showfirendmsg;
   end;
end;

procedure THistoryFrm.FormCreate(Sender: TObject);
begin
inherited;
main_memo.InitRichEditOle(True);
IMG_Savelog.OnClick:=IMG_SavelogClick;
IMG_Clearlog.OnClick:=IMG_ClearlogClick;
Image_Start.OnClick:=Image_StartClick;
Image_Over.OnClick:=Image_OverClick;
Image_Next.OnClick:=Image_NextClick;
Image_Previous.OnClick:=Image_PreviousClick;
//------------------------------------------------------------------------------
// 初始化列表...
//------------------------------------------------------------------------------
Si_IMUserList.ImageList :=  Udpcore.ImgList;
Si_IMUserList.IMAGE_GROUP_NONEXPANDED := 0;
Si_IMUserList.IMAGE_GROUP_EXPANDED := 1;
Si_IMUserList.IMAGE_MAN_ONLINE := 2;
Si_IMUserList.IMAGE_MAN_OFFLINE := 3;
Si_IMUserList.IMAGE_MAN_LEAVE := 4;
Si_IMUserList.IMAGE_WOMEN_ONLINE := 5;
Si_IMUserList.IMAGE_WOMEN_OFFLINE := 6;
Si_IMUserList.IMAGE_WOMEN_LEAVE := 7;
Si_IMUserList.AddGroup(SysFirendlist, True);
Si_IMUserList.AddGroup(SysBlacklist, True);
Si_IMUserList.ItemHeigth := 22;
Si_IMUserList.OnClick:=Si_IMUserListClick;
end;

end.
