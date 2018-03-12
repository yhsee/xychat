unit IMCode;

interface

function ChineseToSpell(sTmpStr:PChar):PChar;Stdcall; external 'chSpell.dll';
function ChineseToSpellEx(sTmpStr:PChar):PChar;Stdcall; external 'chSpell.dll';
function MakeSpellCode(stText: string;Const bSimple:Boolean=False): string;

implementation

uses SysUtils;

function MakeSpellCode(stText: string;Const bSimple:Boolean=False): string;
var
  sTmpStr:PChar;
begin
  if bSimple then
    sTmpStr:=ChineseToSpellEx(PChar(stText))
    else sTmpStr:=ChineseToSpell(PChar(stText));
  Result:=Trim(StrPas(sTmpStr));
  if Length(Result)=0 then Result:=stText;
end;

end.
