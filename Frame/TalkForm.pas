unit TalkForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg, StdCtrls, ConstUnt, ToolWin,
  ComCtrls, Buttons, RichEditOleUnt,SunExpandWorkForm,PanelEx,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus, TntButtons, ImgList;

type
  TTntRichedit = Class(TRichEditOle);
  TTalkForm = class(TTntForm)
    Panel_Frame: TTntPanel;
    Panel_Title: TPanelEx;
    Image_TitleRight: TPanelEx;
    Panel_Left: TPanelEx;
    Panel_Right: TPanelEx;
    Panel_Bottom: TPanelEx;
    Image_BottomLeft: TImage;
    Image_BottomRight: TImage;
    Lab_Min: TTntLabel;
    Lab_Max: TTntLabel;
    Lab_Close: TTntLabel;
    Image_ToolBarBkg: TPanelEx;
    Panel_CharArea: TPanel;
    Image_SendFile: TImage;
    Lab_SendFile: TTntLabel;
    Image_RmtControl: TImage;
    Lab_RmtControl: TTntLabel;
    Image_VSChat: TImage;
    Lab_VSChat: TTntLabel;
    Panel_UserInputArea: TPanel;
    Image_SendMsg: TPanelEx;
    Panel_CenterControl: TPanelEx;
    HistoryImage: TPanelEx;
    Tsb_Icon: TTntSpeedButton;
    Tsb_Font: TTntSpeedButton;
    Tsb_SendImage: TTntSpeedButton;
    Tsb_CopyScreen: TTntSpeedButton;
    Tsb_QuickSend: TTntSpeedButton;
    Image_Cutline1: TImage;
    Image_Cutline2: TImage;
    Panel_InputBox: TPanel;
    Image_ChatInput_Left: TPanelEx;
    Image_ChatInput_Right: TPanelEx;
    Panel_ChatInputUpDownLine: TPanel;
    Image_ChatInput_Top: TPanelEx;
    Image_ChatInput_Buttom: TPanelEx;
    Send_Memo: TTntRichEdit;
    Panel_ChatViewArea: TPanel;
    Panel_ChatViewBox: TPanel;
    Image_ChatView_Left: TPanelEx;
    Image_ChatView_Right: TPanelEx;
    Panel_ChatUpDownLine: TPanel;
    Image_ChatView_Top: TPanelEx;
    main_memo: TTntRichEdit;
    Image_ChatView_Buttom: TPanelEx;
    Image_InfoArea: TPanelEx;
    Image_InfoIco: TImage;
    ImgList_InfoIco: TImageList;
    Lab_SmallInfo: TTntLabel;
    HideInfoTimer: TTimer;
    TitleIcon: TImage;
    Lab_SendMsg: TTntLabel;
    Lab_SendMsgMenu: TTntLabel;
    Lab_FormCaption: TTntLabel;
    Image_TitleLeft: TImage;
    Image_HidePanel: TImage;
    procedure Image_TitleLeftMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image_TitleRightMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image_TitleCenterMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image_BottomRightMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Lab_MinClick(Sender: TObject);
    procedure Lab_MaxClick(Sender: TObject);
    procedure Lab_CloseClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Lab_CloseMouseEnter(Sender: TObject);
    procedure Lab_CloseMouseLeave(Sender: TObject);
    procedure Lab_MaxMouseEnter(Sender: TObject);
    procedure Lab_MinMouseEnter(Sender: TObject);
    procedure Lab_MinMouseLeave(Sender: TObject);
    procedure Lab_MaxMouseLeave(Sender: TObject);
    procedure Lab_SendFileMouseEnter(Sender: TObject);
    procedure Lab_SendFileMouseLeave(Sender: TObject);
    procedure Lab_RmtControlMouseEnter(Sender: TObject);
    procedure Lab_RmtControlMouseLeave(Sender: TObject);
    procedure Lab_VSChatMouseEnter(Sender: TObject);
    procedure Lab_VSChatMouseLeave(Sender: TObject);
    procedure Lab_SendMsgMouseEnter(Sender: TObject);
    procedure Lab_SendMsgMouseLeave(Sender: TObject);
    procedure Lab_SendMsgMenuMouseEnter(Sender: TObject);
    procedure Image_TitleLeftDblClick(Sender: TObject);
    procedure Image_InfoAreaClick(Sender: TObject);
    procedure HideInfoTimerTimer(Sender: TObject);
    procedure Image_HidePanelClick(Sender: TObject);
    procedure Panel_CenterControlResize(Sender: TObject);
  private
    iHideInfoTimes : Integer;
    { Private declarations }
    procedure FormMove(Sender: TObject);
    procedure InitializeFace;
    procedure PaintDefSysControl;
    procedure ResizeChatForm;
  public
    FrmSunExpandWorkForm : TFrmSunExpandWorkForm;
    procedure HideSInfo;
    procedure ShowSInfo(iType: Integer; swInfo: WideString);Overload;
    procedure ShowSInfo(iType: Integer; swInfo: WideString;AutoClose:Boolean);Overload;
    { Public declarations }
  end;

implementation
uses ShareUnt,Activex;
{$R *.dfm}

//System Controls

procedure TTalkForm.InitializeFace;
begin
  Panel_Title.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis001.jpg');
  Image_TitleLeft.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis018.jpg');
  Image_TitleRight.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis002.jpg');
  Panel_Left.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis004.jpg');
  Panel_Right.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis005.jpg');
  Image_BottomLeft.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis006.jpg');
  Image_BottomRight.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis007.jpg');
  Panel_Bottom.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis003.jpg');
  Image_ToolBarBkg.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\TalkBkg.jpg');
  Image_SendFile.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SendFile.bmp');
  Image_RmtControl.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\RmtControl.bmp');
  Image_VSChat.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\VS.bmp');
  Image_SendMsg.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SendMsg.bmp');
  Image_ChatInput_Left.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis019.jpg');
  Image_ChatInput_Right.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis020.jpg');
  Image_ChatInput_Top.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis021.jpg');
  Image_ChatInput_Buttom.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis024.jpg');
  Image_ChatView_Left.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis026.jpg');
  Image_ChatView_Right.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis027.jpg');
  Image_ChatView_Top.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis021.jpg');
  Image_ChatView_Buttom.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis025.jpg');
  Image_InfoArea.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis028.jpg');
  Panel_CenterControl.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis036.jpg');
  Image_Cutline1.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis037.jpg');
  Image_Cutline2.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis037.jpg');
  Image_HidePanel.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Indent.bmp');
  HistoryImage.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis023.jpg');
end;

procedure TTalkForm.FormMove(Sender:TObject);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TTalkForm.Image_TitleLeftMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TTalkForm.Image_TitleRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TTalkForm.Image_TitleCenterMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TTalkForm.Image_BottomRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  if (_CUR_STATE=0) Or (_CUR_STATE=1) then Perform(WM_SYSCOMMAND, $F006, 0)
    else Perform(WM_SYSCOMMAND, $F008, 0);
end;

procedure TTalkForm.Lab_MinClick(Sender: TObject);
begin
  Perform(WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure TTalkForm.Lab_MaxClick(Sender: TObject);
begin
  if (_CUR_STATE=0) Or (_CUR_STATE=1) then Exit;

  if Self.WindowState <> wsMaximized then
  begin
    try
      LockwindowUpdate(Self.Handle);
      WindowState := wsMaximized;
      Self.Top:=0;
      Self.Left:=0;
      Self.Width:=Screen.WorkAreaWidth;
      Self.Height:=Screen.WorkAreaHeight;
    finally
      LockwindowUpdate(0);
    end;
    Lab_Max.Hint := APPLICATION_RESIZE;
  end
  else
  begin
    WindowState := wsNormal;
    //Perform(WM_SYSCOMMAND, SC_RESTORE, 0);
    Lab_Max.Hint := APPLICATION_MAX;
  end; 
end;

procedure TTalkForm.Lab_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TTalkForm.FormResize(Sender: TObject);
begin
  RoundForm(self);
end;

procedure TTalkForm.FormCreate(Sender: TObject);
begin
  Self.DoubleBuffered := True;
  
  SetWindowLong(Self.Handle, GWL_STYLE, GetWindowLong(Self.Handle, GWL_STYLE) Or WS_SYSMENU or WS_MINIMIZEBOX);
  RoundForm(Self);

  InitializeFace;
  FormResize(Sender);

  //创建扩展区
  FrmSunExpandWorkForm := TFrmSunExpandWorkForm.Create(Panel_Frame);
  FrmSunExpandWorkForm.Parent := Panel_Frame;
  FrmSunExpandWorkForm.Align := alRight;
  FrmSunExpandWorkForm.Width := 166;
  FrmSunExpandWorkForm.SetMainForm(Self);
  FrmSunExpandWorkForm.Show;
  //显示小信息
  ShowSInfo(0, '欢迎使用雅乐IM系统！');
end;

procedure TTalkForm.Lab_CloseMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
  swImgPath : WideString;
begin
  swImgPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SysCtlCloseHot.bmp';
  if Not WideFileExists(swImgPath) then Exit;

  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swImgPath);
    Image_TitleRight.Picture.Assign(bmpBuffer);
    Image_TitleRight.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TTalkForm.Lab_CloseMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TTalkForm.Lab_MaxMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
  swImgPath : WideString;
begin
  swImgPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SysCtlMaxHot.bmp';
  if Not WideFileExists(swImgPath) then Exit;

  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swImgPath);
    Image_TitleRight.Picture.Assign(bmpBuffer);
    Image_TitleRight.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TTalkForm.Lab_MinMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
  swImgPath : WideString;
begin
  swImgPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SysCtlMinHot.bmp';
  if Not WideFileExists(swImgPath) then Exit;

  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swImgPath);
    Image_TitleRight.Picture.Assign(bmpBuffer);
    Image_TitleRight.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TTalkForm.Lab_MinMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TTalkForm.Lab_MaxMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TTalkForm.PaintDefSysControl;
Var
  bmpBuffer : TBitmap;
  swImgPath : WideString;
begin
  swImgPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SysCtlDef.bmp';
  if Not WideFileExists(swImgPath) then Exit;

  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swImgPath);
    Image_TitleRight.Picture.Bitmap.Assign(bmpBuffer);
    Image_TitleRight.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TTalkForm.Lab_SendFileMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
  swImgPath : WideString;
begin
  swImgPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SendFileHot.bmp';
  if Not WideFileExists(swImgPath) then Exit;

  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swImgPath);
    Image_SendFile.Picture.Assign(bmpBuffer);
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TTalkForm.Lab_SendFileMouseLeave(Sender: TObject);
Var
  bmpBuffer : TBitmap;
  swImgPath : WideString;
begin
  swImgPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SendFile.bmp';
  if Not WideFileExists(swImgPath) then Exit;
  
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swImgPath);
    Image_SendFile.Picture.Assign(bmpBuffer);
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TTalkForm.Lab_RmtControlMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
  swImgPath : WideString;
begin
  swImgPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\RmtControlHot.bmp';
  if Not WideFileExists(swImgPath) then Exit;

  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swImgPath);
    Image_RmtControl.Picture.Assign(bmpBuffer);
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TTalkForm.Lab_RmtControlMouseLeave(Sender: TObject);
Var
  bmpBuffer : TBitmap;
  swImgPath : WideString;
begin
  swImgPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\RmtControl.bmp';
  if Not WideFileExists(swImgPath) then Exit;

  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swImgPath);
    Image_RmtControl.Picture.Assign(bmpBuffer);
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TTalkForm.Lab_VSChatMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
  swImgPath : WideString;
begin
  swImgPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\VSHot.bmp';
  if Not WideFileExists(swImgPath) then Exit;

  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swImgPath);
    Image_VSChat.Picture.Assign(bmpBuffer);
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TTalkForm.Lab_VSChatMouseLeave(Sender: TObject);
Var
  bmpBuffer : TBitmap;
  swImgPath : WideString;
begin
  swImgPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\VS.bmp';
  if Not WideFileExists(swImgPath) then Exit;

  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swImgPath);
    Image_VSChat.Picture.Assign(bmpBuffer);
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TTalkForm.Lab_SendMsgMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
  swImgPath : WideString;
begin
  swImgPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SendMsgHot.bmp';
  if Not WideFileExists(swImgPath) then Exit;

  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swImgPath);
    Image_SendMsg.Picture.Assign(bmpBuffer);
    Image_SendMsg.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TTalkForm.Lab_SendMsgMouseLeave(Sender: TObject);
Var
  bmpBuffer : TBitmap;
  swImgPath : WideString;
begin
  swImgPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SendMsg.bmp';
  if Not WideFileExists(swImgPath) then Exit;

  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swImgPath);
    Image_SendMsg.Picture.Assign(bmpBuffer);
    Image_SendMsg.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TTalkForm.Lab_SendMsgMenuMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
  swImgPath : WideString;
begin
  swImgPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SendMsgHotMenu.bmp';
  if Not WideFileExists(swImgPath) then Exit;

  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swImgPath);
    Image_SendMsg.Picture.Assign(bmpBuffer);
    Image_SendMsg.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TTalkForm.ResizeChatForm;
begin
  if Self.WindowState = wsMaximized then
    Self.WindowState := wsNormal
  else Self.WindowState := wsMaximized;
end;

procedure TTalkForm.Image_TitleLeftDblClick(Sender: TObject);
begin
  ResizeChatForm;
end;

////////////////////////////////////////////////////////////////////////////////
//                          小信息区域控制函数                                //
////////////////////////////////////////////////////////////////////////////////

procedure TTalkForm.ShowSInfo(iType:Integer;swInfo:WideString);
begin
 ShowSInfo(iType,swInfo,True);
end;

procedure TTalkForm.ShowSInfo(iType: Integer; swInfo: WideString;AutoClose:Boolean);
begin
  //iType, 0 信息 1 安全/传输 2 警告 3 错误 4 帮助
  ImgList_InfoIco.GetIcon(iType, Image_InfoIco.Picture.Icon);
  Lab_SmallInfo.Caption := WideFormat(' %s', [swInfo]);
  Image_InfoArea.Visible := True;
  iHideInfoTimes := 5;
  HideInfoTimer.Enabled := AutoClose;
end;

procedure TTalkForm.HideSInfo;
begin
  Image_InfoArea.Visible := False;
end;

procedure TTalkForm.Image_InfoAreaClick(Sender: TObject);
begin
  HideSInfo;
end;

procedure TTalkForm.HideInfoTimerTimer(Sender: TObject);
begin
  if Not Image_InfoArea.Visible then Exit;
  Dec(iHideInfoTimes);
  if iHideInfoTimes<=0 then
  begin
    HideSInfo;
    HideInfoTimer.Enabled := False;
  end;
end;

procedure TTalkForm.Image_HidePanelClick(Sender: TObject);
begin
FrmSunExpandWorkForm.Visible:=not FrmSunExpandWorkForm.Visible;
//Main_memo.ScrollPageEnd;
end;

procedure TTalkForm.Panel_CenterControlResize(Sender: TObject);
begin
if assigned(FrmSunExpandWorkForm) then
if FrmSunExpandWorkForm.Visible then
   Image_HidePanel.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Indent.bmp')
   else Image_HidePanel.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Expand.bmp');
end;

initialization
  CoInitialize(nil);
finalization
  CoUninitialize;

end.
