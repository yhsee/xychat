unit FileModelUnt;

interface

uses SysUtils,windows,modelunt;

type
  TFileModel=class(Tmodel)
    private
      procedure RequestFile(Params:WideString);
      procedure AcceptFile(Params:WideString);
      procedure StartFile(Params:WideString);
      procedure CancelFile(Params:WideString);
      procedure RefuseFile(Params:WideString);
      procedure CompleteFile(Params:WideString);
    public
      procedure Process(Params:WideString);override;
    end;

implementation
uses shareunt,constunt,UserUnt,EventCommonUnt,EventUnt,structureunt,SimpleXmlunt;

//------------------------------------------------------------------------------
//  要求文件发送文件
//------------------------------------------------------------------------------
procedure TFileModel.RequestFile(Params:WideString);
var
  TmpInfo:Tfirendinfo;
  UserSign:WideString;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');

  if CompareText(UserSign,LoginUserSign)=0 then exit;

  //如果用户属于黑名单就不处理
  if CompareText(TmpInfo.GName,SysBlacklist)=0 then exit;

  if user.Find(UserSign,TmpInfo) then
    event.CreateCoreEvent(File_Request_Event,UserSign,Params);
end;

procedure TFileModel.AcceptFile(Params:WideString);
var
  sIdentifier:String;
begin
  sIdentifier:=GetNoteFromValue(Params,'Identifier');
  event.CreateFileEvent(File_Accept_Event,sIdentifier,Params);
end;

procedure TFileModel.StartFile(Params:WideString);
var
  sIdentifier:String;
begin
  sIdentifier:=GetNoteFromValue(Params,'Identifier');
  event.CreateFileEvent(File_Start_Event,sIdentifier,Params);
end;

procedure TFileModel.CancelFile(Params:WideString);
var
  sIdentifier:String;
begin
  sIdentifier:=GetNoteFromValue(Params,'Identifier');
  event.CreateFileEvent(File_Cancel_Event,sIdentifier,Params);
end;

procedure TFileModel.RefuseFile(Params:WideString);
var
  sIdentifier:String;
begin
  sIdentifier:=GetNoteFromValue(Params,'Identifier');
  event.CreateFileEvent(File_Refuse_Event,sIdentifier,Params);
end;

procedure TFileModel.CompleteFile(Params:WideString);
var
  sIdentifier:String;
begin
  sIdentifier:=GetNoteFromValue(Params,'Identifier');
  event.CreateFileEvent(File_Complete_Event,sIdentifier,Params);
end;

//------------------------------------------------------------------------------
//  处理file有关的消息
//------------------------------------------------------------------------------
procedure TFileModel.Process(Params:WideString);
var
  sOperation:WideString;
begin
  try
  if CheckNoteExists(Params,'Operation') then
    begin
    sOperation:=GetNoteFromValue(Params,'Operation');
    case StrToIntDef(sOperation,UnKnown_Command) of

      File_Request_Operation:            RequestFile(Params);
      File_Accept_Operation:             AcceptFile(Params);
      File_Start_Operation:              StartFile(Params);
      File_Cancel_Operation:             CancelFile(Params);
      File_Refuse_Operation:             RefuseFile(Params);
      File_Complete_Operation:           CompleteFile(Params);
      
      else WriteLog('未知的操作动词');
      end;
    end;

  except
    on e:exception do
      WriteLog(e.Message);
  end;
end;

end.
