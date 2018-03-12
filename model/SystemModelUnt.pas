unit SystemModelUnt;

interface

uses SysUtils,windows,ModelUnt;

type
  TSystemModel=class(TModel)
    private
      procedure UserLoginStatus(Params:WideString);
      procedure UserLoginResponses(Params:WideString);
      procedure UserStatusRefresh(Params:WideString);
      procedure UserLogOutStatus(Params:WideString);
    public
      procedure Process(Params:WideString);override;
  end;

implementation
uses ShareUnt,constunt,udpcores,structureunt,SimpleXmlUnt,userunt,eventunt,EventCommonUnt;

//------------------------------------------------------------------------------
//  �û�״̬�ı���Ϣ.
//------------------------------------------------------------------------------
procedure TSystemModel.UserStatusRefresh(Params:WideString);
var
  TmpInfor:TFirendInfo;
  sUserSign:String;
begin
  try
  sUserSign:=GetNoteFromValue(Params,'UserSign');

  if CompareText(sUserSign,LoginUserSign)=0 then exit;

  if User.Find(sUserSign,TmpInfor) then
    begin
    TmpInfor.Status:=GetNoteFromValue(Params,'Status');
    TmpInfor.Lanip:=GetNoteFromValue(Params,'Lanip');

    User.Update(TmpInfor);
    //֪ͨ���д���.�û���״̬�ı���.
    Event.CreateAllEvent(Refresh_UserStatus_Event,TmpInfor.UserSign,'');

    end;
  except
    on e:exception do
      WriteLog(e.Message);
  end;
end;

//------------------------------------------------------------------------------
//  �û���½��Ϣ.
//------------------------------------------------------------------------------
procedure TSystemModel.UserLoginStatus(Params:WideString);
var
  myInfor,TmpInfor:TFirendInfo;
  sUserSign:String;
  sParams:WideString;
begin
  try
  sUserSign:=GetNoteFromValue(Params,'UserSign');

  if CompareText(sUserSign,LoginUserSign)=0 then exit;

  if User.Find(sUserSign,TmpInfor) then
    begin
    TmpInfor.Status:=GetNoteFromValue(Params,'Status');
    TmpInfor.Lanip:=GetNoteFromValue(Params,'Lanip');

    User.Update(TmpInfor);

    if User.Find(LoginUserSign,myInfor) then
      begin
      if CompareText(sUserSign,LoginUserSign)=0 then exit;
      //��Ӧ�û���½����
      AddValueToNote(sParams,'function',System_Function);
      AddValueToNote(sParams,'operation',UserLoginResponses_Operation);
      AddValueToNote(sParams,'UserSign',LoginUserSign);
      AddValueToNote(sParams,'Status',myInfor.Status);
      AddValueToNote(sParams,'Lastdt',myInfor.Lastdt);

      udpcore.SendServertransfer(sParams,sUserSign);
      end;

    if TmpInfor.Lastdt<GetNoteFromValue(Params,'Lastdt') then  //��Ҫ�����û���Ϣ
      begin
      sParams:='';
      AddValueToNote(sParams,'function',Firend_Function);
      AddValueToNote(sParams,'operation',GetFirendInfor_Operation);
      AddValueToNote(sParams,'UserSign',LoginUserSign);
      udpcore.SendServertransfer(sParams,sUserSign);
      end;

    //֪ͨ������.�û���״̬�ı���.
    Event.CreateAllEvent(Refresh_UserStatus_Event,TmpInfor.UserSign,'');

  //  udpcore.playwave(xy_wave_type_newfirend);
    if showupdownhint then  //������Ϣ
      Event.CreateCoreEvent(ShowHintMesssage_Event,TmpInfor.UserSign,Format('�û� %s(%s) ������!',[TmpInfor.uname,TmpInfor.userid]));
    end;

  except
    on e:exception do
      WriteLog(e.Message);
  end;
end;

//------------------------------------------------------------------------------
//  �û���½��Ӧ��Ϣ.
//------------------------------------------------------------------------------
procedure TSystemModel.UserLoginResponses(Params:WideString);
var
  TmpInfor:TFirendInfo;
  sUserSign:String;
  sParams:WideString;
begin
  try
  sUserSign:=GetNoteFromValue(Params,'UserSign');

  if CompareText(sUserSign,LoginUserSign)=0 then exit;

  if User.Find(sUserSign,TmpInfor) then
    begin
    TmpInfor.Status:=GetNoteFromValue(Params,'Status');
    TmpInfor.Lanip:=GetNoteFromValue(Params,'Lanip');

    User.Update(TmpInfor);

    if TmpInfor.Lastdt<GetNoteFromValue(Params,'Lastdt') then  //��Ҫ�����û���Ϣ
      begin
      AddValueToNote(sParams,'function',Firend_Function);
      AddValueToNote(sParams,'operation',GetFirendInfor_Operation);
      AddValueToNote(sParams,'UserSign',LoginUserSign);
      udpcore.SendServertransfer(sParams,sUserSign);
      end;

    //֪ͨ������.�û���״̬�ı���.
    Event.CreateAllEvent(Refresh_UserStatus_Event,TmpInfor.UserSign,'');

  //  udpcore.playwave(xy_wave_type_newfirend);
    if showupdownhint then  //������Ϣ
      Event.CreateCoreEvent(ShowHintMesssage_Event,TmpInfor.UserSign,Format('�û� %s(%s) ������!',[TmpInfor.uname,TmpInfor.userid]));
    end;

  except
    on e:exception do
      WriteLog(e.Message);
  end;
end;

//------------------------------------------------------------------------------
//  �û�������Ϣ.
//------------------------------------------------------------------------------
procedure TSystemModel.UserLogOutStatus(Params:WideString);
var
  TmpInfor:TFirendInfo;
  sUserSign:String;
begin
  try
  sUserSign:=GetNoteFromValue(Params,'UserSign');

  if CompareText(sUserSign,LoginUserSign)=0 then exit;

  if User.Find(sUserSign,TmpInfor) then
    begin
    TmpInfor.Status:=3;
    User.Update(TmpInfor);
    //֪ͨ���д���.�û���״̬�ı���.
    Event.CreateAllEvent(Refresh_UserStatus_Event,TmpInfor.UserSign,'');

 //   udpcore.playwave(xy_wave_type_newfirend);
    if showupdownhint then
      Event.CreateCoreEvent(ShowHintMesssage_Event,TmpInfor.UserSign,Format('�û� %s(%s) ������!',[TmpInfor.uname,TmpInfor.userid]));

    end;

  except
    on e:exception do
      WriteLog(e.Message);
  end;
end;

//------------------------------------------------------------------------------
//  ���������û��йص���Ϣ
//------------------------------------------------------------------------------
procedure TSystemModel.Process(Params:WideString);
var
  sOperation:WideString;
begin
  try
  if CheckNoteExists(Params,'Operation') then
    begin
    sOperation:=GetNoteFromValue(Params,'Operation');
    case StrToIntDef(sOperation,UnKnown_Command) of

      UserLoginStatus_Operation:UserLoginStatus(Params);
      UserLoginResponses_Operation:UserLoginResponses(Params);
      UserOutStatus_Operation:UserLogOutStatus(Params);
      UserStatus_Operation:UserStatusRefresh(Params);

      else WriteLog('δ֪�Ĳ�������');
      end;
    end;

  except
    on e:exception do
      WriteLog(e.Message);
  end;
end;

end.
