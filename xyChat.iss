; �ű��� Inno Setup �ű������ ������           
; �йش��� INNO SETUP �ű�����������İ����ĵ���


[Setup]
AppName=����
AppVerName=���� 2012
AppPublisher=�Ȼ����������
AppPublisherURL=http://www.yhsee.com
AppSupportURL=http://www.yhsee.com
AppUpdatesURL=http://www.yhsee.com
DefaultDirName={pf}\�Ȼ����\����
DefaultGroupName=�Ȼ����
LicenseFile=license.txt
OutputBaseFilename=xychat
Compression=lzma                                                        
SolidCompression=yes


[Files]
Source: "xyChat.exe";                  DestDir: "{app}"; Flags: ignoreversion
Source: "kmhook.dll";                  DestDir: "{app}"; Flags: ignoreversion  uninsneveruninstall onlyifdoesntexist
Source: "vnchooks.dll";                DestDir: "{app}"; Flags: ignoreversion  uninsneveruninstall onlyifdoesntexist
Source: "Riched20.dll";                DestDir: "{app}"; Flags: ignoreversion  uninsneveruninstall onlyifdoesntexist
Source: "Riched32.dll";                DestDir: "{app}"; Flags: ignoreversion  uninsneveruninstall onlyifdoesntexist
Source: "GdiPlus.dll";                 DestDir: "{app}"; Flags: ignoreversion  uninsneveruninstall onlyifdoesntexist
Source: "ImageOle.dll";                DestDir: "{app}"; Flags: ignoreversion  uninsneveruninstall onlyifdoesntexist regserver
Source: "MPEG4\*.*";                   DestDir: "{app}\MPEG4";        Flags: ignoreversion
Source: "sound\*.wav";                 DestDir: "{app}\sound";       Flags: ignoreversion
Source: "UserData\*.*";                DestDir: "{app}\UserData";    Flags: ignoreversion
Source: "Skins\*";                     DestDir: "{app}\Skins";       Flags: ignoreversion recursesubdirs
Source: "images\*";                    DestDir: "{app}\images";      Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\���� 2012";       Filename: "{app}\xyChat.exe" ;WorkingDir: "{app}"
Name: "{group}\ж������ 2012";   Filename: "{uninstallexe}" ;    WorkingDir: "{app}"
Name: "{userdesktop}\���� 2012"; Filename: "{app}\xyChat.exe"; WorkingDir: "{app}"
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\���� 2012"; Filename: "{app}\xyChat.exe"; WorkingDir: "{app}"


[Run]
Filename: "{app}\MPEG4\install.bat"; Description: "��װMicrosoft MPEG-4���������,��Ƶ������!"; Flags: nowait runhidden postinstall skipifsilent

[Code]
function NextButtonClick(CurPage: Integer): Boolean;
var ResultCode:integer;
begin
  case CurPage of

      wpSelectDir:
        begin
        if fileexists(ExpandConstant('{app}\xyChat.exe')) then
         begin
         MsgBox('�ڵ�ǰ·����⵽�ɰ汾.��װǰ��Ҫж�ؾɰ汾.', mbInformation, MB_OK);
         Exec(ExpandConstant('{app}\unins000.exe'), '', '',SW_SHOW,ewWaitUntilTerminated,ResultCode);
         end;
        end;

  end;
Result := True;
end;


