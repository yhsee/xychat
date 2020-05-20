unit VideoSound;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ConstUnt,PanelEx,
  {Tnt Control}
  TntWindows, TntSysUtils, TntClasses, TntForms, TntStdCtrls, TntComCtrls,
  TntGraphics, ExtCtrls, ActnList, jpeg, StdCtrls, ImgList, Menus, TntMenus,
  RzTrkBar, RzBorder, TntExtCtrls;

type
  TFrmVideoSound = class(TTntForm)
    Panel_Video: TPanelEx;
    Image_VideoBackupGroup: TImage;
    Panel_ControlArea: TPanelEx;
    Panel_SmallVideo: TPanelEx;
    Image_SmallVideoBackupGroup: TImage;
    Lab_UserNameSmall: TTntLabel;
    Image_CutLine: TImage;
    ImgList_Control: TImageList;
    Image_Sound: TImage;
    Image_MicroPhone: TImage;
    Panel_Sound: TPanelEx;
    Panel_MicroPhone: TPanelEx;
    Lab_Yes: TTntLabel;
    Lab_Close: TTntLabel;
    RzTb_Sound: TRzTrackBar;
    RzTb_MicroPhone: TRzTrackBar;
    RzMeter_MicroPhone: TRzMeter;
    RzMeter_Sound: TRzMeter;
    Image_VideoBar: TPanelEx;
    Lab_ChangeUser: TTntLabel;
    Lab_SavePicture: TTntLabel;
    Lab_Menu: TTntLabel;
    Lab_UserName: TTntLabel;
    Panel_BackGround: TPanelEx;
    procedure Lab_SavePictureMouseEnter(Sender: TObject);
    procedure Lab_ChangeUserMouseEnter(Sender: TObject);
    procedure Lab_MenuMouseEnter(Sender: TObject);
    procedure Lab_MenuMouseLeave(Sender: TObject);
    procedure Lab_ChangeUserMouseLeave(Sender: TObject);
    procedure Lab_SavePictureMouseLeave(Sender: TObject);
    procedure Image_MicroPhoneClick(Sender: TObject);
    procedure Image_SoundClick(Sender: TObject);
  private
    { Private declarations }
    FOnMuteClick:TNotifyEvent;
    procedure EnterVideoBar(Sender: TObject);
    procedure LoadImgRes(ImgControl: TImage; swImage: WideString);overload;
    procedure LoadImgRes(ImgControl: TPanelEx; swImage: WideString);overload;
    procedure LeaveVideoBar(Sender: TObject);
  public
    procedure InitializeBox;
    procedure ReLoadBackground;
    { Public declarations }
  published
    property OnMuteClick: TNotifyEvent read FOnMuteClick write FOnMuteClick;
  end;

var
  FrmVideoSound: TFrmVideoSound;

implementation

{$R *.dfm}

procedure TFrmVideoSound.InitializeBox;
begin
  ReLoadBackground;
end;

procedure TFrmVideoSound.ReLoadBackground;
begin
  LoadImgRes(Image_VideoBackupGroup, 'Dis040.jpg');
  LoadImgRes(Image_VideoBar, 'VideoBar01.jpg');
  LoadImgRes(Image_SmallVideoBackupGroup, 'Dis045.jpg');
end;

procedure TFrmVideoSound.EnterVideoBar(Sender: TObject);
begin
  if Sender is TTntLabel then
  begin
    Case (Sender as TTntLabel).Tag of
      0: LoadImgRes(Image_VideoBar, 'VideoBar02.jpg');
      1: LoadImgRes(Image_VideoBar, 'VideoBar03.jpg');
      2: LoadImgRes(Image_VideoBar, 'VideoBar04.jpg');
    end;
  end;
end;

procedure TFrmVideoSound.LeaveVideoBar(Sender: TObject);
begin
  LoadImgRes(Image_VideoBar, 'VideoBar01.jpg');
end;

procedure TFrmVideoSound.LoadImgRes(ImgControl:TImage;swImage:WideString);
begin
  if WideFileExists(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\' + swImage) then
    ImgControl.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\' + swImage);
end;

procedure TFrmVideoSound.LoadImgRes(ImgControl: TPanelEx; swImage: WideString);
begin
  if WideFileExists(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\' + swImage) then
    ImgControl.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\' + swImage);
end;


procedure TFrmVideoSound.Lab_SavePictureMouseEnter(Sender: TObject);
begin
  EnterVideoBar(Sender);
end;

procedure TFrmVideoSound.Lab_ChangeUserMouseEnter(Sender: TObject);
begin
  EnterVideoBar(Sender);
end;

procedure TFrmVideoSound.Lab_MenuMouseEnter(Sender: TObject);
begin
  EnterVideoBar(Sender);
end;

procedure TFrmVideoSound.Lab_MenuMouseLeave(Sender: TObject);
begin
  LeaveVideoBar(Sender);
end;

procedure TFrmVideoSound.Lab_ChangeUserMouseLeave(Sender: TObject);
begin
  LeaveVideoBar(Sender);
end;

procedure TFrmVideoSound.Lab_SavePictureMouseLeave(Sender: TObject);
begin
  LeaveVideoBar(Sender);
end;

procedure TFrmVideoSound.Image_MicroPhoneClick(Sender: TObject);
Var
  bmpPic : TBitmap;
begin
  if Image_MicroPhone.Tag=0 then
  begin
    try
      bmpPic := TBitmap.Create;
      ImgList_Control.GetBitmap(3, bmpPic);
      Image_MicroPhone.Picture.Bitmap.Assign(bmpPic);
      Image_MicroPhone.Tag := 1;
      if assigned(FOnMuteClick) then
         FOnMuteClick(RzTb_MicroPhone);
    finally
      freeandnil(bmpPic);
    end;
  end
  else
  begin
    try
      bmpPic := TBitmap.Create;
      ImgList_Control.GetBitmap(2, bmpPic);
      Image_MicroPhone.Picture.Bitmap.Assign(bmpPic);
      Image_MicroPhone.Tag := 0;
      if assigned(FOnMuteClick) then
         FOnMuteClick(RzTb_MicroPhone);
    finally
      freeandnil(bmpPic);
    end;
  end;
end;

procedure TFrmVideoSound.Image_SoundClick(Sender: TObject);
Var
  bmpPic : TBitmap;
begin
  if Image_Sound.Tag=0 then
  begin
    try
      bmpPic := TBitmap.Create;
      ImgList_Control.GetBitmap(1, bmpPic);
      Image_Sound.Picture.Bitmap.Assign(bmpPic);
      Image_Sound.Tag := 1;
      if assigned(FOnMuteClick) then
         FOnMuteClick(RzTb_Sound);
    finally
      freeandnil(bmpPic);
    end;
  end
  else
  begin
    try
      bmpPic := TBitmap.Create;
      ImgList_Control.GetBitmap(0, bmpPic);
      Image_Sound.Picture.Bitmap.Assign(bmpPic);
      Image_Sound.Tag := 0;
      if assigned(FOnMuteClick) then
         FOnMuteClick(RzTb_Sound);
    finally
      freeandnil(bmpPic);
    end;
  end;
end;

end.
