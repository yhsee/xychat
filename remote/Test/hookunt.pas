unit hookunt;

interface

uses
  Windows,Messages,SysUtils,Classes;

type
  Thook=class
     constructor Create;
     destructor  Destroy;override;
   private
     RFB_SCREEN_UPDATE,
     RFB_COPYRECT_UPDATE,
     RFB_MOUSE_UPDATE:LongWord;
     HookLib: HMODULE;
     FJustHookVNC:Boolean;
   public
     function StartVNCHook:Boolean;
     procedure StopVNCHook;
     function GetSilenceStatus(iOutTime:Word):boolean;
   published
     property SCREEN_UPDATE:LongWord Read RFB_SCREEN_UPDATE;
     property JustHookVNC:Boolean Read FJustHookVNC;     
  end;

var
  hook:Thook;

function StartHookKeyBoardMouse:Bool;Stdcall; external 'kmhook.dll';
function StopHookKeyBoardMouse:Bool;Stdcall; external 'kmhook.dll';
function GetElapsedTime:UINT;Stdcall; external 'kmhook.dll';



implementation

function Thook.GetSilenceStatus(iOutTime:Word):boolean;
begin
  try
    Result:=GetElapsedTime>(iOutTime*60);
  except
    Result:=False;
  end;
end;

constructor Thook.Create;
begin
  inherited Create;
  RFB_MOUSE_UPDATE:=RegisterWindowMessage('Update.Mouse');
  RFB_SCREEN_UPDATE:=RegisterWindowMessage('Update.DrawRect');
  RFB_COPYRECT_UPDATE:=RegisterWindowMessage('Update.CopyRect');
  StartHookKeyBoardMouse;
end;

destructor Thook.Destroy;
begin
  StopHookKeyBoardMouse;
  inherited Destroy;
end;

function Thook.StartVNCHook:Boolean;
var
  SetHooks:function(thread_id:DWORD;UpdateMsg,CopyMsg,MouseMsg:UINT):BOOL; cdecl;
begin
  Result:=False;
  HookLib := LoadLibrary('VNCHooks.dll');
  if HookLib <> 0 then
  begin
    @SetHooks := GetProcAddress(HookLib, 'SetHooks');
    if @SetHooks <> nil then
       Result:=SetHooks(GetCurrentThreadId(),RFB_SCREEN_UPDATE,RFB_COPYRECT_UPDATE,RFB_MOUSE_UPDATE);
    FJustHookVNC:=Result;
    if not Result then
    begin
      FreeLibrary(HookLib);
    end;
  end;
end;

procedure Thook.StopVNCHook;
var
  UnSetHooks:Function(thread_id:DWORD):BOOL; cdecl;
begin
  FJustHookVNC:=False;
  if HookLib <> 0 then
  begin
    @UnSetHooks := GetProcAddress(HookLib, 'UnSetHooks');
    if @UnSetHooks <> nil then
      UnSetHooks(GetCurrentThreadId());
  FreeLibrary(HookLib);
  end;
end;

end.
