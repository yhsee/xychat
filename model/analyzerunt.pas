//******************************************************************************
//            分析处理线程
//            彭晋杰
//            2007-12-20
//******************************************************************************

unit analyzerunt;

interface

uses Windows,Messages,SysUtils,Classes,CustomThreadUnt,AnalyzerCommonUnt,
     SystemModelUnt,FirendModelUnt,MessageModelUnt,MediaModelUnt,
     FileModelUnt,RemoteModelUnt,AssistModelUnt;

type
  TLogEvent=procedure(Sender:TObject;sLog:WideString)of Object;
  TanalyzerThread=class(TComponent)
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;
  private
    bStatus:Boolean;
    FWriteLogEvent:TLogEvent;
    AssistModel:TAssistModel;
    RemoteModel:TRemoteModel;
    FileModel:TFileModel;
    MediaModel:TMediaModel;
    MessageModel:TMessageModel;
    FirendModel:TFirendModel;
    SystemModel:TSystemModel;
    FPrivateThread:TCustomThread;
    RawDataList,
    FreeDataList:TThreadList;
    procedure analyzerproc(Sender:TObject);
    procedure ClientCoreProcess(P:Pointer);
    procedure WriteLog(Sender:TObject;sLog:WideString);
    procedure DestoryList(TmpList:TThreadList);
    function GetOneRawData(var TmpData:PRawData):boolean;
  protected
  public
    procedure NewRawData(var TmpData:PRawData);
    procedure AddRawDataList(TmpData:PRawData);
    procedure AddFreeDataList(TmpData:PRawData);
  published
    property WriteLogEvent:TLogEvent write FWriteLogEvent;
    property Status:boolean write bStatus;
  end;

implementation

uses ActiveX,structureunt,constunt,SimpleXmlUnt,desunt,zlibex;

//------------------------------------------------------------------------------
//   创建过程
//------------------------------------------------------------------------------
constructor TanalyzerThread.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  bStatus:=False;
  RawDataList:=TThreadList.Create;
  FreeDataList:=TThreadList.Create;
  //-----------------------------------------------------------------------------
  SystemModel:=TSystemModel.Create;
  SystemModel.WriteLogEvent:=WriteLog;
  //-----------------------------------------------------------------------------
  FirendModel:=TFirendModel.Create;
  FirendModel.WriteLogEvent:=WriteLog;
  //-----------------------------------------------------------------------------
  MessageModel:=TMessageModel.Create;
  MessageModel.WriteLogEvent:=WriteLog;
  //-----------------------------------------------------------------------------
  MediaModel:=TMediaModel.Create;
  MediaModel.WriteLogEvent:=WriteLog;
  //-----------------------------------------------------------------------------
  FileModel:=TFileModel.Create;
  FileModel.WriteLogEvent:=WriteLog;
  //-----------------------------------------------------------------------------
  RemoteModel:=TRemoteModel.Create;
  RemoteModel.WriteLogEvent:=WriteLog;
  //-----------------------------------------------------------------------------
  AssistModel:=TAssistModel.Create;
  AssistModel.WriteLogEvent:=WriteLog;
  //-----------------------------------------------------------------------------
  FPrivateThread:=TCustomThread.Create;                  //这里是建立基类线程
  FPrivateThread.OnExecute:=analyzerproc;
  //-----------------------------------------------------------------------------
end;


procedure TanalyzerThread.DestoryList(TmpList:TThreadList);
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

procedure TanalyzerThread.NewRawData(var TmpData:PRawData);
begin
  try
  with FreeDataList.LockList do
    begin
    if Count>0 then
      begin
      TmpData:=Items[0];
      delete(0);
      end else begin
      New(TmpData);
      end;
    end;
  finally
  FreeDataList.UnlockList;
  end;
end;

procedure TanalyzerThread.AddRawDataList(TmpData:PRawData);
begin
  RawDataList.Add(TmpData);
end;

procedure TanalyzerThread.AddFreeDataList(TmpData:PRawData);
begin
  FreeDataList.Add(TmpData);
end;

function TanalyzerThread.GetOneRawData(var TmpData:PRawData):boolean;
begin
  try
  with RawDataList.LockList do
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
  RawDataList.UnlockList;
  end;
end;

procedure TanalyzerThread.WriteLog(Sender:TObject;sLog:WideString);
begin
  if assigned(FWriteLogEvent) then FWriteLogEvent(Sender,sLog);
end;

//------------------------------------------------------------------------------
//   释放过程
//------------------------------------------------------------------------------
destructor TanalyzerThread.Destroy;
begin
  bStatus:=False;
  if assigned(FPrivateThread) then freeandnil(FPrivateThread);
  if assigned(AssistModel) then freeandnil(AssistModel);
  if assigned(RemoteModel) then freeandnil(RemoteModel);
  if assigned(FileModel) then freeandnil(FileModel);
  if assigned(MediaModel) then freeandnil(MediaModel);
  if assigned(MessageModel) then freeandnil(MessageModel);
  if assigned(FirendModel) then freeandnil(FirendModel);
  if assigned(SystemModel) then freeandnil(SystemModel);
  DestoryList(RawDataList);
  freeandnil(RawDataList);
  DestoryList(FreeDataList);
  freeandnil(FreeDataList);
  inherited Destroy;
end;

//------------------------------------------------------------------------------
//   这里是一个线程回调函数过程.
//------------------------------------------------------------------------------
procedure TanalyzerThread.analyzerproc(Sender:TObject);
var
  TmpData:PRawData;
begin
  if not bStatus then
    begin
    sleep(10);
    exit;
    end;
  if not GetOneRawData(TmpData) then
    begin
    sleep(10);
    exit;
    end;

  Try
  ClientCoreProcess(TmpData);
  finally
  FreeDataList.Add(TmpData);
  end;
end;

//------------------------------------------------------------------------------
//   处理过程
//------------------------------------------------------------------------------
procedure TanalyzerThread.ClientCoreProcess(P:Pointer);
var
  Params:String;
  sParams:WideString;
  sFunction:WideString;
begin
  if not bStatus then exit;
  try

  SetLength(Params,PRawData(P)^.DataLen);
  CopyMemory(@Params[1],@PRawData(P)^.DataBuf[0],PRawData(P)^.DataLen);
  sParams:=UTF8Decode(Params);

  //取得对方的真正IP
  AddValueToNote(sParams,'Lanip',PRawData(P)^.UserSocket.PeerIP);

  if CheckNoteExists(sParams,'Function') then
    begin
    sFunction:=GetNoteFromValue(sParams,'Function');
    case StrToIntDef(sFunction,UnKnown_Command) of
      System_Function:      SystemModel.Process(sParams);
      Firend_Function:      FirendModel.Process(sParams);
      Message_Function:     MessageModel.Process(sParams);
      Media_Function:       MediaModel.Process(sParams);
      File_Function:        FileModel.Process(sParams);
      Remote_Function:      RemoteModel.Process(sParams);
      Assist_Function:      AssistModel.Process(sParams);

      else WriteLog(nil,'错误');
      end;
    end;

  except
    on e:exception do
      WriteLog(nil,e.Message);
  end;
end;

initialization
  CoInitialize(nil);
finalization
  CoUninitialize;

end.