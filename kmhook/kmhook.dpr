library kmhook;

uses
  Windows;
  
var
  KeyBoardHook,
  MouseHook:HHook;
  PElapsedTime:^LongWord;  
  
{$R *.RES}

procedure KM_Event_Process;stdcall;
begin
if Assigned(PElapsedTime) then
  PElapsedTime^:=GetTickCount;
end;

function CallMouseHook(Code:Integer;wParam:WPARAM;lParam:LPARAM):LRESULT;stdcall;
begin
  if Code=HC_ACTION then KM_Event_Process;
  Result := CallNextHookEx(MouseHook, Code, wParam, lParam)
end;

function CallKeyBoardHook(Code:Integer;wParam:WPARAM;lParam:LPARAM):LRESULT;stdcall;
begin
  if Code=HC_ACTION then KM_Event_Process;
  Result := CallNextHookEx(KeyBoardHook, Code, wParam, lParam)
end;

function StartHookKeyBoardMouse:BOOL;Stdcall;
begin
  MouseHook:=SetWindowsHookEx(WH_MOUSE,@CallMouseHook,Hinstance,0);
  KeyBoardHook:=SetWindowsHookEx(WH_KEYBOARD,@CallKeyBoardHook,Hinstance,0);
  Result:=(KeyBoardHook<>0)and(MouseHook<>0);
end;

function StopHookKeyBoardMouse:BOOL;Stdcall;
begin
  if KeyBoardHook<>0 then UnhookWindowsHookEx(KeyBoardHook);
  if MouseHook<>0 then UnhookWindowsHookEx(MouseHook);
  Result:=True;
end;

procedure DllEntryPoint (dwReason: DWord);
var
 FHandle: LongWord;
begin
 Case dwReason Of
  Dll_Process_Attach:
      begin
      FHandle:=CreateFileMapping($FFFFFFFF,nil,PAGE_READWRITE,0,SizeOf(LongWord),'Hook_Keyboard_Mouse');
      if FHandle = 0 then
      if GetLastError = ERROR_ALREADY_EXISTS then
        begin
         FHandle := OpenFileMapping(FILE_MAP_ALL_ACCESS, False,'Hook_Keyboard_Mouse');
         if FHandle = 0 then Exit;
        end else exit;
      PElapsedTime:=MapViewOfFile(FHandle,FILE_MAP_ALL_ACCESS,0,0,0);
      if Assigned(PElapsedTime) then
         PElapsedTime^:=GetTickCount
         else CloseHandle(FHandle);
      end;

  Dll_Process_Detach:
      begin
      if Assigned(PElapsedTime) then
        begin
         UnmapViewOfFile(PElapsedTime);
         PElapsedTime:=nil;
        end;
      end;
  end
end;

function GetElapsedTime:UINT;Stdcall;
begin
if Assigned(PElapsedTime) then
   Result:=ABS(GetTickCount-PElapsedTime^)div 1000
   else Result:=0;
end;

Exports
  StartHookKeyBoardMouse name 'StartHookKeyBoardMouse',
  StopHookKeyBoardMouse name 'StopHookKeyBoardMouse',
  GetElapsedTime name 'GetElapsedTime';
  
begin
  DLLProc:=@DllEntryPoint;
  DllEntryPoint(Dll_Process_Attach);
end.
