unit frmMediaUnt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Menus,Jpeg, Buttons,constunt,structureunt,
  math,ComCtrls,DirectShowUnt,avplayunt,EventCommonUnt,UDPStreamUnt,
  {Frame}
  VideoSound,
  {Tnt Control}
  TntClasses, TntSysUtils, TntStdCtrls, TntComCtrls, TntGraphics, TntForms,
  TntExtCtrls, TntMenus;
  
Type
  TfrmMedia = class(TFrmVideoSound)
    AVideo_PopupMenu: TTntPopupMenu;
    ITEM_AllowVideo: TTntMenuItem;
    ITEM_Allowaudio: TTntMenuItem;
    ITEM_Break: TTntMenuItem;
    ITEM_VideoConfig: TTntMenuItem;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ITEM_AllowVideoClick(Sender: TObject);
    procedure ITEM_AllowaudioClick(Sender: TObject);
    procedure ITEM_VideoConfigClick(Sender: TObject);
  private
    FVideoPlayback,
    FVideoPerview:TVideoPlayback;

    UDPMedia:TUDPStream;

    FServer:boolean;    //请求方与被邀请方
    FUserSign:string;

    InitiativeClose,just_talking,
    allowaudio,allowvideo,VideoSwap:boolean;

    procedure InitialUDPConnect(Params:WideString);
    procedure CloseTrans;
    procedure media_starting;
    procedure media_Accept(Params:WideString);
    procedure media_cancel;
    procedure media_refuse;
    procedure media_complete;
    procedure PerviewVideo(Sender:TObject;mBitmap:TBitmap);
    //--------------------------------------------------------------------------
    procedure BuildVideoStream(mSample:TMemoryStream);
    procedure PlayVideo(Sender:TObject;mBitmap:TBitmap);
    procedure EventProcess(Sender:TObject;TmpEvent:TEventData);
    procedure UDPMediaOnRecvComplete(Sender:TObject;AData:TStream);
    procedure UDPMediaOnDisconnect(Sender:TObject);
    { Private declarations }
  protected
    procedure Lab_YesClick(Sender: TObject);
    procedure Lab_CloseClick(Sender: TObject);
    procedure Lab_MenuClick(Sender: TObject);
    procedure Lab_ChangeUserClick(Sender: TObject);
    procedure Lab_SavePictureClick(Sender: TObject);
    procedure setwaveaudio(Sender: TObject);
    procedure setwavemute(Sender: TObject);
    procedure getwaveaudio;
    procedure getwavemute;
    procedure UserStatusChange;
  public
    procedure CreateComplete(sUserSign:String;const bServer:boolean=false);
  end;

implementation
uses udpcores,shareunt,funVolume,md5unt,SimpleXmlunt,userunt,EventUnt;
{$R *.DFM}

procedure TfrmMedia.EventProcess(Sender:TObject;TmpEvent:TEventData);
begin
  case TmpEvent.iEvent of
  //------------------------------------------------------------------------------
  // 刷新要改变状态的用户
  //------------------------------------------------------------------------------
    Refresh_UserStatus_Event:UserStatusChange;

    Media_Refuse_Event:media_refuse;
    Media_Accept_Event:media_Accept(TmpEvent.UserParams);    
    Media_Cancel_Event:media_cancel;
    Media_complete_Event:media_complete;

    Close_Form_Event:Close;
  end;
end;

//******************************************************************************
//  传输意外中止
//******************************************************************************
procedure TfrmMedia.UserStatusChange;
var
  TmpInfor:tfirendinfo;
begin
  if user.find(FUserSign,TmpInfor) then
  if TmpInfor.status=3 then //用户下线了..
     begin
     InitiativeClose:=false;
     udpcore.InsertFirendHintMessage(FUserSign,WideString('对方下线了，强行中止视频！'));
     event.CreateDialogEvent(Media_Complete_Event,FUserSign,'');
     end;
end;

procedure TfrmMedia.InitialUDPConnect(Params:WideString);
var
  TmpInfor:Tfirendinfo;
begin
  if not user.find(FUserSign,TmpInfor) then exit;
  UDPMedia.Connect(TmpInfor.Lanip,GetNoteFromValue(Params,'MediaPort'));
  Sleep(100);
end;

//------------------------------------------------------------------------------
//  初始化端口
//------------------------------------------------------------------------------
procedure TfrmMedia.media_starting;
var
  TmpInfor:Tfirendinfo;
  sParams:WideString;
  TmpStream:TMemoryStream;
begin
  try
  TmpStream:=TMemoryStream.Create;
  ControlFlash(True);
  if user.find(FUserSign,TmpInfor) then
    begin
    udpcore.VideoDirectShow.Videostart;

    udpcore.VideoDirectShow.GetVideoMediaType(TmpStream);
    FVideoPerview.StartPlayback(TmpStream);
        
    AddValueToNote(sParams,'function',Media_Function);
    AddValueToNote(sParams,'operation',Media_Accept_Operation);
    AddValueToNote(sParams,'UserSign',LoginUserSign);
    AddValueToNote(sParams,'MediaPort',UDPMedia.LocalPort);
    AddValueToNote(sParams,'VMediaTypes',TmpStream);
    udpcore.SendServertransfer(sParams,FUserSign);
    end;

  finally
  freeandnil(TmpStream);
  end;    
end;

procedure TfrmMedia.media_Accept(Params:WideString);
var
  sParams:WideString;
  TmpStream:TMemoryStream;
begin
  try
  TmpStream:=TMemoryStream.Create;
  ControlFlash(False);
  InitialUDPConnect(Params);
  GetNoteFromValue(Params,'VMediaTypes',TmpStream);
  FVideoplayback.StartPlayback(TmpStream);
  just_talking:=True;
  if FServer then
    begin
    udpcore.VideoDirectShow.Videostart;
    TmpStream.Clear;
    udpcore.VideoDirectShow.GetVideoMediaType(TmpStream);
    FVideoPerview.StartPlayback(TmpStream);
    
    AddValueToNote(sParams,'function',Media_Function);
    AddValueToNote(sParams,'operation',Media_Accept_Operation);
    AddValueToNote(sParams,'UserSign',LoginUserSign);
    AddValueToNote(sParams,'MediaPort',UDPMedia.LocalPort);
    AddValueToNote(sParams,'VMediaTypes',TmpStream);
    udpcore.SendServertransfer(sParams,FUserSign);
    end;
  finally
  freeandnil(TmpStream);
  end;
end;

procedure TfrmMedia.media_cancel;
begin
  InitiativeClose:=false;
  udpcore.InsertFirendHintMessage(FUserSign,WideString('对方取消了视频！'));
  event.CreateDialogEvent(Media_Complete_Event,FUserSign,'');
end;

procedure TfrmMedia.media_refuse;
begin
  InitiativeClose:=false;
  udpcore.InsertFirendHintMessage(FUserSign,WideString('对方拒绝了您的视频！'));
  event.CreateDialogEvent(Media_Complete_Event,FUserSign,'');
end;

procedure TfrmMedia.media_complete;
begin
  InitiativeClose:=false;
  udpcore.InsertFirendHintMessage(FUserSign,WideString('对方停止了视频！'));
  event.CreateDialogEvent(Media_Complete_Event,FUserSign,'');
end;

procedure TfrmMedia.Lab_YesClick(Sender: TObject);
begin
  Lab_Yes.Visible:=false;
  Lab_Close.Caption:='取消';
  media_starting;
end;

procedure TfrmMedia.Lab_CloseClick(Sender: TObject);
begin
  event.CreateDialogEvent(Media_Complete_Event,FUserSign,'');
end;

//------------------------------------------------------------------------------
//  退出
//------------------------------------------------------------------------------
procedure TfrmMedia.CloseTrans;
var
  sParams:WideString;
begin
  if InitiativeClose then
    begin
    if just_talking then
      begin
      just_talking:=false;
      AddValueToNote(sParams,'operation',Media_Complete_Operation);
      udpcore.InsertFirendHintMessage(FUserSign,WideString('您停止了语音视频！'));
      end else begin
      if FServer then
        begin
        AddValueToNote(sParams,'operation',Media_Cancel_Operation);
        udpcore.InsertFirendHintMessage(FUserSign,WideString('您取消了语音视频！'));
        end else begin
        udpcore.InsertFirendHintMessage(FUserSign,WideString('您拒绝了语音视频！'));
        AddValueToNote(sParams,'operation',Media_Refuse_Operation);
        end;
      end;
    AddValueToNote(sParams,'function',Media_Function);
    AddValueToNote(sParams,'UserSign',LoginUserSign);
    udpcore.SendServertransfer(sParams,FUserSign);
    end;
  just_talking:=false;
end;

//------------------------------------------------------------------------------
//  语音视频播放
//------------------------------------------------------------------------------
procedure TfrmMedia.UDPMediaOnRecvComplete(Sender:TObject;AData:TStream);
begin
  if CompareText(UDPMedia.sReserve,'VideoStream')=0 then
    begin
    AData.Seek(0,0);
    FVideoplayback.VideoPlaySample(AData);
    end;
end;

procedure TfrmMedia.UDPMediaOnDisconnect(Sender:TObject);
begin
  if just_talking then
    begin
    InitiativeClose:=false;
    udpcore.InsertFirendHintMessage(FUserSign,WideString('语音视频通道超时断开！'));
    event.CreateDialogEvent(Media_Complete_Event,FUserSign,'');
    end;
end;

//------------------------------------------------------------------------------
// 视频发送
//------------------------------------------------------------------------------
Procedure TfrmMedia.BuildVideoStream(mSample:TMemoryStream);
begin
  FVideoPerview.VideoPlaySample(mSample);
  if just_talking and allowvideo then
    UDPMedia.SendStream(mSample,'VideoStream');
end;

//------------------------------------------------------------------------------
//  播放视频
//------------------------------------------------------------------------------
procedure TfrmMedia.PlayVideo(Sender:TObject;mBitmap:TBitmap);
begin
  if just_talking then
    begin
    if not VideoSwap then
      begin
      Image_VideoBackupGroup.Picture.Bitmap.Assign(mBitmap);
      Image_VideoBackupGroup.Invalidate;
      end else begin
      Image_SmallVideoBackupGroup.Picture.Bitmap.Assign(mBitmap);
      Image_SmallVideoBackupGroup.Invalidate;
      end;
    end
end;

//------------------------------------------------------------------------------
//  视频源信号
//------------------------------------------------------------------------------
procedure TfrmMedia.PerviewVideo(Sender:TObject;mBitmap:TBitmap);
begin
 if VideoSwap then
   begin
   Image_VideoBackupGroup.Picture.Graphic.Assign(mBitmap);
   Image_VideoBackupGroup.Invalidate;
   end else begin
   Image_SmallVideoBackupGroup.Picture.Graphic.Assign(mBitmap);
   Image_SmallVideoBackupGroup.Invalidate;
   end;
end;

procedure TfrmMedia.ITEM_AllowVideoClick(Sender: TObject);
begin
  ITEM_AllowVideo.checked:=not ITEM_AllowVideo.Checked;
  allowvideo:=not ITEM_AllowVideo.checked;
end;

procedure TfrmMedia.ITEM_AllowaudioClick(Sender: TObject);
begin
  ITEM_Allowaudio.checked:=not ITEM_Allowaudio.Checked;
  allowaudio:=not ITEM_Allowaudio.checked;
end;

procedure TfrmMedia.ITEM_VideoConfigClick(Sender: TObject);
begin
  udpcore.VideoDirectShow.videoseting(handle);
end;

procedure TfrmMedia.Lab_MenuClick(Sender: TObject);
var
  TmpPoint:tpoint;
begin
  GetCursorPos(TmpPoint);
  AVideo_PopupMenu.Popup(TmpPoint.x,TmpPoint.y); 
end;

procedure TfrmMedia.Lab_ChangeUserClick(Sender: TObject);
var
  sTmpStr:string;
begin
  VideoSwap:=not VideoSwap;
  sTmpStr:=Lab_UserNameSmall.Caption;
  Lab_UserNameSmall.Caption:=Lab_UserName.Caption;
  Lab_UserName.Caption:=sTmpStr;
  ReLoadBackground;
end;

procedure TfrmMedia.Lab_SavePictureClick(Sender: TObject);
var
  Tmpjpg:TJpegimage;
begin
  try
  Tmpjpg:=TJpegimage.Create;
  Tmpjpg.Assign(Image_VideoBackupGroup.Picture.Graphic);
  With Tsavedialog.Create(nil) do
    try
    Title:='保存图片';
    Filter:='JPEG图片|*.jpg';
    DefaultExt:='.jpg';
    InitialDir:=DefaultSaveDir;
    if execute then
       Tmpjpg.SaveToFile(filename);
    finally
    free;
    end;
  finally
  freeandnil(Tmpjpg);
  end;
end;

procedure TfrmMedia.setwaveaudio(Sender: TObject);
begin
  if Sender=RzTb_Sound then
    SetVolume(dnMaster,RzTb_Sound.position)
    else SetVolume(Microphone,RzTb_MicroPhone.position);
end;

procedure TfrmMedia.setwavemute(Sender: TObject);
begin
  inherited;
  if sender=Image_Sound then
    SetVolumeMute(dnMaster,Image_Sound.Tag=0)
    else SetVolumeMute(Microphone,Image_MicroPhone.Tag=0);
end;

procedure TfrmMedia.getwavemute;
begin
  if not GetVolumeMute(dnMaster) then
     Image_Sound.Tag:=0 else Image_Sound.Tag:=1;
  Image_Sound.OnClick(Image_Sound);
  if not GetVolumeMute(Microphone) then
     Image_MicroPhone.Tag:=0 else Image_MicroPhone.Tag:=1;
  Image_MicroPhone.OnClick(Image_MicroPhone);
end;


procedure TfrmMedia.getwaveaudio;
begin
  RzTb_Sound.position:=GetVolume(dnMaster);
  RzTb_MicroPhone.position:=GetVolume(Microphone);
end;

procedure TfrmMedia.FormCreate(Sender: TObject);
begin
  inherited;
  InitializeBox;//初始化
  InitiativeClose:=true;
  JustAVideoConnect:=True;
  Lab_ChangeUser.OnClick:=Lab_ChangeUserClick;
  Lab_SavePicture.OnClick:=Lab_SavePictureClick;
  Lab_Menu.OnClick:=Lab_MenuClick;
  Lab_Yes.OnClick:=Lab_YesClick;
  Lab_Close.OnClick:=Lab_CloseClick;
  RzTb_Sound.OnChange:=setwaveaudio;
  RzTb_MicroPhone.OnChange:=setwaveaudio;
  OnMuteClick:=setwavemute;
  getwaveaudio;
  getwavemute;

  FVideoPlayback:=TVideoPlayback.Create;
  FVideoPerview:=TVideoPlayback.Create;

  UDPMedia:=TUDPStream.Create;

  UDPMedia.OnUDPRecvComplete:=UDPMediaOnRecvComplete;
  UDPMedia.onDisconnect:=UDPMediaOnDisconnect;
  UDPMedia.InitialUdpTransfers('0.0.0.0');

  FVideoPlayback.OnVideoPlay:=playvideo;
  FVideoPerview.OnVideoPlay:=PerviewVideo;
  udpcore.VideoDirectShow.CaptureVideo:=BuildVideoStream;
end;

procedure TfrmMedia.FormDestroy(Sender: TObject);
begin
  allowvideo:=false;
  allowAudio:=false;
  udpcore.VideoDirectShow.CaptureVideo:=nil;
  udpcore.VideoDirectShow.VideoStop;
  JustAVideoConnect:=false;
  CloseTrans;
  FInitializeBox;
  Event.RemoveEventProcess(Event_Media,FUserSign);
  if assigned(FVideoPerview) then freeandnil(FVideoPerview);
  if assigned(FVideoPlayback) then freeandnil(FVideoPlayback);
  if assigned(UDPMedia) then freeandnil(UDPMedia);
  inherited;
end;

procedure TfrmMedia.CreateComplete(sUserSign:String;const bServer:boolean=false);
var
  sParams:WideString;
  TmpInfor,myinfo:Tfirendinfo;
begin
  FServer:=bServer;
  FUserSign:=sUserSign;
  if not user.Find(LoginUserSign,myinfo) then exit;
  if not user.Find(FUserSign,TmpInfor) then exit;
  Event.CreateEventProcess(EventProcess,Event_Media,FUserSign);

  Lab_UserNameSmall.Caption:=myinfo.uname;
  Lab_UserName.Caption:=TmpInfor.uname;
  if FServer then
    begin
    Lab_Yes.Visible:=false;
    Lab_Close.Caption:='取消';
    end;

  allowvideo:=True;
  allowaudio:=True;

  if FServer then
    begin
    AddValueToNote(sParams,'function',Media_Function);
    AddValueToNote(sParams,'operation',Media_Request_Operation);
    AddValueToNote(sParams,'UserSign',LoginUserSign);
    udpcore.SendServertransfer(sParams,FUserSign);
    end;
end;
  
end.
