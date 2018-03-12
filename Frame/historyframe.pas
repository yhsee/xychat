unit historyframe;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg, StdCtrls,ConstUnt,
  PanelEx,SunIMTreeList,RichEditOleUnt,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus, ComCtrls, ToolWin, Menus;

type
  TRichedit=Class(TRichEditOle);
  TTreeView = class(TSIMTreeList);
  THistoryFrame = class(TTntForm)
    Panel_Frame: TPanelEx;
    Image_TitleLeft: TImage;
    Panel_Title: TPanelEx;
    Image_TitleRight: TImage;
    Panel_Left: TPanelEx;
    Panel_Right: TPanelEx;
    Panel_Bottom: TPanelEx;
    Image_BottomLeft: TImage;
    Image_BottomRight: TImage;
    Lab_Min: TTntLabel;
    Lab_Max: TTntLabel;
    Lab_Close: TTntLabel;
    Lab_FormCaption: TTntLabel;
    Si_IMUserList: TTreeView;
    Bottom_Center: TPanelEx;
    Image_Next: TImage;
    Image_Previous: TImage;
    Lab_PageInfo: TTntLabel;
    Panel_ChatViewBox: TPanel;
    Image_ChatView_Left: TPanelEx;
    Image_ChatView_Right: TPanelEx;
    Image_ChatView_Buttom: TPanelEx;
    Panel_ChatUpDownLine: TPanel;
    Image_ChatView_Top: TPanelEx;
    Main_Memo: TRichEdit;
    Panel_InputBox: TPanel;
    Image_ChatInput_Left: TPanelEx;
    Image_ChatInput_Right: TPanelEx;
    Panel_ChatInputUpDownLine: TPanel;
    Image_ChatInput_Top: TPanelEx;
    Image_ChatInput_Buttom: TPanelEx;
    Panel_Spliter: TPanelEx;
    Image_Start: TImage;
    Image_Over: TImage;
    IMG_Savelog: TImage;
    IMG_Clearlog: TImage;
    Ed_NonHistory: TTntEdit;
    procedure Image_TitleLeftMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image_TitleRightMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image_TitleCenterMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image_BottomRightMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Lab_MinClick(Sender: TObject);
    procedure Lab_CloseClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Lab_CloseMouseEnter(Sender: TObject);
    procedure Lab_CloseMouseLeave(Sender: TObject);
    procedure Lab_MaxMouseEnter(Sender: TObject);
    procedure Lab_MinMouseEnter(Sender: TObject);
    procedure Lab_MinMouseLeave(Sender: TObject);
    procedure Lab_MaxMouseLeave(Sender: TObject);
    procedure Lab_MaxClick(Sender: TObject);
    procedure Main_MemoChange(Sender: TObject);
  private
    { Private declarations }
    procedure FormMove(Sender: TObject);
    procedure InitializeFace;
    procedure PaintDefSysControl;
    procedure ResizeButton;
  public
    { Public declarations }
  end;

implementation
uses udpcores,ShareUnt;
{$R *.dfm}

procedure THistoryFrame.InitializeFace;
begin
  Image_TitleLeft.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis029.jpg');
  Panel_Title.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis001.jpg');
  Image_TitleRight.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis002.jpg');
  Panel_Left.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis004.jpg');
  Panel_Right.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis005.jpg');
  Image_BottomLeft.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis006.jpg');
  Image_BottomRight.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis007.jpg');
  Panel_Bottom.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis003.jpg');
  IMG_Savelog.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis046.jpg');
  IMG_Clearlog.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis047.jpg');
  Image_Start.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\But_FirstPage.jpg');
  Image_Over.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\But_LastPage.jpg');
  Image_Next.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\But_PageDown.jpg');
  Image_Previous.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\But_PageUp.jpg');
  Bottom_Center.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis017.jpg');
  Panel_Spliter.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis017.jpg');
  Image_ChatView_Left.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis026.jpg');
  Image_ChatView_Right.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis027.jpg');
  Image_ChatView_Top.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis021.jpg');
  Image_ChatView_Buttom.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis025.jpg');
  Image_ChatInput_Left.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis026.jpg');
  Image_ChatInput_Right.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis027.jpg');
  Image_ChatInput_Top.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis021.jpg');
  Image_ChatInput_Buttom.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis021.jpg');
end;

procedure THistoryFrame.FormMove(Sender:TObject);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure THistoryFrame.Image_TitleLeftMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure THistoryFrame.Image_TitleRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure THistoryFrame.Image_TitleCenterMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure THistoryFrame.Image_BottomRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  if (_CUR_STATE=0) Or (_CUR_STATE=1) then Perform(WM_SYSCOMMAND, $F007, 0)
    else Perform(WM_SYSCOMMAND, $F008, 0);
end;

procedure THistoryFrame.Lab_MinClick(Sender: TObject);
begin
  Perform(WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure THistoryFrame.Lab_CloseClick(Sender: TObject);
begin
  Perform(WM_SYSCOMMAND, SC_CLOSE, 0);
end;

procedure THistoryFrame.FormResize(Sender: TObject);
begin
  ResizeButton;
  RoundForm(Self);
end;

procedure THistoryFrame.ResizeButton;
begin
  Lab_Close.Left := Panel_Title.Width - 52;
  Lab_Max.Left := Lab_Close.Left - 29;
  Lab_Min.Left := Lab_Max.Left - 29;
  IMG_Clearlog.Left := Self.Width - 273;
  IMG_Savelog.Left := Self.Width - 353;
  Ed_NonHistory.Left := (Main_Memo.Width - Ed_NonHistory.Width) Div 2;  
end;

procedure THistoryFrame.FormCreate(Sender: TObject);
begin
  SetWindowLong(Self.Handle, GWL_STYLE, GetWindowLong(Self.Handle, GWL_STYLE) Or WS_SYSMENU or WS_MINIMIZEBOX);
  DoubleBuffered:=True;
  RoundForm(Self);
  InitializeFace;
  ResizeButton;
end;

procedure THistoryFrame.Lab_CloseMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SysCtlCloseHot.bmp');
    Image_TitleRight.Picture.Assign(bmpBuffer);
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure THistoryFrame.Lab_CloseMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure THistoryFrame.Lab_MaxMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SysCtlMaxHot.bmp');
    Image_TitleRight.Picture.Assign(bmpBuffer);
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure THistoryFrame.Lab_MinMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SysCtlMinHot.bmp');
    Image_TitleRight.Picture.Assign(bmpBuffer);
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure THistoryFrame.Lab_MinMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure THistoryFrame.Lab_MaxMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure THistoryFrame.PaintDefSysControl;
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SysCtlDef.bmp');
    Image_TitleRight.Picture.Bitmap.Assign(bmpBuffer);
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure THistoryFrame.Lab_MaxClick(Sender: TObject);
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
    Lab_Max.Hint := APPLICATION_MAX;
  end; 
end;

procedure THistoryFrame.Main_MemoChange(Sender: TObject);
begin
  Ed_NonHistory.Visible := Trim(Main_Memo.Text)='';
end;

end.
