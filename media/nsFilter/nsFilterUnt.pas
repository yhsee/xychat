unit nsFilterUnt;

interface
uses BaseClass, DirectShow9, dspack,ActiveX, Windows,
     classes,DSUtil, Sysutils,dialogs;

const CLSID_NetSendFilter : TGUID = '{34374021-57EC-4A88-8F0A-19F730D31E5B}';

nsPinType: TRegPinTypes =(clsMajorType: @MEDIATYPE_NULL;clsMinorType: @MEDIASUBTYPE_NULL);
nsPins : array[0..0] of TRegFilterPins =
    ((strName: 'Input'; bRendered: FALSE; bOutput: FALSE; bZero: FALSE; bMany: FALSE;
      oFilter: nil; strConnectsToPin: nil; nMediaTypes: 1; lpMediaType: @nsPinType));

Type
  TnsFilter=class;
  TnsFilters=Class(TFilterGraph);

  TReciveOnBuffer=procedure(Sender:Tobject;pData:Pbyte;dLength:Longint) of object;
  
  TnsInputPin = Class (TBCRenderedInputPin)
  private
    FSharedState: TBCCritSec;
    FnsFilter:TnsFilter;
  protected
    FonRecive:TReciveOnBuffer;
  public
    constructor Create(Filter: TnsFilter;lock:TBCCritSec; out hr: HRESULT);
    destructor Destroy;override;
    function CheckMediaType(mt: PAMMediaType): HRESULT; override;
    function Receive(pSample: IMediaSample): HRESULT; override;
    function EndOfStream: HRESULT; override;
    function BeginFlush: HRESULT; override;
    function EndFlush: HRESULT; override;
  published
    property onRecive:TReciveOnBuffer read FonRecive write FonRecive;
  end;

  TnsFilter = class (TBCBaseFilter,Ifilter)
  private
    FMediaType:TAMMediaType;
    FFilter: IBaseFilter;
    FFilterGraph : TnsFilters;
    function GetFilter: IBaseFilter;
    function GetName: string;
    procedure NotifyFilter(operation: TFilterOperation; Param: integer = 0);
    procedure SetFilterGraph(AFilterGraph: TnsFilters);
  protected
    FonReciveData:TReciveOnBuffer;
    FnsInputPin: TnsInputPin;
    procedure ReceiveData(Sender:Tobject;pData:Pbyte;dLength:Longint);
  public
    constructor Create(Unk : IUnKnown);
    destructor Destroy;override;
    function GetPin(n: Integer): TBCBasePin; override;
    function GetPinCount: integer; override;
    function Stop: HRESULT; override;
    function Run(tStart: TReferenceTime): HRESULT; override;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  published
    property onReciveData:TReciveOnBuffer read FonReciveData write FonReciveData;
    property FilterGraph: TnsFilters read FFilterGraph write SetFilterGraph;
    property MediaType:TAMMediaType read FMediaType;
  end;

implementation

//------------------------------------------------------------------------------
//  TnsInputPin
//------------------------------------------------------------------------------
constructor TnsInputPin.Create(Filter: TnsFilter; lock:TBCCritSec;out hr: HRESULT);
begin
  inherited Create('nsInput Pin', Filter, lock, hr, 'Input');
  FnsFilter:=Filter;
  FSharedState := TBCCritSec.Create;
end;

destructor TnsInputPin.Destroy;
begin
  inherited destroy;
end;

function TnsInputPin.CheckMediaType(mt: PAMMediaType): HRESULT;
begin
 if IsEqualGUID(mt.formattype,FORMAT_VideoInfo)or
    IsEqualGUID(mt.formattype,FORMAT_WaveFormatEx) then
    begin
    result := S_OK;
    FreeMediaType(@FnsFilter.FMediaType);
    copymediatype(@FnsFilter.FMediaType,mt);
    end else result := E_Fail;
end;

function TnsInputPin.Receive(pSample: IMediaSample): HRESULT;
var
  pData:Pbyte;
  dLength:Longint;
  hr:HRESULT;
begin
FSharedState.Lock;
try
  hr:=inherited Receive(pSample);
  if Succeeded(hr) then
  if FSampleProps.dwStreamId=AM_STREAM_MEDIA then
     begin
     pSample.GetPointer(pData);
     dLength:=pSample.GetActualDataLength;
     if assigned(FonRecive) then
        FonRecive(nil,pData,dLength);
     end;
  result := hr;
finally
FSharedState.UnLock;
end;

end;

function TnsInputPin.EndOfStream: HRESULT;
begin
 result := inherited EndOfStream;
end;

function TnsInputPin.BeginFlush: HRESULT;
begin
Result:= inherited BeginFlush;
end;

function TnsInputPin.EndFlush: HRESULT;
begin
Result:= inherited EndFlush;
end;

//------------------------------------------------------------------------------
//  TnsFilter
//------------------------------------------------------------------------------
constructor TnsFilter.Create(Unk : IUnKnown);
begin
  inherited create('NetSendFilter',Unk,TBCCritSec.create,CLSID_NetSendFilter);
end;

destructor TnsFilter.Destroy;
begin
  freeandnil(FnsInputPin);
  inherited destroy;
end;

function TnsFilter.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
result:= inherited QueryInterface(IID,Obj);
end;

function TnsFilter.GetPin(n: Integer): TBCBasePin;
var
  hr: HRESULT;
begin
  if (n = 0) then
    begin
    FnsInputPin:= TnsInputPin.Create(self,TBCCritSec.create, hr);
    FnsInputPin.onRecive:=ReceiveData;
    end;
result := FnsInputPin;
end;

function TnsFilter.GetPinCount: integer;
begin
  result := 1;
end;

function TnsFilter.Stop: HRESULT;
begin
  result := inherited Stop;
  FnsInputPin.BreakConnect;
end;

function TnsFilter.Run(tStart: TReferenceTime): HRESULT;
begin
  result := inherited Run(tStart);
end;

procedure TnsFilter.ReceiveData(Sender:Tobject;pData:Pbyte;dLength:Longint);
begin
 if assigned(FonReciveData) then
    FonReciveData(Sender,pData,dLength);
end;

procedure TnsFilter.SetFilterGraph(AFilterGraph: TnsFilters);
begin
  if AFilterGraph = FFilterGraph then exit;
  if FFilterGraph <> nil then FFilterGraph.RemoveFilter(self);
  if AFilterGraph <> nil then AFilterGraph.InsertFilter(self);
  FFilterGraph := AFilterGraph;
end;

function TnsFilter.GetFilter: IBaseFilter;
begin
  result := FFilter;
end;

function TnsFilter.GetName: string;
begin
  result := 'NetSendFilter';
end;

procedure TnsFilter.NotifyFilter(operation: TFilterOperation; Param: integer = 0);
var
  State : TFilterState;
begin
  case operation of
    foAdding: FFilter := self;
    foRemoving:
      if (FFilter <> nil) and (FFilter.GetState(0,State) = S_OK) then
         case State of
           State_Paused,
           State_Running: FFilter.Stop;
         end;
    foRemoved: FFilter := nil;
    foRefresh:
      if assigned(FFilterGraph) then
         begin
           FFilterGraph.RemoveFilter(self);
           FFilterGraph.InsertFilter(self);
         end;
  end;
  
end;


initialization
  TBCClassFactory.CreateFilter(TnsFilter, 'NetSendFilter', CLSID_NetSendFilter,
    CLSID_LegacyAmFilterCategory, MERIT_DO_NOT_USE, 1, @nsPins);
end.
