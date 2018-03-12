unit reginfor;

interface

uses

  Windows,inifiles,graphics,TntRegistry,TntSysUtils;

  procedure ReadMyconfig;
  procedure WriteMyconfig;
  procedure ReadXml;
  procedure WriteXml;
  procedure Reg_autorun;

implementation
uses ShareUnt,RichEditCommUnt,SimpleXmlUnt;

//------------------------------------------------------------------------------
// 读INI配置文件
//------------------------------------------------------------------------------
procedure ReadXml;
var
  sXmlSourec,
  sFileName : WideString;
begin
  revertmsg:='你好，我现在有事不在，一会儿再和你联系';
  AutoReplymemo.add('工作中，请勿打扰');
  AutoReplymemo.add('我去吃饭了，一会儿再联系');
  AutoReplymemo.add('我在吃饭，你别吵，我多给你回一条信息就少抢一块肉。');
  AutoReplymemo.Add(revertmsg);

  QuickReplymemo.Add('哦');
  QuickReplymemo.Add('好了,好了,我知道了');
  QuickReplymemo.Add('是吗?');
  QuickReplymemo.Add('不会是真的吧?');

  sFilename:= ConCat(Application_Path,'UserData\basepic.txt');
  if WideFileexists(sFilename) then facelist.LoadFromFile(sFilename);
  sFilename:= ConCat(Application_Path,'UserData\charpic.txt');
  if WideFileexists(sFilename) then charlist.LoadFromFile(sFilename);
  sFilename:= ConCat(Application_Path,'UserData\message.txt');
  if WideFileexists(sFilename) then AutoReplymemo.LoadFromFile(sFilename);
  sFilename:= ConCat(Application_Path,'UserData\quickmsg.txt');
  if WideFileexists(sFilename) then QuickReplymemo.LoadFromFile(sFilename);
  sFilename:= ConCat(Application_Path,'UserData\IPBound.txt');
  if WideFileexists(sFilename) then IPBoundList.LoadFromFile(sFilename);

  sFileName:=WideChangefileext(application_name,'.xml');
  if LoadFileToXml(sFileName,sXmlSourec) then
    begin
    core_port:=GetNoteFromValue(sXmlSourec,'core_port');
    starting_mini:=GetNoteFromValue(sXmlSourec,'runmini');
    mainfrm_left:=GetNoteFromValue(sXmlSourec,'mainfrm_left');
    mainfrm_top:=GetNoteFromValue(sXmlSourec,'mainfrm_top');
    end;
end;

//------------------------------------------------------------------------------
// 写INI配置文件
//------------------------------------------------------------------------------
procedure WriteXml;
var
  sXmlSourec,
  sFileName:WideString;
begin
  logmemo.SaveToFile(ConCat(Application_Path,'UserData\log.txt'));
  AutoReplymemo.SaveToFile(ConCat(Application_Path,'UserData\message.txt'));
  QuickReplymemo.SaveToFile(ConCat(Application_Path,'UserData\quickmsg.txt'));
  IPBoundList.SaveToFile(ConCat(Application_Path,'UserData\IPBound.txt'));

  sFileName:=WideChangefileext(application_name,'.xml');
  if WideFileExists(sFileName) then WideDeleteFile(sFileName);
  
  AddValueToNote(sXmlSourec,'core_port',core_port);
  AddValueToNote(sXmlSourec,'runmini',starting_mini);
  AddValueToNote(sXmlSourec,'mainfrm_left',mainfrm_left);
  AddValueToNote(sXmlSourec,'mainfrm_top',mainfrm_top);

  SaveXmlToFile(sFileName,sXmlSourec);
end;


procedure ReadMyconfig;
var
  sXmlSourec,
  sFileName:WideString;
begin
  sFileName:=ConCat(Application_Path,'UserData\',loginuser,'\userconfig.xml');
  if LoadFileToXml(sFileName,sXmlSourec) then
    try
    //------------------------------------------------------------------------------
    newmsg_popup:=GetNoteFromValue(sXmlSourec,'CustomInfor','newmsgpopup');
    pressenter_send:=GetNoteFromValue(sXmlSourec,'CustomInfor','pressentersend');
    Allow_Playwave:=GetNoteFromValue(sXmlSourec,'CustomInfor','AllowPlaywave');
    file_supervention:=GetNoteFromValue(sXmlSourec,'CustomInfor','filevention');
    closetomin:=GetNoteFromValue(sXmlSourec,'CustomInfor','closetomin');
    newpictext_ok:=GetNoteFromValue(sXmlSourec,'CustomInfor','newpictext');
    auto_status:=GetNoteFromValue(sXmlSourec,'CustomInfor','auto_status');
    status_outtime:=GetNoteFromValue(sXmlSourec,'CustomInfor','status_outtime');
    allow_auto_status:=GetNoteFromValue(sXmlSourec,'CustomInfor','allow_auto_status');
    showonline:=GetNoteFromValue(sXmlSourec,'CustomInfor','showonline');
    showupdownhint:=GetNoteFromValue(sXmlSourec,'CustomInfor','showupdownhint');
    //------------------------------------------------------------------------------    
    systemhot_key:=GetNoteFromValue(sXmlSourec,'HotKeyInfor','systemkey');
    bosshot_key:=GetNoteFromValue(sXmlSourec,'HotKeyInfor','bosskey');
    video_index:=GetNoteFromValue(sXmlSourec,'AudioVideoInfor','video_index');
    audio_index:=GetNoteFromValue(sXmlSourec,'AudioVideoInfor','audio_index');
    mic_index:=GetNoteFromValue(sXmlSourec,'AudioVideoInfor','mic_index');
    //------------------------------------------------------------------------------
    revertmsg:=GetNoteFromValue(sXmlSourec,'revertmsg');
    ClientMsg_WaveFile:=GetNoteFromValue(sXmlSourec,'ClientMsgWave');
    SystemMsg_WaveFile:=GetNoteFromValue(sXmlSourec,'SystemMsgWave');
    NewFirend_WaveFile:=GetNoteFromValue(sXmlSourec,'NewFirendWave');
    GroupMsg_WaveFile:=GetNoteFromValue(sXmlSourec,'GroupMsgWave');
    //------------------------------------------------------------------------------
    DefaultSaveDir:=GetNoteFromValue(sXmlSourec,'DefaultSaveDir');
    DefaultOpenDir:=GetNoteFromValue(sXmlSourec,'DefaultOpenDir');
    //------------------------------------------------------------------------------
    DefaultFontFormat.FontName:=GetNoteFromValue(sXmlSourec,'fontInfor','fontname');
    DefaultFontFormat.FontSize:=GetNoteFromValue(sXmlSourec,'fontInfor','fontsize');
    DefaultFontFormat.FontColor:=GetNoteFromValue(sXmlSourec,'fontInfor','fontcolor');
    DefaultFontFormat.FontStyle:=GetNoteFromValue(sXmlSourec,'fontInfor','fontstyle');
    except
    
    end;
end;

procedure WriteMyconfig;
var
  sXmlSourec,
  sFileName:WideString;
begin
  sFileName:=ConCat(Application_Path,'UserData\',loginuser,'\userconfig.xml');
  if WideFileExists(sFileName) then WideDeleteFile(sFileName);

  AddValueToNote(sXmlSourec,'CustomInfor','showonline',showonline);
  AddValueToNote(sXmlSourec,'CustomInfor','showupdownhint',showupdownhint);
  AddValueToNote(sXmlSourec,'CustomInfor','AllowPlaywave',Allow_Playwave);
  AddValueToNote(sXmlSourec,'CustomInfor','newmsgpopup',newmsg_popup);
  AddValueToNote(sXmlSourec,'CustomInfor','pressentersend',pressenter_send);
  AddValueToNote(sXmlSourec,'CustomInfor','closetomin',closetomin);
  AddValueToNote(sXmlSourec,'CustomInfor','filevention',file_supervention);
  AddValueToNote(sXmlSourec,'CustomInfor','newpictext',newpictext_ok);
  AddValueToNote(sXmlSourec,'CustomInfor','allow_auto_status',allow_auto_status);
  AddValueToNote(sXmlSourec,'CustomInfor','auto_status',auto_status);
  AddValueToNote(sXmlSourec,'CustomInfor','status_outtime',status_outtime);
 //------------------------------------------------------------------------------
  AddValueToNote(sXmlSourec,'HotKeyInfor','systemkey',systemhot_key);
  AddValueToNote(sXmlSourec,'HotKeyInfor','bosskey',bosshot_key);
  AddValueToNote(sXmlSourec,'AudioVideoInfor','video_index',video_index);
  AddValueToNote(sXmlSourec,'AudioVideoInfor','audio_index',audio_index);
  AddValueToNote(sXmlSourec,'AudioVideoInfor','mic_index',mic_index);
 //------------------------------------------------------------------------------
  AddValueToNote(sXmlSourec,'ClientMsgWave',ClientMsg_WaveFile);
  AddValueToNote(sXmlSourec,'SystemMsgWave',SystemMsg_WaveFile);
  AddValueToNote(sXmlSourec,'NewFirendWave',NewFirend_WaveFile);
  AddValueToNote(sXmlSourec,'GroupMsgWave',GroupMsg_WaveFile);
 //------------------------------------------------------------------------------
  AddValueToNote(sXmlSourec,'revertmsg',revertmsg);
  AddValueToNote(sXmlSourec,'DefaultOpenDir',DefaultOpenDir);
  AddValueToNote(sXmlSourec,'DefaultSaveDir',DefaultSaveDir);
 //------------------------------------------------------------------------------
  AddValueToNote(sXmlSourec,'fontInfor','fontname',DefaultFontFormat.FontName);
  AddValueToNote(sXmlSourec,'fontInfor','fontsize',DefaultFontFormat.FontSize);
  AddValueToNote(sXmlSourec,'fontInfor','fontcolor',DefaultFontFormat.FontColor);
  AddValueToNote(sXmlSourec,'fontInfor','fontstyle',DefaultFontFormat.FontStyle);
  
  SaveXmlToFile(sFileName,sXmlSourec);
end;

//------------------------------------------------------------------------------
// 将自动运行写入 windows 注册表
//------------------------------------------------------------------------------
procedure Reg_autorun;
begin
  with TTntRegistry.Create do
    try
    RootKey:=hkey_local_machine;
    openkey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run',true);
    if ValueExists('Mushroom') then DeleteValue('Mushroom');
    if winstart_run then WriteString('Mushroom',application_name);
    finally
    CloseKey;
    free;
    end;
end;



end.
