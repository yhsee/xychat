unit RemoteModelUnt;

interface

uses SysUtils,windows,SystemModelUnt;

type
  TRemoteModel=class(TSystemModel)
    private
      procedure RequestRemote(Params:WideString);
      procedure AcceptRemote(Params:WideString);
      procedure CancelRemote(Params:WideString);
      procedure CompleteRemote(Params:WideString);
      procedure RefuseRemote(Params:WideString);
    public
      procedure Process(Params:WideString);override;
    end;

implementation
uses ShareUnt,constunt,udpcores,structureunt,SimpleXmlUnt,userunt,eventunt,EventCommonUnt;

//------------------------------------------------------------------------------
//  ����������Ƶ
//------------------------------------------------------------------------------
procedure TRemoteModel.RequestRemote(Params:WideString);
var
  TmpInfo:Tfirendinfo;
  UserSign:WideString;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');

  if CompareText(UserSign,LoginUserSign)=0 then exit;

  //����û����ں������Ͳ�����
  if CompareText(TmpInfo.GName,SysBlacklist)=0 then exit;

  if user.Find(UserSign,TmpInfo) then
    event.CreateCoreEvent(Remote_Request_Event,UserSign,Params);
end;

procedure TRemoteModel.AcceptRemote(Params:WideString);
var
  UserSign:WideString;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');
  event.CreateRemoteEvent(Remote_Accept_Event,UserSign,Params);
end;

procedure TRemoteModel.CancelRemote(Params:WideString);
var
  UserSign:String;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');
  event.CreateRemoteEvent(Remote_Cancel_Event,UserSign,Params);
end;

procedure TRemoteModel.RefuseRemote(Params:WideString);
var
  UserSign:String;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');
  event.CreateRemoteEvent(Remote_Refuse_Event,UserSign,Params);
end;

procedure TRemoteModel.CompleteRemote(Params:WideString);
var
  UserSign:String;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');
  event.CreateRemoteEvent(Remote_Complete_Event,UserSign,Params);
end;

//------------------------------------------------------------------------------
//  ����meida�йص���Ϣ
//------------------------------------------------------------------------------
procedure TRemoteModel.Process(Params:WideString);
var
  sOperation:WideString;
begin
  try
  if CheckNoteExists(Params,'Operation') then
    begin
    sOperation:=GetNoteFromValue(Params,'Operation');
    case StrToIntDef(sOperation,UnKnown_Command) of

      Remote_Request_Operation:            RequestRemote(Params);
      Remote_Accept_Operation:             AcceptRemote(Params);
      Remote_Refuse_Operation:             RefuseRemote(Params);
      Remote_Cancel_Operation:             CancelRemote(Params);
      Remote_Complete_Operation:           CompleteRemote(Params);
      
      else WriteLog('δ֪�Ĳ�������');
      end;
    end;

  except
    on e:exception do
      WriteLog(e.Message);
  end;
end;


end.
