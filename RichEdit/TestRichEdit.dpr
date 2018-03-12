program TestRichEdit;

uses
  Forms,
  frmTest in 'frmTest.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
