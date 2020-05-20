//******************************************************************************
//            事件处理线程
//******************************************************************************

unit EventThreadUnt;

interface

uses Windows,Messages,SysUtils,Classes,CustomThreadUnt,
     EventCommonUnt;

type
  TEventThread=class(TComponent)
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;
  private
    bStatus:Boolean;
    PEventProcessList,
    FreeEventList,
    EvenDatatList:TThreadList;
    FPrivateThread:TCustomThread;
    procedure DestoryList(TmpList:TThreadList);
    function GetOneEventRawData(var TmpData:PEventData):boolean;
    procedure analyzerproc(Sender:TObject);
    procedure ClientCoreProcess(P:PEventData);
  protected
  public
    procedure NewEventRawData(var TmpData:PEventData);
    procedure AppendEventRawData(TmpData:PEventData);
    procedure AppendEventFreeData(TmpData:PEventData);
    procedure AddEventProcessList(TmpEvent:PEventProcess);
  published
    property Status:boolean write bStatus;  
  end;

implementation
uses ShareUnt;

//------------------------------------------------------------------------------
//   创建过程
//------------------------------------------------------------------------------
constructor TEventThread.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  bStatus:=False;
  EvenDatatList:=TThreadList.Create;
  FreeEventList:=TThreadList.Create;
  PEventProcessList:=TThreadlist.Create;
  FPrivateThread:=TCustomThread.Create;                  //这里是建立基类线程
  FPrivateThread.SynThread:=True;
  FPrivateThread.OnExecute:=analyzerproc;
end;


//------------------------------------------------------------------------------
// 缓冲区队列操作
//------------------------------------------------------------------------------
procedure TEventThread.AddEventProcessList(TmpEvent:PEventProcess);
begin
  PEventProcessList.Add(TmpEvent);
end;

procedure TEventThread.AppendEventFreeData(TmpData:PEventData);
begin
  EvenDatatList.Add(TmpData);
end;

procedure TEventThread.NewEventRawData(var TmpData:PEventData);
begin
  try
  with FreeEventList.LockList do
    begin
    if Count>0 then
      begin
      TmpData:=Items[0];
      delete(0);
      end else New(TmpData);
    end;
  finally
  FreeEventList.UnlockList;
  end;
end;

procedure TEventThread.AppendEventRawData(TmpData:PEventData);
begin
  try
  with EvenDatatList.LockList do
    begin
    if Count>1024 then
      begin
      Dispose(Items[0]);
      delete(0);
      end;
    add(TmpData);
    end;
  finally
  EvenDatatList.UnlockList;
  end;
end;

function TEventThread.GetOneEventRawData(var TmpData:PEventData):boolean;
begin
  try
  with EvenDatatList.LockList do
    begin
    result:=false;
    if Count>0 then
      begin
      TmpData:=Items[0];
      delete(0);
      result:=true;
      end;
    end;
  finally
  EvenDatatList.UnlockList;
  end;
end;

procedure TEventThread.DestoryList(TmpList:TThreadList);
var i:integer;
begin
try
with TmpList.LockList do
  for i:=Count downto 1 do
   begin
   Dispose(Items[i-1]);
   delete(i-1);
   end;
finally
TmpList.UnlockList;
end;
end;

//------------------------------------------------------------------------------
//   释放过程
//------------------------------------------------------------------------------
destructor TEventThread.Destroy;
begin
  bStatus:=False;
  if assigned(FPrivateThread) then
    freeandnil(FPrivateThread);  //结束基类线程
  //-----------------------------------------------------------------------------
  DestoryList(EvenDatatList);
  freeandnil(EvenDatatList);
  DestoryList(FreeEventList);
  freeandnil(FreeEventList);
  DestoryList(PEventProcessList);
  freeandnil(PEventProcessList);  
  inherited Destroy;
end;

//------------------------------------------------------------------------------
//   这里是一个线程回调函数过程.
//------------------------------------------------------------------------------
procedure TEventThread.analyzerproc(Sender:TObject);
var
  TmpData:PEventData;
begin
  if not bStatus then
    begin
    sleep(10);
    exit;
    end;
  if not GetOneEventRawData(TmpData) then
    begin
    sleep(10);
    exit;
    end;

  Try
  ClientCoreProcess(TmpData);
  finally
  FreeEventList.Add(TmpData); 
  end;
end;
//------------------------------------------------------------------------------
//   处理过程
//------------------------------------------------------------------------------
procedure TEventThread.ClientCoreProcess(P:PEventData);
var
  i:Integer;
  TmpProcess:PEventProcess;
begin
  if not bStatus then
    begin
    Sleep(10);
    exit;
    end;
  try
  with PEventProcessList.LockList do
  for i:=Count downto 1 do
    begin
    if not bStatus then break;
    TmpProcess:=Items[i-1];
    if TmpProcess.iDelete then
      begin
      Delete(i-1);
      Dispose(TmpProcess);
      continue;
      end;

    if PEventData(P)^.iType=Event_All then   //通知所有窗口处理
      begin
      if Assigned(TmpProcess.OnEvent) then
        TmpProcess.OnEvent(nil,P^);
      continue;
      end;


    if TmpProcess.iType=PEventData(P)^.iType then
    if (TmpProcess.iType in [Event_Main,Event_Core]) then  //分发给对应的窗口去处理
      begin
      if Assigned(TmpProcess.OnEvent) then
        TmpProcess.OnEvent(nil,P^);
      Break;
      end;

    if TmpProcess.iType=PEventData(P)^.iType then
    if CompareText(TmpProcess.UserSign,P^.UserSign)=0 then  //分发给对应窗口的指定用户处理
      begin
      if Assigned(TmpProcess.OnEvent) then
        TmpProcess.OnEvent(nil,P^);
      Break;
      end;

    end;
  finally
  PEventProcessList.UnlockList;
  end;
end;

end.