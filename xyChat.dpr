program xyChat;

uses
  Forms,
  Windows,
  udpcores in 'main\udpcores.pas' {udpcore: TDataModule},
  mainunt in 'main\mainunt.pas' {MainForm};

{$R *.RES}

begin
  if FindWindowW('TApplication','���� 2012')>0 then exit;
  Application.Initialize;
  Application.Title := '���� 2012';
  Application.CreateForm(Tudpcore, udpcore);
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
