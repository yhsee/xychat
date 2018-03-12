unit FoundUser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg, StdCtrls, ResStringUnit, PublicVariable, PanelEx,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus;

type 
  TFrmFoundUser = class(TTntForm)
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
    Panel_Frame: TTntPanel;
    procedure CreateParams(var Params: TCreateParams); override;
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
    procedure Lab_CloseClick(Sender: TObject);
  private
    { Private declarations }
    procedure FormMove(Sender: TObject);
    procedure InitializeFace;
    procedure PaintDefSysControl;
    procedure ResizeButton;
  public
    { Public declarations }
  end;

var
  FrmFoundUser: TFrmFoundUser;

implementation

{$R *.dfm}

procedure TFrmFoundUser.InitializeFace;
begin
  Image_TitleLeft.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis029.jpg');
  Panel_Title.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis001.jpg');
  Image_TitleRight.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis002.jpg');
  Panel_Left.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis004.jpg');
  Panel_Right.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis005.jpg');
  Image_BottomLeft.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis006.jpg');
  Image_BottomRight.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis007.jpg');
  Panel_Bottom.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis003.jpg');
end;

procedure TFrmFoundUser.FormMove(Sender:TObject);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TFrmFoundUser.Image_TitleLeftMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TFrmFoundUser.Image_TitleRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TFrmFoundUser.Image_TitleCenterMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TFrmFoundUser.Image_BottomRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  if (_CUR_STATE=0) Or (_CUR_STATE=1) then Perform(WM_SYSCOMMAND, $F007, 0)
    else Perform(WM_SYSCOMMAND, $F008, 0);
end;

procedure TFrmFoundUser.Lab_MinClick(Sender: TObject);
begin
  Perform(WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure TFrmFoundUser.FormResize(Sender: TObject);
begin
  ResizeButton;
  RoundForm(Self);
end;

procedure TFrmFoundUser.ResizeButton;
begin
  Lab_Close.Left := Panel_Title.Width - 52;
  Lab_Max.Left := Lab_Close.Left - 29;
  Lab_Min.Left := Lab_Max.Left - 29;
end;

procedure TFrmFoundUser.FormCreate(Sender: TObject);
begin
  SetWindowLong(Self.Handle, GWL_STYLE, GetWindowLong(Self.Handle, GWL_STYLE) Or WS_SYSMENU or WS_MINIMIZEBOX);  
  RoundForm(Self);
  Self.DoubleBuffered := True;
  InitializeFace;

  ResizeButton;
end;

procedure TFrmFoundUser.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent:=GetDeskTopWindow;
  //Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TFrmFoundUser.Lab_CloseMouseEnter(Sender: TObject);
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

procedure TFrmFoundUser.Lab_CloseMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TFrmFoundUser.Lab_MaxMouseEnter(Sender: TObject);
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

procedure TFrmFoundUser.Lab_MinMouseEnter(Sender: TObject);
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

procedure TFrmFoundUser.Lab_MinMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TFrmFoundUser.Lab_MaxMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TFrmFoundUser.PaintDefSysControl;
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

procedure TFrmFoundUser.Lab_CloseClick(Sender: TObject);
begin
  Close;
end;

end.
