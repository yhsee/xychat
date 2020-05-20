unit chatrec;

interface

uses
  Windows, SysUtils,Classes,constunt,structureunt,
  TntSystem,TntClasses,TntSysutils,TntWideStrUtils;

type
  Tchat=class
     constructor Create;
     destructor  Destroy;override;
   private
     FRecNo:Integer;
     FChatRecList:TThreadList;
   public
     procedure clearchatreclist;overload;
     function clearchatreclist(UserSign:String):Boolean;overload;
     procedure loadfromfile;
     procedure savetofile;

     procedure First;
     procedure Last;
     procedure Next;
     procedure Prior;
     function Eof:Boolean;
     function Bof:Boolean;
     function GetCurChatRecInfo(var TmpInfor:TChatrec):Boolean;

     function CheckChatRec(P:Pointer):Boolean;
     procedure Update(TmpInfor:TChatrec);
     procedure DelRec(TmpInfor:TChatrec);

     procedure addusertext(sParams:WideString;sendok,readok:boolean);overload;
     procedure addusertext(UserSign:string;sParams:WideString;sendok,readok:boolean);overload;
     procedure getlatelylist(var Tmplist:TStringList);
   end;

var
  chat:Tchat;

implementation

uses ShareUnt,SimpleXmlUnt,md5unt;

//------------------------------------------------------------------------------
// 添加聊天记录
//------------------------------------------------------------------------------
procedure Tchat.addusertext(UserSign:string;sParams:WideString;sendok,readok:boolean);
var
  P:Pchatrec;
begin
  New(P);
  FillMemory(P,sizeof(Tchatrec),0);
  P^.UserSign:=UserSign;
  WStrPCopy(P^.msgtext,GetNoteFromValue(sParams,'msgtext'));
  P^.msgtime:=strtodatetime(GetNoteFromValue(sParams,'dt'));  
  P^.PLink:=P;
  P^.sendok:=sendok;
  P^.readok:=readok;
  FChatRecList.Add(P);
end;

procedure Tchat.addusertext(sParams:WideString;sendok,readok:boolean);
var
  UserSign:String;
begin
  UserSign:=GetNoteFromValue(sParams,'UserSign');
  addusertext(UserSign,sParams,sendok,readok);
end;

//------------------------------------------------------------------------------
// 获取最近用户列表
//------------------------------------------------------------------------------
procedure Tchat.getlatelylist(var Tmplist:TStringList);
var
  i:integer;
  sTmpStr:String;
begin
  try
  with FChatRecList.LockList do
  for i:=count downto 1 do
    begin
    sTmpStr:=PChatrec(items[i-1])^.UserSign;
    if Tmplist.IndexOf(sTmpStr)+1=0 then
       begin
       Tmplist.Add(sTmpStr);
       if Tmplist.Count>19 then break;
       end;
    end;
  finally
  FChatRecList.UnlockList;
  end;
end;


procedure Tchat.First;
begin
  FRecNo:=1;
end;

procedure Tchat.Last;
begin
  try
  with FChatRecList.LockList do
    FRecNo:=Count;
  finally
  FChatRecList.UnlockList;
  end;
end;

procedure Tchat.Next;
begin
  Inc(FRecNo);
end;

procedure Tchat.Prior;
begin
  Dec(FRecNo);
end;

function Tchat.Eof:Boolean;
begin
  try
  with FChatRecList.LockList do
    Result:=FRecNo>Count;
  finally
  FChatRecList.UnlockList;
  end;
end;

function Tchat.Bof:Boolean;
begin
  Result:=FRecNo<1;
end;

function Tchat.GetCurChatRecInfo(var TmpInfor:TChatrec):Boolean;
begin
  try
  Result:=False;
  with FChatRecList.LockList do
    begin
    if (FRecNo>0)and (FRecNo<=Count) then
      begin
      TmpInfor:=PChatrec(items[FRecNo-1])^;
      Result:=True;
      end;
    end;
  finally
  FChatRecList.UnlockList;
  end;
end;

function Tchat.CheckChatRec(P:Pointer):Boolean;
begin
  try
  with FChatRecList.LockList do
    Result:=IndexOf(P)>=0;
  finally
  FChatRecList.UnlockList;
  end;
end;
//------------------------------------------------------------------------------
// 修改
//------------------------------------------------------------------------------
procedure Tchat.Update(TmpInfor:TChatrec);
begin
  if CheckChatRec(TmpInfor.PLink) then
    CopyMemory(TmpInfor.PLink,@TmpInfor,SizeOf(TChatrec));
end;

//------------------------------------------------------------------------------
// 删除
//------------------------------------------------------------------------------
procedure Tchat.DelRec(TmpInfor:TChatrec);
begin
  if CheckChatRec(TmpInfor.PLink) then
    begin
    FChatRecList.Remove(TmpInfor.PLink);
    dispose(TmpInfor.PLink);
    end;
end;
//------------------------------------------------------------------------------
// 创建 iconex
//------------------------------------------------------------------------------
constructor Tchat.Create;
begin
  inherited Create;
  FChatRecList:=TThreadList.Create;
end;

//------------------------------------------------------------------------------
// 从文件装入
//------------------------------------------------------------------------------
procedure Tchat.loadfromfile;
var TmpStream:TTntFileStream;
    sFilename:Widestring;
    P:PChatrec;
    datfile:Tdatfile;
begin
  sFilename:=ConCat(Application_Path,'UserData\',loginuser,'\MsgDb.dat');
  if Widefileexists(sFilename) then
    try
    TmpStream:=TTntFileStream.Create(sFilename,fmOpenReadWrite);

    TmpStream.Seek(0,soFromBeginning);
    FillChar(datfile,sizeof(Tdatfile),#0);
    TmpStream.ReadBuffer(datfile,sizeof(Tdatfile));//读文件头
    if (CompareText(datfile.DatHeader,DatFile_Header)=0)and
       (datfile.DatType=DatType_UserChatLog) and
       (datfile.Version=DatVersion) then
      while TmpStream.Position<TmpStream.Size do
        begin
        New(P);
        FillMemory(P,sizeof(Tchatrec),0);
        TmpStream.ReadBuffer(P^,sizeof(Tchatrec));
        P^.PLink:=P;
        FChatRecList.Add(P);
        end;
    finally
    freeandnil(TmpStream);
    end;
end;

//------------------------------------------------------------------------------
// 保存列表
//------------------------------------------------------------------------------
procedure Tchat.savetofile;
var TmpStream:TTntFileStream;
    sFilename:Widestring;
    datfile:Tdatfile;
    i:integer;
begin
sFilename:=ConCat(Application_Path,'UserData\',loginuser,'\MsgDb.dat');
if fileexists(sFilename) then Deletefile(sFilename);
  try
  TmpStream:=TTntFileStream.Create(sFilename,fmCreate or fmOpenReadWrite);
  
  FillChar(datfile,sizeof(Tdatfile),#0);
  datfile.DatHeader:=DatFile_Header;
  datfile.DatType:=DatType_UserChatLog;
  datfile.Version:=DatVersion;

  TmpStream.WriteBuffer(datfile,sizeof(Tdatfile));//写入文件头
    try
    with FChatRecList.LockList do
    for i:=1 to count do
      TmpStream.WriteBuffer(PChatrec(items[i-1])^,sizeof(Tchatrec));
    finally
    FChatRecList.UnlockList;
    end;

  finally
  freeandnil(TmpStream);
  end;
end;

procedure Tchat.clearchatreclist;
var
  i:integer;
begin
  try
  with FChatRecList.LockList do
  for i:=count downto 1 do
    begin
    dispose(items[i-1]);
    delete(i-1);
    end;
  finally
  FChatRecList.UnlockList;
  end;
end;

function Tchat.clearchatreclist(UserSign:String):Boolean;
var
  i:integer;
begin
  try
  with FChatRecList.LockList do
  for i:=count downto 1 do
  if CompareText(pchatrec(items[i-1])^.UserSign,UserSign)=0 then
    begin
    dispose(items[i-1]);
    delete(i-1);
    end;
  result:=True;
  finally
  FChatRecList.UnlockList;
  end;
end;
//------------------------------------------------------------------------------
// 释放 iconex
//------------------------------------------------------------------------------
destructor TChat.Destroy;
begin
  clearchatreclist;
  freeandnil(FChatRecList);
  inherited Destroy;
end;

end.
