unit frmMainUnt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;
  
type
  TfrmMain = class(TForm)
    BtnStart: TButton;
    procedure BtnStartClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses frmClientUnt;
{$R *.dfm}

procedure TfrmMain.BtnStartClick(Sender: TObject);
var
  frmClient: TfrmClient;
begin
  frmClient := TfrmClient.Create(Application);
  frmClient.Show;
end;

end.
