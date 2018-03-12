unit FirendModelUnt;

interface

uses Windows,SysUtils,SystemModelUnt;

type

  TFirendModel=class(TSystemModel)
    constructor Create;
    destructor  Destroy;override;
  protected
    procedure GetFirendInfor(Params:WideString);
    procedure UpdateFirendInfo(Params:WideString);
    procedure AddFirendInfor(Params:WideString);
    procedure FinderReponses(Params:WideString);
  public
    procedure Process(Params:WideString);override;
  end;

implementation

uses constunt,structureunt,ShareUnt,SimpleXmlUnt,Udpcores,UserUnt,eventunt,EventCommonUnt;

constructor TFirendModel.Create;
begin
  inherited Create;
end;

destructor TFirendModel.Destroy;
begin
  inherited Destroy;
end;

//------------------------------------------------------------------------------
//  �������ϸ�����Ϣ
//------------------------------------------------------------------------------
procedure TFirendModel.UpdateFirendInfo(Params:WideString);
var
  TmpInfor:Tfirendinfo;
  UserSign:WideString;
begin
  try
  if CheckNoteExists(Params,'UserSign') then
    begin
    UserSign:=GetNoteFromValue(Params,'UserSign');
    if CompareText(UserSign,LoginUserSign)=0 then exit;
    if not User.Find(UserSign,TmpInfor) then exit;

    GetNoteFromValue(Params,'FirendInfor',@TmpInfor);
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
//  �û���������.
//------------------------------------------------------------------------------
procedure TFirendModel.GetFirendInfor(Params:WideString);
var
  TmpInfor:Tfirendinfo;
  UserSign,sParams:WideString;
begin
  try
  if not User.Find(LoginUserSign,TmpInfor) then exit;
   
  if CheckNoteExists(Params,'UserSign') then
    begin
    UserSign:=GetNoteFromValue(Params,'UserSign');
    if CompareText(UserSign,LoginUserSign)=0 then exit;

    AddValueToNote(sParams,'function',Firend_Function);
    AddValueToNote(sParams,'operation',SendFirendInfor_Operation);
    AddValueToNote(sParams,'UserSign',LoginUserSign);
    AddValueToNote(sParams,'FirendInfor',TmpInfor,SizeOf(Tfirendinfo)-108);
    udpcore.SendServertransfer(sParams,UserSign);
    end;

  except
    on e:exception do
      WriteLog(e.Message);
  end;
end;

//------------------------------------------------------------------------------
//  ����̽���Ӧ
//------------------------------------------------------------------------------
procedure TFirendModel.FinderReponses(Params:WideString);
var
  TmpInfor:Tfirendinfo;
  UserSign,sParams:WideString;
begin
  AddFirendInfor(Params);
  UserSign:=GetNoteFromValue(Params,'UserSign');
  if CompareText(UserSign,LoginUserSign)=0 then exit;  
  if not User.Find(LoginUserSign,TmpInfor) then exit;

  //�ظ���ӳɹ���Ϣ
  AddValueToNote(sParams,'function',Firend_Function);
  AddValueToNote(sParams,'operation',Firend_Add_Operation);
  AddValueToNote(sParams,'UserSign',LoginUserSign);
  AddValueToNote(sParams,'FirendInfor',TmpInfor,SizeOf(Tfirendinfo)-108);
  udpcore.SendServertransfer(sParams,UserSign);
end;

//------------------------------------------------------------------------------
//  ������Ӻ���.
//------------------------------------------------------------------------------
procedure TFirendModel.AddFirendInfor(Params:WideString);
var
  TmpInfor:Tfirendinfo;
  UserSign:WideString;
begin
  try
  if CheckNoteExists(Params,'UserSign') then
    begin
    UserSign:=GetNoteFromValue(Params,'UserSign');
    if CompareText(UserSign,LoginUserSign)=0 then exit;  
    if not User.Find(UserSign,TmpInfor) then
      User.AddUser(UserSign);
    GetNoteFromValue(Params,'FirendInfor',@TmpInfor);
    User.Update(TmpInfor);
    //֪ͨ����������û�������.    
    Event.CreateMainEvent(Refresh_UserList_Event,TmpInfor.UserSign,'');
    //֪ͨ���д���.�û���״̬�ı���.
    Event.CreateAllEvent(Refresh_UserStatus_Event,TmpInfor.UserSign,'');
    end;
  except
    on e:exception do
      WriteLog(e.Message);
  end;
end;

procedure TFirendModel.Process(Params:WideString);
var
  sOperation:WideString;
begin
  try
  if CheckNoteExists(Params,'Operation') then
    begin
    sOperation:=GetNoteFromValue(Params,'Operation');
    case StrToIntDef(sOperation,UnKnown_Command) of
      GetFirendInfor_Operation:GetFirendInfor(Params);
      SendFirendInfor_Operation:UpdateFirendInfo(Params);
      Firend_Add_Operation:AddFirendInfor(Params);
      FinderResponses_Operation:FinderReponses(Params);
      else WriteLog('δ֪�Ĳ�������');
      end;
    end;

  except
    on e:exception do
      WriteLog(e.Message);
  end;
end;


end.
