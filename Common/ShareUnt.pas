unit ShareUnt;

interface

uses
  Windows, Messages, SysUtils, Classes, ComCtrls, StdCtrls,
  forms,Math, StructureUnt,RichEditCommUnt,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus, TntButtons, TntFileCtrl;

var
  logmemo,      //������־
  AutoReplymemo, //���߻ظ�
  IPBoundList,

  QuickReplymemo,  //��ݻظ�
  charlist,        //�ַ���ͼ�б�
  facelist         //������ͼ�б�
  :TTntStringList;

//------------------------------------------------------------------------------
// ȫ��BOOL����
//------------------------------------------------------------------------------
  file_supervention,                     //�ļ�����ʱ����
  frmAutoHide,                           //�����Զ�����
  Allow_Playwave,                        //����������ʾ
  newmsg_popup,                          //�Զ�����
  winstart_run,                          //��windows����
  starting_mini,                         //����ʱ��С��
  closetomin,                            //��ر�ʱ��С��
  newpictext_ok,                         //ͼ������


  //�Ի���
  allow_auto_status,                     //�����Զ�ת��״̬
  pressenter_send,                       //���س�������Ϣ
  
  //������Ƶ
  videoisok,                            // ��Ƶ�豸OK
  micisok,                              // ¼���豸OK
  waveisok,                             // �ط��豸OK

  //������
  JustAVideoConnect,                    //������Ƶֻ��������һ��ʵ��
  JustRemoteConnect,                    //Զ��Э��ֻ��������һ��ʵ��
  showonline,                           //ֻ��ʾ�����û�
  showupdownhint,                       //��ʾ��������ʾ

  ClientRun,
  allow_application_quit                 //�û��˳�

  :boolean;

//------------------------------------------------------------------------------
// ȫ���ַ�����
//------------------------------------------------------------------------------
  MyComputerName,                      //������������  
  MyComputerMac,                       //�û�����MAC��ַ
  svrhost,                             // ������IP
  mylocalip,                           //�����ڲ�IP
  LoginUserSign,                       //�û�Ψһ��ʶ
  LoginUser                           //��ǰ�û�
  :string;

  ClientMsg_WaveFile,                  //��ʾ��
  SystemMsg_WaveFile,
  NewFirend_WaveFile,
  GroupMsg_WaveFile,
  DefaultUserPath,
  DefaultCustomImagePath,
  userdefpic,  
  revertmsg,                           //��ǰ�趨���Զ��ظ���
  User_Directory,                     //�û�·��
  Application_Path,                    //Ӧ�ó���Ŀ¼
  Application_Name,                    //Ӧ�ó�����
  DefaultSaveDir,                       //�ļ�����Ĭ��·��.
  DefaultOpenDir                       //�ļ�����Ĭ��·��.
  :WideString;

//------------------------------------------------------------------------------
// ȫ�����ͱ���
//------------------------------------------------------------------------------
  mainfrm_left,
  mainfrm_top,

  video_index,                            //��Ƶ�豸������
  audio_index,                            //��Ƶ����豸������
  mic_index                             //��Ƶ�����豸������
  :Integer;

  status_outtime,                      //״̬��ʱ
  auto_status,                         //��ʱ���״̬
  core_port,                           //����ͨѶ�˿�
  systemhot_key,                       //ϵͳ�ȼ�
  bosshot_key                             //�ϰ��...
  :LongWord;

//------------------------------------------------------------------------------
// ȫ�� handle ������Ϣ����
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
// ���Ķ��ִ���
//------------------------------------------------------------------------------
procedure fixmsgtxt(var msg:WideString;dLength:Integer);
begin
  if length(msg)>dLength then msg:=copy(msg,1,dLength);
  if msg[length(msg)]=Widechar(10) then delete(msg,length(msg),1);
end;

//------------------------------------------------------------------------------
// �����ļ��ߴ�
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
if WideSelectDirectory('ѡ��Ŀ¼','',path) then
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
// ����ָ����������
//------------------------------------------------------------------------------
procedure opencmd(sTmpStr:WideString;Const Bool:Boolean=false);
begin
  if not bool then Tnt_ShellExecuteW(GetDeskTopWindow,nil,pwidechar(sTmpStr),nil,nil,1) else
  Tnt_ShellExecuteW(GetDeskTopWindow,pwidechar(WideString('open')),pwidechar(WideString('Explorer.exe')),pwidechar(ConCat('/e,/select,',sTmpStr)),nil,1);
end;

//------------------------------------------------------------------------------
// ���ر���IP��ַ
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
// ��֤IP��ַ�Ϸ���
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
// ���ص�ǰϵͳ����
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
// �û�״̬
//------------------------------------------------------------------------------
function statustostr(n:integer):string;
begin
result:='����';
case n of
  0:result:='����';
  1:result:='�뿪';
  2:result:='����';
  3:result:='����';
 end;
end;

//------------------------------------------------------------------------------
// ȫ�ֱ�����ʼ��
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
