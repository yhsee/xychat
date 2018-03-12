unit Sha256Unt;

interface
uses Windows;
type
	Sha256State = array[0..7] of WORD;
	Sha256Digest = array[0..31] of byte;
	Sha256Buffer = array[0..63] of byte;
	Sha256Context = record
		State: Sha256State;
		Count: LongWord;
		Buffer: Sha256Buffer;
	end;
  
var
 P:Sha256Context;

{$LINK 'Sha256.obj'}
procedure _Sha256_Init(P:Pointer); cdecl; external;
procedure _Sha256_Update(P:Pointer; const data:Pointer; size:Word); cdecl; external;
procedure _Sha256_Final(P:Pointer; digest:Pointer); cdecl; external;

procedure Sha256(sKey:String;var buf);

implementation

procedure Sha256(sKey:String;var buf);
begin
  _Sha256_Init(@P);
  _Sha256_Update(@P,@sKey[1],Length(sKey));
  _Sha256_Final(@P,@buf);
end;


end.
