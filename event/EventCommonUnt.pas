//******************************************************************************
//            事件定义
//******************************************************************************

unit EventCommonUnt;

interface


const
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
  File_UpdateInfor_Event                     =10077;
  File_UpdateProcess_Event                   =10078;

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
    iDelete:Boolean;
    UserSign:String[32];
    OnEvent:TOnEventProcess;
    end;


implementation


end.
