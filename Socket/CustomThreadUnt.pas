unit CustomThreadUnt;

interface

uses
  Classes,SysUtils,Windows;

type
  TCustomThread = Class(TThread)
    constructor Create(Const FPriority: TThreadPriority = tpLowest);
    destructor Destroy; override;
  private
    FOnExecute: TNotifyEvent;
    FSynThread: Boolean;
    procedure ThreadProcess;
  protected
    procedure Execute; override;
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
  FreeOnTerminate := False;
end;

destructor TCustomThread.Destroy;
begin
  Terminate;
  inherited Destroy;
end;

procedure TCustomThread.Execute;
begin
  CoInitialize(nil);
  While Not Terminated do
    begin
    if Terminated then break;

    if FSynThread then
      begin
      Synchronize(ThreadProcess);
      Sleep(100);
      end else ThreadProcess;

    if Terminated then break;
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
