unit compress;

interface
uses Windows,tntsystem,SysUtils,Classes,TntClasses,
     IdHash,IdHashMessageDigest,ZLibEx;

const
  DefEnDecryption  ='DES';//RSA,AES,LH5

function ComparessString(s:string):string;
function UnComparessString(s:string):string;
function ComparessStream(InStream,OutStream:TmemoryStream):boolean;
function UnComparessStream(InStream,OutStream:TmemoryStream):boolean;

Function EncryptStream(InStream,OutStream:TmemoryStream;Const AName:String=DefEnDecryption):Boolean;
Function DecryptStream(InStream,OutStream:TmemoryStream;Const AName:String=DefEnDecryption):Boolean;
Function EncryptString(strSource:String;Const AName:String=DefEnDecryption):String;
Function DecryptString(strSource:String;Const AName:String=DefEnDecryption):String;



implementation

function ComparessString(s:string):string;
var Instream,OutStream:TMemoryStream;
begin
try
OutStream:=TMemoryStream.Create;
Instream:=TMemoryStream.Create;
Instream.WriteBuffer(s[1],length(s));
Instream.Seek(0,soFromBeginning);
if ComparessStream(Instream,OutStream) then
   begin
   OutStream.Seek(0,soFromBeginning);
   setlength(s,OutStream.size);
   OutStream.ReadBuffer(s[1],OutStream.size);
   end;
finally
result:=s;
FreeAndNil(Instream);
FreeAndNil(OutStream);
end;
end;

function UnComparessString(s:string):string;
var Instream,OutStream:TMemoryStream;
begin
try
OutStream:=TMemoryStream.Create;
Instream:=TMemoryStream.Create;
Instream.WriteBuffer(s[1],length(s));
Instream.Seek(0,soFromBeginning);
if UnComparessStream(Instream,OutStream) then
   begin
   OutStream.Seek(0,soFromBeginning);
   setlength(s,OutStream.size);
   OutStream.ReadBuffer(s[1],OutStream.size);
   end;
finally
FreeAndNil(Instream);
FreeAndNil(OutStream);
result:=s;
end;
end;

function ComparessStream(InStream,OutStream:TmemoryStream):boolean;
begin
  Result:=True;
    try
    ZCompressStream(Instream,OutStream);
    except
    Result:=False;
    end;
end;

function UnComparessStream(InStream,OutStream:TmemoryStream):boolean;
begin
  Result:=True;
    Try
    ZDecompressStream(InStream,OutStream);
    Except
    Result:=False;
    end;
end;

Function EncryptStream(InStream,OutStream:TmemoryStream;Const AName:String=DefEnDecryption):Boolean;
begin
  Result:=True;
    try
    OutStream.LoadFromStream(InStream);
    except
    Result:=False;
    end;
end;

Function DecryptStream(InStream,OutStream:TmemoryStream;Const AName:String=DefEnDecryption):Boolean;
begin
  Result:=True;
    try
    OutStream.LoadFromStream(InStream);
    except
    Result:=False;
    end;
end;

Function EncryptString(strSource:String;Const AName:String=DefEnDecryption):String;
var Instream,OutStream:TMemoryStream;
begin
try
OutStream:=TMemoryStream.Create;
Instream:=TMemoryStream.Create;
Instream.WriteBuffer(strSource[1],length(strSource));
Instream.Seek(0,soFromBeginning);
if EncryptStream(Instream,OutStream,AName) then
   begin
   OutStream.Seek(0,soFromBeginning);
   setlength(strSource,OutStream.size);
   OutStream.ReadBuffer(strSource[1],OutStream.size);
   end;
finally
result:=strSource;
FreeAndNil(Instream);
FreeAndNil(OutStream);
end;
end;

Function DecryptString(strSource:String;Const AName:String=DefEnDecryption):String;
var Instream,OutStream:TMemoryStream;
begin
try
OutStream:=TMemoryStream.Create;
Instream:=TMemoryStream.Create;
Instream.WriteBuffer(strSource[1],length(strSource));
Instream.Seek(0,soFromBeginning);
if DecryptStream(Instream,OutStream,AName) then
   begin
   OutStream.Seek(0,soFromBeginning);
   setlength(strSource,OutStream.size);
   OutStream.ReadBuffer(strSource[1],OutStream.size);
   end;
finally
result:=strSource;
FreeAndNil(Instream);
FreeAndNil(OutStream);
end;
end;


initialization

finalization

end.
