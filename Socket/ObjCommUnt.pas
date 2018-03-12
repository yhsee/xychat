unit ObjCommUnt;

interface

// "C" routines needed by the linked LZO OBJ file
function _memcmp (s1,s2: Pointer; numBytes: LongWord): Integer; cdecl;
procedure _memcpy (s1, s2: Pointer; n: Integer); cdecl;
procedure _memmove(dstP, srcP: pointer; numBytes: LongWord); cdecl;
procedure _memset (s: Pointer; c: Byte; n: Integer); cdecl;

implementation

procedure _memset(s: Pointer; c: Byte; n: Integer); cdecl;
begin
  FillChar(s^, n, c);
end;

procedure _memcpy(s1, s2: Pointer; n: Integer); cdecl;
begin
  Move(s2^, s1^, n);
end;

function _memcmp (s1, s2: Pointer; numBytes: LongWord): Integer; cdecl;
var
  i: Integer;
  p1, p2: ^byte;
begin
  p1 := s1;
  p2 := s2;
  for i := 0 to numBytes -1 do
  begin
    if p1^ <> p2^ then
    begin
      if p1^ < p2^ then
        Result := -1
      else
        Result := 1;
      exit;
    end;
    inc(p1);
    inc(p2);
  end;
  Result := 0;
end;

procedure _memmove(dstP, srcP: pointer; numBytes: LongWord); cdecl;
begin
  Move(srcP^, dstP^, numBytes); 
  FreeMem(srcP, numBytes);
end;


end.
