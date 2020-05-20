//******************************************************************************
//            事件管理模块
//******************************************************************************

unit EventUnt;

interface

uses Windows,Messages,SysUtils,Classes,
     EventThreadUnt,EventCommonUnt;

type

  TEvent=class(TComponent)
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;
  private
    FEventThread:TEventThread;
  protected
    procedure SetStatus(bStatus:Boolean);
    procedure CreateEvent(iType:TEventType;iEvent:Integer;sUserSign:String;sParams:WideString);
  public
    function CreateEventProcess(Sender:TOnEventProcess;iType:TEventType;Const sUserSign:String=''):Pointer;
    procedure RemoveEventProcess(TmpEvent:Pointer);
    //--------------------------------------------------------------------------
    procedure CreateAllEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
    procedure CreateMainEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
    procedure CreateCoreEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
    procedure CreateDialogEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
    procedure CreateRemoteEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
    procedure CreateMediaEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
    procedure CreateFileEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
    procedure CreateAssistEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
  published
    property Status:boolean write SetStatus;
  end;

var
  Event:TEvent;

implementation

constructor TEvent.Create(AOwner: TComponent);
begin
  Inherited;
  FEventThread:=TEventThread.Create(self);
end;

destructor TEvent.Destroy;
begin
  if assigned(FEventThread) then freeandnil(FEventThread);
  Inherited;
end;

function TEvent.CreateEventProcess(Sender:TOnEventProcess;iType:TEventType;Const sUserSign:String=''):Pointer;
var
  TmpEvent:PEventProcess;
begin
  New(TmpEvent);
  try
  TmpEvent.UserSign:=sUserSign;
  TmpEvent.iType:=iType;
  TmpEvent.OnEvent:=Sender;
  TmpEvent.iDelete:=False;
  FEventThread.AddEventProcessList(TmpEvent);
  Result:=TmpEvent;
  except
  Dispose(TmpEvent);
  Result:=nil;
  end;
end;

procedure TEvent.RemoveEventProcess(TmpEvent:Pointer);
begin
  PEventProcess(TmpEvent).iDelete:=true;
  PEventProcess(TmpEvent).OnEvent:=nil;
end;

procedure TEvent.CreateEvent(iType:TEventType;iEvent:Integer;sUserSign:String;sParams:WideString);
var
  TmpData:PEventData;
begin
  try
  FEventThread.NewEventRawData(TmpData);
  TmpData.iEvent:=iEvent;
  TmpData.iType:=iType;
  TmpData.UserSign:=sUserSign;
  TmpData.UserParams:=sParams;
  FEventThread.AppendEventRawData(TmpData);
  except
  FEventThread.AppendEventFreeData(TmpData);
  end;
end;


procedure TEvent.SetStatus(bStatus:Boolean);
begin
  FEventThread.Status:=bStatus;
end;

procedure TEvent.CreateAllEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
begin
  CreateEvent(Event_All,iEvent,sUserSign,sParams);
end;

procedure TEvent.CreateMainEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
begin
  CreateEvent(Event_Main,iEvent,sUserSign,sParams);
end;

procedure TEvent.CreateCoreEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
begin
  CreateEvent(Event_Core,iEvent,sUserSign,sParams);
end;

procedure TEvent.CreateDialogEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
begin
  CreateEvent(Event_Dialog,iEvent,sUserSign,sParams);
end;

procedure TEvent.CreateRemoteEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
begin
  CreateEvent(Event_Remote,iEvent,sUserSign,sParams);
end;

procedure TEvent.CreateMediaEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
begin
  CreateEvent(Event_Media,iEvent,sUserSign,sParams);
end;

procedure TEvent.CreateFileEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
begin
  CreateEvent(Event_File,iEvent,sUserSign,sParams);
end;

procedure TEvent.CreateAssistEvent(iEvent:Integer;sUserSign:String;sParams:WideString);
begin
  CreateEvent(Event_Assist,iEvent,sUserSign,sParams);
end;

end.
