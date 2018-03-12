unit AudioUnt;

interface

uses
  Windows, Messages,SysUtils,Classes,extctrls,
  BaseClass,DSPack,directshow9,DSUtil,dialogs,
  nrFilterUnt,nsFilterUnt,activex;
  
type
  TAudioCore=class
      constructor Create;
      destructor  Destroy;override;
    private
      SendAudioFilter:TnsFilter;
      ReceiveAudioFilter:TnrFilter;
      AudioSample:TSampleGrabber;
      VideoSource:Tfilter;

      ReceiveFiltergraph,
      SendFiltergraph:tfiltergraph;
      procedure InitDirectShow;
      procedure finalDirectShow;
      procedure SetAudioVideoProperty;
      procedure initvideosource;
      function GeTAudioCoreTypestr:string;
      function SetupMediaType(FMediaTypeStr:String):boolean;
      procedure VideoOnBuffer(Sender:Tobject;pData:Pbyte;dLength:Longint);
    public
      procedure mediaSendstart(VideoWindow:TVideoWindow);
      procedure mediaSendstop;
    end;
    
implementation

//------------------------------------------------------------------------------
// 初始化 DirectShow  视频设备
//------------------------------------------------------------------------------
constructor TAudioCore.Create;
begin
InitDirectShow;
SetAudioVideoProperty;
end;

//------------------------------------------------------------------------------
// 释放 DirectShow  视频设备
//------------------------------------------------------------------------------
destructor TAudioCore.Destroy;
begin
  SendFiltergraph.Stop;
  SendFiltergraph.Active := false;
  ReceiveFiltergraph.Stop;
  ReceiveFiltergraph.Active:=false;
  finalDirectShow;
  inherited Destroy;
end;

procedure TAudioCore.InitDirectShow;
begin
try
SendFiltergraph:=tfiltergraph.Create(nil);
SendFiltergraph.Mode:=gmCapture;

ReceiveFiltergraph:=tfiltergraph.Create(nil);
ReceiveFiltergraph.Mode:=gmCapture;


AudioSample:=TSampleGrabber.Create(nil);
AudioSample.FilterGraph:=SendFiltergraph;


VideoSource:=Tfilter.Create(nil);
VideoSource.FilterGraph:=SendFiltergraph;

SendAudioFilter:=TnsFilter.Create(nil);
SendAudioFilter.FilterGraph:=TnsFilters(SendFiltergraph);

ReceiveAudioFilter:=TnrFilter.Create(nil);
ReceiveAudioFilter.FilterGraph:=TnrFilters(ReceiveFiltergraph);

except
audio_index:=-1;
end;

end;

procedure TAudioCore.finalDirectShow;
begin
  try
    if assigned(SendFiltergraph)          then freeandnil(SendFiltergraph);
    if assigned(ReceiveFiltergraph)       then freeandnil(ReceiveFiltergraph);
    if assigned(SendAudioFilter)          then freeandnil(SendAudioFilter);
    if assigned(ReceiveAudioFilter)       then freeandnil(ReceiveAudioFilter);
    if assigned(VideoSource)              then freeandnil(VideoSource);
    if assigned(AudioSample)               then freeandnil(AudioSample);
  except

  end;
end;

procedure TAudioCore.SetAudioVideoProperty;
begin
SendAudioFilter.onReciveData:=VideoOnBuffer;
end;

procedure TAudioCore.VideoOnBuffer(Sender:Tobject;pData:Pbyte;dLength:Longint);
var tmpstream:tmemorystream;
begin
try
tmpstream:=tmemorystream.Create;
tmpstream.WriteBuffer(pData^,dLength);
tmpstream.Seek(0,0);
if ReceiveFiltergraph.State=gsPlaying then
   ReceiveAudioFilter.PlaySample(tmpstream.Memory,tmpstream.Size);
finally
freeandnil(tmpstream);
end;
end;


function TAudioCore.GeTAudioCoreTypestr:string;
var TmpStr:string;
begin
if videoisok then
with tmemorystream.create do
  try
  writebuffer(SendAudioFilter.MediaType,sizeof(TAMMediaType));
  WriteBuffer(SendAudioFilter.MediaType.pbFormat^,SendAudioFilter.MediaType.cbFormat);
  Seek(0,soFromBeginning);
  setlength(TmpStr,Size);
  readbuffer(TmpStr[1],Size);
  finally
  free;
  end;
result:=TmpStr;
end;

function TAudioCore.SetupMediaType(FMediaTypeStr:String):boolean;
var mt:TAMMediaType;
    dlength:integer;
    tmpstream:tmemorystream;
begin
try
result:=False;
if length(FMediaTypeStr)>0 then
  try
  FreeMediaType(@mt);
  tmpstream:=tmemorystream.Create;
  tmpstream.WriteBuffer(FMediaTypeStr[1],length(FMediaTypeStr));
  tmpstream.Seek(0,soFromBeginning);
  tmpstream.ReadBuffer(mt,sizeof(TAMMediaType));
  dlength:=length(FMediaTypeStr)-sizeof(TAMMediaType);
  mt.pbFormat:=CoTaskMemAlloc(dlength);
  tmpstream.ReadBuffer(mt.pbFormat^,dlength);
  ReceiveAudioFilter.SetupMediaType(mt);
  result:=true;
  finally
  freeandnil(tmpstream);
  end;
except
result:=false;
end;
end;


procedure TAudioCore.initvideosource;
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
procedure TAudioCore.mediaSendstart(VideoWindow:TVideoWindow);
begin
if videoisok then
  try
  SendFiltergraph.ClearGraph;
  SendFiltergraph.Active := false;
  VideoWindow.FilterGraph:=ReceiveFiltergraph;
//  VideoSource.BaseFilter.Moniker := VideoDevList.GetMoniker(video_index);
  SendFiltergraph.Active := true;
  //--------------------------------------------------------------------------
  initvideosource;
  //--------------------------------------------------------------------------
  with (SendFiltergraph as ICaptureGraphBuilder2) do
      begin
      RenderStream(@PIN_CATEGORY_CAPTURE ,nil,VideoSource as IBaseFilter,nil,AudioSample as IBaseFilter);
      RenderStream(nil,nil,AudioSample as IBaseFilter,nil,SendAudioFilter as IBaseFilter);
      end;

  SendFiltergraph.Play;

  if not SetupMediaType(GeTAudioCoreTypestr) then showmessage('MediaType Error');

  ReceiveFiltergraph.ClearGraph;
  ReceiveFiltergraph.Active:=false;
  VideoWindow.FilterGraph:=ReceiveFiltergraph;
  ReceiveFiltergraph.Active:=true;


  with (ReceiveFiltergraph as ICaptureGraphBuilder2) do
    RenderStream(nil,nil,ReceiveAudioFilter as IBaseFilter,nil,VideoWindow as IBaseFilter);


  ReceiveFiltergraph.Play;

  except
  
  end;
end;
//------------------------------------------------------------------------------
// 停止视频
//------------------------------------------------------------------------------
procedure TAudioCore.mediaSendstop();
begin
if videoisok then
 begin
 SendFiltergraph.Stop;
 SendFiltergraph.Active := false;
 ReceiveFiltergraph.Stop;
 ReceiveFiltergraph.Active:=false;
 end;
end;


end.
