unit MacUnt;

interface

uses windows,sysutils,winsock;

function GetLocatMACAddress(Const sIPAddress : String):String;

implementation

function GetMacRPCMode : String;
//Only Get Location MAC Address
Var
  Lib: Cardinal; 
  Func: function(GUID: PGUID): Longint; stdcall; 
  GUID1, GUID2: TGUID; 
begin 
  Result := ''; 
  Lib := LoadLibrary('rpcrt4.dll'); 
  if Lib <> 0 then
  begin
    if Win32Platform<>VER_PLATFORM_WIN32_NT then
      @Func := GetProcAddress(Lib, 'UuidCreate')
      else @Func := GetProcAddress(Lib, 'UuidCreateSequential'); 
    if Assigned(Func) then 
    begin 
      if (Func(@GUID1) = 0) and 
        (Func(@GUID2) = 0) and 
        (GUID1.D4[2] = GUID2.D4[2]) and 
        (GUID1.D4[3] = GUID2.D4[3]) and 
        (GUID1.D4[4] = GUID2.D4[4]) and 
        (GUID1.D4[5] = GUID2.D4[5]) and 
        (GUID1.D4[6] = GUID2.D4[6]) and 
        (GUID1.D4[7] = GUID2.D4[7]) then 
      begin 
        Result := 
         IntToHex(GUID1.D4[2], 2) + '-' + 
         IntToHex(GUID1.D4[3], 2) + '-' + 
         IntToHex(GUID1.D4[4], 2) + '-' + 
         IntToHex(GUID1.D4[5], 2) + '-' + 
         IntToHex(GUID1.D4[6], 2) + '-' + 
         IntToHex(GUID1.D4[7], 2); 
      end; 
    end; 
    FreeLibrary(Lib); 
  end; 
end;

function GetMacARPMode(sIPAddress : String): String;
Type
  rmiInfo = Array[0..7] of Byte;
Var
  dwTargetIP : DWord;
  dwMacAddress : Array[0..1] of DWord;
  dwMacLen : DWord;
  dwResult : DWord;
  rmiGetInfo : rmiInfo;
  sMacTemp : String;
  iloop : Integer;
  Lib : Cardinal;
  Func: function(Destip,scrip:DWORD;pmacaddr:PDWORD;VAR phyAddrlen:DWORD):DWORD; stdcall;
begin
  Result := '';
  Lib := LoadLibrary('iphlpapi.dll');

  if Lib <> 0 then 
  begin
    @Func := GetProcAddress(Lib, 'SendARP');

    if Assigned(Func) then
    begin
      dwTargetIP := Inet_Addr(PChar(sIPAddress));
      dwMacLen := 6;
      dwResult := Func(dwTargetIP,0,@dwMacAddress[0], dwMacLen);

      if dwResult=NO_ERROR then
      begin
        rmiGetInfo := rmiInfo(dwMacAddress);
        for iloop:= 0 to 5 do
        begin
          if iloop = 0 then
            sMacTemp := InttoHex(rmiGetInfo[iloop], 2)
          else
            sMacTemp := sMacTemp + '-' + InttoHex(rmiGetInfo[iloop], 2);
        end;
        Result := sMacTemp;
      end;
    end;
  end;
end;

function GetLocatMACAddress(Const sIPAddress : String):String;
begin
  Result := GetMacARPMode(sIPAddress);
  if Length(Result)=0 then
    Result := GetMacRPCMode;
  if Length(Result)=0 then
    Result:='00-00-00-00-00-00';
end;


end.
