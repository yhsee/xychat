unit LzoObj;

interface

uses
  SysUtils, Classes, Windows;

const
  LZO_E_OK                    = 0;
  LZO_E_ERROR                 =-1;
  LZO_E_OUT_OF_MEMORY         =-2;    //* not used right now */
  LZO_E_NOT_COMPRESSIBLE      =-3;    //* not used right now */
  LZO_E_INPUT_OVERRUN         =-4;
  LZO_E_OUTPUT_OVERRUN        =-5;
  LZO_E_LOOKBEHIND_OVERRUN    =-6;
  LZO_E_EOF_NOT_FOUND         =-7;
  LZO_E_INPUT_NOT_CONSUMED    =-8;

type
TLzoCompress=class
  public
    function compress(var buf;bufSize:Integer):Integer;
    function decompress(var buf;bufSize:Integer):Integer;
  end;

{$LINK 'minilzo.obj'}

function _lzo1x_1_compress(const Source: Pointer; SourceLength: LongWord; Dest: Pointer; var DestLength: LongWord; WorkMem: Pointer): Integer; cdecl; external;
function _lzo1x_decompress(const Source: Pointer; SourceLength: LongWord; Dest: Pointer; var DestLength: LongWord; WorkMem: Pointer (* NOT USED! *)): Integer; cdecl; external;
function _lzo1x_decompress_safe(const Source: Pointer; SourceLength: LongWord; Dest: Pointer; var DestLength: LongWord; WorkMem: Pointer (* NOT USED! *)): Integer; cdecl; external;
function _lzo_adler32(Adler: LongWord; const Buf: Pointer; Len: LongWord): LongWord; cdecl; external;
function _lzo_version: word; cdecl; external;
function _lzo_version_date: PChar; cdecl; external;
function _lzo_copyright(): PChar; cdecl; external;


implementation

uses ObjCommUnt;

function TLzoCompress.compress(var buf;bufSize:Integer):Integer;
var
  iRet:Integer;
  dLen:LongWord;
  dWork:Array[0..65535] of Byte;
  dOutPut:Array[0..2047] of Byte;
begin
  Result:=-1;
  if bufSize>1500 then exit;

  iRet:=_lzo1x_1_compress(@buf,bufSize,@dOutPut,dLen,@dWork);
  if iRet<>LZO_E_OK then exit;
  
  CopyMemory(@buf,@dOutPut,dLen);
  Result:=dLen;
end;

function TLzoCompress.decompress(var buf;bufSize:Integer):Integer;
var
  iRet:Integer;
  dLen:LongWord;
  dOutPut:Array[0..2047] of Byte;
begin
  Result:=-1;
  if bufSize>2048 then exit;

  iRet:=_lzo1x_decompress(@buf,bufSize,@dOutPut,dLen,nil);
  if iRet<>LZO_E_OK then exit;

  CopyMemory(@buf,@dOutPut,dLen);
  Result:=dLen;
end;

end.












