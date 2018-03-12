unit Found_FirstUnt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg, StdCtrls, ResStringUnit, PublicVariable, XPMan,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus, Buttons;

type
  TFound_First = class(TFrame)
    Panel_Frame: TTntPanel;
    TntLabel1: TTntLabel;
    Image_CutLine0: TImage;
    TntLabel2: TTntLabel;
    Image_CutLine1: TImage;
    Image_Found: TImage;
    Image_Close: TImage;
    Ed_Key: TTntEdit;
    Image_BackGroup: TImage;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    frmListBox: TTntListBox;
    procedure Ed_KeyEnter(Sender: TObject);
    procedure Ed_KeyExit(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure InitializeFace;
    { Public declarations }
  end;

implementation
uses shareunit;
{$R *.dfm}

procedure TFound_First.InitializeFace;
begin
  Image_BackGroup.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis031.jpg');
  Image_Found.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\But_Found.jpg');
  Image_Close.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\But_Close.jpg');
  Image_CutLine0.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis032.jpg');
  Image_CutLine1.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis032.jpg');
  Ed_Key.Text := IPBound_KEY_HINT;
end;


procedure TFound_First.Ed_KeyEnter(Sender: TObject);
begin
  Ed_Key.Font.Color := clBlack;
  if WideCompareText(Ed_Key.Text, IPBound_KEY_HINT)=0 then
    Ed_Key.Text := '';
end;

procedure TFound_First.Ed_KeyExit(Sender: TObject);
begin
  Ed_Key.Font.Color := clGray;
  if Trim(Ed_Key.Text)='' then
    Ed_Key.Text := IPBound_KEY_HINT;
end;

procedure TFound_First.SpeedButton1Click(Sender: TObject);
var
  sTmpStr:String;
begin
  sTmpStr:=Trim(Ed_Key.Text);
  if checkip(sTmpStr) then
    begin
    sTmpStr:=GetIPHead(sTmpStr);
    if Length(sTmpStr)>0 then
    if frmListBox.Items.IndexOf(sTmpStr)<0 then
      begin
      AddToIPBoundList(sTmpStr);
      frmListBox.Items.Add(sTmpStr);
      end;
    end;
end;

procedure TFound_First.SpeedButton2Click(Sender: TObject);
begin
  frmListBox.DeleteSelected;
  IPBoundList.Assign(frmListBox.items);
end;

end.
