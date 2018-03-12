//******************************************************************************
//            ������
//******************************************************************************

unit AnalyzerCommonUnt;

interface

uses
  Windows,SysUtils,Classes;

const
  Buffer_Count                               =2048;
  Buffer_Size                                =High(Word);
//------------------------------------------------------------------------------
  DataVersion                                =2012;

type
//------------------------------------------------------------------------------
// �����ݰ���ʽ
//------------------------------------------------------------------------------
  TSocketInfor=Packed record
    PeerIP:String[15];
    PeerPort:Word;
    end;

  PDataHead = ^TDataHead;
  TDataHead=Packed record
    DataFlag:Byte; //���ݰ�ͷ��־
    Version,      //���ݰ��汾
    DataLen:Word;     //��Ϣ����
    end;

  PRawData = ^TRawData;
  TRawData = packed record
    DataHead:TDataHead;  //��Ϣͷ
    DataBuf : array[0..Buffer_Size-1] of Byte;   //��Ϣ��
    UserSocket:TSocketInfor;
    end;


var
  RawDataList,
  FreeDataList:TThreadList;

procedure NewRawData(var TmpData:Pointer);
procedure AppendRawData(TmpData:Pointer);
function GetOneRawData(var TmpData:Pointer):boolean;
function GetRawDataCount:integer;
procedure InitialDataPack(var TmpData:PRawData);

implementation


//------------------------------------------------------------------------------
// ���������в���
//------------------------------------------------------------------------------
procedure NewRawData(var TmpData:Pointer);
begin
  try
  with FreeDataList.LockList do
    begin
    if Count>0 then
      begin
      TmpData:=Items[0];
      delete(0);
      end else begin
      New(PRawData(TmpData));
      end;
    end;
  finally
  FreeDataList.UnlockList;
  end;
end;

procedure AppendRawData(TmpData:Pointer);
begin
  try
  with RawDataList.LockList do
    begin
    if Count>2048 then
      begin
      Dispose(Items[0]);
      delete(0);
      end;
    add(TmpData);
    end;
  finally
  RawDataList.UnlockList;
  end;
end;

function GetOneRawData(var TmpData:Pointer):boolean;
begin
  try
  with RawDataList.LockList do
    begin
    result:=false;
    if Count>0 then
      begin
      TmpData:=Items[0];
      delete(0);
      result:=true;
      end;
    end;
  finally
  RawDataList.UnlockList;
  end;
end;

function GetRawDataCount:integer;
begin
  try
  with RawDataList.LockList do
    Result:=Count;
  finally
  RawDataList.UnlockList;
  end;
end;

procedure InitialDataPack(var TmpData:PRawData);
begin
  FillMemory(TmpData,SizeOf(TRawData),0);
  TmpData^.DataHead.Version:=DataVersion;
  TmpData^.DataHead.DataFlag:=255;
end;


procedure DestoryList(TmpList:TThreadList);
var i:integer;
begin
try
with TmpList.LockList do
  for i:=Count downto 1 do
   begin
   Dispose(Items[i-1]);
   delete(i-1);
   end;
finally
TmpList.UnlockList;
end;
end;

initialization
  RawDataList:=TThreadList.Create;
  FreeDataList:=TThreadList.Create;

finalization
  DestoryList(RawDataList);
  freeandnil(RawDataList);
  DestoryList(FreeDataList);
  freeandnil(FreeDataList);

end.
