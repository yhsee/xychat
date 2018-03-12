unit filter;

interface
uses BaseClass, DirectShow9, Windows,
     classes,DSUtil,Sysutils;
  
type  
  TnrSourceStream = class;
  TStreamArray = array of TnrSourceStream;

  TnrSource = class(TBCBaseFilter)
  protected
    FPins: Integer;
    FStreams: Pointer;
    FStateLock: TBCCritSec;
  public
    constructor Create(const Name: string; unk: IUnknown; const clsid: TGUID; out hr: HRESULT); overload;
    constructor Create(const Name: string; unk: IUnknown; const clsid: TGUID); overload;
    destructor Destroy; override;

    function GetPinCount: Integer; override;
    function GetPin(n: Integer): TBCBasePin; override;

    property StateLock: TBCCritSec read FStateLock;
    function AddPin(Stream: TnrSourceStream): HRESULT;
    function RemovePin(Stream: TnrSourceStream): HRESULT;
    function FindPin(Id: PWideChar; out Pin: IPin): HRESULT; override;
    function FindPinNumber(Pin: IPin): Integer;
  end;

  TnrSourceStream = class(TBCBaseOutputPin)
  public
    constructor Create(const ObjectName: string; out hr: HRESULT;
      Filter: TnrSource; const Name: WideString);
    destructor Destroy; override;
  protected
    FFilter: TnrSource;
  public

    function Active: HRESULT; override;
    function Inactive: HRESULT; override;

    function CheckMediaType(MediaType: PAMMediaType): HRESULT; override;
    function GetMediaType(Position: integer; out MediaType: PAMMediaType): HRESULT; overload; override; // List pos. 0-n

    function GetMediaType(MediaType: PAMMediaType): HRESULT; reintroduce; overload; virtual;

    function QueryId(out id: PWideChar): HRESULT; override;

  end;

implementation

{ TBCSource }

function TnrSource.AddPin(Stream: TnrSourceStream): HRESULT;
begin
  FStateLock.Lock;
  try
    inc(FPins);
    ReallocMem(FStreams, FPins * SizeOf(TBCSourceStream));
    TStreamArray(FStreams)[FPins-1] := Stream;
    Result := S_OK;
  finally
    FStateLock.UnLock;
  end;
end;

constructor TnrSource.Create(const Name: string; unk: IUnknown;
  const clsid: TGUID; out hr: HRESULT);
begin
  FStateLock := TBCCritSec.Create;
  inherited Create(Name, unk, FStateLock, clsid, hr);
  FPins := 0;
  FStreams := nil;
end;

constructor TnrSource.Create(const Name: string; unk: IUnknown;
  const clsid: TGUID);
begin
  FStateLock := TBCCritSec.Create;
  inherited Create(Name, unk, FStateLock, clsid);
  FPins := 0;
  FStreams := nil;
end;

destructor TnrSource.Destroy;
begin
  while (FPins <> 0) do
     TStreamArray(FStreams)[FPins - 1].Free;
  if Assigned(FStreams) then FreeMem(FStreams);
  ASSERT(FPins = 0);
  inherited;
end;

function TnrSource.FindPin(Id: PWideChar; out Pin: IPin): HRESULT;
var
  i : integer;
  Code : integer;
begin
  Val(Id,i,Code);
  if Code = 0 then
  begin
    i := i - 1;
    Pin := GetPin(i);
    if (Pin <> nil) then
      Result := NOERROR else
      Result := VFW_E_NOT_FOUND;
  end else Result := inherited FindPin(Id,Pin);
end;

function TnrSource.FindPinNumber(Pin: IPin): Integer;
begin
  for Result := 0 to FPins - 1 do
    if (IPin(TStreamArray(FStreams)[Result]) = Pin) then
      Exit;
  Result := -1;
end;

function TnrSource.GetPin(n: Integer): TBCBasePin;
begin
  FStateLock.Lock;
  try
    if ((n >= 0) and (n < FPins)) then
    begin
      ASSERT(TStreamArray(FStreams)[n] <> nil);
    	Result := TStreamArray(FStreams)[n];
    end else
      Result := nil;
  finally
    FStateLock.UnLock;
  end;
end;

function TnrSource.GetPinCount: Integer;
begin
  FStateLock.Lock;
  try
    Result := FPins;
  finally
    FStateLock.UnLock;
  end;
end;

function TnrSource.RemovePin(Stream: TnrSourceStream): HRESULT;
var i, j: Integer;
begin
  for i := 0 to FPins - 1 do
  begin
    if (TStreamArray(FStreams)[i] = Stream) then
    begin
      if (FPins = 1) then
      begin
        FreeMem(FStreams);
        FStreams := nil;
      end else
      begin
        j := i + 1;
        while (j < FPins) do
        begin
          TStreamArray(FStreams)[j-1] := TStreamArray(FStreams)[j];
          inc(j);
        end;
      end;
      dec(FPins);
      Result := S_OK;
      Exit;
    end;
  end;
  Result := S_FALSE;
end;

{ TBCSourceStream }

function TnrSourceStream.Active: HRESULT;
begin
  FFilter.FStateLock.Lock;
  try
    if (FFilter.IsActive) then
    begin
      Result := S_FALSE;
      Exit;
    end;

    if not IsConnected then
    begin
      Result := NOERROR;
      Exit;
    end;

    Result := inherited Active;
    if FAILED(Result) then
      Exit;

  finally
    FFilter.FStateLock.UnLock;
  end;
end;

function TnrSourceStream.CheckMediaType(MediaType: PAMMediaType): HRESULT;
var mt: TAMMediaType;
    pmt: PAMMediaType;
begin
  FFilter.FStateLock.Lock;
  try
    pmt := @mt;
    GetMediaType(pmt);
    if TBCMediaType(pmt).Equal(MediaType) then
      Result := NOERROR else
      Result := E_FAIL;
  finally
    FFilter.FStateLock.UnLock;
  end;
end;


constructor TnrSourceStream.Create(const ObjectName: string;
  out hr: HRESULT; Filter: TnrSource; const Name: WideString);
begin
  inherited Create(ObjectName, Filter, Filter.FStateLock,  hr, Name);
  FFilter := Filter;
  hr := FFilter.AddPin(Self);
end;

destructor TnrSourceStream.Destroy;
begin
  FFilter.RemovePin(Self);
  inherited;
end;

function TnrSourceStream.GetMediaType(MediaType: PAMMediaType): HRESULT;
begin
  Result := E_UNEXPECTED;
end;

function TnrSourceStream.GetMediaType(Position: integer;
  out MediaType: PAMMediaType): HRESULT;
begin
  FFilter.FStateLock.Lock;
  try
    if (Position = 0) then
      Result := GetMediaType(MediaType)
    else
      if (Position > 0) then
        Result := VFW_S_NO_MORE_ITEMS else
        Result := E_INVALIDARG;
  finally
    FFilter.FStateLock.UnLock;
  end;
end;

function TnrSourceStream.Inactive: HRESULT;
begin
  FFilter.FStateLock.Lock;
  try

    if not IsConnected then
    begin
      Result := NOERROR;
      Exit;
    end;

    Result := inherited Inactive;
    if FAILED(Result) then
      Exit;
      
    Result := NOERROR;
  finally
    FFilter.FStateLock.UnLock;
  end;
end;


function TnrSourceStream.QueryId(out id: PWideChar): HRESULT;
var
  i: Integer;
begin
  i := 1 + FFilter.FindPinNumber(Self);
  if (i < 1) then
    Result := VFW_E_NOT_FOUND else
    Result := AMGetWideString(IntToStr(i), id);
end;

end.