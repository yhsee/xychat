unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,aWavePlayerUnt, StdCtrls;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    xx:TAudioVolume;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  xx:=TAudioVolume.Create(self);
  xx:=TAudioVolume.CreateParented(self.Handle);
  xx.Parent:=self;

  xx.Left:=100;
  xx.Top:=100;
  xx.Visible:=True;

end;

end.
