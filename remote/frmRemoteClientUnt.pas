unit frmRemoteClientUnt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls,structureunt,constunt,math,
  jpeg,Gifimage,pngimage,TntStdCtrls,RemoteControl, StdCtrls;

type
  TSendInfor=procedure(Sender:TObject;Params:WideString) of Object;
  TTntForm=class(TRemoteControl);
  TfrmRemoteClient = class(TTntForm)
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams);override;
    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure TntFormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure TntFormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TntFormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TntFormClose(Sender: TObject; var Action: TCloseAction);
  private
    FUserSign:String;
    FDeskTopRect:TRect;
    FSendInfor:TSendInfor;
    procedure InitPaintBoxEx;
    procedure ProcessMouseEvent(x,y,event,wheel:integer);
    procedure ProcessKeyboardEvent(iKey:Word;bDown:Boolean);
  protected
    procedure PaintBoxExMouseDown(Sender: TObject; Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxExMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxExMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Lab_CloseClick(Sender: TObject);
    procedure Lab_SetColorClick(Sender:TObject);
    { Private declarations }
  public
    procedure SetRemoteUser(sUserSign:String;Params:WideString);
    procedure RefreshScreen(AData:TStream;rt:TRect;iCursor:LongWord;TmpPoint:TPoint);
  published
    property SendInfor:TSendInfor write FSendInfor;
    { Public declarations }
  end;


implementation
uses ShareUnt,udpcores,SimpleXmlUnt,userunt;
{$R *.dfm}

//------------------------------------------------------------------------------
// 窗体事件
//------------------------------------------------------------------------------
procedure TfrmRemoteClient.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent:=GetDeskTopWindow;
end;

//******************************************************************************
// 根据双方之间的网络来决定数据包的大小
//******************************************************************************
procedure TfrmRemoteClient.FormCreate(Sender: TObject);
begin
  inherited;
  InitPaintBoxEx;
end;

procedure TfrmRemoteClient.SetRemoteUser(sUserSign:String;Params:WideString);
begin
  FUserSign:=sUserSign;
  GetNoteFromValue(Params,'ScreenRect',@FDeskTopRect);
  Lab_FullScreen.Enabled:=EqualRect(FDeskTopRect,Screen.DesktopRect);

  PaintBox.Width:=FDeskTopRect.Right;
  PaintBox.Height:=FDeskTopRect.Bottom;
  
  PaintBox.left:=0;
  PaintBox.top:=0;
end;

procedure TfrmRemoteClient.FormShow(Sender: TObject);
var
  TmpInfor:Tfirendinfo;
  TmpRect:TRect;
begin
  if not User.Find(FUserSign,TmpInfor) then exit;

  SystemParametersInfo(SPI_GETWORKAREA,0,@TmpRect,0);

  Width:=min(TmpRect.Right,FDeskTopRect.Right+10);
  Height:=min(TmpRect.Bottom,FDeskTopRect.Bottom+42);

  caption:=TmpInfor.uname+' 远程协助中';
  Lab_RmtCtlCaption.Caption:=TmpInfor.uname+' 远程协助中';
end;

procedure TfrmRemoteClient.RefreshScreen(AData:TStream;rt:TRect;iCursor:LongWord;TmpPoint:TPoint);
var
  TmpBmp:TJPEGImage;
begin
  try
  TmpBmp:=TJPEGImage.Create;
  if AData.Size>0 then
    try
    AData.Seek(0,0);
    TmpBmp.LoadFromStream(AData);
    PaintBox.Canvas.Lock;
    PaintBox.Canvas.Draw(rt.Left,rt.Top,TmpBmp);
//    DrawIcon(PaintBox.Canvas.handle,TmpPoint.x,TmpPoint.y,iCursor);
    PaintBox.Canvas.Unlock;
    except
    PaintBox.Canvas.Unlock;
    end
  finally
  freeandnil(TmpBmp);
  end;
end;

procedure TfrmRemoteClient.ProcessMouseEvent(x,y,event,wheel:integer);
var
  sParams:WideString;
begin
  AddValueToNote(sParams,'Event','MouseEvent');
  AddValueToNote(sParams,'MouseEvent',event);
  AddValueToNote(sParams,'MouseWheel',wheel);
  AddValueToNote(sParams,'MouseLeft',x);
  AddValueToNote(sParams,'MouseTop',y);
  if assigned(FSendInfor) then FSendInfor(nil,sParams);
end;

procedure TfrmRemoteClient.ProcessKeyboardEvent(iKey:Word;bDown:Boolean);
var
  sParams:WideString;
begin
  AddValueToNote(sParams,'Event','KeyboardEvent');
  AddValueToNote(sParams,'iKey',iKey);
  AddValueToNote(sParams,'bDown',bDown);
  if assigned(FSendInfor) then FSendInfor(nil,sParams);
end;


procedure TfrmRemoteClient.PaintBoxExMouseDown(Sender: TObject; Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then ProcessMouseEvent(x,y,MOUSEEVENTF_LEFTDOWN,0);
  if Button=mbRight then ProcessMouseEvent(x,y,MOUSEEVENTF_RIGHTDOWN,0);
  if Button=mbMiddle then ProcessMouseEvent(x,y,MOUSEEVENTF_MIDDLEDOWN,0);
end;

procedure TfrmRemoteClient.PaintBoxExMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
begin
  ProcessMouseEvent(x,y,0,0);
end;

procedure TfrmRemoteClient.PaintBoxExMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then ProcessMouseEvent(x,y,MOUSEEVENTF_LEFTUP,0);
  if Button=mbRight then ProcessMouseEvent(x,y,MOUSEEVENTF_RIGHTUP,0);
  if Button=mbMiddle then ProcessMouseEvent(x,y,MOUSEEVENTF_MIDDLEUP,0);
end;

procedure TfrmRemoteClient.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if not IsRectEmpty(FDeskTopRect) then
    begin
    if NewWidth>FDeskTopRect.Right+10 then NewWidth:=FDeskTopRect.Right+10;
    if NewHeight>FDeskTopRect.Bottom+42 then NewHeight:=FDeskTopRect.Bottom+42;
    end;
end;


procedure TfrmRemoteClient.InitPaintBoxEx;
begin
  PaintBox.Top:=0;
  PaintBox.Left:=0;
  PaintBox.OnMouseDown:=PaintBoxExMouseDown;
  PaintBox.OnMouseMove:=PaintBoxExMouseMove;
  PaintBox.OnMouseUp:=PaintBoxExMouseUp;
  Lab_Close.OnClick:=Lab_CloseClick;
  Lab_FSColor8.OnClick:=Lab_SetColorClick;
  Lab_FSColor16.OnClick:=Lab_SetColorClick;
  Lab_FSColor32.OnClick:=Lab_SetColorClick;
end;

procedure TfrmRemoteClient.Lab_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRemoteClient.Lab_SetColorClick(Sender:TObject);
 var
  sParams:WideString;
begin
  AddValueToNote(sParams,'Event','SetColorEvent');
  AddValueToNote(sParams,'iLevel',TComponent(Sender).Tag);
  if assigned(FSendInfor) then FSendInfor(nil,sParams);
end;

procedure TfrmRemoteClient.TntFormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  ProcessMouseEvent(MousePos.X,MousePos.y,MOUSEEVENTF_WHEEL,WheelDelta);
end;

procedure TfrmRemoteClient.TntFormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ProcessKeyboardEvent(key,True);
end;

procedure TfrmRemoteClient.TntFormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ProcessKeyboardEvent(key,False);
end;

procedure TfrmRemoteClient.TntFormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if assigned(FSendInfor) then FSendInfor(nil,'');
end;

end.
