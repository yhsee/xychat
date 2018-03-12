unit ImageOleUnt;

interface

uses
  Windows, SysUtils,Classes,structureunt,
  TntClasses,TntSysUtils;

type
  TImageOle=class
      constructor Create;
      destructor  Destroy;override;
    private
      FPicturelist:TThreadList;
    public
      procedure ClearImageOle;
      procedure LoadImageOle;
      function CheckImageExists(sTmpStr:string):Boolean;
      function GetImageFileName(sTmpStr:string;var sFileName:WideString):Boolean;
      function Find(md5:String;var TmpInfor:PImageInfo):Boolean;overload;
      function Find(md5:String;var TmpInfor:TImageInfo):Boolean;overload;
      function AddFileToImageOle(sFileName:WideString;Const bCopy:Boolean=False):String;
  end;

var
  ImageOle:TImageOle;

implementation
uses ShareUnt,FindFileUnt,md5Unt;

function TImageOle.GetImageFileName(sTmpStr:string;var sFileName:WideString):Boolean;
var
  P:PImageInfo;
begin
  Result:=False;
  if Find(sTmpStr,P) and WideFileExists(P^.filename) then
    begin
    Result:=True;
    sFileName:=P^.filename;
    end;
end;

function TImageOle.CheckImageExists(sTmpStr:string):boolean;
var
  P:PImageInfo;
begin
  Result:=Find(sTmpStr,P) and WideFileExists(P^.filename);
end;

function TImageOle.Find(md5:String;var TmpInfor:PImageInfo):Boolean;
var
  i:integer;
begin
  try
  Result:=False; TmpInfor:=nil;
  with FPicturelist.LockList do
  for i:=count downto 1 do
  if CompareText(PImageInfo(items[i-1])^.md5,md5)=0 then
    begin
    TmpInfor:=PImageInfo(items[i-1]);
    Result:=True;
    break;
    end;
  finally
  FPicturelist.UnlockList;
  end;
end;

function TImageOle.Find(md5:String;var TmpInfor:TImageInfo):Boolean;
var
  P:PImageInfo;
begin
  Result:=Find(md5,P);
  if Result then TmpInfor:=P^;
end;

function TImageOle.AddFileToImageOle(sFileName:WideString;Const bCopy:Boolean=False):String;
var
  sTmpStr:WideString;
  TmpInfor:PImageInfo;
begin
  Result:='';
  if WideFileexists(sFileName) then
    begin
    Result:='{'+md5encodefile(sFileName)+'}';
    if Find(Result,TmpInfor) and WideFileExists(TmpInfor^.filename) then exit;

    sTmpStr:=sFileName;
    if bCopy then
    if CompareText(DefaultCustomImagePath,WideExtractFilePath(sFileName))<>0 then
      begin
      sTmpStr:=ConCat(DefaultCustomImagePath,Result,WideExtractFileExt(sFileName));
      WideCopyFile(sFileName,sTmpStr,true);
      end;

    if not Assigned(TmpInfor) then
      begin
      New(TmpInfor);
      TmpInfor^.md5:=Result;
      TmpInfor^.filename:=sTmpStr;
      FPicturelist.Add(TmpInfor);
      end else TmpInfor^.filename:=sTmpStr;
    end;
end;

procedure TImageOle.LoadImageOle;
var
  i:integer;
  ext:string;
  TmpList:TTntStringList;
begin
  try
  TmpList:=TTntStringList.create;
  userdefpic:=ConCat(Application_Path,'Skins\BlueSky\DefUser.jpg');
  FindFile(ConCat(Application_Path,'Images\'),TmpList,true);
  FindFile(ConCat(Application_Path,'UserData\',loginuser,'\Images\'),TmpList,false);
  if TmpList.count>0 then
  for i:=1 to TmpList.count do
    begin
    ext:=WideExtractfileext(TmpList.strings[i-1]);
    if (WideCompareText(ext,'.jpg')=0)or
       (WideCompareText(ext,'.jpeg')=0)or
       (WideCompareText(ext,'.bmp')=0)or
       (WideCompareText(ext,'.gif')=0)or
       (WideCompareText(ext,'.png')=0)or
       (WideCompareText(ext,'.ico')=0) then
        AddFileToImageOle(TmpList.strings[i-1]);
    end;
  finally
  freeandnil(TmpList);
  end;
end;

procedure TImageOle.ClearImageOle;
var
  i:integer;
begin
  try
  with FPicturelist.LockList do
  for i:=count downto 1 do
    begin
    dispose(items[i-1]);
    delete(i-1);
    end;
  finally
  FPicturelist.UnlockList;
  end;
end;
//------------------------------------------------------------------------------
// ¥¥Ω® iconex
//------------------------------------------------------------------------------
constructor TImageOle.Create;
begin
  inherited Create;
  FPicturelist:=TThreadList.Create;
end;

//------------------------------------------------------------------------------
//  Õ∑≈ iconex
//------------------------------------------------------------------------------
destructor TImageOle.Destroy;
begin
  ClearImageOle;
  freeandnil(FPicturelist);
  inherited Destroy;
end;

end.
