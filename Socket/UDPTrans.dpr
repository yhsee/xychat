program UDPTrans;

uses
  Forms,
  frmMainUnt in 'frmMainUnt.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;

end.
