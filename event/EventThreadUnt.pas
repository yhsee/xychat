//******************************************************************************
//            �¼������߳�
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
//   ��������
//------------------------------------------------------------------------------
constructor TEventThread.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 FPrivateThread:=TCustomThread.Create;                  //�����ǽ��������߳�
 FPrivateThread.SynThread:=True; 
 FPrivateThread.OnExecute:=analyzerproc;
end;


//------------------------------------------------------------------------------
//   �ͷŹ���
//------------------------------------------------------------------------------
destructor TEventThread.Destroy;
begin
  if assigned(FPrivateThread) then
    freeandnil(FPrivateThread);  //���������߳�
  //-----------------------------------------------------------------------------
  inherited Destroy;
end;

//------------------------------------------------------------------------------
//   ������һ���̻߳ص���������.
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
//   �������
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
      if PEventData(P)^.iType=Event_All then   //֪ͨ���д��ڴ���
        begin
        TmpProcess.OnEvent(nil,PEventData(P)^);
        continue;
        end;


      if TmpProcess.iType=PEventData(P)^.iType then
      if (TmpProcess.iType in [Event_Main,Event_Core]) then  //�ַ�����Ӧ�Ĵ���ȥ����
        begin
        TmpProcess.OnEvent(nil,PEventData(P)^);
        Break;
        end;

      if TmpProcess.iType=PEventData(P)^.iType then
      if CompareText(TmpProcess.UserSign,PEventData(P)^.UserSign)=0 then  //�ַ�����Ӧ���ڵ�ָ���û�����
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