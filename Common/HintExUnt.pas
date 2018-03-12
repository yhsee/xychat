unit HintExUnt;

interface

uses
  Windows, Messages, Classes, Controls, Forms, CommCtrl;

type
  THintWin=class(THintWindow)
  private
    FTitle:String;
    FLastActive: THandle;
  public
    procedure ActivateHint(Rect:TRect;Const AHint:string);override;
  published
    property Title:String Write FTitle;
  end;

var
  hWndTip: DWORD;

implementation

procedure changeLayered(hand:hwnd);
Type TMyFunc=function (hwnd:HWND; crKey:Longint; bAlpha:byte; dwFlags:longint ):longint; stdcall;
var 
    MyFunc: TMyFunc;
    FuncPtr: TFarProc;
    DLLHandle: THandle;
begin
  SetWindowLong(hand, GWL_EXSTYLE,WS_EX_LAYERED);

  DLLHandle:= GetModuleHandle(PChar('user32.dll'));
  FuncPtr:= GetProcAddress(DLLHandle, 'SetLayeredWindowAttributes');
  if FuncPtr <> NIL then
      begin
      @MyFunc:= FuncPtr;
      MyFunc(hand, 0, 215, LWA_ALPHA Or LWA_COLORKEY);
      end;
  //FreeLibrary(DLLHandle);
  //SetLayeredWindowAttributes(hand, 0, skinclarity, 2);
end;

procedure AddTipTool(hWnd: DWORD; IconType: Integer; Title,Text: PChar);
const
  TTS_BALLOON =$0040;
  TTM_SETTITLE=WM_USER + 32;
var
  ToolInfo: TToolInfo;
begin
  if hWndTip <> 0 then DestroyWindow(hWndTip);

  hWndTip:=CreateWindow(TOOLTIPS_CLASS, nil,
          WS_POPUP or TTS_NOPREFIX or TTS_BALLOON or TTS_ALWAYSTIP or WS_EX_LAYERED,
          0, 0, 0, 0, hWnd, 0, HInstance, nil);
          
  if (hWndTip<>0) then
  begin
    ToolInfo.cbSize:=SizeOf(ToolInfo);
    ToolInfo.uFlags:=TTF_IDISHWND or TTF_SUBCLASS or TTF_TRANSPARENT;
    ToolInfo.uId:=hWnd;
    ToolInfo.lpszText:=Text;
    SendMessage(hWndTip,TTM_ADDTOOL,1,Integer(@ToolInfo));
    SendMessage(hWndTip,TTM_SETTITLE,IconType,Integer(Title));
    changeLayered(hWndTip);
  end;
  InitCommonControls();
end;

procedure THintWin.ActivateHint(Rect:TRect;const AHint:string);
var sTitle:String;
begin
  try
    caption := AHint;
    if Pos(#13,Caption)>0 then sTitle:=Application.Title;
    AddTipTool(WindowFromPoint(Mouse.CursorPos),1,
               Pchar(sTitle),
               PChar(Caption));
  finally
    FLastActive := GetTickCount;
  end;
end;

initialization
 Application.HintPause:=0;
 Application.ShowHint:=False;
 HintWindowClass:=THintWin; 
 Application.ShowHint:=True;
end. 


