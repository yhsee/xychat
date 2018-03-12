unit MediaModelUnt;

interface

uses SysUtils,windows,SystemModelUnt;

type
  TMediaModel=class(TSystemModel)
    private
      procedure RequestMedia(Params:WideString);
      procedure AcceptMedia(Params:WideString);
      procedure CancelMedia(Params:WideString);
      procedure CompleteMedia(Params:WideString);
      procedure RefuseMedia(Params:WideString);
    public
      procedure Process(Params:WideString);override;
    end;

implementation
uses ShareUnt,constunt,udpcores,structureunt,SimpleXmlUnt,userunt,eventunt,EventCommonUnt;

//------------------------------------------------------------------------------
//  请求语音视频
//------------------------------------------------------------------------------
procedure TMediaModel.RequestMedia(Params:WideString);
var
  TmpInfo:Tfirendinfo;
  UserSign:WideString;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');

  if CompareText(UserSign,LoginUserSign)=0 then exit;

  //如果用户属于黑名单就不处理
  if CompareText(TmpInfo.GName,SysBlacklist)=0 then exit;

  if user.Find(UserSign,TmpInfo) then
    event.CreateCoreEvent(Media_Request_Event,UserSign,Params);
end;

procedure TMediaModel.AcceptMedia(Params:WideString);
var
  UserSign:WideString;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');
  event.CreateMediaEvent(Media_Accept_Event,UserSign,Params);
end;

procedure TMediaModel.Cancelmedia(Params:WideString);
var
  UserSign:String;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');
  event.CreateMediaEvent(Media_Cancel_Event,UserSign,Params);
end;

procedure TMediaModel.RefuseMedia(Params:WideString);
var
  UserSign:String;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');
  event.CreateMediaEvent(Media_Refuse_Event,UserSign,Params);
end;

procedure TMediaModel.CompleteMedia(Params:WideString);
var
  UserSign:String;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');
  event.CreateMediaEvent(Media_Complete_Event,UserSign,Params);
end;

//------------------------------------------------------------------------------
//  处理meida有关的消息
//------------------------------------------------------------------------------
procedure TMediaModel.Process(Params:WideString);
var
  sOperation:WideString;
begin
  try
  if CheckNoteExists(Params,'Operation') then
    begin
    sOperation:=GetNoteFromValue(Params,'Operation');
    case StrToIntDef(sOperation,UnKnown_Command) of

      Media_Request_Operation:            RequestMedia(Params);
      Media_Accept_Operation:             AcceptMedia(Params);
      Media_Refuse_Operation:             RefuseMedia(Params);
      Media_Cancel_Operation:             CancelMedia(Params);
      Media_Complete_Operation:           CompleteMedia(Params);
      
      else WriteLog('未知的操作动词');
      end;
    end;

  except
    on e:exception do
      WriteLog(e.Message);
  end;
end;

end.
