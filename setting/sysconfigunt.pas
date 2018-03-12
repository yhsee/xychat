unit sysconfigunt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,mmsystem,
  StdCtrls, ComCtrls, ExtCtrls,inifiles, Buttons, Menus,Gifimage,pngimage,jpeg,
  syshot, Mask, constunt, Spin, Settings,TntWideStrUtils;

type
  TTntForm = class(TFrmSettings);
  Tsysconfig = class(TTntForm)
    procedure CreateParams(var Params: TCreateParams);override;
    procedure FormCreate(Sender: TObject);
  private
    procedure InitialEvent;
    procedure InitialMyinfo;
    procedure InitialBaseinfo;
    procedure InitialStatusinfo;
    procedure ApplyCurSeting;
    procedure SaveMyinfo;
    procedure SaveBaseinfo;
    procedure SaveStatusinfo;
    procedure SaveWaveinfo;
    procedure SaveSafeinfo;
    { Private declarations }
  protected
    procedure But_YesClick(Sender: TObject);
    procedure But_ApplyClick(Sender: TObject);
    procedure Lab_SetMyImageClick(Sender: TObject);
    procedure But_PlaySoundClick(Sender: TObject);
    procedure Be_SoundPathButtonClick(Sender: TObject);
    procedure Ls_SoundTypeListClick(Sender: TObject);
    procedure But_ChangePassClick(Sender: TObject);
    procedure But_AddAutoReplyClick(Sender: TObject);
    procedure But_DelAutoReplyClick(Sender: TObject);
    procedure But_AddQuickReplyClick(Sender: TObject);
    procedure But_DelQuickReplyClick(Sender: TObject);
    procedure Cmb_AutoReplyIndexSelect(Sender: TObject);
    procedure Cmb_QuickReplyIndexSelect(Sender: TObject);
  public
    { Public declarations }
  end;


implementation

uses udpcores, structureunt,ShareUnt,md5unt,SimpleXmlUnt,UserUnt,ImageOleUnt,eventunt,eventcommonunt;

{$R *.DFM}

procedure Tsysconfig.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent:=GetDeskTopWindow;
end;


procedure Tsysconfig.FormCreate(Sender: TObject);
begin
  inherited;
  InitialEvent;
  InitialMyinfo;
  InitialBaseinfo;
  InitialStatusinfo;
end;

procedure Tsysconfig.But_YesClick(Sender: TObject);
begin
  if But_Apply.Enabled then ApplyCurSeting;
  close;
end;

procedure Tsysconfig.But_ApplyClick(Sender: TObject);
begin
  ApplyCurSeting;
end;

procedure Tsysconfig.ApplyCurSeting;
begin
  But_Apply.Enabled:=False;
  Case Ls_Options.ItemIndex of
    0:SaveMyinfo;
    1:SaveBaseinfo;
    2:SaveStatusinfo;
    3:SaveWaveinfo;
    4:SaveSafeinfo;
    end;
end;

procedure Tsysconfig.SaveMyinfo;
var
  MyInfo:Tfirendinfo;
begin
  if (Ed_NickName.Text<>'') then
  if user.Find(LoginUserSign,MyInfo) then
    begin
    myinfo.visualize:=Img_Self.Hint;    
    WStrPCopy(myinfo.sex,Cmb_Sex.text);
    WStrPCopy(myinfo.age,Ed_Age.text);
    WStrPCopy(myinfo.uname,Ed_NickName.text);
    WStrPCopy(myinfo.area,Ed_Address.text);
    WStrPCopy(myinfo.constellation,Cmb_Constellation.Text);
    WStrPCopy(myinfo.mytext,Ed_Memo.Text);
    WStrPCopy(myinfo.Communication,Ed_Communication.Text);
    WStrPCopy(myinfo.Phone,Ed_Phone.text);
    WStrPCopy(myinfo.qqmsn,Ed_QQMSN.text);
    WStrPCopy(myinfo.Email,Ed_Email.Text);
    WStrPCopy(myinfo.signing,Memo_Signing.text);
    user.Update(MyInfo);
    event.CreateMainEvent(Refresh_UserStatus_Event,LoginUserSign,'');
    end;
end;

procedure Tsysconfig.SaveBaseinfo;
begin
  systemhot_key:=Hotkey_SysHotkey.HotKey;
  bosshot_key:=Hotkey_HideHotkey.HotKey;
  winstart_run:=Chk_BootWithWin.Checked;
  frmAutoHide:=Chk_AutoDockHide.Checked;
  newpictext_ok:=Chk_UseImageChar.Checked;
  newmsg_popup:=Chk_AutoPopChat.Checked;
  closetomin:=Chk_CloseToTray.Checked;
  starting_mini:=Chk_StartMini.Checked;
  file_supervention:=Chk_AutoContinueTsf.Checked;
  udpcore.recreate_hotkey;
end;

procedure Tsysconfig.SaveStatusinfo;
var i:integer;
    TmpStr:string;
begin
  allow_auto_status:=Chk_AutoChangeState.Checked;
  auto_status:=Cmb_AutoChangeState_State.ItemIndex+1;
  status_outtime:=Se_AutoChangeState_Times.Value;

  AutoReplymemo.Clear;
  for i:=1 to Cmb_AutoReplyIndex.Items.Count do
   begin
   TmpStr:=Cmb_AutoReplyIndex.Items.Strings[i-1];
   if TmpStr<>'' then AutoReplymemo.Add(TmpStr);
   end;

  QuickReplymemo.clear;
  for i:=1 to Cmb_QuickReplyIndex.Items.Count do
   begin
   TmpStr:=Cmb_QuickReplyIndex.Items.Strings[i-1];
   if TmpStr<>'' then QuickReplymemo.Add(TmpStr);
   end;

  if Memo_AutoReply.Text<>'' then
  revertmsg:=Memo_AutoReply.Text
  else if AutoReplymemo.Count>0 then
  revertmsg:=AutoReplymemo.Strings[0];

  if not Chk_AutoReplyInfo.Checked then revertmsg:='';
end;

procedure Tsysconfig.SaveWaveinfo;
begin
Allow_Playwave:=Chk_OpenSound.Checked;
case Ls_SoundTypeList.ItemIndex of
  0:ClientMsg_WaveFile:=Be_SoundPath.Text;
  1:SystemMsg_WaveFile:=Be_SoundPath.Text;
  2:NewFirend_WaveFile:=Be_SoundPath.Text;
  end;
end;

procedure Tsysconfig.SaveSafeinfo;
var
  myinfo:Tfirendinfo;
begin
  if user.Find(LoginUserSign,MyInfo) then
    begin
    if Rb_AllAdd.Checked then myinfo.checkup:=0;
    if Rb_CheckAdd.Checked then myinfo.checkup:=1;
    if Rb_NonAdd.Checked then myinfo.checkup:=2;
    user.Update(myinfo);
    udpcore.changemyinfo;
    end;
end;

procedure Tsysconfig.Lab_SetMyImageClick(Sender: TObject);
var img_path,newfilename:string;
begin
with topendialog.Create(nil) do
   try
   Title:='图片大小(120*120)';
   Filter:='图片文件|*.bmp;*.jpg;*.jpeg;*.gif';
   img_path:=extractfilepath(application_name)+'UserData\'+loginuser+'\images\';
   InitialDir:=img_path;
   if execute then
     try
     Img_Self.Picture.loadfromfile(filename);
     Img_Self.Hint:='{'+md5encodefile(filename)+'}';
     if (extractfilepath(filename)<>img_path)
        and (not ImageOle.CheckImageExists(Img_Self.Hint)) then
        begin
        newfilename:=img_path+Img_Self.Hint+extractfileext(filename);
        if not fileexists(newfilename) then
           copyfile(pchar(filename),pchar(newfilename),true);
        ImageOle.AddFileToImageOle(newfilename);
        But_Apply.Enabled:=True;
        end;
     except
      on EInvalidGraphic do
         Img_Self.Picture:= nil;
     end;
   finally
   free;
   end;
end;

procedure Tsysconfig.But_PlaySoundClick(Sender: TObject);
begin
udpcore.playwave(Be_SoundPath.Text);
end;

procedure Tsysconfig.Be_SoundPathButtonClick(Sender: TObject);
begin
with topendialog.Create(nil) do
   try
   Filter:='声音文件|*.wav';
   InitialDir:=extractfilepath(application_name)+'sound\';
   if execute then Be_SoundPath.Text:=filename;
   finally
   free;
   end;
end;

procedure Tsysconfig.Ls_SoundTypeListClick(Sender: TObject);
begin
case Ls_SoundTypeList.ItemIndex of
  0:Be_SoundPath.Text:=ClientMsg_WaveFile;
  1:Be_SoundPath.Text:=SystemMsg_WaveFile;
  2:Be_SoundPath.Text:=NewFirend_WaveFile;
  end;
end;

procedure Tsysconfig.But_ChangePassClick(Sender: TObject);
var
  msgex:WideString;
begin
if (Ed_OldPassword.Text<>'')and(Ed_NewPassword.text<>'') then
if (Ed_OldPassword.Text<>Ed_NewPassword.Text) then
if (Ed_NewPassword.Text=Ed_ConfigPassword.Text) then
   begin
{   AddValueToNote(msgex,'msgid',xy_user);
   AddValueToNote(msgex,'funid',xy_change);
   AddValueToNote(msgex,'userid',loginuser);
   AddValueToNote(msgex,'oldpwd',md5encode(Ed_OldPassword.text));
   AddValueToNote(msgex,'newpwd',md5encode(Ed_NewPassword.text));    }
   udpcore.sendserver(msgex);
   Ed_OldPassword.text:='';
   Ed_NewPassword.text:='';
   Ed_ConfigPassword.Text:='';
   end;
end;

procedure Tsysconfig.But_AddAutoReplyClick(Sender: TObject);
var n:integer;
begin
if Memo_AutoReply.Text<>'' then
   begin
   n:=Cmb_AutoReplyIndex.ItemIndex;
   Cmb_AutoReplyIndex.Items.Strings[n]:=Memo_AutoReply.Text;
   Memo_AutoReply.Clear;
   Cmb_AutoReplyIndex.Items.Add(inttostr(Cmb_AutoReplyIndex.Items.Count+1));
   Cmb_AutoReplyIndex.ItemIndex:=Cmb_AutoReplyIndex.Items.Count-1;
   end
   else MessageBox(Handle, PChar(MSGBOX_ERROR_SYSSETLEAVEWORDNULL), PChar(MSGBOX_TYPE_ERROR), MB_ICONERROR);
end;

procedure Tsysconfig.But_DelAutoReplyClick(Sender: TObject);
var i:integer;
begin
if Cmb_AutoReplyIndex.Items.count>0 then
   begin
   Cmb_AutoReplyIndex.DeleteSelected;
   for i:=1 to Cmb_AutoReplyIndex.Items.count do
     Cmb_AutoReplyIndex.Items.Strings[i-1]:=inttostr(i);
   if Cmb_AutoReplyIndex.Items.Count>0 then
      begin
      Cmb_AutoReplyIndex.Itemindex:=Cmb_AutoReplyIndex.Items.Count-1;
      Cmb_AutoReplyIndex.OnSelect(nil);
      end;
   end;
end;

procedure Tsysconfig.But_AddQuickReplyClick(Sender: TObject);
var n:integer;
begin
if Memo_QuickReply.Text<>'' then
   begin
   n:=Cmb_QuickReplyIndex.ItemIndex;
//   Cmb_QuickReplyIndex.Values[n]:=Memo_QuickReply.Text;
   Memo_QuickReply.Clear;
   Cmb_QuickReplyIndex.Items.Add(inttostr(Cmb_QuickReplyIndex.Items.Count+1));
   Cmb_QuickReplyIndex.ItemIndex:=Cmb_QuickReplyIndex.Items.Count-1;
   end
   else MessageBox(Handle, PChar(MSGBOX_ERROR_SYSSETLEAVEWORDNULL), PChar(MSGBOX_TYPE_ERROR), MB_ICONERROR);
end;

procedure Tsysconfig.But_DelQuickReplyClick(Sender: TObject);
var i:integer;
begin
if Cmb_QuickReplyIndex.Items.count>0 then
   begin
   Cmb_QuickReplyIndex.DeleteSelected;
   for i:=1 to Cmb_QuickReplyIndex.Items.count do
     Cmb_QuickReplyIndex.Items.Strings[i-1]:=inttostr(i);
   if Cmb_QuickReplyIndex.Items.Count>0 then
      begin
      Cmb_QuickReplyIndex.itemindex:=Cmb_QuickReplyIndex.Items.Count-1;
      Cmb_QuickReplyIndex.OnSelect(nil);
      end;
   end;
end;

procedure Tsysconfig.Cmb_AutoReplyIndexSelect(Sender: TObject);
var n:integer;
begin
n:=Cmb_AutoReplyIndex.ItemIndex;
//Memo_AutoReply.Text:=Cmb_AutoReplyIndex.Values.Strings[n];
end;

procedure Tsysconfig.Cmb_QuickReplyIndexSelect(Sender: TObject);
var n:integer;
begin
n:=Cmb_QuickReplyIndex.ItemIndex;
//Memo_QuickReply.Text:=Cmb_QuickReplyIndex.Values.Strings[n];
end;

procedure Tsysconfig.InitialEvent;
begin
But_Apply.OnClick:=But_ApplyClick;
But_Yes.OnClick:=But_YesClick;
Lab_SetMyImage.OnClick:=Lab_SetMyImageClick;
But_PlaySound.OnClick:=But_PlaySoundClick;
Be_SoundBtn.OnClick:=Be_SoundPathButtonClick;
Ls_SoundTypeList.OnClick:=Ls_SoundTypeListClick;
But_ChangePass.OnClick:=But_ChangePassClick;
But_AddAutoReply.OnClick:=But_AddAutoReplyClick;
But_DelAutoReply.OnClick:=But_DelAutoReplyClick;
But_AddQuickReply.OnClick:=But_AddQuickReplyClick;
But_DelQuickReply.OnClick:=But_DelQuickReplyClick;
Cmb_AutoReplyIndex.OnSelect:=Cmb_AutoReplyIndexSelect;
Cmb_QuickReplyIndex.OnSelect:=Cmb_QuickReplyIndexSelect;
end;

procedure Tsysconfig.InitialMyinfo;
var
  myinfo:Tfirendinfo;
  sFileName:WideString;
begin
  if not user.find(loginusersign,myinfo) then exit;
  Ed_UserID.Text:=loginuser;
  Ed_NickName.Text:=myinfo.uname;
  Ed_Age.Text:=myinfo.age;
  Ed_Communication.Text:=myinfo.Communication;
  Ed_Phone.Text:=myinfo.Phone;
  Ed_QQMSN.text:=myinfo.qqmsn;
  Ed_Email.text:=myinfo.email;
  Ed_Memo.text:=myinfo.mytext;
  Ed_Address.Text:=myinfo.area;
  Memo_Signing.Text:=myinfo.signing;
  Cmb_Sex.ItemIndex:=Cmb_Sex.items.IndexOf(myinfo.sex);
  Cmb_Constellation.ItemIndex:=Cmb_Constellation.items.IndexOf(myinfo.constellation);
  case myinfo.checkup of
    0:Rb_AllAdd.Checked:=true;
    1:Rb_CheckAdd.Checked:=true;
    2:Rb_NonAdd.Checked:=true;
    end;
  if not ImageOle.GetImageFileName(myinfo.visualize,sFileName) then sFileName:=userdefpic;
    try
    Img_Self.Picture.LoadFromFile(sFileName);
    Img_Self.Hint:=myinfo.visualize;
    except
      on EInvalidGraphic do
         Img_Self.Picture:= nil;
    end;
end;

procedure Tsysconfig.InitialBaseinfo;
begin
Hotkey_SysHotkey.HotKey:=systemhot_key;
Hotkey_HideHotkey.HotKey:=bosshot_key;

Chk_BootWithWin.Checked:=winstart_run;
Chk_AutoDockHide.Checked:=frmAutoHide;
Chk_UseImageChar.Checked:=newpictext_ok;
Chk_AutoPopChat.Checked:=newmsg_popup;
Chk_CloseToTray.Checked:=closetomin;
Chk_AutoContinueTsf.Checked:=file_supervention;
Chk_OpenSound.Checked:=Allow_Playwave;
Chk_StartMini.Checked:=starting_mini;
end;

procedure Tsysconfig.InitialStatusinfo;
var i:integer;
begin
Chk_AutoChangeState.Checked:=allow_auto_status;
Chk_AutoReplyInfo.Checked:=revertmsg<>'';

Cmb_AutoReplyIndex.Clear;
if AutoReplymemo.Count>0 then
  begin
//  for i:=1 to AutoReplymemo.Count do
 //   Cmb_AutoReplyIndex.Items.Add(inttostr(i),AutoReplymemo.Strings[i-1]);
  if Chk_AutoReplyInfo.Checked then
  Cmb_AutoReplyIndex.ItemIndex:=AutoReplymemo.IndexOf(revertmsg)
  else Cmb_AutoReplyIndex.ItemIndex:=0;
  Cmb_AutoReplyIndex.OnSelect(nil);
  end;

Cmb_QuickReplyIndex.Clear;
if QuickReplymemo.Count>0 then
  begin
//  for i:=1 to QuickReplymemo.Count do
//    Cmb_QuickReplyIndex.AddItemValue(inttostr(i),QuickReplymemo.Strings[i-1]);
  Cmb_QuickReplyIndex.ItemIndex:=0;
  Cmb_QuickReplyIndex.OnSelect(nil);
  end;

Cmb_AutoChangeState_State.ItemIndex:=auto_status-1;
Se_AutoChangeState_Times.Value:=status_outtime;
end;

end.
