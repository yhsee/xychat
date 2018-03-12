unit ShareUnt;

interface

uses
  Windows, Messages, SysUtils, Classes, ComCtrls, StdCtrls,
  forms,Math, StructureUnt,RichEditCommUnt,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus, TntButtons, TntFileCtrl;

var
  logmemo,      //运行日志
  AutoReplymemo, //离线回复
  IPBoundList,

  QuickReplymemo,  //快捷回复
  charlist,        //字符贴图列表
  facelist         //表情贴图列表
  :TTntStringList;

//------------------------------------------------------------------------------
// 全局BOOL变量
//------------------------------------------------------------------------------
  file_supervention,                     //文件存在时续传
  frmAutoHide,                           //窗口自动隐藏
  Allow_Playwave,                        //允许声音提示
  newmsg_popup,                          //自动弹出
  winstart_run,                          //随windows启动
  starting_mini,                         //启动时最小化
  closetomin,                            //点关闭时最小化
  newpictext_ok,                         //图形文字


  //对话框
  allow_auto_status,                     //允许自动转换状态
  pressenter_send,                       //按回车发送消息
  
  //语音视频
  videoisok,                            // 视频设备OK
  micisok,                              // 录音设备OK
  waveisok,                             // 回放设备OK

  //主界面
  JustAVideoConnect,                    //语音视频只能允许有一个实例
  JustRemoteConnect,                    //远程协助只能允许有一个实例
  showonline,                           //只显示在线用户
  showupdownhint,                       //显示上下线提示

  ClientRun,
  allow_application_quit                 //用户退出

  :boolean;

//------------------------------------------------------------------------------
// 全局字符变量
//------------------------------------------------------------------------------
  MyComputerName,                      //本机电脑名称  
  MyComputerMac,                       //用户网卡MAC地址
  svrhost,                             // 服务器IP
  mylocalip,                           //本机内部IP
  LoginUserSign,                       //用户唯一标识
  LoginUser                           //当前用户
  :string;

  ClientMsg_WaveFile,                  //提示音
  SystemMsg_WaveFile,
  NewFirend_WaveFile,
  GroupMsg_WaveFile,
  DefaultUserPath,
  DefaultCustomImagePath,
  userdefpic,  
  revertmsg,                           //当前设定的自动回复语
  User_Directory,                     //用户路径
  Application_Path,                    //应用程序目录
  Application_Name,                    //应用程序名
  DefaultSaveDir,                       //文件发送默认路径.
  DefaultOpenDir                       //文件接收默认路径.
  :WideString;

//------------------------------------------------------------------------------
// 全局整型变量
//------------------------------------------------------------------------------
  mainfrm_left,
  mainfrm_top,

  video_index,                            //视频设备索引号
  audio_index,                            //音频输出设备索引号
  mic_index                             //音频输入设备索引号
  :Integer;

  status_outtime,                      //状态超时
  auto_status,                         //操时后的状态
  core_port,                           //基本通讯端口
  systemhot_key,                       //系统热键
  bosshot_key                             //老板键...
  :LongWord;

//------------------------------------------------------------------------------
// 全局 handle 用于消息传递
//------------------------------------------------------------------------------
  main_hwnd,
  search_hwnd:hwnd;

  DefaultFontFormat:TFontFormat;

  _CUR_STATE : DWord;
  //0 - Login 1 - Connecting 2 - User Frame
  _CUR_PAGE : DWord;

function WhichLanguage:boolean;
function locallanguage:string;
function statustostr(n:integer):string;

function GetIPhead(sTmpStr:String):String;
function checkip(sTmpStr:string):boolean;
function checkmac(sTmpStr:string):boolean;

procedure opencmd(sTmpStr:WideString;Const Bool:Boolean=false);

function selectpath(var path:WideString):boolean;
procedure FixDirectory(var sPath:WideString);
procedure ForceCreateDirectorys(sTmpStr:WideString);
function getfilesize(files:WideString):int64;

function FormatSize(iSize:Int64):WideString;overload;
function FormatSize(iSize:Int64;Bool:boolean):WideString;overload;

function GetShortFilename(filenames:WideString;iWidth:Integer):WideString;

procedure fixmsgtxt(var msg:WideString;dLength:Integer);

procedure SafeSleep(TimeSleep: LongWord);
procedure AddToIPBoundList(sTmpStr:String);

procedure RoundForm(fForm:TForm);
procedure FullScreenForm(fForm:TForm);


implementation

uses constunt,WinSock,shellapi,mmsystem,SimpleXmlUnt,macunt;

procedure RoundForm(fForm:TForm);
Var
  rgnRGN : HRGN;
begin
  rgnRGN := CreateRoundRectRgn(0, 0, fForm.Width, fForm.Height, 9, 9);
  SetWindowRgn(fForm.Handle, rgnRGN, True);
end;

procedure FullScreenForm(fForm:TForm);
Var
  rgnRGN : HRGN;
begin
  rgnRGN := CreateRoundRectRgn(0, 0, fForm.Width, fForm.Height, 0, 0);
  SetWindowRgn(fForm.Handle, rgnRGN, True);
end;

procedure SafeSleep(TimeSleep: LongWord);
var
  dwTime                                : LongWord;
  Msg                                   : TMsg;
begin
  dwTime := GetTickCount();

  while GetTickCount() - TimeSleep < dwTime do
  begin
    if PeekMessage(Msg, 0, 0, 0, PM_NOREMOVE) then
      Continue
    else
      Exit;
  end;
end;

function FormatSize(iSize:Int64;Bool:boolean):WideString;
var
  TmpStr:String;
begin
  TmpStr:=Format('%.dByte',[iSize]);
  if (iSize Div (1024*1024*1024))>0 then
     begin
     TmpStr:=Format('%.2fGB',[iSize / (1024*1024*1024)]);
     end else
  if (iSize Div (1024*1024))>0 then
     begin
     TmpStr:=Format('%.1fMB',[iSize / (1024*1024)]);
     end else
  if (iSize Div 1024)>0 then
     begin
     TmpStr:=Format('%.dKB',[iSize Div 1024]);
     end;
  if Bool then TmpStr:=ConCat('(',TmpStr,')');
  result:=TmpStr;
end;

function FormatSize(iSize:Int64):WideString;
begin
  result:=FormatSize(iSize,True);
end;

function GetShortFilename(filenames:WideString;iWidth:Integer):WideString;
var
  K:integer;
begin
  K:=iWidth Div 8;
  Result:=filenames;
  if length(filenames)>k then
     result:=ConCat(Copy(filenames,1,k-6),WideString('..'),Copy(filenames,length(filenames)-2,3));
end;

//------------------------------------------------------------------------------
// 中文断字处理
//------------------------------------------------------------------------------
procedure fixmsgtxt(var msg:WideString;dLength:Integer);
begin
  if length(msg)>dLength then msg:=copy(msg,1,dLength);
  if msg[length(msg)]=Widechar(10) then delete(msg,length(msg),1);
end;

//------------------------------------------------------------------------------
// 返回文件尺寸
//------------------------------------------------------------------------------
function getfilesize(files:WideString):int64;
begin
  Try
    with TTntFilestream.Create(files,fmopenread or fmShareDenyNone) do
     try
     Result:=size;
     finally
     free;
     end;
  Except
  Result:=0;
  end;
end;

procedure FixDirectory(var sPath:WideString);
begin
  if sPath[length(sPath)]<>'\' then
     sPath:=ConCat(sPath,'\');
end;

function selectpath(var path:WideString):boolean;
begin
result:=false;
if WideSelectDirectory('选择目录','',path) then
   begin
   if path[length(path)]<>'\' then path:=path+'\';
   result:=true;
   end;
end;

procedure ForceCreateDirectorys(sTmpStr:WideString);
begin
if not WideDirectoryExists(sTmpStr) then
   WideForceDirectories(sTmpStr);
end;
//------------------------------------------------------------------------------
// 运行指定的命令行
//------------------------------------------------------------------------------
procedure opencmd(sTmpStr:WideString;Const Bool:Boolean=false);
begin
  if not bool then Tnt_ShellExecuteW(GetDeskTopWindow,nil,pwidechar(sTmpStr),nil,nil,1) else
  Tnt_ShellExecuteW(GetDeskTopWindow,pwidechar(WideString('open')),pwidechar(WideString('Explorer.exe')),pwidechar(ConCat('/e,/select,',sTmpStr)),nil,1);
end;

//------------------------------------------------------------------------------
// 返回本地IP地址
//------------------------------------------------------------------------------
function Getmycomputer: String;
var
  sName: PChar;
  len: ^dword;
begin
  GetMem(sName, 255);
  New(Len); Len^ := 255;
  GetComputerName(sName, Len^);
  result := StrPas(sName);
  freemem(sName, 255);
  dispose(len);
end;

function GetIP(sName: string): string;
type
  TaPInAddr = array[0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  GInitData: TWSADATA;
begin
  WSAStartup($101, GInitData);
  Result := '';
  phe := GetHostByName(pchar(sName));
  pptr := PaPInAddr(Phe^.h_addr_list);
  result := StrPas(inet_ntoa(pptr^[0]^));
  WSACleanup;
end;

//------------------------------------------------------------------------------
// 验证IP地址合法性
//------------------------------------------------------------------------------
function CheckIP(sTmpStr:string):Boolean;
begin
  result:=inet_addr(PChar(sTmpStr))<>INADDR_NONE;
end;

function GetIPhead(sTmpStr:String):String;
var
  TmpList:TStringList;
begin
  try
  TmpList:=TStringList.Create;
  
  Result:='';
  TmpList.Delimiter:='.';
  TmpList.DelimitedText:=sTmpStr;
  if TmpList.Count>2 then
    Result:=ConCat(TmpList.Strings[0],'.',TmpList.Strings[1],'.',TmpList.Strings[2]);
  finally
  freeandnil(TmpList);
  end;
end;

procedure AddToIPBoundList(sTmpStr:String);
begin
  if checkip(sTmpStr) then
    begin
    sTmpStr:=GetIPhead(sTmpStr);
    if IPBoundList.IndexOf(sTmpStr)<0 then
      IPBoundList.Add(sTmpStr);
    end;
end;

function checkmac(sTmpStr:string):boolean;
var i:integer;
begin
  Result := False;
  sTmpStr := UpperCase(sTmpStr);
  if length(sTmpStr)<>17 then Exit;

  for i:=1 to 17 do
  if (i mod 3)=0 then
     begin
     if not(ord(sTmpStr[i]) in [45,58]) then exit;
     end else begin
     if not(ord(sTmpStr[i]) in [48..57,65..70]) then exit;
     end;
  Result:=True;
end;

//------------------------------------------------------------------------------
// 返回当前系统语言
//------------------------------------------------------------------------------
function WhichLanguage:boolean;
var
  ID:LangID;
begin
  ID:=GetSystemDefaultLangID;
  result:=ID=$0804;
end;

function locallanguage:string;
begin
  if WhichLanguage then
    result:='chs' else result:='cht';
end;

//------------------------------------------------------------------------------
// 用户状态
//------------------------------------------------------------------------------
function statustostr(n:integer):string;
begin
result:='下线';
case n of
  0:result:='在线';
  1:result:='离开';
  2:result:='隐身';
  3:result:='下线';
 end;
end;

//------------------------------------------------------------------------------
// 全局变量初始化
//------------------------------------------------------------------------------
initialization
randomize;
TimeSeparator:=':';
DateSeparator:='-';
ShortDateFormat:='yyyy-mm-dd';
ShortTimeFormat:='hh:mm:ss';
//------------------------------------------------------------------------------
core_port:=6810;
svrhost:='127.0.0.1';
auto_status:=1;
DefaultSaveDir:='c:\';
DefaultFontFormat:=InitFontFormat;
MyComputerName:=GetMyComputer;
myLocalIP:=GetIP(MyComputerName);
MyComputerMac:=GetLocatMACAddress(myLocalIP);
AutoReplymemo:=TTntStringlist.create;
QuickReplymemo:=TTntStringlist.create;
logmemo:=TTntStringlist.Create;
facelist:=TTntStringlist.create;
charlist:=TTntStringlist.create;
IPBoundList:=TTntStringList.Create;

finalization
freeandnil(AutoReplymemo);
freeandnil(QuickReplymemo);
freeandnil(IPBoundList);
logmemo.SaveToFile('./system.log'); 
freeandnil(logmemo);
freeandnil(facelist);
freeandnil(charlist);

end.
