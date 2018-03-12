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
    procedure CreateEvent(iType:TEventType;iEvent:Integer;sUserSign:String;sParams:WideString);
  public
    procedure CreateEventProcess(Sender:TOnEventProcess;iType:TEventType;Const sUserSign:String='');
    procedure RemoveEventProcess(iType:TEventType;Const sUserSign:String='');
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

procedure TEvent.CreateEventProcess(Sender:TOnEventProcess;iType:TEventType;Const sUserSign:String='');
var
  TmpEvent:PEventProcess;
begin
  New(TmpEvent);
  TmpEvent.UserSign:=sUserSign;
  TmpEvent.iType:=iType;
  TmpEvent.OnEvent:=Sender;
  EventList.Add(TmpEvent);
end;

procedure TEvent.RemoveEventProcess(iType:TEventType;Const sUserSign:String='');
var
  i:Integer;
  TmpEvent:PEventProcess;
begin
  try
  with EventList.LockList do
  for i:=Count downto 1 do
    begin
    TmpEvent:=Items[i-1];
    if TmpEvent.iType=iType then
    if CompareText(TmpEvent.UserSign,sUserSign)=0 then
      begin
      Delete(i-1);
      Dispose(TmpEvent);
      Break;
      end;
    end;
  finally
  EventList.UnlockList;
  end;
end;

procedure TEvent.CreateEvent(iType:TEventType;iEvent:Integer;sUserSign:String;sParams:WideString);
var
  TmpEvent:PEventData;
begin
  NewEventRawData(Pointer(TmpEvent));
  TmpEvent.iEvent:=iEvent;
  TmpEvent.iType:=iType;
  TmpEvent.UserSign:=sUserSign;
  TmpEvent.UserParams:=sParams;
  AppendEventRawData(TmpEvent);
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
