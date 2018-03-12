unit VideoUnt;

interface

uses
  Windows, Messages,SysUtils,Classes,extctrls,
  BaseClass,DSPack,directshow9,DSUtil,dialogs,
  nrFilterUnt,nsFilterUnt,activex;
  
type
  TVideoCore=class
      constructor Create;
      destructor  Destroy;override;
    private
      FVideoImage:TImage;
      FVideoisok:Boolean;
      Fvideo_index:Integer;
      SendVideoFilter:TnsFilter;
      ReceiveVideoFilter:TnrFilter;
      VideoSample:TSampleGrabber;
      VideoSource,VEncoder,VDecoder:Tfilter;

      VideoDevList: TSysDevEnum;

      mSampleStream:TMemoryStream;
      ReceiveFiltergraph,
      SendFiltergraph:tfiltergraph;
      procedure InitDirectShow;
      procedure finalDirectShow;
      procedure SetAudioVideoProperty;
      procedure initvideosource;
      procedure GetMediaType(TmpStream:TStream);
      procedure SetMediaType(TmpStream:TStream);
      procedure VideoOnBuffer(Sender:Tobject;pData:Pbyte;dLength:Longint);
      procedure SampleOnBuffer(sender: TObject; SampleTime: Double; pBuffer: Pointer; BufferLen: longint);
    public
      procedure video_select(dev_list:tstrings);
      procedure videoseting(hwd:thandle);
      procedure mediaSendstart(TmpImg:TImage);
      procedure mediaSendstop;
    end;
    
implementation
uses SimpleXmlUnt;
//------------------------------------------------------------------------------
// 初始化 DirectShow  视频设备
//------------------------------------------------------------------------------
constructor TVideoCore.Create;
begin
InitDirectShow;
SetAudioVideoProperty;
end;

//------------------------------------------------------------------------------
// 释放 DirectShow  视频设备
//------------------------------------------------------------------------------
destructor TVideoCore.Destroy;
begin
  SendFiltergraph.Stop;
  SendFiltergraph.Active := false;
  ReceiveFiltergraph.Stop;
  ReceiveFiltergraph.Active:=false;
  finalDirectShow;
  inherited Destroy;
end;

procedure TVideoCore.InitDirectShow;
begin
try
mSampleStream:=TMemoryStream.Create;
SendFiltergraph:=tfiltergraph.Create(nil);
SendFiltergraph.Mode:=gmCapture;

ReceiveFiltergraph:=tfiltergraph.Create(nil);
ReceiveFiltergraph.Mode:=gmCapture;


VideoSample:=TSampleGrabber.Create(nil);
VideoSample.FilterGraph:=ReceiveFiltergraph;
VideoSample.OnBuffer:=SampleOnBuffer;

VideoDevList:= TSysDevEnum.Create(CLSID_VideoInputDeviceCategory);
if VideoDevList.CountFilters > 0 then
   begin
   if not(VideoDevList.CountFilters>Fvideo_index) then Fvideo_index:=0;
   if Fvideo_index=-1 then Fvideo_index:=0;
   FVideoisok:=true;
   end;

VideoSource:=Tfilter.Create(nil);
VideoSource.FilterGraph:=SendFiltergraph;

SendVideoFilter:=TnsFilter.Create(nil);
SendVideoFilter.FilterGraph:=TnsFilters(SendFiltergraph);

ReceiveVideoFilter:=TnrFilter.Create(nil);
ReceiveVideoFilter.FilterGraph:=TnrFilters(ReceiveFiltergraph);

VEncoder:=Tfilter.Create(nil);
VEncoder.FilterGraph:=SendFiltergraph;

VDecoder:=Tfilter.Create(nil);
VDecoder.FilterGraph:=ReceiveFiltergraph;


except
Fvideo_index:=-1;
Fvideoisok:=false;
end;

end;

procedure TVideoCore.finalDirectShow;
begin
  try
    if assigned(SendFiltergraph)          then freeandnil(SendFiltergraph);
    if assigned(ReceiveFiltergraph)       then freeandnil(ReceiveFiltergraph);
    if assigned(SendVideoFilter)          then freeandnil(SendVideoFilter);
    if assigned(ReceiveVideoFilter)       then freeandnil(ReceiveVideoFilter);
    if assigned(VideoSource)              then freeandnil(VideoSource);
    if assigned(VEncoder)                 then freeandnil(VEncoder);
    if assigned(VDecoder)                 then freeandnil(VDecoder);
    if assigned(VideoSample)              then freeandnil(VideoSample);
    if assigned(VideoDevList)             then freeandnil(VideoDevList);
    if assigned(mSampleStream)                then freeandnil(mSampleStream);
  except

  end;
end;


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

function SetDefaultMonikerEx(sName:String;TmpBaseFilter:TBaseFilter):boolean;
var
  i:Integer;
begin
  Result:=False;
  with TSysDevEnum.Create(CLSID_VideoCompressorCategory) do
    try
    for i:=CountFilters Downto 1 do
    if CompareText(filters[i-1].FriendlyName,sName)=0 then
      begin
      TmpBaseFilter.Moniker:=GetMoniker(i-1);
      Result:=True;
      Break;
      end;
    finally
    free;
    end;
end;

procedure TVideoCore.SetAudioVideoProperty;
begin
try
SendVideoFilter.onReciveData:=VideoOnBuffer;
if not SetDefaultMonikerEx('Microsoft MPEG-4 Video Codec V3',VEncoder.BaseFilter)then
  SetDefaultMonikerEx('Microsoft MPEG-4  VKI  Codec V3',VEncoder.BaseFilter);
//寻找解码器。如果没有找到将不能正常播放
if not SetDefaultMoniker('{82CCD3E0-F71A-11D0-9FE5-00609778EA66}',VDecoder.BaseFilter) then
  SetDefaultMoniker('{04FE9017-F873-410E-871E-AB91661A4EF7}',VDecoder.BaseFilter);


except

end;
end;

procedure TVideoCore.VideoOnBuffer(Sender:Tobject;pData:Pbyte;dLength:Longint);
begin
if ReceiveFiltergraph.State=gsPlaying then
   ReceiveVideoFilter.PlaySample(pData,dLength);
end;

procedure TVideoCore.SampleOnBuffer(sender: TObject; SampleTime: Double; pBuffer: Pointer; BufferLen: longint);
begin
  try
  FVideoImage.Canvas.Lock;
  VideoSample.GetBitmap(FVideoImage.Picture.Bitmap,pBuffer,BufferLen);
  finally
  FVideoImage.Canvas.Unlock;
  end;
end;
//------------------------------------------------------------------------------
// 视频选择
//------------------------------------------------------------------------------
procedure TVideoCore.video_select(dev_list:tstrings);
var i:integer;
begin
if Fvideoisok then
 begin
 if VideoDevList.CountFilters > 0 then
 for i:=1 to  VideoDevList.CountFilters do
   dev_list.add(VideoDevList.Filters[i-1].FriendlyName);
 end;
end;

//------------------------------------------------------------------------------
// 显示视频属性
//------------------------------------------------------------------------------
procedure TVideoCore.videoseting(hwd:thandle);
begin
if Fvideoisok then
   begin
   VideoSource.BaseFilter.Moniker := videoDevList.GetMoniker(Fvideo_index);
   SendFiltergraph.Active := True;
   ShowFilterPropertyPage(hwd,VideoSource as IBaseFilter);
   end;
end;


procedure TVideoCore.GetMediaType(TmpStream:TStream);
begin
  TmpStream.Writebuffer(SendVideoFilter.MediaType,sizeof(TAMMediaType));
  TmpStream.WriteBuffer(SendVideoFilter.MediaType.pbFormat^,SendVideoFilter.MediaType.cbFormat);
end;

procedure TVideoCore.SetMediaType(TmpStream:TStream);
var
  mt:TAMMediaType;
  dlength:integer;
begin
  TmpStream.Seek(0,soFromBeginning);
  TmpStream.ReadBuffer(mt,sizeof(TAMMediaType));
  dlength:=TmpStream.Size-sizeof(TAMMediaType);
  mt.pbFormat:=CoTaskMemAlloc(dlength);
  TmpStream.ReadBuffer(mt.pbFormat^,dlength);
  ReceiveVideoFilter.SetupMediaType(mt);
end;


procedure TVideoCore.initvideosource;
var i,n:integer;
    PinList:TPinList;
    MediaTypes:TEnumMediaType;
    MediaType:TAMMediaType;
begin
try
PinList := TPinList.Create(VideoSource as IBaseFilter);
MediaTypes := TEnumMediaType.Create;
for n:=1 to pinlist.Count do
if pinlist.PinInfo[n-1].dir=PINDIR_OUTPUT then
   begin
   MediaTypes.Assign(pinlist.Items[n-1]);
   for i:=1 to MediaTypes.Count do
     begin
     MediaType:=MediaTypes.Items[i-1].AMMediaType^;
     if ((MediaType.cbFormat > 0) and assigned(MediaType.pbFormat)) then
     with PVIDEOINFOHEADER(MediaType.pbFormat)^.bmiHeader do
     if (biWidth=320)and(biHeight=240) then
         begin
         with (pinlist.Items[n-1] as IAMStreamConfig) do
            SetFormat(MediaType);
            break;
         end;
     end;
   break;
   end;
finally
freeandnil(MediaTypes);
freeandnil(PinList);
end;
end;
//------------------------------------------------------------------------------
// 开始视频
//------------------------------------------------------------------------------
procedure TVideoCore.mediaSendstart(TmpImg:TImage);
var
  sParams:WideString;
  TmpStream:TMemoryStream;
begin
  try
  TmpStream:=TMemoryStream.Create;
  if Fvideoisok then
    try
    FVideoImage:=TmpImg;
    SendFiltergraph.ClearGraph;
    SendFiltergraph.Active := false;
    VideoSource.BaseFilter.Moniker := VideoDevList.GetMoniker(Fvideo_index);
    SendFiltergraph.Active := true;
    //--------------------------------------------------------------------------
    initvideosource;
    //--------------------------------------------------------------------------
    with (SendFiltergraph as ICaptureGraphBuilder2) do
      RenderStream(@PIN_CATEGORY_CAPTURE ,nil,VideoSource as IBaseFilter,VEncoder as IBaseFilter,SendVideoFilter as IBaseFilter);

    SendFiltergraph.Play;

    GetMediaType(TmpStream);
    AddValueToNote(sParams,'sFormat',TmpStream);
    TmpStream.Clear;
    GetNoteFromValue(sParams,'sFormat',TmpStream);
    SetMediaType(TmpStream);


    ReceiveFiltergraph.ClearGraph;
    ReceiveFiltergraph.Active:=false;
    ReceiveFiltergraph.Active:=true;


    with (ReceiveFiltergraph as ICaptureGraphBuilder2) do
      RenderStream(nil,nil,ReceiveVideoFilter as IBaseFilter,VDecoder as IBaseFilter,VideoSample as IBaseFilter);


    ReceiveFiltergraph.Play;

    except

    end;
  finally
  freeandnil(TmpStream);
  end;
end;
//------------------------------------------------------------------------------
// 停止视频
//------------------------------------------------------------------------------
procedure TVideoCore.mediaSendstop();
begin
if Fvideoisok then
 begin
 SendFiltergraph.Stop;
 SendFiltergraph.Active := false;
 ReceiveFiltergraph.Stop;
 ReceiveFiltergraph.Active:=false;
 end;
end;


end.
