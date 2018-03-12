unit DirectShowUnt;

interface

uses
  Windows, Messages,SysUtils,Classes,extctrls,Graphics,
  BaseClass,DSPack,directshow9,DSUtil,TntClasses,
  nsFilterUnt,activex;
  
type
  TCaptureStream=Procedure (mSample:TMemoryStream)of Object;
  TOnWriteLogEvent=procedure(Sender:TObject;sLog:WideString)of Object;
  TVideoDirectShow=class
      constructor Create;
      destructor  Destroy;override;
    private
      FVideoDevice:Boolean;
      FVideoUse:word;
      SendVideoFilter:TnsFilter;
      VideoSource,VEncoder:Tfilter;
      VideoDevList: TSysDevEnum;
      SendFiltergraph:tfiltergraph;
      FCaptureVideo:TCaptureStream;
      FOnWriteLog:TOnWriteLogEvent;
      FVideoStream:TMemoryStream;
      procedure InitVideoSourceFormat;
      function GetVideoUse:boolean;
      procedure WriteLog(sLog:WideString);
      procedure VideoOnBuffer(Sender:Tobject;pData:Pbyte;dLength:Longint);
    public
      procedure GetVideoMediaType(TmpStream:TStream);
      procedure Video_Select(dev_list:TTntstrings);
      procedure VideoSeting(hwd:thandle);
      procedure VideoStart(Const bPerview:Boolean=false);
      procedure VideoPerview;
      procedure VideoStop;
    published
      property CaptureVideo:TCaptureStream Read FCaptureVideo Write FCaptureVideo;
      property OnWriteLog:TOnWriteLogEvent Write FOnWriteLog;
      property JustVideoUse:boolean Read GetVideoUse;
    end;
    
implementation
uses math,shellapi;

function SetDefaultMoniker(sName:String;TmpBaseFilter:TBaseFilter):boolean;
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

{TVideoDirectShow}
//------------------------------------------------------------------------------
// 初始化采集设备
//------------------------------------------------------------------------------
constructor TVideoDirectShow.Create;
begin
  try
  FVideoStream:=TMemoryStream.Create;

  SendFiltergraph:=tfiltergraph.Create(nil);
  SendFiltergraph.Mode:=gmCapture;

  VideoSource:=Tfilter.Create(nil);
  VideoSource.FilterGraph:=SendFiltergraph;

  VEncoder:=Tfilter.Create(nil);
  VEncoder.FilterGraph:=SendFiltergraph;

  SendVideoFilter:=TnsFilter.Create(nil);
  SendVideoFilter.FilterGraph:=TnsFilters(SendFiltergraph);

  VideoDevList:= TSysDevEnum.Create(CLSID_VideoInputDeviceCategory);
  FVideoDevice:=VideoDevList.CountFilters> 0;
  SendVideoFilter.onReciveData:=VideoOnBuffer;

  if not SetDefaultMoniker('Microsoft MPEG-4 Video Codec V3',VEncoder.BaseFilter)then
  if not SetDefaultMoniker('Microsoft MPEG-4  VKI  Codec V3',VEncoder.BaseFilter) then
    begin
    FVideoDevice:=false;
    if MessageBox(0,pchar('没有找到视频所需的编码解码器，按确定进行安装！安装完成后需重新运行软件。'),
    pchar('提示'),MB_OKCANCEL or MB_ICONINFORMATION)=1 then
    shellexecute(GetDeskTopWindow,'Open',pchar(extractfilepath(ParamStr(0))+'MPEG4\install.bat'),nil,
                                         pchar(extractfilepath(ParamStr(0))+'MPEG4\'),0);
    end;

  except
  FVideoDevice:=false;
  end;
end;

//------------------------------------------------------------------------------
// 释放采集设备
//------------------------------------------------------------------------------
destructor TVideoDirectShow.Destroy;
begin
if assigned(SendFiltergraph) then
   begin
   SendFiltergraph.Stop;
   SendFiltergraph.Active := false;
   SendFiltergraph.ClearGraph;
   freeandnil(SendFiltergraph);
   end;
if assigned(SendVideoFilter) then
   freeandnil(SendVideoFilter);
if assigned(VideoSource) then
   freeandnil(VideoSource);
if assigned(VEncoder) then
   freeandnil(VEncoder);
if assigned(FVideoStream) then
  freeandnil(FVideoStream);
if assigned(VideoDevList) then
   freeandnil(VideoDevList);
end;

function TVideoDirectShow.GetVideoUse:boolean;
begin
  result:=FVideoUse>0;
end;

procedure TVideoDirectShow.WriteLog(sLog:WideString);
begin
  if assigned(FOnWriteLog)then FOnWriteLog(nil,sLog);
end;

procedure TVideoDirectShow.VideoOnBuffer(Sender:Tobject;pData:Pbyte;dLength:Longint);
begin
  FVideoStream.SetSize(0);
  FVideoStream.WriteBuffer(pData^,dLength);
  if assigned(FCaptureVideo) then FCaptureVideo(FVideoStream);
end;

//------------------------------------------------------------------------------
// 视频选择
//------------------------------------------------------------------------------
procedure TVideoDirectShow.video_select(dev_list:TTntstrings);
var
  i:integer;
begin
  if FVideoDevice then
  for i:=1 to  VideoDevList.CountFilters do
    begin
    if (dev_list.IndexOf(VideoDevList.Filters[i-1].FriendlyName)<0) then
    dev_list.add(VideoDevList.Filters[i-1].FriendlyName);
    end;
end;

//------------------------------------------------------------------------------
// 显示视频属性
//------------------------------------------------------------------------------
procedure TVideoDirectShow.videoseting(hwd:thandle);
begin
  if FVideoDevice then
    begin
    VideoSource.BaseFilter.Moniker := videoDevList.GetMoniker(0);
    SendFiltergraph.Active := True;
    ShowFilterPropertyPage(hwd,VideoSource as IBaseFilter);
    end;
end;


procedure TVideoDirectShow.GetVideoMediaType(TmpStream:TStream);
begin
  if FVideoDevice then
    begin
    TmpStream.Writebuffer(SendVideoFilter.MediaType,sizeof(TAMMediaType));
    TmpStream.WriteBuffer(SendVideoFilter.MediaType.pbFormat^,SendVideoFilter.MediaType.cbFormat);
    end;
end;

procedure TVideoDirectShow.InitVideoSourceFormat;
var
  i,n:integer;
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
procedure TVideoDirectShow.VideoStart(Const bPerview:Boolean=false);
begin
  if FVideoDevice then
    begin
    inc(FVideoUse);
    if FVideoUse=1 then
      try
      SendFiltergraph.Active := false;
      SendFiltergraph.ClearGraph;
      VideoSource.BaseFilter.Moniker := VideoDevList.GetMoniker(0);
      SendFiltergraph.Active := true;
      //--------------------------------------------------------------------------
      InitVideoSourceFormat;
      //--------------------------------------------------------------------------
      with (SendFiltergraph as ICaptureGraphBuilder2) do //PIN_CATEGORY_PREVIEW
        RenderStream(@PIN_CATEGORY_CAPTURE ,nil,VideoSource as IBaseFilter,VEncoder as IBaseFilter,SendVideoFilter as IBaseFilter);
      SendFiltergraph.Play;
      except
      WriteLog('Video Is Fail');
      end;
    end;
end;

procedure TVideoDirectShow.VideoPerview;
begin
  VideoStart(True);
end;
//------------------------------------------------------------------------------
// 停止视频
//------------------------------------------------------------------------------
procedure TVideoDirectShow.VideoStop;
begin
  if FVideoDevice then
    begin
    dec(FVideoUse);
    if FVideoUse=0 then
      begin
      SendFiltergraph.Stop;
      SendFiltergraph.Active := false;
      SendFiltergraph.ClearGraph;
      end;
    end;
end;

initialization
  CoInitialize(nil);
finalization
  CoUninitialize;

end.
