unit nrFilterUnt;

interface
uses BaseClass, DirectShow9, ActiveX,Dspack, Windows,
     mmsystem, classes,DSUtil, Sysutils,math,filter;

const CLSID_NetReceiveFilter : TGUID = '{8DE7E995-F12D-4F78-B7AF-AF63D265C8E1}';

nrPinType: TRegPinTypes =(clsMajorType: @MEDIATYPE_NULL;clsMinorType: @MEDIASUBTYPE_NULL);
nrPins : array[0..0] of TRegFilterPins =
    ((strName: 'Output'; bRendered: FALSE; bOutput: True; bZero: FALSE; bMany: FALSE;
      oFilter: nil; strConnectsToPin: nil; nMediaTypes: 1; lpMediaType: @nrPinType));

Type
  TnrFilter=class;
  TnrFilters=Class(TFilterGraph);
  TnrOutputPin = class(TnrSourceStream)
  private
    FnrFilter:TnrFilter;
    FSharedState: TBCCritSec;
  protected
  public
    constructor Create(out hr: HResult; Filter: TnrFilter);
    destructor Destroy; override;
    function GetMediaType(iPosition: Integer;
      out MediaType: PAMMediaType): HResult; override;
    function CheckMediaType(MediaType: PAMMediaType): HResult; override;
    function DecideBufferSize(Allocator: IMemAllocator;
      Properties: PAllocatorProperties): HRESULT; override;
    function SetMediaType(MediaType: PAMMediaType): HRESULT; override;
    function Notify(Filter: IBaseFilter; q: TQuality): HRESULT; override;
      stdcall;
  published
  end;

  TnrFilter = class (TnrSource,Ifilter)
  private
    FisVideo:Boolean;
    Fmediatype:TAMMediaType;
    FFilter: IBaseFilter;
    FFilterGraph : TnrFilters;
    function GetFilter: IBaseFilter;
    function GetName: string;
    procedure NotifyFilter(operation: TFilterOperation; Param: integer = 0);
    procedure SetFilterGraph(AFilterGraph: TnrFilters);
  protected
    FnrOutputPin: TnrOutputPin;
  public
    constructor Create(Unk: IUnKnown);
    constructor CreateFromFactory(Factory: TBCClassFactory;
      const Controller: IUnknown); override;
    destructor Destroy; override;
    procedure SetupMediaType(mt:TAMMediaType);
    function PlaySample(pData:Pbyte;dLength:Longint): HRESULT;
  published
    property FilterGraph: TnrFilters read FFilterGraph write SetFilterGraph;
  end;

implementation

//------------------------------------------------------------------------------
//  TnrOutputPin
//------------------------------------------------------------------------------
constructor TnrOutputPin.Create(out hr: HResult; Filter: TnrFilter);
begin
  inherited Create('nrOutput Pin', hr, Filter, 'Output');
  FnrFilter:=Filter;
  FSharedState := TBCCritSec.Create;
  hr := S_OK;
end;

destructor TnrOutputPin.Destroy;
begin
  inherited destroy;
end;

function TnrOutputPin.CheckMediaType(MediaType: PAMMediaType): HResult;
begin
 if IsEqualGUID(MediaType.formattype,FORMAT_VideoInfo)or
    IsEqualGUID(MediaType.formattype,FORMAT_WaveFormatEx) then
    result := S_OK else result := E_Fail;
end;

function TnrOutputPin.DecideBufferSize(Allocator: IMemAllocator;
      Properties: PAllocatorProperties): HRESULT;
var
  wfx:PWaveFormatEx;
  PVI:PVIDEOINFOHEADER;
  Actual: ALLOCATOR_PROPERTIES;
begin
  if (Allocator = nil) or (Properties = nil) then
  begin
    Result := E_POINTER;
    Exit;
  end;

  FFilter.StateLock.Lock;
  try
  if FnrFilter.FisVideo then
     begin
     PVI:=AMMediaType.pbFormat;
     Properties.cbBuffer :=pvi.bmiHeader.biSizeImage;
     end else begin
     wfx:=AMMediaType.pbFormat;
     Properties.cbBuffer :=wfx.nAvgBytesPerSec;
     end;

    Properties.cBuffers := 1;
    Properties.cbAlign:=1;
    Assert(Properties.cbBuffer <> 0);

    Result := Allocator.SetProperties(Properties^, Actual);

    if Failed(Result) then Exit;

    if (Actual.cbBuffer < Properties.cbBuffer) then
      begin
      Result := E_FAIL;
      Exit;
      end;

    Assert(Actual.cBuffers = 1);

    Result := S_OK;

  finally
    FFilter.StateLock.UnLock;
  end;
end;

function TnrOutputPin.GetMediaType(iPosition: Integer;
      out MediaType: PAMMediaType): HResult;
begin
FFilter.StateLock.Lock;
try
  if (MediaType = nil) then
    begin
    Result := E_POINTER;
    Exit;
    end;

  if (iPosition=0) then
    begin
    FreeMediaType(MediaType);
    copymediatype(MediaType,@FnrFilter.FMediaType);
    Result:=NOERROR;
    end else Result := VFW_S_NO_MORE_ITEMS;
finally
FFilter.StateLock.UnLock;
end;
end;

function TnrOutputPin.SetMediaType(MediaType: PAMMediaType): HRESULT;
begin
  FFilter.StateLock.Lock;
  try
    Result := inherited SetMediaType(MediaType);
  finally
    FFilter.StateLock.UnLock;
  end;
end;

function TnrOutputPin.Notify(Filter: IBaseFilter; q: TQuality): HRESULT;
begin
  Result := E_FAIL;
end;


//------------------------------------------------------------------------------
//  TnrFilter
//------------------------------------------------------------------------------
constructor TnrFilter.Create(Unk: IUnKnown);
var hr: HRESULT;
begin
  inherited Create('NetReceiveFilter', Unk, CLSID_NetReceiveFilter);
  FnrOutputPin := TnrOutputPin.Create(hr, Self);
end;

destructor TnrFilter.Destroy;
begin
  FreeAndNil(FnrOutputPin);
  inherited destroy;
end;

procedure TnrFilter.SetupMediaType(mt:TAMMediaType);
begin
FisVideo:=IsEqualGUID(mt.formattype,FORMAT_VideoInfo);
FreeMediaType(@Fmediatype);
copymediatype(@Fmediatype,@mt);
end;

function TnrFilter.PlaySample(pData:Pbyte;dLength:Longint): HRESULT;
var
  p:Pbyte; pleng:longint;
  Sample: IMediaSample;
begin
  FnrOutputPin.FSharedState.Lock;
  try
    result := FnrOutputPin.GetDeliveryBuffer(Sample, nil, nil, 0);
    while FAILED(result) do
      begin
      Sleep(1);
      result := FnrOutputPin.GetDeliveryBuffer(Sample, nil, nil, 0);
      end; 

   if Assigned(Sample) then
      begin
      Sample.GetPointer(P);
      pleng:=Sample.GetSize;;
      CopyMemory(p,pData,min(pleng,dLength));
      Sample.SetActualDataLength(dLength);
      Sample.SetSyncPoint(True);
      Sample.SetTime(nil,nil);
      result := FnrOutputPin.Deliver(Sample);
      Sample:=nil;
      end;
  finally
    FnrOutputPin.FSharedState.UnLock;
  end;
end;

constructor TnrFilter.CreateFromFactory(Factory: TBCClassFactory;
  const Controller: IUnknown);
begin
  Create(Controller);
end;

procedure TnrFilter.SetFilterGraph(AFilterGraph: TnrFilters);
begin
  if AFilterGraph = FFilterGraph then exit;
  if FFilterGraph <> nil then FFilterGraph.RemoveFilter(self);
  if AFilterGraph <> nil then AFilterGraph.InsertFilter(self);
  FFilterGraph := AFilterGraph;
end;

function TnrFilter.GetFilter: IBaseFilter;
begin
  result := FFilter;
end;

function TnrFilter.GetName: string;
begin
  result := 'NetReceiveFilter';
end;

procedure TnrFilter.NotifyFilter(operation: TFilterOperation; Param: integer = 0);
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
  TBCClassFactory.CreateFilter(TnrFilter, 'NetReceiveFilter', CLSID_NetReceiveFilter,
    CLSID_LegacyAmFilterCategory, MERIT_DO_NOT_USE, 1, @nrPins);
end.
