unit Found_SecondUnt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg, StdCtrls, ResStringUnit, PublicVariable, XPMan,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus, ComCtrls;

type
  TFound_Second = class(TFrame)
    Panel_Frame: TTntPanel;
    Image_BackGroup: TImage;
    FoundListView: TListView;
    Image_Return: TImage;
    Label1: TLabel;
    Image_AddFirend: TImage;
  private
    { Private declarations }
  public
    procedure InitializeFace;
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFound_Second.InitializeFace;
begin
  Image_BackGroup.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis031.jpg');
  Image_Return.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\But_Return.jpg');
  Image_AddFirend.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\But_Yes.jpg');
end;

end.
