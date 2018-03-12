unit avplayunt;

interface

uses
  Windows, Messages,SysUtils,Classes,extctrls,Graphics,
  BaseClass,DSPack,directshow9,DSUtil,ActiveX,
  nrFilterUnt;
  
type
  TOnWriteLogEvent=procedure(Sender:TObject;sLog:WideString)of Object;
  TOnVideoPlayEvent=procedure(Sender:TObject;mBitmap:TBitmap)of Object;
  TVideoPlayback=class
      constructor Create;
      destructor  Destroy;override;
    private
      FVideoPlayInitial:boolean;
      FVideoBmp:TBitmap;      
      FOnVideoPlay:TOnVideoPlayEvent;
      FOnWriteLog:TOnWriteLogEvent;
      ReceiveFiltergraph:TFiltergraph;
      ReceiveVideoFilter:TnrFilter;
      VideoSample:TSampleGrabber;
      VDecoder:Tfilter;
      FPlayStream:TMemoryStream;
      function SetVideoMediaType(TmpStream:TStream):Boolean;
      procedure WriteLog(sLog:WideString);
      procedure VideoSampleGrabber(sender: TObject; SampleTime: Double;
        pBuffer: Pointer; BufferLen: Integer);
    public
      procedure StartPlayback(TmpStream:TStream);
      procedure VideoPlaySample(mSample:TStream);
    published
      property OnVideoPlay:TOnVideoPlayEvent Write FOnVideoPlay;
      property OnWriteLog:TOnWriteLogEvent Write FOnWriteLog;
    end;

implementation
uses math;

function SetDefaultMoniker(sGUID:String;TmpBaseFilter:TBaseFilter):boolean;
var
  i:Integer;
begin
  Result:=False;
  with TSysDevEnum.Create(CLSID_LegacyAmFilterCategory) do
    try
    for i:=CountFilters Downto 1 do
    if CompareText(GUIDToString(filters[i-1].CLSID),sGUID)=0 then
      begin
      TmpBaseFilter.Moniker:=GetMoniker(i-1);
      Result:=True;
      Break;
      end;
    finally
    free;
    end;
end;

{TVideoPlayback}
//------------------------------------------------------------------------------
// 回放设备
//------------------------------------------------------------------------------
constructor TVideoPlayback.Create;
begin
  try
  FVideoBmp:=TBitmap.Create;
  FPlayStream:=TMemoryStream.Create;

  ReceiveFiltergraph:=TFiltergraph.Create(nil);
  ReceiveFiltergraph.Mode:=gmCapture;

  ReceiveVideoFilter:=TnrFilter.Create(nil);
  ReceiveVideoFilter.FilterGraph:=TnrFilters(ReceiveFiltergraph);

  VDecoder:=Tfilter.Create(nil);
  VDecoder.FilterGraph:=ReceiveFiltergraph;

  VideoSample:=TSampleGrabber.Create(nil);
  VideoSample.FilterGraph:=ReceiveFiltergraph;
  VideoSample.OnBuffer:=VideoSampleGrabber;

  //寻找解码器。如果没有找到将不能正常播放
  FVideoPlayInitial:=SetDefaultMoniker('{82CCD3E0-F71A-11D0-9FE5-00609778EA66}',VDecoder.BaseFilter);
  if not FVideoPlayInitial then FVideoPlayInitial:=SetDefaultMoniker('{04FE9017-F873-410E-871E-AB91661A4EF7}',VDecoder.BaseFilter);

  except
  WriteLog('Playback Initial Is Fail');
  end;
end;

destructor  TVideoPlayback.Destroy;
begin
  if assigned(ReceiveFiltergraph) then
     begin
     ReceiveFiltergraph.Stop;
     ReceiveFiltergraph.Active:=false;
     ReceiveFiltergraph.ClearGraph;
     freeandnil(ReceiveFiltergraph);
     end;
  if assigned(ReceiveVideoFilter) then freeandnil(ReceiveVideoFilter);
  if assigned(VDecoder) then freeandnil(VDecoder);
  if assigned(VideoSample) then freeandnil(VideoSample);
  if assigned(FPlayStream) then freeandnil(FPlayStream);
  if assigned(FVideoBmp) then freeandnil(FVideoBmp);
end;

function TVideoPlayback.SetVideoMediaType(TmpStream:TStream):Boolean;
var
  mt:TAMMediaType;
  dlength:integer;
begin
  Result:=False;
  if TmpStream.Size>0 then
    try
    TmpStream.Seek(0,soFromBeginning);
    TmpStream.ReadBuffer(mt,sizeof(TAMMediaType));
    dlength:=TmpStream.Size-sizeof(TAMMediaType);
    mt.pbFormat:=CoTaskMemAlloc(dlength);
    TmpStream.ReadBuffer(mt.pbFormat^,dlength);
    ReceiveVideoFilter.SetupMediaType(mt);
    Result:=True;
    except
    WriteLog('Playback SetupMediaType Is Error');
    end;
end;

procedure TVideoPlayback.WriteLog(sLog:WideString);
begin
  if assigned(FOnWriteLog)then FOnWriteLog(nil,sLog);
end;

procedure TVideoPlayback.VideoSampleGrabber(sender: TObject; SampleTime: Double;
  pBuffer: Pointer; BufferLen: Integer);
begin
  VideoSample.GetBitmap(FVideoBmp,pBuffer,BufferLen);
  if assigned(FOnVideoPlay) then FOnVideoPlay(nil,FVideoBmp);
end;

procedure TVideoPlayback.StartPlayback(TmpStream:TStream);
begin
  if FVideoPlayInitial  then
    try
    ReceiveFiltergraph.Active:=false;
    ReceiveFiltergraph.ClearGraph;
    ReceiveFiltergraph.Active:=true;
    if SetVideoMediaType(TmpStream) then
      begin
      with (ReceiveFiltergraph as ICaptureGraphBuilder2) do
        RenderStream(nil, nil, ReceiveVideoFilter as IBaseFilter,VDecoder as IBaseFilter, VideoSample as IBaseFilter);
      ReceiveFiltergraph.Play;
      end;
    except
    WriteLog('Playback is Fail');
    end;
end;

procedure TVideoPlayback.VideoPlaySample(mSample:TStream);
begin
  if FVideoPlayInitial then
  if ReceiveFiltergraph.State=gsPlaying then
    try
    mSample.Seek(0,0);
    FPlayStream.SetSize(0);
    FPlayStream.LoadFromStream(mSample);
    FPlayStream.Seek(0,soFromBeginning);
    ReceiveVideoFilter.PlaySample(FPlayStream.Memory,FPlayStream.Size);
    except
    WriteLog('Playback Video Is Error');
    end;
end;

initialization
  CoInitialize(nil);
finalization
  CoUninitialize;

end.
