unit MultiTimerUnt;

interface

{*******************************************************}
{                                                       }
{       计时器组件                                      }
{                                                       }
{	           email: yihuas@163.com                      }
{		         2012.11.7                                  }
{                                                       }
{*******************************************************}

uses
  Windows, SysUtils, Classes, CustomThreadUnt, MultiTimerCommonUnt;

type
  TMultiTimer = Class
    constructor Create(const bSynch:boolean=false);
    destructor Destroy; override;
  private
    FActive:Boolean;//组件状态
    FTimeList,
    //计时器回收列表
    FreeTimeList: TThreadList;
    FLock:TRTLCriticalSection;
    //计时器轮询线程
    FBasicThread: TCustomThread;
  protected
    procedure GetNewTimer(var P: PSingleTime);
    function GetNextTimer(var P: Pointer): Boolean;
    procedure FreeThreadList(TmpList: TThreadList);
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

constructor TMultiTimer.Create(const bSynch:boolean=false);
begin
  InitializeCriticalSection(FLock);
  FTimeList := TThreadList.Create;
  FreeTimeList := TThreadList.Create;
  FBasicThread := TCustomThread.Create;
  FBasicThread.SynThread:=bSynch;
  FBasicThread.OnExecute := BasicOnProcess;
  FActive := True;
end;

//清空列表
procedure TMultiTimer.FreeThreadList(TmpList: TThreadList);
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

  if assigned(FTimeList) then
  begin
    FreeThreadList(FTimeList);
    freeandnil(FTimeList);
  end;
  DeleteCriticalSection(FLock);  
end;

// 取出一个计时器指针如果没有可用的则创建一个新的
procedure TMultiTimer.GetNewTimer(var P: PSingleTime);
begin
  try
    with FreeTimeList.LockList do
      begin
      if count > 0 then
        begin
          P := Items[0];
          Delete(0);
        end else New(P);
      end;
  finally
    FreeTimeList.UnlockList;
  end;
end;

//取出一个计时器列表内的计时器指针
function TMultiTimer.GetNextTimer(var P: Pointer): Boolean;
begin
  try
    Result := False;
    With FTimeList.LockList do
      begin
      if Count>0 then
        begin
        P := Items[0];
        Delete(0);
        Result:=True;        
        end;
      end;
  finally
    FTimeList.UnlockList;
  end;
end;

//处理计时器的事件
procedure TMultiTimer.BasicOnProcess(Sender: TObject);
var
  P: Pointer;
begin
  Try
  EnterCriticalSection(FLock);
  
  if not FActive then
    begin
    sleep(10);
    exit;
    end;

  //从循环列表取一个计时器出来.
  if not GetNextTimer(P) then
    begin //如果失败则换一个循环列表
    Sleep(10);
    exit;
    end;

  if PSingleTime(P)^.iDelete then // 需要删除的数据
    begin
    FreeTimeList.Add(P);
    sleep(10);
    exit;
    end;

  if not PSingleTime(P)^.iActive then
    begin
    FTimeList.Add(P);
    sleep(10);
    exit;
    end;

  if PSingleTime(P)^.iActive then  //处理活动状态
  if LongWord(abs(PSingleTime(P)^.iStartTick - GetTickCount)) > PSingleTime(P)^.iTime then
    try
    PSingleTime(P)^.Sender(P);  //执行预定的事件
    PSingleTime(P)^.iStartTick := GetTickCount;
    except

    end;
  FTimeList.Add(P);

  finally
  LeaveCriticalSection(FLock);
  end;
end;

//注册一个新的计时器
function TMultiTimer.RegTimer(iTime: LongWord; Sender: TNotifyEvent;
  Const Data: Pointer=nil): Pointer;
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
  FTimeList.Add(P);
  Result := P;
end;

//改变计时器的状态并重新赋值起计时间
procedure TMultiTimer.ActiveTime(P: Pointer; Const bActive: Boolean = True);
begin
  PSingleTime(P).iStartTick := GetTickCount;
  PSingleTime(P).iActive := bActive;
end;

//删除一个计时器
procedure TMultiTimer.DeleteTimer(P: Pointer);
begin
  PSingleTime(P).iActive := False;
  PSingleTime(P).iDelete := True;
end;

end.
