//******************************************************************************
//            事件定义
//******************************************************************************

unit EventCommonUnt;

interface

uses
  SysUtils,Classes;


const
  Buffer_Count                               =1024;
//------------------------------------------------------------------------------
//  事件定义
//------------------------------------------------------------------------------
  Refresh_UserStatus_Event                   =10001;
  Refresh_Latelylist_Event                   =10002;
  Refresh_UserList_Event                     =10003;

  ShowMainForm_Event                         =10011;
  HideMainForm_Event                         =10012;
  ShowIconFlash_Event                        =10013;

  Close_Form_Event                           =10021;
  ShowHintMesssage_Event                     =10022;
  ShowFirendDialog_Event                     =10023;

  ShowFirendMessage_Event                    =10031;
  ShowInputimpact_Event                      =10032;

  UserImage_Request_Event                    =10033;
  UserImage_Complete_Event                   =10034;

  Dialog_Hint_Message                        =10041;
  Dialog_HintEx_Message                      =10042;

  Dialog_Phiz_Image                          =10051;
  Assist_Request_Event                       =10052;  

  Media_Request_Event                        =10061;
  Media_Accept_Event                         =10062;
  Media_Refuse_Event                         =10063;
  Media_Cancel_Event                         =10064;
  Media_Complete_Event                       =10065;

  Media_VideoPlay_Event                      =10067;
  Media_AudioPlay_Event                      =10068;

  File_Request_Event                         =10071;
  File_Accept_Event                          =10072;
  File_Start_Event                           =10073;
  File_Refuse_Event                          =10074;
  File_Cancel_Event                          =10075;
  File_Complete_Event                        =10076;

  Remote_Request_Event                       =10081;
  Remote_Accept_Event                        =10082;
  Remote_Refuse_Event                        =10083;
  Remote_Cancel_Event                        =10084;
  Remote_Complete_Event                      =10085;

type
//------------------------------------------------------------------------------
// 事件分发
//------------------------------------------------------------------------------
  TEventType=(Event_All,Event_Main,Event_Core,Event_Dialog,Event_Media,Event_Remote,Event_File,Event_Assist);

  PEventData= ^TEventData;
  TEventData=Packed record
    iEvent:Integer;
    iType:TEventType;
    UserSign:String[32];
    UserParams:WideString;
    end;

  TOnEventProcess=procedure(Sender:TObject;TmpEvent:TEventData) of Object;

  PEventProcess=^TEventProcess;
  TEventProcess=Packed Record
    iType:TEventType;
    UserSign:String[32];
    OnEvent:TOnEventProcess;
    end;

//------------------------------------------------------------------------------
// 事件缓冲区
//------------------------------------------------------------------------------
var
  EventList,
  EvenDatatList,
  FreeEventList:TThreadList;

function GetEventRawDataCount:integer;
function GetOneEventRawData(var TmpData:Pointer):boolean;
procedure NewEventRawData(var TmpData:Pointer);
procedure AppendEventRawData(TmpData:Pointer);

implementation

//------------------------------------------------------------------------------
// 缓冲区队列操作
//------------------------------------------------------------------------------
procedure NewEventRawData(var TmpData:Pointer);
begin
  try
  with FreeEventList.LockList do
    begin
    if Count>0 then
      begin
      TmpData:=Items[0];
      delete(0);
      end else begin
        New(PEventData(TmpData));
      end;
    end;
  finally
  FreeEventList.UnlockList;
  end;
end;

procedure AppendEventRawData(TmpData:Pointer);
begin
  try
  with EvenDatatList.LockList do
    begin
    if Count>Buffer_Count then
      begin
      Dispose(Items[0]);
      delete(0);
      end;
    add(TmpData);
    end;
  finally
  EvenDatatList.UnlockList;
  end;
end;

function GetOneEventRawData(var TmpData:Pointer):boolean;
begin
  try
  with EvenDatatList.LockList do
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
  EvenDatatList.UnlockList;
  end;
end;

function GetEventRawDataCount:integer;
begin
  try
  with EvenDatatList.LockList do
    Result:=Count;
  finally
  EvenDatatList.UnlockList;
  end;
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
  EvenDatatList:=TThreadList.Create;
  FreeEventList:=TThreadList.Create;
  EventList:=TThreadlist.Create;

finalization
  DestoryList(EvenDatatList);
  freeandnil(EvenDatatList);
  DestoryList(FreeEventList);
  freeandnil(FreeEventList);
  DestoryList(EventList);
  freeandnil(EventList);

end.
