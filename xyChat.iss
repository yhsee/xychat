; 脚本由 Inno Setup 脚本设计向导 创建。           
; 有关创建 INNO SETUP 脚本的详情请查阅帮助文档！


[Setup]
AppName=絮语
AppVerName=絮语 2012
AppPublisher=奕华软件工作室
AppPublisherURL=http://www.yhsee.com
AppSupportURL=http://www.yhsee.com
AppUpdatesURL=http://www.yhsee.com
DefaultDirName={pf}\奕华软件\絮语
DefaultGroupName=奕华软件
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
Name: "{group}\絮语 2012";       Filename: "{app}\xyChat.exe" ;WorkingDir: "{app}"
Name: "{group}\卸载絮语 2012";   Filename: "{uninstallexe}" ;    WorkingDir: "{app}"
Name: "{userdesktop}\絮语 2012"; Filename: "{app}\xyChat.exe"; WorkingDir: "{app}"
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\絮语 2012"; Filename: "{app}\xyChat.exe"; WorkingDir: "{app}"


[Run]
Filename: "{app}\MPEG4\install.bat"; Description: "安装Microsoft MPEG-4编码解码器,视频所必需!"; Flags: nowait runhidden postinstall skipifsilent

[Code]
function NextButtonClick(CurPage: Integer): Boolean;
var ResultCode:integer;
begin
  case CurPage of

      wpSelectDir:
        begin
        if fileexists(ExpandConstant('{app}\xyChat.exe')) then
         begin
         MsgBox('在当前路径检测到旧版本.安装前需要卸载旧版本.', mbInformation, MB_OK);
         Exec(ExpandConstant('{app}\unins000.exe'), '', '',SW_SHOW,ewWaitUntilTerminated,ResultCode);
         end;
        end;

  end;
Result := True;
end;


