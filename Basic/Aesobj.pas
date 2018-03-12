unit Aesobj;

interface

uses
  Windows, SysUtils, Classes;

type
TAesCryptic=class
    constructor Create;
  private
    _Initial_IV:TGUID;  //��ֵ
  public
    function EncodeBuffer(var buf;var bufSize:Word;sKey:String):Boolean;
    function DecodeBuffer(var buf;var bufSize:Word;sKey:String):Boolean;
    function EncodeStream(TmpStream:TStream;sKey:String):Boolean;
    function DecodeStream(TmpStream:TStream;sKey:String):Boolean;
  end;

{$LINK 'aes.obj'}

// AES_BLOCK_SIZE 16 Byte
// AES_NUM_IVMRK_WORDS ((1 + 1 + 15) * 4)

//** Call AesGenTables one time before other AES functions */
procedure _AesGenTables; cdecl; external;

//** aes - 16-byte aligned pointer to keyMode+roundKeys sequence */
//** keySize = 16 or 24 or 32 (bytes) */
procedure _Aes_SetKey_Enc(aes:Pointer; const key:Pointer; keySize:Word); cdecl; external;
procedure _Aes_SetKey_Dec(aes:Pointer; const key:Pointer; keySize:Word); cdecl; external;

//** ivAes - 16-byte aligned pointer to iv+keyMode+roundKeys sequence: UInt32[AES_NUM_IVMRK_WORDS] */
procedure _AesCbc_Init(ivAes:Pointer; const iv:Pointer); cdecl; external; //** iv size is AES_BLOCK_SIZE */

//** data - 16-byte aligned pointer to data */
//** numBlocks - the number of 16-byte blocks in data array */
procedure _AesCbc_Encode(ivAes:Pointer; data:Pointer; numBlocks:Word); cdecl; external;
procedure _AesCbc_Decode(ivAes:Pointer; data:Pointer; numBlocks:Word); cdecl; external;
procedure _AesCtr_Code(ivAes:Pointer; data:Pointer; numBlocks:Word); cdecl; external;

//------------------------------------------------------------------------------

implementation
uses Sha256Unt;

constructor TAesCryptic.Create;
begin
  _Initial_IV:=StringToGUID('{2A0B9C39-2A7E-4330-8F40-C60CB974991A}');
  _AesGenTables;
end;

//------------------------------------------------------------------------------
// ���ܻ�����,������Ӧ���� 32 byte �ı����ռ� ������ܹ��̽��޷�����
//------------------------------------------------------------------------------
function TAesCryptic.EncodeBuffer(var buf;var bufSize:Word;sKey:String):Boolean;
var
  iBlock:Word;
  Aes:array[0..271] of Byte;
  key:array[0..31] of Byte;
begin
  try
  //----------------------------------------------------------------------------
  // �����ݽ��з��� ��ԭʼ��Сд������
  //----------------------------------------------------------------------------
  iBlock:=(bufSize+SizeOf(LongWord)) div 16;
  if (bufSize+SizeOf(LongWord)) div 16>0 then inc(iBlock);
  CopyMemory(Pointer(Integer(@buf)+iBlock*16-SizeOf(LongWord)),@bufSize,SizeOf(LongWord));
  //----------------------------------------------------------------------------
  // ��ʼ����
  //----------------------------------------------------------------------------
  Sha256(sKey,key);
  //���� ����
  _Aes_SetKey_Enc(Pointer(Integer(@aes)+16),@key,32);
  _AesCbc_Init(@Aes,@_Initial_IV);
  _AesCbc_Encode(@Aes,@buf,iBlock);
  bufSize:=iBlock*16;
  
  Result:=True;
  except
  Result:=False;
  end;
end;

//------------------------------------------------------------------------------
// ���ܻ�����
//------------------------------------------------------------------------------
function TAesCryptic.DecodeBuffer(var buf;var bufSize:Word;sKey:String):Boolean;
var
  iBlock:Word;
  Aes:array[0..271] of Byte;
  key:array[0..31] of Byte;
begin
  try
  iBlock:=bufSize div 16;
  //----------------------------------------------------------------------------
  // ��ʼ����
  //----------------------------------------------------------------------------
  Sha256(sKey,key);
  //���� ����
  _Aes_SetKey_Dec(Pointer(Integer(@aes)+16),@key,32);
  _AesCbc_Init(@Aes,@_Initial_IV);
  _AesCbc_Decode(@Aes,@buf,iBlock);
  //----------------------------------------------------------------------------
  // ��ȡ�����ڵ����ݳ���
  //----------------------------------------------------------------------------
  CopyMemory(@bufSize,Pointer(Integer(@buf)+iBlock*16-SizeOf(LongWord)),SizeOf(LongWord));
  Result:=True;
  except
  Result:=False;
  end;
end;

//Aes ���ܹ���
function TAesCryptic.EncodeStream(TmpStream:TStream;sKey:String):Boolean;
var
  iSize:Word;
  buf:array of byte;
begin
  iSize:=TmpStream.Size;
  SetLength(buf,iSize+32);
  TmpStream.Seek(0,0);
  TmpStream.Read(buf[0],iSize);
  Result:=EncodeBuffer(buf[0],iSize,sKey);
  if Result then
    begin
    TmpStream.Size:=0;
    TmpStream.Write(buf[0],iSize);
    end;
end;

//Aes ���ܹ���
function TAesCryptic.DecodeStream(TmpStream:TStream;sKey:String):Boolean;
var
  iSize:Word;
  buf:array of byte;
begin
  iSize:=TmpStream.Size;
  SetLength(buf,iSize);
  TmpStream.Seek(0,0);
  TmpStream.Read(buf[0],iSize);
  Result:=DecodeBuffer(buf[0],iSize,sKey);
  if Result then
    begin
    TmpStream.Size:=0;
    TmpStream.Write(buf[0],iSize);
    end;
end;

end.










