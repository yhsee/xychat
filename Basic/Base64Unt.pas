unit Base64Unt;

interface

uses SysUtils,Classes,EncdDecd;

//------------------------------------------------------------------------------
// ×Ö·û±àÂë
//------------------------------------------------------------------------------
function EnCodeStreamBase64(TmpValue:TStream):String;
function DeCodeStreamBase64(Value:String;TmpValue:TStream):Boolean;

function EnCodeWideBase64(Value:WideString):String;
function DeCodeWideBase64(Value:String):WideString;

function EnCodeObjectBase64(TmpObject:TComponent):String;
function DeCodeObjectBase64(Value:String;TmpObject:TComponent):Boolean;

function EnCodeBufferBase64(var buf;iBufLen:Integer):String;
function DeCodeBufferBase64(Value:String;pBuffer:Pointer):Integer;

implementation

function EnCodeWideBase64(Value:WideString):String;
begin
  Result:=EncodeString(UTF8Encode(Value));
end;

function DeCodeWideBase64(Value:String):WideString;
begin
  Result:=UTF8Decode(DecodeString(Value));
end;

function EnCodeStreamBase64(TmpValue:TStream):String;
var
  TmpStream:TMemoryStream;
begin
  try
    TmpStream:=TMemoryStream.Create;
      try
      TmpValue.Seek(0,soFromBeginning);
      EncodeStream(TmpValue,TmpStream);
      TmpStream.Seek(0,soFromBeginning);
      SetLength(Result,TmpStream.Size);
      TmpStream.Read(Result[1],TmpStream.Size);
      except
      Result:='';
      end;
  finally
    freeandnil(TmpStream);
  end;
end;


function DeCodeStreamBase64(Value:String;TmpValue:TStream):Boolean;
var
  TmpStream:TMemoryStream;
begin
  try
    TmpStream:=TMemoryStream.Create;
    TmpStream.Write(Value[1],Length(Value));
    TmpStream.Seek(0,soFromBeginning);
      try
      DecodeStream(TmpStream,TmpValue);
      TmpValue.Seek(0,soFromBeginning);
      Result:=True;
      except
      Result:=False;
      end;
  finally
    freeandnil(TmpStream);
  end;
end;

function EnCodeObjectBase64(TmpObject:TComponent):String;
var
  TmpStream:TMemoryStream;
begin
  try
    TmpStream:=TMemoryStream.Create;
    TmpStream.WriteComponent(TmpObject);
    Result:=EnCodeStreamBase64(TmpStream);
  finally
    freeandnil(TmpStream);
  end;
end;

function DeCodeObjectBase64(Value:String;TmpObject:TComponent):Boolean;
var
  TmpStream:TMemoryStream;
begin
  try
    TmpStream:=TMemoryStream.Create;
    Result:=DeCodeStreamBase64(Value,TmpStream);
    if Result then TmpStream.ReadComponent(TmpObject);
  finally
    freeandnil(TmpStream);
  end;
end;

function EnCodeBufferBase64(var buf;iBufLen:Integer):String;
var
  TmpStream:TMemoryStream;
begin
  try
    TmpStream:=TMemoryStream.Create;
    TmpStream.WriteBuffer(buf,iBufLen);
    Result:=EnCodeStreamBase64(TmpStream);
  finally
    freeandnil(TmpStream);
  end;
end;

function DeCodeBufferBase64(Value:String;pBuffer:Pointer):Integer;
var
  TmpStream:TMemoryStream;
begin
  try
    Result:=-1;
    TmpStream:=TMemoryStream.Create;
    if DeCodeStreamBase64(Value,TmpStream) then
      begin
      Result:=TmpStream.Size;
      TmpStream.Read(pBuffer^,Result);
      end;
  finally
    freeandnil(TmpStream);
  end;
end;

end.
