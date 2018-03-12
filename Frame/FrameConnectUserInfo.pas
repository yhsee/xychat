unit FrameConnectUserInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, jpeg, StdCtrls, ExtCtrls,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus;

type
  TFrame_ConnectUserInfo = class(TTntFrame)
    Image_BackGroup: TImage;
    Image_User: TImage;
    Lab_UserName: TTntLabel;
    Lab_MPhone: TTntLabel;
    Lab_Phone: TTntLabel;
    Lab_NetContact: TTntLabel;
    Lab_ViewUserInfo: TTntLabel;
    s: TImage;
    procedure TntFrameResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure InitializeConnectUserInfo;
  end;

Var
  fConnectUserInfo : TFrame_ConnectUserInfo;

implementation

{$R *.dfm}

procedure TFrame_ConnectUserInfo.InitializeConnectUserInfo;
begin
	//
end;

procedure TFrame_ConnectUserInfo.TntFrameResize(Sender: TObject);
begin
	Image_User.Left := (Self.Width-Image_User.Width) Div 2;
end;

end.
