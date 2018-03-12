unit userunt;

interface

uses
  Windows, SysUtils,Classes,structureunt,
  TntClasses,TntSysUtils;

type
  Tuser=class
     constructor Create;
     destructor  Destroy;override;
   private
     FRecNo:Integer;
     FUserList:TThreadList;
   public
     procedure clearuserlist;
     procedure savetofile;

     procedure First;
     procedure Last;
     procedure Next;
     procedure Prior;
     function Eof:Boolean;
     function Bof:Boolean;
     function GetCurUserInfo(var TmpInfor:Tfirendinfo):Boolean;
     function Find(UserSign:String):Boolean; overload;
     function Find(UserSign:String;var TmpInfor:PFirendinfo):Boolean; overload;
     function Find(UserSign:String;var TmpInfor:TFirendinfo):Boolean; overload;
     procedure AddUser(UserSign:String);
     procedure Update(TmpInfor:TFirendinfo);
     procedure deluser(UserSign:String);

     procedure loadfromfile;
     procedure DelGroup(sGroup:WideString);
     procedure ModifyGroup(OldGroup,NewGroup:WideString);
   end;

var
  User:TUser;

implementation

uses ConstUnt,ShareUnt,SimpleXmlUnt,md5unt,TntWideStrUtils;

procedure Tuser.First;
begin
  FRecNo:=1;
end;

procedure Tuser.Last;                                     
begin
  try
  with FUserList.LockList do
    FRecNo:=Count;
  finally
  FUserList.UnlockList;
  end;
end;

procedure Tuser.Next;
begin
  Inc(FRecNo);
end;

procedure Tuser.Prior;
begin
  Dec(FRecNo);
end;

function Tuser.Eof:Boolean;
begin
  try
  with FUserList.LockList do
    Result:=FRecNo>Count;
  finally
  FUserList.UnlockList;
  end;
end;

function Tuser.Bof:Boolean;
begin
  Result:=FRecNo<1;
end;

function TUser.GetCurUserInfo(var TmpInfor:Tfirendinfo):Boolean;
begin
  try
  Result:=False;
  with FUserList.LockList do
    begin
    if (FRecNo>0)and (FRecNo<=Count) then
      begin
      TmpInfor:=Pfirendinfo(items[FRecNo-1])^;
      Result:=True;
      end;
    end;
  finally
  FUserList.UnlockList;
  end;
end;

function TUser.Find(UserSign:String):Boolean;
var
  P:PFirendinfo;
begin
  Result:=Find(UserSign,P);
end;

function TUser.Find(UserSign:String;var TmpInfor:PFirendinfo):Boolean;
var
  i:integer;
begin
  try
  Result:=False;
  with FUserList.LockList do
  for i:=count downto 1 do
  if CompareText(Pfirendinfo(items[i-1])^.UserSign,UserSign)=0 then
    begin
    TmpInfor:=Pfirendinfo(items[i-1]);
    Result:=True;
    break;
    end;
  finally
  FUserList.UnlockList;
  end;
end;

function TUser.Find(UserSign:String;var TmpInfor:TFirendinfo):Boolean;
var
  P:PFirendinfo;
begin
  Result:=Find(UserSign,P);
  if Result then TmpInfor:=P^;
end;

procedure Tuser.Update(TmpInfor:TFirendinfo);
var
  P:PFirendinfo;
begin
  if Find(TmpInfor.UserSign,P) then
    CopyMemory(P,@TmpInfor,SizeOf(TFirendinfo));
end;

procedure Tuser.deluser(UserSign:String);
var
  P:Pfirendinfo;
begin
  if Find(UserSign,P) then
    FUserList.Remove(P);
end;

procedure Tuser.AddUser(UserSign:String);
var
  TmpInfo:Pfirendinfo;
begin
  if not Find(UserSign) then
    begin
    New(TmpInfo);
    FillMemory(TmpInfo,sizeof(Tfirendinfo),0);
    TmpInfo^.UserSign:=UserSign;
    TmpInfo^.chatdlg:=nil;    
    TmpInfo^.status:=3;
    FUserList.Add(TmpInfo);
    end;
end;

//------------------------------------------------------------------------------
// 修改本地分组
//------------------------------------------------------------------------------
procedure Tuser.ModifyGroup(OldGroup,NewGroup:WideString);
var
  i:integer;
begin
  try
  with FUserList.LockList do
  for i:=count downto 1 do
  if WideCompareText(Pfirendinfo(items[i-1])^.GName,OldGroup)=0 then
    WStrPCopy(Pfirendinfo(items[i-1])^.GName,NewGroup);
  finally
  FUserList.UnlockList;
  end;
end;

//------------------------------------------------------------------------------
// 删除本地分组
//------------------------------------------------------------------------------
procedure Tuser.DelGroup(sGroup:WideString);
begin
  ModifyGroup(sGroup,SysFirendlist);
end;

//------------------------------------------------------------------------------
// 从文件装入
//------------------------------------------------------------------------------
procedure Tuser.loadfromfile;
var TmpStream:TTntFileStream;
    sFileName:WideString;
    TmpInfo:Pfirendinfo;
    datfile:Tdatfile;
begin
sFileName:=ConCat(Application_Path,'UserData\',loginuser,'\UserDB.dat');
if WideFileexists(sFileName) then
  try
  TmpStream:=TTntFileStream.Create(sFileName,fmOpenReadWrite);
  TmpStream.Seek(0,soFromBeginning);
  FillChar(datfile,sizeof(Tdatfile),#0);
  TmpStream.ReadBuffer(datfile,sizeof(Tdatfile));//读文件头
  if (CompareText(datfile.DatHeader,DatFile_Header)=0)and
     (datfile.DatType=DatType_UserList) and
     (datfile.Version=DatVersion) then
    begin
    //--------------------------------------------------------------------------
    //用户自己的信息更新
    //--------------------------------------------------------------------------
    New(TmpInfo);
    FillMemory(TmpInfo,sizeof(Tfirendinfo),0);
    TmpStream.ReadBuffer(TmpInfo^,sizeof(Tfirendinfo));
    LoginUserSign:=md5encode(ConCat(loginuser,'@',MyComputerMac));
    TmpInfo^.UserSign:=LoginUserSign;
    TmpInfo^.lanip:=mylocalip;
    TmpInfo^.Status:=0;
    TmpInfo^.chatdlg:=nil;
    TmpInfo^.macstr:=MyComputerMac;
    FUserList.Add(TmpInfo);
    //--------------------------------------------------------------------------
    while TmpStream.Position<TmpStream.Size do
      begin
      New(TmpInfo);
      FillMemory(TmpInfo,sizeof(Tfirendinfo),0);
      TmpStream.ReadBuffer(TmpInfo^,sizeof(Tfirendinfo));
      TmpInfo^.chatdlg:=nil;
      TmpInfo^.status:=3;
      FUserList.Add(TmpInfo);
      end;
    end;
  finally
  freeandnil(TmpStream);
  end;
end;

//------------------------------------------------------------------------------
// 保存列表
//------------------------------------------------------------------------------
procedure Tuser.savetofile;
var TmpStream:TTntFileStream;
    sFileName:WideString;
    datfile:Tdatfile;
    i:integer;
begin
sFileName:=ConCat(Application_Path,'UserData\',loginuser,'\UserDB.dat');
if Widefileexists(sFileName) then WideDeletefile(sFileName);
  try
  TmpStream:=TTntFileStream.Create(sFilename,fmCreate or fmOpenReadWrite);

  FillChar(datfile,sizeof(Tdatfile),#0);
  datfile.DatHeader:=DatFile_Header;
  datfile.DatType:=DatType_UserList;
  datfile.Version:=DatVersion;

  TmpStream.WriteBuffer(datfile,sizeof(Tdatfile));//写入文件头
    try
    with FUserList.LockList do
    for i:=1 to Count do
       TmpStream.WriteBuffer(Pfirendinfo(items[i-1])^,sizeof(Tfirendinfo));
    finally
    FUserList.UnlockList;
    end;
     
  finally
  freeandnil(TmpStream);
  end;
end;

//------------------------------------------------------------------------------
// 创建 iconex
//------------------------------------------------------------------------------
constructor Tuser.Create;
begin
  inherited Create;
  FUserList:=TThreadList.create;
end;

procedure Tuser.clearuserlist;
var i:integer;
begin
try
with FUserList.LockList do
for i:=count downto 1 do
  begin
  dispose(Pfirendinfo(items[i-1]));
  delete(i-1);
  end;
finally
FUserList.UnlockList;
end;
end;

//------------------------------------------------------------------------------
// 释放 iconex
//------------------------------------------------------------------------------
destructor Tuser.Destroy;
begin
  clearuserlist;
  freeandnil(FUserList);
  inherited Destroy;
end;
end.
