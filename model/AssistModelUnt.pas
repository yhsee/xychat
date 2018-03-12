unit AssistModelUnt;

interface

uses SysUtils,windows,modelunt;

type
  TAssistModel=class(Tmodel)
    private
      procedure RequestAssist(Params:WideString);
    public
      procedure Process(Params:WideString);override;
    end;

implementation
uses shareunt,constunt,UserUnt,EventCommonUnt,EventUnt,structureunt,SimpleXmlunt;

//------------------------------------------------------------------------------
//  Ҫ���ļ������ļ�
//------------------------------------------------------------------------------
procedure TAssistModel.RequestAssist(Params:WideString);
var
  TmpInfo:Tfirendinfo;
  UserSign:WideString;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');

  if CompareText(UserSign,LoginUserSign)=0 then exit;

  //����û����ں������Ͳ�����
  if CompareText(TmpInfo.GName,SysBlacklist)=0 then exit;

  if user.Find(UserSign,TmpInfo) then
    event.CreateCoreEvent(Assist_Request_Event,UserSign,Params);
end;

//------------------------------------------------------------------------------
//  ����Assist�йص���Ϣ
//------------------------------------------------------------------------------
procedure TAssistModel.Process(Params:WideString);
var
  sOperation:WideString;
begin
  try
  if CheckNoteExists(Params,'Operation') then
    begin
    sOperation:=GetNoteFromValue(Params,'Operation');
    case StrToIntDef(sOperation,UnKnown_Command) of

      Assist_Request_Operation:            RequestAssist(Params);

      
      else WriteLog('δ֪�Ĳ�������');
      end;
    end;

  except
    on e:exception do
      WriteLog(e.Message);
  end;
end;

end.
