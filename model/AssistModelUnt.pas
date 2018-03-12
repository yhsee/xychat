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
//  要求文件发送文件
//------------------------------------------------------------------------------
procedure TAssistModel.RequestAssist(Params:WideString);
var
  TmpInfo:Tfirendinfo;
  UserSign:WideString;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');

  if CompareText(UserSign,LoginUserSign)=0 then exit;

  //如果用户属于黑名单就不处理
  if CompareText(TmpInfo.GName,SysBlacklist)=0 then exit;

  if user.Find(UserSign,TmpInfo) then
    event.CreateCoreEvent(Assist_Request_Event,UserSign,Params);
end;

//------------------------------------------------------------------------------
//  处理Assist有关的消息
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

      
      else WriteLog('未知的操作动词');
      end;
    end;

  except
    on e:exception do
      WriteLog(e.Message);
  end;
end;

end.
