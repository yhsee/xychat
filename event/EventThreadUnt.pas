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
    FPrivateThread:TCustomThread;
    procedure analyzerproc(Sender:TObject);
    procedure ClientCoreProcess(P:Pointer);
  protected
  public
  published
  end;

implementation
uses ShareUnt;

//------------------------------------------------------------------------------
//   创建过程
//------------------------------------------------------------------------------
constructor TEventThread.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 FPrivateThread:=TCustomThread.Create;                  //这里是建立基类线程
 FPrivateThread.SynThread:=True; 
 FPrivateThread.OnExecute:=analyzerproc;
end;


//------------------------------------------------------------------------------
//   释放过程
//------------------------------------------------------------------------------
destructor TEventThread.Destroy;
begin
  if assigned(FPrivateThread) then
    freeandnil(FPrivateThread);  //结束基类线程
  //-----------------------------------------------------------------------------
  inherited Destroy;
end;

//------------------------------------------------------------------------------
//   这里是一个线程回调函数过程.
//------------------------------------------------------------------------------
procedure TEventThread.analyzerproc(Sender:TObject);
var
  TmpData:Pointer;
begin
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
procedure TEventThread.ClientCoreProcess(P:Pointer);
var
  i:Integer;
  TmpProcess:PEventProcess;
begin
  if not ClientRun then exit;
  try

    try
    with EventList.LockList do
    for i:=Count downto 1 do
      begin
      TmpProcess:=Items[i-1];
      if PEventData(P)^.iType=Event_All then   //通知所有窗口处理
        begin
        TmpProcess.OnEvent(nil,PEventData(P)^);
        continue;
        end;


      if TmpProcess.iType=PEventData(P)^.iType then
      if (TmpProcess.iType in [Event_Main,Event_Core]) then  //分发给对应的窗口去处理
        begin
        TmpProcess.OnEvent(nil,PEventData(P)^);
        Break;
        end;

      if TmpProcess.iType=PEventData(P)^.iType then
      if CompareText(TmpProcess.UserSign,PEventData(P)^.UserSign)=0 then  //分发给对应窗口的指定用户处理
        begin
        TmpProcess.OnEvent(nil,PEventData(P)^);
        Break;
        end;

      end;
    finally
    EventList.UnlockList;
    end;

  except
    on e:exception do
      logmemo.add(e.Message);
  end;
end;

end.