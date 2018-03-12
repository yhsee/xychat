unit CustomThreadUnt;

interface

uses
  Classes,SysUtils,Windows;

type
  TCustomThread = Class(TThread)
    constructor Create(Const FPriority: TThreadPriority = tpLowest);
  private
    FOnExecute: TNotifyEvent;
    FSynThread: Boolean;
    procedure ThreadProcess;
  protected
    procedure Execute; override;
  public
    procedure OverThread;
  published
    property SynThread: Boolean read FSynThread write FSynThread Default False;
    property OnExecute: TNotifyEvent read FOnExecute write FOnExecute;
  end;

implementation

uses activex;
{ TCustomThread }

constructor TCustomThread.Create(Const FPriority: TThreadPriority = tpLowest);
begin
  inherited Create(False);
  Priority := FPriority;
  FreeOnTerminate := True;
end;

procedure TCustomThread.OverThread;
begin
  Terminate;
  while not Terminated do
    begin
    Terminate;
    Sleep(100);
    end;
end;

procedure TCustomThread.Execute;
begin
  CoInitialize(nil);
  While Not Terminated do
    begin
    if FSynThread then
      begin
      Synchronize(ThreadProcess);
      Sleep(10);
      end else ThreadProcess;
    end;
  FOnExecute := nil;
  CoUninitialize;
end;

procedure TCustomThread.ThreadProcess;
begin
  try
  if Assigned(FOnExecute) then
    FOnExecute(nil) else Sleep(10);
  except
  end;
end;

end.
