unit CreateUserID;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg, StdCtrls, ResStringUnit, PublicVariable, PanelEx,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus, RzButton;

type 
  TFrmCreateUserID = class(TTntForm)
    Panel_Frame: TTntPanel;
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
    Image_BackGroup: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    userid: TEdit;
    pwd: TEdit;
    pwd2: TEdit;
    Label9: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label18: TLabel;
    BtnOK: TRzButton;
    BtnCancel: TRzButton;
    Label1: TLabel;
    uname: TEdit;
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
    procedure TntFormClose(Sender: TObject; var Action: TCloseAction);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure uidKeyPress(Sender: TObject; var Key: Char);
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

{$R *.dfm}

procedure TFrmCreateUserID.InitializeFace;
begin
  Image_TitleLeft.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis029.jpg');
  Panel_Title.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis001.jpg');
  Image_TitleRight.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis002.jpg');
  Panel_Left.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis004.jpg');
  Panel_Right.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis005.jpg');
  Image_BottomLeft.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis006.jpg');
  Image_BottomRight.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis007.jpg');
  Panel_Bottom.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis003.jpg');
  Image_BackGroup.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis031.jpg');
end;

procedure TFrmCreateUserID.FormMove(Sender:TObject);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TFrmCreateUserID.Image_TitleLeftMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TFrmCreateUserID.Image_TitleRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TFrmCreateUserID.Image_TitleCenterMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TFrmCreateUserID.Image_BottomRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  if (_CUR_STATE=0) Or (_CUR_STATE=1) then Perform(WM_SYSCOMMAND, $F007, 0)
    else Perform(WM_SYSCOMMAND, $F008, 0);
end;

procedure TFrmCreateUserID.Lab_MinClick(Sender: TObject);
begin
  Perform(WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure TFrmCreateUserID.Lab_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCreateUserID.FormResize(Sender: TObject);
begin
  ResizeButton;
  RoundForm(Self);
end;

procedure TFrmCreateUserID.ResizeButton;
begin
  Lab_Close.Left := Panel_Title.Width - 52;
  Lab_Max.Left := Lab_Close.Left - 29;
  Lab_Min.Left := Lab_Max.Left - 29;
end;

procedure TFrmCreateUserID.FormCreate(Sender: TObject);
begin
  SetWindowLong(Self.Handle, GWL_STYLE, GetWindowLong(Self.Handle, GWL_STYLE) Or WS_SYSMENU or WS_MINIMIZEBOX);  
  RoundForm(Self);
  Self.DoubleBuffered := True;
  InitializeFace;

  ResizeButton;
end;

procedure TFrmCreateUserID.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TFrmCreateUserID.Lab_CloseMouseEnter(Sender: TObject);
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

procedure TFrmCreateUserID.Lab_CloseMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TFrmCreateUserID.Lab_MaxMouseEnter(Sender: TObject);
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

procedure TFrmCreateUserID.Lab_MinMouseEnter(Sender: TObject);
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

procedure TFrmCreateUserID.Lab_MinMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TFrmCreateUserID.Lab_MaxMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TFrmCreateUserID.PaintDefSysControl;
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

procedure TFrmCreateUserID.TntFormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmCreateUserID.uidKeyPress(Sender: TObject; var Key: Char);
begin
If Key = #13 Then
  Begin
  If HiWord(GetKeyState(VK_SHIFT)) <> 0 then
     SelectNext(Sender as TWinControl,False,True)
  else
   SelectNext(Sender as TWinControl,True,True);
   Key := #0
  end;
end;

end.
