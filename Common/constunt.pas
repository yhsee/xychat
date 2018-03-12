unit ConstUnt;

interface
uses messages;

const
  SysFirendlist                              ='我的联系人';
  SysBlacklist                               ='黑名单';
  SysSearchList                              ='搜索结果';
  blackpic                                   ='{4E16CB00351DC3DCE729E87E97100564}';
  receivpic                                  ='{C0A5F6F0DF3AA55A549DAF001C105552}';  
  inforpic                                   ='{D2795E8AAFCE7669FAE6A3292B740FA7}';
  EnterCtrl                                  =chr(10);
  localver                                   =1001;
//------------------------------------------------------------------------------
  refresh_status                             =wm_user+1111;
//------------------------------------------------------------------------------
  UnKnown_Command                            =9999;
//------------------------------------------------------------------------------
//  消息类型
//------------------------------------------------------------------------------
  System_Function                            =1001; //系统类
  Firend_Function                            =1002; //好友类
  Group_Function                             =1003; //群组类
  Message_Function                           =1004; //消息类
  Picture_Function                           =1005; //图形类
  File_Function                              =1006; //文件类
  Media_Function                             =1007; //视步类
  Remote_Function                            =1008; //远程类
  Assist_Function                            =1009; //协助P2P连接

//------------------------------------------------------------------------------
//  子消息
//------------------------------------------------------------------------------
  Heart_Operation                            =20001;
  UserLoginStatus_Operation                  =20002;
  UserLoginResponses_Operation               =20003;
  UserOutStatus_Operation                    =20004;
  UserStatus_Operation                       =20005;
  UserClipboard_Operation                    =20006;

  GetFirendInfor_Operation                   =20011;
  SendFirendInfor_Operation                  =20012;

  UserText_Operation                         =20021;
  UserTextStatus_Operation                   =20022;
  AutoReText_Operation                       =20023;
  UserImage_Operation                        =20024;

  BroadCastText_Operation                    =20031;
  FinderBroadCast_Operation                  =20032;
  FinderResponses_Operation                  =20033;
  Firend_Add_Operation                       =20034;
  Firend_Request_Operation                   =20035;

  Media_Request_Operation                    =20041;
  Media_Accept_Operation                     =20042;
  Media_Refuse_Operation                     =20043;
  Media_Cancel_Operation                     =20044;
  Media_Complete_Operation                   =20045;

  File_Request_Operation                     =20051;
  File_Accept_Operation                      =20052;
  File_Start_Operation                       =20053;
  File_Refuse_Operation                      =20054;
  File_Cancel_Operation                      =20055;
  File_Complete_Operation                    =20056;

  Remote_Request_Operation                   =20061;
  Remote_Accept_Operation                    =20062;
  Remote_Refuse_Operation                    =20063;
  Remote_Cancel_Operation                    =20064;
  Remote_Complete_Operation                  =20065;

  Assist_Request_Operation                   =20071;

//------------------------------------------------------------------------------
  DatFile_Header                             ='xyChat';
//------------------------------------------------------------------------------
  DatType_UserList                           =1001;
  DatType_UserChatLog                        =1002;
//------------------------------------------------------------------------------
  DatVersion                                 =1200;
//------------------------------------------------------------------------------
  AES_Key                                    ='NH%^*()KMJUOpwr[{46FC65C8-1D3D-4FAD-9641-E69BE0F850AE}]emkdi$@0o';
//------------------------------------------------------------------------------
  Soft_Name                                  ='xyChat';

Resourcestring
  MSGBOX_TYPE_INFO = '信息';
  MSGBOX_TYPE_ERROR = '错误';
  MSGBOX_TYPE_WARAING = '警告';
  MSGBOX_TYPE_CONFIG = '确认';

  TRAYICON_INFO = '奕信 2012 - %s(%s)';
  TRAYICON_INFO_ADMIN = '在线管理员';

  MSGBOX_INFORMATION_REGINFONONPASS = '您填写的注册资料不完整，星号标记的项目必须填写。';
  MSGBOX_INFORMATION_REGACCOUNTSUCCESS = '您的账号已经注册成功！账号是 %s，点击确定进入登陆界面。';
  MSGBOX_INFORMATION_CLEARCHATHISTORYSUCCESS = '所有好友交谈记录已经成功清除。';
  MSGBOX_INFORMATION_NOMANADDFIREND = '很遗憾，对方拒绝任何人加好友。';
  MSGBOX_INFORMATION_ADDFIRENDNEEDINFO = '验证信息为空，您必须输入验证信息。';
  MSGBOX_CONFIG_CLEARALLCHATHISTORY = '您确定要将所有好友的交谈记录全部清空吗？这个操作是无法恢复的。';
  MSGBOX_CONFIG_CLEARCHATHISTORY = '您确定要将好友 %s 的交谈记录全部清空吗？这个操作是无法恢复的。';
  MSGBOX_CONFIG_QUITRMTCONTROL = '您确定要关闭远程协助吗？';
  MSGBOX_ERROR_REGACCOUNTFAILED = '网络通讯超时，请检查网络连接是否正常或服务器没有开放。';
  MSGBOX_ERROR_REGERRORBOOTSOFT = '注册账号时发生错误，请重启软件以解决该错误。';
  MSGBOX_ERROR_FSCNONEXISTS = '没有找到自由空间服务器插件，请检查是否已安装该插件。'#13#13'%s';
  MSGBOX_ERROR_CLEARCHATHISTORY = '清除好友交谈记录失败，可能服务器繁忙，请稍后再试。';
  MSGBOX_ERROR_NONPRMTRSFFILETYPE = '您传输的文件类型被管理员禁止，传输被取消。'#13#13'%s';
  MSGBOX_ERROR_SYSSETLEAVEWORDNULL = '请输入留言信息，留言信息不能为空。';
  MSGBOX_ERROR_IMAGEBIG2MB = '您传输的图片太大了，请使用文件传输功能直接传送。';
  MSGBOX_ERROR_ADDICONBIGEST = '您加入的表情图片大小太大，您只能添加小于1MB的表情文件。';

  GROUP_CONFIG_DEF = '组 %s 是系统默认组，请重新输入新的名称。';

  CONFIG_REMOTECONTROL_AUTOACCEPT = '(%d 秒后自动接受)';
  CONFIG_REMOTECONTROL_ACCEPT = '%s 请求对您进行远程协助，您确认接受吗？如您不进行任何确认，系统将在15秒后自动接受请求。';

  SEX_TAG_WOMEN = '女';

  //OEM点
  BUTTON_CANCEL = '取消';
  APPLICATION_MAX = '最大化';
  APPLICATION_RESIZE = '恢复大小';
  SEARCH_KEY_HINT = '输入关键字搜索';
  IPBound_KEY_HINT = '输入IP地址';
  CHANGE_SCREEN_COLOR = '正在应用 %s 色彩模式，请稍候...';
  SCREEN_COLOR_16C = '16色';
  SCREEN_COLOR_8 = '8位色';
  SCREEN_COLOR_16 = '16位色';
  SCREEN_COLOR_32 = '32位真彩色';
  CHANGE_SCREEN_FULLMODE = '已经切换到全屏幕显示模式，您可以通过点击返回按钮回到窗口模式。';
  PAGE_TITLE_USERINFO = '联系人';
  PAGE_TITLE_FILETRANSFERS = '文件传输';
  PAGE_TITLE_VIDEOSOUND = '视频语音';
  PAGE_BUTTON_VIEWUSERINFO = '详细信息';
  PAGE_BUTTON_VIEWUSERINFOHINT = '点击查看联系人详细信息';
  VS_DEVICE_NULL = '无';
  VS_BUTTON_NEXT = '下一步(N) >';
  VS_BUTTON_FINISH = '完成(&F)';

  SET_MYINFO = '个人资料';
  SET_BASESETTINGS = '基础设置';
  SET_STATEREPLYTO = '状态转换和回复';
  SET_SOUND = '提示声音设置';
  SET_SAFEUSERADDMODE = '账号和验证模式';
  
implementation

end.
