unit About;

interface

uses
  Windows, Classes, Graphics, Forms, Controls, StdCtrls, Buttons, ExtCtrls,
  ComCtrls, jpeg, SysUtils, ShellAPI,
  {Unicode Controls}
  TntForms, TntExtCtrls, TntButtons, TntStdCtrls;

type
  TAboutBox = class(TTntForm)
    Img_About: TImage;
    Panel_Control: TTntPanel;
    TntBevel1: TTntBevel;
    But_Close: TTntBitBtn;
    Lab_Version: TTntLabel;
    Lab_HomeSite: TTntLabel;
    Lab_CopyRight: TTntLabel;
    Lab_Phone: TTntLabel;
    Lab_WebSite: TTntLabel;
    TntLabel1: TTntLabel;
    procedure But_CloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Lab_HomeSiteClick(Sender: TObject);
  private
    function GetBuildVersion: WideString;
    function ExtractFileVersionInfo(FileName, ExtractWhat: string): string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

uses ShareUnt, udpcores;

{$R *.DFM}

function TAboutBox.ExtractFileVersionInfo(FileName,ExtractWhat: string): string;
type
  warr = array[0..1] of word;
  pwarr = ^warr;
var
  si: DWORD;
  dw: DWORD;
  pc: pointer;
  ss: pointer;
  ee: pointer;
  ll: UINT;
  la: string;
begin
  Result := '';
  si := GetFileVersionInfoSize(PChar(FileName),dw);
  if si <> 0 then
    begin
      GetMem(pc,si);
      try
        if GetFileVersionInfo(PChar(FileName),dw,si,pc) then
          begin
            if VerQueryValue(pc,PChar('\VarFileInfo\Translation'),ss,ll) and
              (ll >= 4) then // 4 = 2*sizeof(word) - at least one pair exists!
              begin
                la := Format('\StringFileInfo\%.4x%.4x\',[pwarr(ss)^[0],pwarr(ss)^[1]]);
                if VerQueryValue(pc,PChar(la+ExtractWhat),ee,ll) and (ll <> 0) then
                  Result := StrPas(PChar(ee));
              end;
          end;
      finally
        FreeMem(pc,si);
      end;
    end;
end;

function TAboutBox.GetBuildVersion: WideString;
begin
  Result := ExtractFileVersionInfo(Application.ExeName, 'FileVersion'); // do not localize
end;

procedure TAboutBox.But_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  Lab_Version.Caption := '²úÆ·°æ±¾: ' + GetBuildVersion;
end;

procedure TAboutBox.Lab_HomeSiteClick(Sender: TObject);
begin
  OpenCMD('http://www.yhsee.com');
end;

end.

