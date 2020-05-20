//------------------------------------------------------------------------------
//  简化了的文件传输 专门用于传输 图片
//------------------------------------------------------------------------------
unit downpicunt;

interface

uses
  Windows, SysUtils,Classes,ExtCtrls,
  constunt,structureunt,UDPStreamUnt,math,
  EventCommonUnt,
  {Tnt Control}
  TntClasses, TntSysUtils, TntStdCtrls;

Type
   TDownPicComplete=procedure(Sender:TObject;sFileSign:String)of Object;
   TDownPicRequest=procedure(Sender:TObject;var sFileSign:String)of Object;
   Tdownpic=class
    constructor Create;
    destructor  Destroy;override;
    private
      UDPImage:TUDPStream;
      //------------------------------------------------------------------------
      FCurFileSign,
      FDefaultPath,
      UserSign:String;
      FOnRequest:TDownPicRequest;
      FOnComplete:TDownPicComplete;
      FOutTimer:TTimer;
      //------------------------------------------------------------------------
      procedure UDPRecvReady(Sender:TObject;var sNewFileName:WideString; iSize:Int64);
      procedure UDPRecvComplete(Sender:TObject;AData:TStream);
      procedure RecvOutTimer(Sender:TObject);
      //------------------------------------------------------------------------
    public
      procedure UserImage_Request(Params:WideString);
      procedure UserImage_Complete(Params:WideString);
      procedure InitialComplete(sUserSign:String);
      procedure StratRequestDownPicture;
    published
      property OnRequest:TDownPicRequest Write FOnRequest;
      property OnComplete:TDownPicComplete Write FOnComplete;
    end;

implementation
uses ShareUnt,udpcores,ImageOleUnt,UserUnt,EventUnt,SimpleXmlUnt;
//------------------------------------------------------------------------------
// 创建
//------------------------------------------------------------------------------
constructor Tdownpic.Create;
begin
  inherited Create;
  FCurFileSign:='';
  FOutTimer:=TTimer.Create(nil);
  FOutTimer.Interval:=15000;
  FOutTimer.OnTimer:=RecvOutTimer;
  FOutTimer.Enabled:=False;
    
  UDPImage:=TUDPStream.Create;
  UDPImage.onDisconnect:=RecvOutTimer;
  UDPImage.OnUDPRecvComplete:=UDPRecvComplete;
  UDPImage.OnUDPRecvReady:=UDPRecvReady;
  UDPImage.InitialUdpTransfers('0.0.0.0');
end;

//------------------------------------------------------------------------------
// 释放
//------------------------------------------------------------------------------
destructor Tdownpic.Destroy;
begin
  FOutTimer.Enabled:=False;
  UDPImage.onDisconnect:=nil;
  UDPImage.OnUDPRecvComplete:=nil;
  if assigned(FOutTimer) then
    freeandnil(FOutTimer);
  if assigned(UDPImage) then
    begin
    UDPImage.CloseServer;
    freeandnil(UDPImage);
    end;
  inherited Destroy;
end;

//------------------------------------------------------------------------------
// 初始化
//------------------------------------------------------------------------------
procedure Tdownpic.InitialComplete(sUserSign:String);
var
  Tmpinfor:TFirendInfo;
begin
  UserSign:=sUserSign;
  FDefaultPath:=ConCat(WideExtractfilepath(Application_Name),'UserData\',LoginUser,'\images\');
  ForceCreateDirectorys(FDefaultPath);
  if not user.Find(LoginUserSign,Tmpinfor) then exit;
  if not user.Find(UserSign,Tmpinfor) then exit;
end;

//------------------------------------------------------------------------------
// 开始请求
//------------------------------------------------------------------------------
procedure Tdownpic.StratRequestDownPicture;
var
  Params:WideString;
begin
  if Length(FCurFileSign)=0 then
    begin
    if assigned(FOnRequest) then FOnRequest(nil,FCurFileSign);
    if Length(FCurFileSign)=34 then
      begin
      FOutTimer.Enabled:=True;
      AddValueToNote(Params,'function',Message_Function);
      AddValueToNote(Params,'operation',UserImage_Operation);
      AddValueToNote(Params,'UserSign',LoginUserSign);
      AddValueToNote(Params,'ImagePort',UDPImage.LocalPort);
      AddValueToNote(Params,'sFileSign',FCurFileSign);
      udpcore.SendServertransfer(Params,UserSign);
      end;
    end;
end;

procedure Tdownpic.RecvOutTimer(Sender:TObject);
begin
  FOutTimer.Enabled:=False;
  if assigned(FOnComplete) then
    FOnComplete(nil,FCurFileSign);
end;

//------------------------------------------------------------------------------
// 开始发送
//------------------------------------------------------------------------------
procedure Tdownpic.UserImage_Request(Params:WideString);
var
  sTmpStr,UserSign:String;
  sFileName:WideString;
  TmpInfor:TfirendInfo;
begin
  sTmpStr:=GetNoteFromValue(Params,'sFileSign');
  UserSign:=GetNoteFromValue(Params,'UserSign');
  if User.Find(UserSign,TmpInfor) then
    begin
    if not UDPImage.Connected then
      begin
      UDPImage.Connect(TmpInfor.Lanip,GetNoteFromValue(Params,'ImagePort'));
      Sleep(100);
      end;
    if ImageOle.GetImageFileName(sTmpStr,sFileName) then
      UDPImage.SendFile(sFileName);
    end;
end;

procedure Tdownpic.UserImage_Complete(Params:WideString);
begin
  if assigned(FOnComplete) then
    FOnComplete(nil,Params);
end;


procedure Tdownpic.UDPRecvReady(Sender:TObject;var sNewFileName:WideString; iSize:Int64);
begin
  sNewFileName:=ConCat(FDefaultPath,UTF8Decode(UDPImage.sReserve));
end;

//------------------------------------------------------------------------------
// 非同步线程
//------------------------------------------------------------------------------
procedure Tdownpic.UDPRecvComplete(Sender:TObject;AData:TStream);
var
  sTmpStr,
  sFileName:WideString;
begin
  FOutTimer.Enabled:=False;
  sFileName:=ConCat(FDefaultPath,UTF8Decode(UDPImage.sReserve));
  if WideFileExists(sFileName) then
    ImageOle.AddFileToImageOle(sFileName);
  sTmpStr:=FCurFileSign;
  FCurFileSign:='';
  event.CreateDialogEvent(UserImage_Complete_Event,UserSign,sTmpStr);
end;

end.
