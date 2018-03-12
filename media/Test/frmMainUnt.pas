unit frmMainUnt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,VideoUnt, DSPack, ExtCtrls,
  BaseClass,directshow9,DSUtil;

type
  TfrmMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    Video:TVideoCore;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
freeandnil(Video);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
Video:=TVideoCore.Create;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
Video.mediaSendstart(image1);
end;

end.
