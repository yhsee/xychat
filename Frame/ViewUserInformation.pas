unit ViewUserInformation;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg, StdCtrls, ConstUnt, PanelEx,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus, ComCtrls;

type  
  TTntEdit=class(TEdit);
  TTntMemo=class(TMemo);
  TFrmViewUserInformation = class(TTntForm)
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
    Image_Close: TImage;
    Image_Yes: TImage;
    Panel_WorkArea: TPanel;
    Panel_UserBaseInfo: TPanel;
    Image_BaseUserInfo: TImage;
    Panel_MoreInfo: TPanel;
    Image_MoreInfo: TImage;
    Panel_InfoPageTitle: TPanel;
    Image_PageTitle: TImage;
    ImageBut_BaseInfo: TImage;
    ImageBut_MoreInfo: TImage;
    Communication: TTntEdit;
    phone: TTntEdit;
    email: TTntEdit;
    qqmsn: TTntEdit;
    area: TTntMemo;
    mytext: TTntMemo;
    uid: TTntEdit;
    uname: TTntEdit;
    sex: TTntEdit;
    constellation: TTntEdit;
    age: TTntEdit;
    signing: TTntMemo;
    myimg: TImage;
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
    procedure ImageBut_BaseInfoClick(Sender: TObject);
    procedure TntFormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure FormMove(Sender: TObject);
    procedure InitializeFace;
    procedure PaintDefSysControl;
    procedure ResizeButton;
    procedure SetPageActive(iPage: Integer);
  public
    { Public declarations }
  end;


implementation
uses ShareUnt;
{$R *.dfm}

procedure TFrmViewUserInformation.InitializeFace;
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
  Image_Yes.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\But_Yes.jpg');
  Image_Close.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\But_Close.jpg');
  Image_BaseUserInfo.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis038.jpg');
  Image_MoreInfo.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis039.jpg');  
end;

procedure TFrmViewUserInformation.FormMove(Sender:TObject);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TFrmViewUserInformation.Image_TitleLeftMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TFrmViewUserInformation.Image_TitleRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TFrmViewUserInformation.Image_TitleCenterMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormMove(Sender);
end;

procedure TFrmViewUserInformation.Image_BottomRightMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  if (_CUR_STATE=0) Or (_CUR_STATE=1) then Perform(WM_SYSCOMMAND, $F007, 0)
    else Perform(WM_SYSCOMMAND, $F008, 0);
end;

procedure TFrmViewUserInformation.Lab_MinClick(Sender: TObject);
begin
  Perform(WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure TFrmViewUserInformation.Lab_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmViewUserInformation.FormResize(Sender: TObject);
begin
  ResizeButton;
  RoundForm(Self);
end;

procedure TFrmViewUserInformation.ResizeButton;
begin
  Lab_Close.Left := Panel_Title.Width - 52;
  Lab_Max.Left := Lab_Close.Left - 29;
  Lab_Min.Left := Lab_Max.Left - 29;
end;

procedure TFrmViewUserInformation.FormCreate(Sender: TObject);
begin
  SetWindowLong(Self.Handle, GWL_STYLE, GetWindowLong(Self.Handle, GWL_STYLE) Or WS_SYSMENU or WS_MINIMIZEBOX);  
  RoundForm(Self);
  Self.DoubleBuffered := True;
  InitializeFace;

  ResizeButton;
  SetPageActive(0);
end;

procedure TFrmViewUserInformation.Lab_CloseMouseEnter(Sender: TObject);
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

procedure TFrmViewUserInformation.Lab_CloseMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TFrmViewUserInformation.Lab_MaxMouseEnter(Sender: TObject);
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

procedure TFrmViewUserInformation.Lab_MinMouseEnter(Sender: TObject);
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

procedure TFrmViewUserInformation.Lab_MinMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TFrmViewUserInformation.Lab_MaxMouseLeave(Sender: TObject);
begin
  PaintDefSysControl;
end;

procedure TFrmViewUserInformation.PaintDefSysControl;
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

procedure TFrmViewUserInformation.SetPageActive(iPage:Integer);
Var
  bmpBuffer : TBitmap;
  swPath : WideString;
begin
  try
    LockWindowUpdate(Self.Handle);

    Case iPage Of
      0:
        begin
          swPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\BaseInfoTitle.bmp';
          if Not Panel_UserBaseInfo.Visible then
          begin
            Panel_UserBaseInfo.Visible := True;
            Panel_MoreInfo.Visible := False;
          end;
        end;
      1:
        begin
          swPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\MoreInfoTitle.bmp';
          if Not Panel_MoreInfo.Visible then
          begin
            Panel_MoreInfo.Visible := True;
            Panel_UserBaseInfo.Visible := False;
          end;
        end;
    end;
    if Not WideFileExists(swPath) then Exit;

    try
      bmpBuffer := TBitmap.Create;
      bmpBuffer.LoadFromFile(swPath);
      Image_PageTitle.Picture.Bitmap.Assign(bmpBuffer);
    finally
      if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
    end;
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TFrmViewUserInformation.ImageBut_BaseInfoClick(Sender: TObject);
begin
  SetPageActive((Sender as TImage).Tag);
end;

procedure TFrmViewUserInformation.TntFormClose(Sender: TObject;
  var Action: TCloseAction);
begin
action:=cafree;
end;

end.
