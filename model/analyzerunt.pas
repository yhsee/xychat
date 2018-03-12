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
  TanalyzerThread=class(TComponent)
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;
  private
    AssistModel:TAssistModel;
    RemoteModel:TRemoteModel;
    FileModel:TFileModel;
    MediaModel:TMediaModel;
    MessageModel:TMessageModel;
    FirendModel:TFirendModel;
    SystemModel:TSystemModel;
    FPrivateThread:TCustomThread;
    procedure analyzerproc(Sender:TObject);
    procedure ClientCoreProcess(P:Pointer);
    procedure WriteLog(Sender:TObject;sLog:WideString);
  protected
  public
  end;

implementation

uses ActiveX,ShareUnt,structureunt,constunt,SimpleXmlUnt,desunt,zlibex;

//------------------------------------------------------------------------------
//   创建过程
//------------------------------------------------------------------------------
constructor TanalyzerThread.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
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

procedure TanalyzerThread.WriteLog(Sender:TObject;sLog:WideString);
begin
  logmemo.add(sLog);
end;

//------------------------------------------------------------------------------
//   释放过程
//------------------------------------------------------------------------------
destructor TanalyzerThread.Destroy;
begin
  if assigned(FPrivateThread) then freeandnil(FPrivateThread);
  if assigned(AssistModel) then freeandnil(AssistModel);
  if assigned(RemoteModel) then freeandnil(RemoteModel);
  if assigned(FileModel) then freeandnil(FileModel);
  if assigned(MediaModel) then freeandnil(MediaModel);
  if assigned(MessageModel) then freeandnil(MessageModel);
  if assigned(FirendModel) then freeandnil(FirendModel);
  if assigned(SystemModel) then freeandnil(SystemModel);
  inherited Destroy;
end;

//------------------------------------------------------------------------------
//   这里是一个线程回调函数过程.
//------------------------------------------------------------------------------
procedure TanalyzerThread.analyzerproc(Sender:TObject);
var
  TmpData:Pointer;
begin
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
  if not ClientRun then exit;
  try
    
  //版本检查
  if PRawData(P)^.DataHead.Version<>DataVersion then exit; //版本不一致.

  SetLength(Params,PRawData(P)^.DataHead.DataLen);
  CopyMemory(@Params[1],@PRawData(P)^.DataBuf[0],PRawData(P)^.DataHead.DataLen);
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

      else logmemo.Add('错误');
      end;
    end;

  except
    on e:exception do
      logmemo.add(e.Message);
  end;
end;

initialization
  CoInitialize(nil);
finalization
  CoUninitialize;

end.