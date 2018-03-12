unit phizmodifyunt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls,Gifimage,pngimage,jpeg, StdCtrls, TntStdCtrls,TntDialogs,
  TntExtCtrls, RzPanel;

type
  Tfrmphizmodify = class(TForm)
    TntButton2: TTntButton;
    TntButton3: TTntButton;
    TntLabel3: TTntLabel;
    TntLabel2: TTntLabel;
    TntLabel1: TTntLabel;
    TntButton1: TTntButton;
    imgPreview: TTntImage;
    ED_picfilename: TTntEdit;
    ED_FaceQuick: TTntEdit;
    ED_FaceName: TTntEdit;
    Bevel1: TBevel;
    procedure TntButton1Click(Sender: TObject);
    procedure TntButton3Click(Sender: TObject);
    procedure TntButton2Click(Sender: TObject);
  private
    bComplete:Boolean;
    procedure ShowImage(sfilename:WideString);
    { Private declarations }
  public
    { Public declarations }
  end;

function NewPhizInfor(var sFileName,sQuick,sName:WideString):Boolean;
function EditPhizInfor(sFileName:WideString;var sQuick,sName:WideString):Boolean;

implementation
uses ShareUnt;
{$R *.dfm}

function NewPhizInfor(var sFileName,sQuick,sName:WideString):Boolean;
begin
with Tfrmphizmodify.Create(Application) do
  try
  Caption:='添加表情';
  ED_picfilename.Text:='';
  ED_FaceQuick.Text:='';
  ED_FaceName.Text:='';
  ShowModal;
  sFileName:=ED_picfilename.Text;
  sQuick:=TRIM(ED_FaceQuick.Text);
  sName:=TRIM(ED_FaceName.Text);
  Result:=bComplete;
  finally
  free;
  end;
end;

function EditPhizInfor(sFileName:WideString;var sQuick,sName:WideString):Boolean;
begin
  with Tfrmphizmodify.Create(Application) do
    try
    Caption:='修改表情';
    TntButton1.OnClick:=nil;
    ED_FaceQuick.Text:=sQuick;
    ED_FaceName.Text:=sName;
    ShowImage(sFileName);
    showmodal;
    sQuick:=TRIM(ED_FaceQuick.Text);
    sName:=TRIM(ED_FaceName.Text);
    Result:=bComplete;
    finally
    free;
    end;
end;

procedure Tfrmphizmodify.TntButton1Click(Sender: TObject);
begin
  with TTntOpenDialog.Create(self) do
    try
    Title:='选择图片';
    Filter:='图片文件|*.bmp;*.jpg;*.jpeg;*.gif;*.png';
    InitialDir:=DefaultOpenDir;
    if execute then ShowImage(filename);
    finally
    free;
    end;
end;

procedure Tfrmphizmodify.ShowImage(sfilename:WideString);
begin
  Try
  imgPreview.Picture.LoadFromFile(sfilename);
  imgPreview.Stretch:=imgPreview.Picture.Graphic.Width>imgPreview.Width;
  imgPreview.Invalidate;
  ED_picfilename.Text:=sfilename;
  except
  on EInvalidGraphic do
    imgPreview.Picture:= nil;
  end;
end;

procedure Tfrmphizmodify.TntButton3Click(Sender: TObject);
begin
  close;
end;

procedure Tfrmphizmodify.TntButton2Click(Sender: TObject);
begin
  bComplete:=ED_picfilename.Text<>'';
  close;
end;

end.
