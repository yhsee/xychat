unit MultiTimerUnt;

interface

{*******************************************************}
{                                                       }
{       ��ʱ�����                                      }
{                                                       }
{	           email: yihuas@163.com                      }
{		         2012.11.7                                  }
{                                                       }
{*******************************************************}

uses
  Windows, SysUtils, Classes,
  CustomThreadUnt, MultiTimerCommonUnt;

type
  TMultiTimer = Class
    constructor Create;
    destructor Destroy; override;
  private
    FActive,//���״̬
    FbCauda: Boolean; //��ǰ��ѯ�б�״̬ A:b?
    //��ʱ������ѯ�б�,��ѯʱ��A�б�ȡ���������ͻص�B�б�,
    //��A�б�Ϊ��ʱ��B�б�ʼȡ����������ͻص�A�б�,һֱѭ��
    FTimeListHead,
    FTimeListCauda,
    //��ʱ�������б�
    FreeTimeList: TThreadList;

    FLock:TRTLCriticalSection;

    //��ʱ����ѯ�߳�
    FBasicThread: TCustomThread;
  protected
    procedure GetNewTimer(var P: PSingleTime);
    function GetNextTimer(var P: Pointer): Boolean;
    procedure BasicOnProcess(Sender: TObject);
  public
    function RegTimer(iTime: LongWord; Sender: TNotifyEvent;
      Const Data: Pointer = nil): Pointer;
    procedure ActiveTime(P: Pointer; Const bActive: Boolean = True);
    procedure DeleteTimer(P: Pointer);
  published

  end;

implementation

{ TMultiTimer }

constructor TMultiTimer.Create;
begin
  InitializeCriticalSection(FLock);
  FTimeListHead := TThreadList.Create;
  FTimeListCauda := TThreadList.Create;
  FreeTimeList := TThreadList.Create;
  FBasicThread := TCustomThread.Create;
  FBasicThread.OnExecute := BasicOnProcess;
  FbCauda:=False;
  FActive := True;
end;

//����б�
procedure FreeThreadList(TmpList: TThreadList);
var
  i: Word;
  P: Pointer;
begin
  try
    with TmpList.LockList do
      for i := count downto 1 do
      begin
        P := Items[i - 1];
        Delete(i - 1);
        Dispose(P);
      end;
  finally
    TmpList.UnlockList;
  end;
end;

destructor TMultiTimer.Destroy;
begin
  FActive := False;

  if assigned(FBasicThread) then
    FreeAndNil(FBasicThread);

  if assigned(FreeTimeList) then
  begin
    FreeThreadList(FreeTimeList);
    freeandnil(FreeTimeList);
  end;

  if assigned(FTimeListHead) then
  begin
    FreeThreadList(FTimeListHead);
    freeandnil(FTimeListHead);
  end;

  if assigned(FTimeListCauda) then
  begin
    FreeThreadList(FTimeListCauda);
    freeandnil(FTimeListCauda);
  end;
  DeleteCriticalSection(FLock);
end;

// ȡ��һ����ʱ��ָ�����û�п��õ��򴴽�һ���µ�
procedure TMultiTimer.GetNewTimer(var P: PSingleTime);
begin
  try
    with FreeTimeList.LockList do
      if count > 0 then
      begin
        P := Items[0];
        Delete(0);
      end else New(P);
  finally
    FreeTimeList.UnlockList;
  end;
end;

//ȡ��һ����ʱ���б��ڵļ�ʱ��ָ��
function TMultiTimer.GetNextTimer(var P: Pointer): Boolean;
var
  TmpList:TThreadList;
begin
  if FbCauda then
    TmpList:=FTimeListCauda
    else TmpList:=FTimeListHead;
  try
    Result := False;
    With TmpList.LockList do
      begin
      if Count>0 then
        begin
        P := Items[0];
        Delete(0);
        Result:=True;        
        end;
      end;
  finally
    TmpList.UnlockList;
  end;
end;

//�����ʱ�����¼�
procedure TMultiTimer.BasicOnProcess(Sender: TObject);
var
  P: Pointer;
begin
  Try
  EnterCriticalSection(FLock);

  if not FActive then
    begin
    sleep(100);
    exit;
    end;

  //��ѭ���б�ȡһ����ʱ������.
  if not GetNextTimer(P) then
    begin //���ʧ����һ��ѭ���б�
    FbCauda:=not FbCauda;
    Sleep(10);
    exit;
    end;

  if PSingleTime(P)^.iDelete then // ��Ҫɾ��������
    begin
    FreeTimeList.Add(P);
    exit;
    end;

  if PSingleTime(P)^.iActive then  //����״̬
  if LongWord(abs(PSingleTime(P)^.iStartTick - GetTickCount)) > PSingleTime(P)^.iTime then 
    try
    PSingleTime(P)^.Sender(P);  //ִ��Ԥ����ִ���¼�
    PSingleTime(P)^.iStartTick := GetTickCount;
    except

    end;

  if FbCauda then        //����ʱ��ָ�����·Żص� ѭ���б�
    FTimeListHead.Add(P)
    else FTimeListCauda.Add(P);

  finally
  LeaveCriticalSection(FLock);
  end;
end;

//ע��һ���µļ�ʱ��
function TMultiTimer.RegTimer(iTime: LongWord; Sender: TNotifyEvent;
  Const Data: Pointer = nil): Pointer;
var
  P: PSingleTime;
begin
  GetNewTimer(P);
  P^.iActive := False;
  P^.iDelete := False;
  P^.iTime := iTime;
  P^.iCount := 0;
  P^.iStartTick := GetTickCount;
  P^.Data := Data;
  P^.Sender := Sender;
  FTimeListHead.Add(P);
  Result := P;
end;

//�ı��ʱ����״̬�����¸�ֵ���ʱ��
procedure TMultiTimer.ActiveTime(P: Pointer; Const bActive: Boolean = True);
begin
  PSingleTime(P).iStartTick := GetTickCount;
  PSingleTime(P).iActive := bActive;
end;

//ɾ��һ����ʱ��
procedure TMultiTimer.DeleteTimer(P: Pointer);
begin
  PSingleTime(P).iActive := False;
  PSingleTime(P).iDelete := True;
end;

end.
