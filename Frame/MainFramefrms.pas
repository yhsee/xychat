unit MainFramefrms;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg, StdCtrls, ConstUnt, 
  AutoShrinkForm,PanelEx,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus, ImgList;

type
  TFrmMain = class(TTntForm)
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
    procedure Image_TitleLeftMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image_TitleRightMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image_TitleCenterMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image_BottomRightMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Lab_MaxClick(Sender: TObject);
    procedure Lab_CloseClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TntFormDestroy(Sender: TObject);
    procedure Lab_CloseMouseEnter(Sender: TObject);
    procedure Lab_CloseMouseLeave(Sender: TObject);
    procedure Lab_MaxMouseEnter(Sender: TObject);
    procedure Lab_MinMouseEnter(Sender: TObject);
    procedure Lab_MinMouseLeave(Sender: TObject);
    procedure Lab_MaxMouseLeave(Sender: TObject);
  private
    { Private declarations }  
    procedure FormMove(Sender: TObject);
    procedure InitializeFace;
    procedure PaintDefSysControl;
  public
    { Public declarations }
  end;

var
  asfDock : TAutoShrinkForm;

implementation
uses ShareUnt;
{$R *.dfm}

//System Controls

procedure TFrmMain.InitializeFace;
begin
  Image_TitleLeft.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis000.jpg');
  Panel_Title.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis001.jpg');
  Image_TitleRight.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis002.jpg');
  Panel_Left.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis004.jpg');
  Panel_Right.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis005.jpg');
  Image_BottomLeft.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis006.jpg');
  Image_BottomRight.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis007.jpg');
  Panel_Bottom.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis003.jpg');    
end;

procedure TFrmMain.FormMove(Sender:TObject);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TFrmMain.Image_TitleLeftMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TFrmMain.Image_TitleRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TFrmMain.Image_TitleCenterMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TFrmMain.Image_BottomRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  if (_CUR_STATE=0) Or (_CUR_STATE=1) then Perform(WM_SYSCOMMAND, $F006, 0)
    else Perform(WM_SYSCOMMAND, $F008, 0);
end;

procedure TFrmMain.Lab_MaxClick(Sender: TObject);
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

procedure TFrmMain.Lab_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmMain.FormResize(Sender: TObject);
begin
  Lab_Close.Left := Panel_Title.Width - 52;
  Lab_Max.Left := Lab_Close.Left - 29;
  Lab_Min.Left := Lab_Max.Left - 29;
  RoundForm(self);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  Self.DoubleBuffered := True;
  SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_TOOLWINDOW);
  asfDock := TAutoShrinkForm.Create(Self);
  asfDock.AutoDock := True;
  InitializeFace;
  RoundForm(self);
end;

procedure TFrmMain.TntFormDestroy(Sender: TObject);
begin
  if Assigned(asfDock) then FreeAndNil(asfDock);
end;

procedure TFrmMain.Lab_CloseMouseEnter(Sender: TObject);
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

procedure TFrmMain.Lab_CloseMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TFrmMain.Lab_MaxMouseEnter(Sender: TObject);
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

procedure TFrmMain.Lab_MinMouseEnter(Sender: TObject);
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

procedure TFrmMain.Lab_MinMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TFrmMain.Lab_MaxMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TFrmMain.PaintDefSysControl;
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

end.
