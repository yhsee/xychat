unit SunFlashCtl;

interface

Uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls, StdCtrls, Dialogs,
  TntWindows, TntSysUtils, TntClasses, ShockwaveFlashObjects_TLB;

type
  TSunFlashPlayer = class(TShockwaveFlash)
  private
    FStrecth: Boolean;
    function InitializeFlashPlayer(AOwner: TComponent): Boolean;
    function GetPlayTempFileName: WideString;
  protected
  public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
    
    function PlayFlash(swPath:WideString):Boolean;
    procedure AutoResizeFlash;
  published
    {published}
    property Align Default alClient;
    property Menu Default False;
    property Loop Default True;
    property Quality Default 1;
  end;

  procedure Register;

implementation
{$R *.res} //"Brcc32 -r flash.rc"

(*TSunFlashPlayer Control*)
procedure Register;
begin
  RegisterComponents('Sunwards Software', [TSunFlashPlayer]);
end;

Constructor TSunFlashPlayer.Create(AOwner: TComponent);
begin
  if Not InitializeFlashPlayer(AOwner) then
    Showmessage('Initialize Sunwards Flash Player Failed.');

  inherited Create(AOwner);
  FStrecth := True;    
end;

Destructor TSunFlashPlayer.Destroy;
begin
  inherited Destroy;
end;

function TSunFlashPlayer.InitializeFlashPlayer(AOwner: TComponent):Boolean;
Var
  acSys : Array [0..MAX_PATH] of Char;
  swSysPath : WideString;
  sSysPath : String;
  resFile : TResourceStream;
  stmFile: TTntFileStream;
  fPlayer : TShockwaveFlash;
begin

  try
    fPlayer := TShockwaveFlash.Create(AOwner);
    FreeAndNil(fPlayer);
    Result := True;
  except
    Result := False;
  end;

  if Not Result then
  begin
    GetSystemDirectory(@acSys, MAX_PATH);
    swSysPath := acSys  + '\macromed\flash\';
    if Not WideFileExists(swSysPath + 'swflash.ocx') then
    begin
      {$i-}
      WideForceDirectories(swSysPath + '\macromed\flash');
      {$i+}
      try
        try
          resFile := TResourceStream.Create(0, 'SHOCKWAVEOCX', RT_RCDATA);
          stmFile := TTntFileStream.Create(swSysPath + 'swflash.ocx', fmCreate);
          stmFile.CopyFrom(resFile, resFile.Size);
          Result := True;
        except
          Result := False;
        end;
      finally
        if Assigned(resFile) then FreeAndNil(resFile);
        if Assigned(stmFile) then FreeAndNil(stmFile);

        if Result then
        begin
          sSysPath := swSysPath;
          WinExec(PChar('regsvr32 /s ' + sSysPath + 'swflash.ocx'), SW_HIDE);
        end;
      end;
    end
    else
    begin
      sSysPath := swSysPath;
      WinExec(PChar('regsvr32 /s ' + sSysPath + 'swflash.ocx'), SW_HIDE);
    end;

    if Result then
    begin
      try
        fPlayer := TShockwaveFlash.Create(AOwner);
        FreeAndNil(fPlayer);
        Result := True;
      except
        Result := False;
      end;
    end;
  end;
end;

//swPath ²ÎÊý£¬:BIG Or :SMALL Player Memory Flash, Else Player File
function TSunFlashPlayer.PlayFlash(swPath:WideString):Boolean;
Var
  dPlayType : DWord;
  resFile : TResourceStream;
  stmFile: TTntFileStream;
  swTempFile : WideString;
begin
  Result := False;

  dPlayType := 0;
  if WideCompareText(swPath, ':BIG')=0 then dPlayType := 1;
  if WideCompareText(swPath, ':SMALL')=0 then dPlayType := 2;

  Case dPlayType Of
    0:
      begin
        if WideFileExists(swPath) then
        begin
          Self.Movie := swPath;
          Self.Visible := True;
          Self.Play;
          Self.SendToBack;
          Result := True;
        end;
      end;
    1, 2:
      begin
        swTempFile := GetPlayTempFileName;
        try
          if dPlayType=1 then resFile := TResourceStream.Create(0, 'FLASHBIG', RT_RCDATA)
            else resFile := TResourceStream.Create(0, 'FLASHSMALL', RT_RCDATA);
          stmFile := TTntFileStream.Create(swTempFile, fmCreate);
          stmFile.CopyFrom(resFile, resFile.Size);
        finally
          if Assigned(resFile) then FreeAndNil(resFile);
          if Assigned(stmFile) then FreeAndNil(stmFile);
        end;

        if WideFileExists(swTempFile) then
        begin
          Self.Movie := swTempFile;
          Self.Visible := True;
          Self.Play;
          Self.SendToBack;          
          Result := True;
        end;
      end;
  end;
end;


function TSunFlashPlayer.GetPlayTempFileName: WideString;
var
  TempDir: array[0..255] of Char;
  sWinTempDir, TmpStr : String;
  i : Integer;
begin
  i := 0;

  GetTempPath(255, @TempDir);
  sWinTempDir := StrPas(TempDir);
  TmpStr := IncludeTrailingPathDelimiter(sWinTempDir) + '~TempSFPFile.swf';
  While WideFileExists(TmpStr) do
  begin
    TmpStr := IncludeTrailingPathDelimiter(sWinTempDir) + WideFormat('~TempSFPFile%d.swf', [i]);
    Inc(i);
  end;
  Result := TmpStr;
end;

procedure TSunFlashPlayer.AutoResizeFlash;
begin
  if Assigned(Self) then
  begin
    Self.Enabled := False;
    Self.Enabled := True;
    if Self.CanFocus then Self.SetFocus;
  end;
end;

end.
