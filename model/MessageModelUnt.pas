unit MessageModelUnt;

interface

uses SysUtils,windows,SystemModelUnt;

type
  TMessageModel=class(TSystemModel)
    private
      procedure RecvUserText(Params:WideString;const bAuto:Boolean=False);
      procedure RecvUserTextStatus(Params:WideString);
      procedure RecvBroadcast(Params:WideString);
      procedure RecvUserImage(Params:WideString);
    public
      procedure Process(Params:WideString);override;
    end;

implementation
uses ShareUnt,constunt,udpcores,structureunt,SimpleXmlUnt,userunt,chatrec,eventunt,EventCommonUnt;

//------------------------------------------------------------------------------
//  ����Է��������ı���Ϣ.�����ֱ�ӵ�����
//------------------------------------------------------------------------------
procedure TMessageModel.RecvUserText(Params:WideString;const bAuto:Boolean=False);
var
  TmpInfo,MyInfo:Tfirendinfo;
  UserSign,sParams:WideString;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');

//  if CompareText(UserSign,LoginUserSign)=0 then exit;

  if user.Find(UserSign,TmpInfo) then
    begin
    //����û����ں������Ͳ�����
    if CompareText(TmpInfo.GName,SysBlacklist)=0 then exit;

  //  udpcore.playwave(xy_wave_type_clientmsg);

    Event.CreateCoreEvent(ShowFirendMessage_Event,UserSign,Params);
    Event.CreateMainEvent(Refresh_Latelylist_Event,UserSign,'');

    //����Է�����Ϣ�������Զ��ظ��Ͳ�����.
    if not bAuto then 
    if User.Find(LoginUserSign,MyInfo) then
    if (MyInfo.Status=1)and (Length(RevertMsg)>0) then  //�����Զ��ظ�״̬
      begin
      AddValueToNote(sParams,'function',Message_Function);
      AddValueToNote(sParams,'operation',AutoReText_Operation);
      AddValueToNote(sParams,'UserSign',LoginUserSign);
      AddValueToNote(sParams,'MsgText',revertmsg);
      AddValueToNote(sParams,'fontname',DefaultFontFormat.FontName);
      AddValueToNote(sParams,'fontsize',DefaultFontFormat.FontSize);
      AddValueToNote(sParams,'fontcolor',DefaultFontFormat.FontColor);
      AddValueToNote(sParams,'fontstyle',DefaultFontFormat.FontStyle);
      AddValueToNote(sParams,'dt',datetimetostr(now));
      chat.addusertext(UserSign,sParams,true,true);
      udpcore.SendServertransfer(sParams,UserSign);
      end;
    end;
end;

procedure TMessageModel.RecvBroadcast(Params:WideString);
begin
  event.CreateCoreEvent(ShowHintMesssage_Event,'',GetNoteFromValue(params,'msgtext'));
end;

procedure TMessageModel.RecvUserImage(Params:WideString);
var
  UserSign:WideString;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');
  event.CreateDialogEvent(UserImage_Request_Event,UserSign,Params);
end;

procedure TMessageModel.RecvUserTextStatus(Params:WideString);
var
  TmpInfo:Tfirendinfo;
  UserSign:WideString;
begin
  UserSign:=GetNoteFromValue(Params,'UserSign');
  
  if CompareText(UserSign,LoginUserSign)=0 then exit;

  if user.Find(UserSign,TmpInfo) then
    begin
    //����û����ں������Ͳ�����
    if CompareText(TmpInfo.GName,SysBlacklist)=0 then exit;
    event.CreateDialogEvent(ShowInputimpact_Event,UserSign,Params);
    end;
end;
//------------------------------------------------------------------------------
//  ���������û��йص���Ϣ
//------------------------------------------------------------------------------
procedure TMessageModel.Process(Params:WideString);
var
  sOperation:WideString;
begin
  try
  if CheckNoteExists(Params,'Operation') then
    begin
    sOperation:=GetNoteFromValue(Params,'Operation');
    case StrToIntDef(sOperation,UnKnown_Command) of

      UserText_Operation:            RecvUserText(Params);
      AutoReText_Operation:          RecvUserText(Params,True);
      UserTextStatus_Operation:      RecvUserTextStatus(Params);      
      BroadCastText_Operation:       RecvBroadcast(Params);
      UserImage_Operation:           RecvUserImage(Params);

      else WriteLog('δ֪�Ĳ�������');
      end;
    end;

  except
    on e:exception do
      WriteLog(e.Message);
  end;
end;

end.
