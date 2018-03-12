unit ModelUnt;

interface

uses Windows,SysUtils,Classes;

type
  TLogEvent=procedure(Sender:TObject;sLog:WideString)of Object;
  Tmodel=class
    constructor Create;
    destructor  Destroy;override;
    procedure Process(Params:WideString);virtual;abstract;        
  private
    FWriteLogEvent:TLogEvent;
  protected
    procedure WriteLog(sLog:WideString);
  published
    property WriteLogEvent:TLogEvent write FWriteLogEvent;
  end;

implementation

constructor Tmodel.Create;
begin
  inherited Create;
end;

destructor Tmodel.Destroy;
begin
  inherited Destroy;
end;

procedure Tmodel.WriteLog(sLog:WideString);
begin
  if assigned(FWriteLogEvent) then
    FWriteLogEvent(nil,sLog);
end;

end.
