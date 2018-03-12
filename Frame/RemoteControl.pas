unit RemoteControl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ConstUnt,
  jpeg,Gifimage,pngimage,PanelEx,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus, ImgList;

type
  TScreenSize = Record
    dMode : DWord;
    iLeft : Integer;
    iTop : Integer;
    iWidth : Integer;
    iHeigth : Integer;
  end;
  
  TRemoteControl = class(TTntForm)
    Panel_Frame: TPanelEx;
    Image_TitleLeft: TImage;
    Image_TitleCenter: TPanelEx;
    Image_TitleRight: TPanelEx;
    Panel_Left: TPanelEx;
    Panel_Right: TPanelEx;
    Panel_Bottom: TPanelEx;
    Image_BottomLeft: TImage;
    Image_BottomRight: TImage;
    Lab_Min: TTntLabel;
    Lab_Max: TTntLabel;
    Lab_Close: TTntLabel;
    ScrollBox_ScreenAera: TScrollBox;
    Lab_RmtCtlCaption: TTntLabel;
    Lab_FullScreen: TTntLabel;
    Image_ScreenColor: TPanelEx;
    Lab_ColorMode32: TTntLabel;
    Lab_ColorMode16: TTntLabel;
    Lab_ColorMode8: TTntLabel;
    Lab_ColorMode16C: TTntLabel;
    Panel_Information: TPanelEx;
    Image_InfoBkg: TImage;
    Image_InfoIco: TImage;
    Lab_Information: TTntLabel;
    ImgList_InfoIco: TImageList;
    HideInfoTimer: TTimer;
    Panel_FullScreenTitle: TPanelEx;
    Image_RetureFormMode: TImage;
    Image_FSColorMode: TImage;
    Lab_ReturnFScreen: TTntLabel;
    Lab_FSColor32: TTntLabel;
    Lab_FSColor16: TTntLabel;
    Lab_FSColor8: TTntLabel;
    Lab_FSColor16C: TTntLabel;
    Image_BottomCenter: TPanelEx;
    PaintBox: TPaintBox;
    procedure Image_TitleLeftMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image_TitleRightMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image_TitleCenterMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image_BottomRightMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Lab_MinClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Lab_CloseMouseEnter(Sender: TObject);
    procedure Lab_CloseMouseLeave(Sender: TObject);
    procedure Lab_MaxMouseEnter(Sender: TObject);
    procedure Lab_MinMouseEnter(Sender: TObject);
    procedure Lab_MinMouseLeave(Sender: TObject);
    procedure Lab_MaxMouseLeave(Sender: TObject);
    procedure Lab_FullScreenMouseEnter(Sender: TObject);
    procedure Lab_FullScreenMouseLeave(Sender: TObject);
    procedure Image_InfoBkgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HideInfoTimerTimer(Sender: TObject);
    procedure Lab_FullScreenClick(Sender: TObject);
    procedure Lab_ReturnFScreenMouseEnter(Sender: TObject);
    procedure Lab_ReturnFScreenMouseLeave(Sender: TObject);
    procedure Lab_ReturnFScreenClick(Sender: TObject);
  private
    { Private declarations }
    procedure FormMove(Sender: TObject);
    procedure InitializeFace;
    procedure PaintDefSysControl;
    procedure HideSInfo;
    procedure ShowSInfo(iType: Integer; swInfo: WideString);
    procedure ChangeScreenMode(dMode: DWord);
    procedure ShowFullScreenControl;
    procedure HideFullScreenControl;
  public
    ResizeStart:Boolean;
    procedure SetColorMode(dMode: DWord; bViewInformation:Boolean);
    { Public declarations }
  end;

Const
  COLOR_16COLOR = 0;
  COLOR_8BITCOLOR = 1;
  COLOR_16BITCOLOR = 2;
  COLOR_32BITCOLOR = 3;

var
  FrmRemoteControl: TRemoteControl;
  cColorMode, dScreenMode : DWord; //dScreenMode 0 默认 1 全屏幕
  iHideInfoTimes : Integer;
  ssRecord : TScreenSize;

implementation
uses ShareUnt;

{$R *.dfm}

//System Controls

procedure TRemoteControl.InitializeFace;
begin
  Image_TitleLeft.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis029.jpg');
  Image_TitleCenter.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis001.jpg');
  Image_TitleRight.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\RmtCtlSysCtl.bmp');
  Image_ScreenColor.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\RmtCtlSysCtlColorDef.bmp');
  Panel_Left.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis004.jpg');
  Panel_Right.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis005.jpg');
  Image_BottomLeft.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis006.jpg');
  Image_BottomRight.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis007.jpg');
  Image_BottomCenter.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis003.jpg');
  Image_InfoBkg.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis030.jpg');
end;

procedure TRemoteControl.FormMove(Sender:TObject);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TRemoteControl.Image_TitleLeftMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TRemoteControl.Image_TitleRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TRemoteControl.Image_TitleCenterMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TRemoteControl.Image_BottomRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  if (_CUR_STATE=0) Or (_CUR_STATE=1) then Perform(WM_SYSCOMMAND, $F007, 0)
    else Perform(WM_SYSCOMMAND, $F008, 0);
end;

procedure TRemoteControl.Lab_MinClick(Sender: TObject);
begin
  Perform(WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure TRemoteControl.FormResize(Sender: TObject);
begin
  if dScreenMode=1 then
   begin
    Panel_FullScreenTitle.Left := (Screen.Width-Panel_FullScreenTitle.Width) Div 2;
    Exit;
   end;
  RoundForm(Self);
end;


procedure TRemoteControl.FormCreate(Sender: TObject);
begin
  SetWindowLong(Self.Handle, GWL_STYLE, GetWindowLong(Self.Handle, GWL_STYLE) Or WS_SYSMENU or WS_MINIMIZEBOX);
  RoundForm(Self);
  InitializeFace;
  ScrollBox_ScreenAera.DoubleBuffered:=True;
  //Def Color Mode
  SetColorMode(COLOR_8BITCOLOR, False);
end;

procedure TRemoteControl.SetColorMode(dMode:DWord; bViewInformation:Boolean);
Var
  bmpBuffer : TBitmap;
  swPath, swPathFull : WideString;
begin
  if Not (dMode in [0..3]) then Exit;

  cColorMode := dMode;
  Case cColorMode of
    COLOR_16COLOR:
      begin
        swPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\RmtCtlSysCtlColor16C.bmp';
        swPathFull := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\FSCtlBarColor16C.bmp';
        if bViewInformation then ShowSInfo(0, WideFormat(CHANGE_SCREEN_COLOR, [SCREEN_COLOR_16C]));
      end;
    COLOR_8BITCOLOR:
      begin
        swPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\RmtCtlSysCtlColor8.bmp';
        swPathFull := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\FSCtlBarColor8.bmp';
        if bViewInformation then ShowSInfo(0, WideFormat(CHANGE_SCREEN_COLOR, [SCREEN_COLOR_8]));
      end;
    COLOR_16BITCOLOR:
      begin
        swPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\RmtCtlSysCtlColor16.bmp';
        swPathFull := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\FSCtlBarColor16.bmp';
        if bViewInformation then ShowSInfo(0, WideFormat(CHANGE_SCREEN_COLOR, [SCREEN_COLOR_16]));
      end;
    COLOR_32BITCOLOR:
      begin
        swPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\RmtCtlSysCtlColor32.bmp';
        swPathFull := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\FSCtlBarColor32.bmp';        
        if bViewInformation then ShowSInfo(0, WideFormat(CHANGE_SCREEN_COLOR, [SCREEN_COLOR_32]));
      end;
  end;

  if WideFileExists(swPath) then
  begin
    try
      bmpBuffer := TBitmap.Create;
      bmpBuffer.LoadFromFile(swPath);
      Image_ScreenColor.Picture.Assign(bmpBuffer);
      Image_ScreenColor.Repaint;
    finally
      if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
    end;
    try
      bmpBuffer := TBitmap.Create;
      bmpBuffer.LoadFromFile(swPathFull);
      Image_FSColorMode.Picture.Assign(bmpBuffer);
    finally
      if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
    end;    
  end;

  //这里可以添加你的色彩模式应用代码
end;

procedure TRemoteControl.Lab_CloseMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\RmtCtlSysCtlCloseHot.bmp');
    Image_TitleRight.Picture.Assign(bmpBuffer);
    Image_TitleRight.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TRemoteControl.Lab_CloseMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TRemoteControl.Lab_MaxMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\RmtCtlSysCtlMaxHot.bmp');
    Image_TitleRight.Picture.Assign(bmpBuffer);
    Image_TitleRight.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TRemoteControl.Lab_MinMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\RmtCtlSysCtlMinHot.bmp');
    Image_TitleRight.Picture.Assign(bmpBuffer);
    Image_TitleRight.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TRemoteControl.Lab_MinMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TRemoteControl.Lab_MaxMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TRemoteControl.PaintDefSysControl;
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\RmtCtlSysCtl.bmp');
    Image_TitleRight.Picture.Bitmap.Assign(bmpBuffer);
    Image_TitleRight.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TRemoteControl.Lab_FullScreenMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\RmtCtlSysCtlFSHot.bmp');
    Image_TitleRight.Picture.Assign(bmpBuffer);
    Image_TitleRight.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TRemoteControl.Lab_FullScreenMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

////////////////////////////////////////////////////////////////////////////////
//                          小信息区域控制函数                                //
////////////////////////////////////////////////////////////////////////////////

procedure TRemoteControl.ShowSInfo(iType:Integer;swInfo:WideString);
begin
  //iType, 0 信息 1 安全/传输 2 警告 3 错误 4 帮助
  ImgList_InfoIco.GetIcon(iType, Image_InfoIco.Picture.Icon);
  Lab_Information.Caption := swInfo;
  Panel_Information.Visible := True;
  iHideInfoTimes := 3;
  HideInfoTimer.Enabled := True;
end;

procedure TRemoteControl.HideSInfo;
begin
  Panel_Information.Visible := False;
end;

procedure TRemoteControl.Image_InfoBkgMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  HideSInfo;
end;

procedure TRemoteControl.HideInfoTimerTimer(Sender: TObject);
begin
  if Not Panel_Information.Visible then Exit;
  Dec(iHideInfoTimes);
  if iHideInfoTimes<=0 then
  begin
    HideSInfo;
    HideInfoTimer.Enabled := False;
  end;
end;

procedure TRemoteControl.Lab_FullScreenClick(Sender: TObject);
begin
  ChangeScreenMode(1);
end;

procedure TRemoteControl.ChangeScreenMode(dMode:DWord);
begin
  Case dMode Of
    0:
      begin
        dScreenMode := 0;
        
        try
          LockwindowUpdate(Self.Handle);
          HideFullScreenControl;
          Panel_Left.Visible := True;
          Panel_Right.Visible := True;
          Panel_Bottom.Visible := True;
          Image_TitleCenter.Visible := True;
          if ssRecord.dMode=0 then
          begin
            WindowState := wsNormal;
            Self.Left := ssRecord.iLeft;
            Self.Top := ssRecord.iTop;
            Self.Width := ssRecord.iWidth;
            Self.Height := ssRecord.iHeigth;
          end
          else WindowState := wsMaximized;
        finally
          LockwindowUpdate(0);
        end;
      end;
    1:
      begin
        dScreenMode := 1;
        
        //记录原来屏幕设定
        if WindowState = wsMaximized then ssRecord.dMode := 1
          else if WindowState = wsNormal then ssRecord.dMode := 0;
        ssRecord.iLeft := Self.Left;
        ssRecord.iTop := Self.Top;
        ssRecord.iWidth := Self.Width;
        ssRecord.iHeigth := Self.Height;

        try
          LockwindowUpdate(Self.Handle);
          WindowState := wsNormal;
          WindowState := wsMaximized;
          Self.Top := 0;
          Self.Left := 0;
          Self.Width := Screen.Width;
          Self.Height := Screen.Height;
          Panel_Left.Visible := False;
          Panel_Right.Visible := False;
          Panel_Bottom.Visible := False;
          Image_TitleCenter.Visible := False;
          FullScreenForm(Self);
          ShowFullScreenControl;
        finally
          LockwindowUpdate(0);
        end;
      end;
  end;
end;

procedure TRemoteControl.ShowFullScreenControl;
begin
  Panel_FullScreenTitle.Top := 0;
  Panel_FullScreenTitle.Left := (Screen.Width-Panel_FullScreenTitle.Width) Div 2;
  Panel_FullScreenTitle.Visible := True;
end;

procedure TRemoteControl.HideFullScreenControl;
begin
  Panel_FullScreenTitle.Visible := False;
end;

procedure TRemoteControl.Lab_ReturnFScreenMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\FSRCtlBarExitHot.bmp');
    Image_RetureFormMode.Picture.Assign(bmpBuffer);
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TRemoteControl.Lab_ReturnFScreenMouseLeave(Sender: TObject);
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\FSRCtlBarExit.bmp');
    Image_RetureFormMode.Picture.Assign(bmpBuffer);
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TRemoteControl.Lab_ReturnFScreenClick(Sender: TObject);
begin
  ChangeScreenMode(0);
end;

end.
