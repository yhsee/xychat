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
  Windows, SysUtils, Classes,
  CustomThreadUnt, MultiTimerCommonUnt;

type
  TMultiTimer = Class
    constructor Create;
    destructor Destroy; override;
  private
    FActive,//组件状态
    FbCauda: Boolean; //当前轮询列表状态 A:b?
    //计时器又轮询列表,轮询时从A列表取出处理完送回到B列表,
    //当A列表为空时从B列表开始取出处理完后送回到A列表,一直循环
    FTimeListHead,
    FTimeListCauda,
    //计时器回收列表
    FreeTimeList: TThreadList;

    FLock:TRTLCriticalSection;

    //计时器轮询线程
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

//清空列表
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

// 取出一个计时器指针如果没有可用的则创建一个新的
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

//取出一个计时器列表内的计时器指针
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

//处理计时器的事件
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

  //从循环列表取一个计时器出来.
  if not GetNextTimer(P) then
    begin //如果失败则换一个循环列表
    FbCauda:=not FbCauda;
    Sleep(10);
    exit;
    end;

  if PSingleTime(P)^.iDelete then // 需要删除的数据
    begin
    FreeTimeList.Add(P);
    exit;
    end;

  if PSingleTime(P)^.iActive then  //处理活动状态
  if LongWord(abs(PSingleTime(P)^.iStartTick - GetTickCount)) > PSingleTime(P)^.iTime then 
    try
    PSingleTime(P)^.Sender(P);  //执行预定的执行事件
    PSingleTime(P)^.iStartTick := GetTickCount;
    except

    end;

  if FbCauda then        //将计时器指针重新放回到 循环列表
    FTimeListHead.Add(P)
    else FTimeListCauda.Add(P);

  finally
  LeaveCriticalSection(FLock);
  end;
end;

//注册一个新的计时器
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
