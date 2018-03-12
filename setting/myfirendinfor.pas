unit myfirendinfor;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons,Gifimage,pngimage,jpeg,TntWideStrUtils,
  ViewUserInformation,ComCtrls,constunt;

type
  TtntForm=class(TFrmViewUserInformation);
  Tmyfirend_infor = class(TtntForm)
    procedure FormShow(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams);override;
  private
    FUserSign:WideString;
    procedure refresh_infor;
    procedure CloseForm(Sender: TObject);
    procedure ModifyUserInfor(Sender: TObject);
    { Private declarations }
  public
    procedure ShowSearchInfor(P:Pointer);
    { Public declarations }
  published
    property UserSign:WideString Write FUserSign;
  end;

var
  myfirend_infor: Tmyfirend_infor;

implementation
uses structureunt,ShareUnt,SimpleXmlUnt,userunt,udpcores,ImageOleUnt,eventunt,eventcommonunt;
{$R *.DFM}

procedure Tmyfirend_infor.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDeskTopWindow;
end;

procedure Tmyfirend_infor.refresh_infor;
var
  TmpInfo:Tfirendinfo;
  sFileName:WideString;
begin
if user.Find(FUserSign,TmpInfo) then
  begin
  Communication.text:=TmpInfo.Communication;
  constellation.text:=TmpInfo.constellation;
  phone.Text:=TmpInfo.Phone;
  email.Text:=TmpInfo.email;
  qqmsn.Text:=TmpInfo.qqmsn;
  area.Text:=TmpInfo.area;
  mytext.Text:=TmpInfo.mytext;
  uid.Text:=TmpInfo.userid;
  age.Text:=TmpInfo.age;
  uname.text:=TmpInfo.uname;
  sex.text:=TmpInfo.sex;
  signing.text:=TmpInfo.signing;
  caption:=TmpInfo.uname+' 的资料';
  Lab_FormCaption.Caption:=TmpInfo.uname+' 的资料';
  if not ImageOle.GetImageFileName(TmpInfo.visualize,sFileName) then
     sFileName:=userdefpic;
  try
  myimg.Picture.LoadFromFile(sFileName);
  except
    on EInvalidGraphic do
       myimg.Picture:= nil;
  end;
  end;
end;

procedure Tmyfirend_infor.FormShow(Sender: TObject);
var
  bOnlyRead:Boolean;
begin
  bOnlyRead:=CompareText(FUserSign,LoginUserSign)=0;
  Image_close.OnClick:=CloseForm;
  Image_yes.OnClick:=ModifyUserInfor;
  Communication.ReadOnly:=not bOnlyRead;
  constellation.ReadOnly:=not bOnlyRead;
  phone.ReadOnly:=not bOnlyRead;
  email.ReadOnly:=not bOnlyRead;
  qqmsn.ReadOnly:=not bOnlyRead;
  area.ReadOnly:=not bOnlyRead;
  mytext.ReadOnly:=not bOnlyRead;
  age.ReadOnly:=not bOnlyRead;
  uname.ReadOnly:=not bOnlyRead;
  sex.ReadOnly:=not bOnlyRead;
  signing.ReadOnly:=not bOnlyRead;
  if not bOnlyRead then
     begin
     sex.Color:=$00F2F2F2;
     age.Color:=$00F2F2F2;
     area.Color:=$00F2F2F2;
     uname.Color:=$00F2F2F2;
     phone.Color:=$00F2F2F2;
     email.Color:=$00F2F2F2;
     qqmsn.Color:=$00F2F2F2;
     mytext.Color:=$00F2F2F2;
     signing.Color:=$00F2F2F2;
     Communication.Color:=$00F2F2F2;
     constellation.Color:=$00F2F2F2;
     end else refresh_infor;
end;

procedure Tmyfirend_infor.CloseForm(Sender: TObject);
begin
  close;
end;

procedure Tmyfirend_infor.ModifyUserInfor(Sender: TObject);
var
 TmpInfor:Tfirendinfo;
begin
  if CompareText(FUserSign,loginUserSign)<>0 then
  if User.Find(FUserSign,TmpInfor) then
    begin
    WStrPCopy(TmpInfor.sex,sex.text);
    WStrPCopy(TmpInfor.age,age.text);
    WStrPCopy(TmpInfor.uname,uname.text);
    WStrPCopy(TmpInfor.mytext,mytext.Text);
    WStrPCopy(TmpInfor.signing,signing.Text);
    WStrPCopy(TmpInfor.area,area.Text);
    WStrPCopy(TmpInfor.Phone,Phone.Text);
    WStrPCopy(TmpInfor.qqmsn,qqmsn.Text);
    WStrPCopy(TmpInfor.Email,email.Text);
    WStrPCopy(TmpInfor.constellation,constellation.Text);
    WStrPCopy(TmpInfor.Communication,Communication.Text);
    User.Update(TmpInfor);
    event.CreateMainEvent(Refresh_UserStatus_Event,FUserSign,'');
    end;
end;

procedure Tmyfirend_infor.ShowSearchInfor(P:Pointer);
var
  sFileName:WideString;
begin
  Communication.text:=Pfirendinfo(P)^.Communication;
  constellation.text:=Pfirendinfo(P)^.Constellation;
  phone.Text:=Pfirendinfo(P)^.Phone;
  email.Text:=Pfirendinfo(P)^.Email;
  qqmsn.Text:=Pfirendinfo(P)^.QQmsn;
  area.Text:=Pfirendinfo(P)^.Area;
  mytext.Text:=Pfirendinfo(P)^.MyText;
  uid.Text:=Pfirendinfo(P)^.UserID;
  age.Text:=Pfirendinfo(P)^.Age;
  uname.text:=Pfirendinfo(P)^.UName;
  sex.text:=Pfirendinfo(P)^.Sex;
  signing.text:=Pfirendinfo(P)^.Signing;
  caption:=uname.text+' 的资料';
  Lab_FormCaption.Caption:=uname.text+' 的资料';
  if not ImageOle.GetImageFileName(Pfirendinfo(P)^.Visualize,sFileName) then
    sFileName:=userdefpic;
  try
  myimg.Picture.LoadFromFile(sFileName);
  except
    on EInvalidGraphic do
       myimg.Picture:= nil;
  end;
end;

end.
