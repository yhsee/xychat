unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,desksource,Jpeg, AppEvnts, ExtCtrls,
  TntForms;

type
  TForm= class(TTntForm);
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    ApplicationEvents1: TApplicationEvents;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
  private
    CurBitmap:TBitmap;
    FClipView:HWND;
    TmpSource:Tdesksource;
    procedure CHANGE_CB_CHAIN(var msg:Tmessage);message WM_CHANGECBCHAIN;
    procedure DRAW_CLIPBOARD(var msg:Tmessage);message WM_DRAWCLIPBOARD;
    procedure CaptureOnEvent(TmpStream:TStream;rt:TRect;iCursor:LongWord);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses hookUnt,lzoobj;
{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  hook:=THook.Create;
  hook.StartVNCHook;
  CurBitmap:=TBitmap.Create;
  TmpSource:=Tdesksource.Create;
  TmpSource.CaptureEvent:=CaptureOnEvent;
  TmpSource.CaptureStart;
  TmpSource.Capture;

  //进入剪贴板 事件链
  FClipView:=SetClipboardViewer(handle);
end;


procedure TForm1.CaptureOnEvent(TmpStream:TStream;rt:TRect;iCursor:LongWord);
var
  TmpBitmap:TJPEGImage;
begin
  try
  TmpBitmap:=TJPEGImage.Create;
  if TmpStream.Size>0 then
    begin
    TmpStream.Seek(0,0);
    TmpBitmap.LoadFromStream(TmpStream);
    Canvas.Lock;
    Canvas.Draw(rt.Left,rt.Top,TmpBitmap);
    Canvas.Unlock;
    end
  finally
  TmpSource.Capture;
  freeandnil(TmpBitmap);
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  //退出剪贴板 事件链
  ChangeClipboardChain(Application.handle,FClipView);
  SendMessage(FClipView,WM_CHANGECBCHAIN,handle,FClipView);

  hook.StopVNCHook;
  TmpSource.CaptureStop;
  freeandnil(hook);
  freeandnil(TmpSource);
  freeandnil(CurBitmap);
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  TmpSource.SetColorLevel(1);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  TmpSource.SetColorLevel(2);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  TmpSource.SetColorLevel(3);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  TmpSource.SetColorLevel(0);
end;

procedure TForm1.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  rt:TRect;
begin
  if assigned(hook) then
  if Msg.message=Hook.SCREEN_UPDATE then
    begin
    if Assigned(TmpSource) then
      begin
      rt.Left:=Short(LOWORD(Msg.wParam));
      rt.top:=Short(HIWORD(Msg.wParam));
      rt.Right:=Short(LOWORD(Msg.lParam));
      rt.Bottom:=Short(HIWORD(Msg.lParam));
      TmpSource.UpdateRect(rt);
      end;
    Handled:=True;
    end;
end;


procedure TForm1.CHANGE_CB_CHAIN(var msg:Tmessage);
begin
  if LongWord(msg.WParam)=FClipView then FClipView:=msg.LParam
  else if FClipView<>0 then
    SendMessage(FClipView,WM_CHANGECBCHAIN,msg.wParam,msg.lParam);
end;

procedure TForm1.DRAW_CLIPBOARD(var msg:Tmessage);
begin
  if FClipView<>0 then
    SendMessage(FClipView,WM_DRAWCLIPBOARD,msg.wParam,msg.lParam);
end;

end.
