unit ConstUnt;

interface
uses messages;

const
  SysFirendlist                              ='�ҵ���ϵ��';
  SysBlacklist                               ='������';
  SysSearchList                              ='�������';
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
//  ��Ϣ����
//------------------------------------------------------------------------------
  System_Function                            =1001; //ϵͳ��
  Firend_Function                            =1002; //������
  Group_Function                             =1003; //Ⱥ����
  Message_Function                           =1004; //��Ϣ��
  Picture_Function                           =1005; //ͼ����
  File_Function                              =1006; //�ļ���
  Media_Function                             =1007; //�Ӳ���
  Remote_Function                            =1008; //Զ����
  Assist_Function                            =1009; //Э��P2P����

//------------------------------------------------------------------------------
//  ����Ϣ
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
  MSGBOX_TYPE_INFO = '��Ϣ';
  MSGBOX_TYPE_ERROR = '����';
  MSGBOX_TYPE_WARAING = '����';
  MSGBOX_TYPE_CONFIG = 'ȷ��';

  TRAYICON_INFO = '���� 2012 - %s(%s)';
  TRAYICON_INFO_ADMIN = '���߹���Ա';

  MSGBOX_INFORMATION_REGINFONONPASS = '����д��ע�����ϲ��������Ǻű�ǵ���Ŀ������д��';
  MSGBOX_INFORMATION_REGACCOUNTSUCCESS = '�����˺��Ѿ�ע��ɹ����˺��� %s�����ȷ�������½���档';
  MSGBOX_INFORMATION_CLEARCHATHISTORYSUCCESS = '���к��ѽ�̸��¼�Ѿ��ɹ������';
  MSGBOX_INFORMATION_NOMANADDFIREND = '���ź����Է��ܾ��κ��˼Ӻ��ѡ�';
  MSGBOX_INFORMATION_ADDFIRENDNEEDINFO = '��֤��ϢΪ�գ�������������֤��Ϣ��';
  MSGBOX_CONFIG_CLEARALLCHATHISTORY = '��ȷ��Ҫ�����к��ѵĽ�̸��¼ȫ�����������������޷��ָ��ġ�';
  MSGBOX_CONFIG_CLEARCHATHISTORY = '��ȷ��Ҫ������ %s �Ľ�̸��¼ȫ�����������������޷��ָ��ġ�';
  MSGBOX_CONFIG_QUITRMTCONTROL = '��ȷ��Ҫ�ر�Զ��Э����';
  MSGBOX_ERROR_REGACCOUNTFAILED = '����ͨѶ��ʱ���������������Ƿ������������û�п��š�';
  MSGBOX_ERROR_REGERRORBOOTSOFT = 'ע���˺�ʱ������������������Խ���ô���';
  MSGBOX_ERROR_FSCNONEXISTS = 'û���ҵ����ɿռ����������������Ƿ��Ѱ�װ�ò����'#13#13'%s';
  MSGBOX_ERROR_CLEARCHATHISTORY = '������ѽ�̸��¼ʧ�ܣ����ܷ�������æ�����Ժ����ԡ�';
  MSGBOX_ERROR_NONPRMTRSFFILETYPE = '��������ļ����ͱ�����Ա��ֹ�����䱻ȡ����'#13#13'%s';
  MSGBOX_ERROR_SYSSETLEAVEWORDNULL = '������������Ϣ��������Ϣ����Ϊ�ա�';
  MSGBOX_ERROR_IMAGEBIG2MB = '�������ͼƬ̫���ˣ���ʹ���ļ����书��ֱ�Ӵ��͡�';
  MSGBOX_ERROR_ADDICONBIGEST = '������ı���ͼƬ��С̫����ֻ�����С��1MB�ı����ļ���';

  GROUP_CONFIG_DEF = '�� %s ��ϵͳĬ���飬�����������µ����ơ�';

  CONFIG_REMOTECONTROL_AUTOACCEPT = '(%d ����Զ�����)';
  CONFIG_REMOTECONTROL_ACCEPT = '%s �����������Զ��Э������ȷ�Ͻ����������������κ�ȷ�ϣ�ϵͳ����15����Զ���������';

  SEX_TAG_WOMEN = 'Ů';

  //OEM��
  BUTTON_CANCEL = 'ȡ��';
  APPLICATION_MAX = '���';
  APPLICATION_RESIZE = '�ָ���С';
  SEARCH_KEY_HINT = '����ؼ�������';
  IPBound_KEY_HINT = '����IP��ַ';
  CHANGE_SCREEN_COLOR = '����Ӧ�� %s ɫ��ģʽ�����Ժ�...';
  SCREEN_COLOR_16C = '16ɫ';
  SCREEN_COLOR_8 = '8λɫ';
  SCREEN_COLOR_16 = '16λɫ';
  SCREEN_COLOR_32 = '32λ���ɫ';
  CHANGE_SCREEN_FULLMODE = '�Ѿ��л���ȫ��Ļ��ʾģʽ��������ͨ��������ذ�ť�ص�����ģʽ��';
  PAGE_TITLE_USERINFO = '��ϵ��';
  PAGE_TITLE_FILETRANSFERS = '�ļ�����';
  PAGE_TITLE_VIDEOSOUND = '��Ƶ����';
  PAGE_BUTTON_VIEWUSERINFO = '��ϸ��Ϣ';
  PAGE_BUTTON_VIEWUSERINFOHINT = '����鿴��ϵ����ϸ��Ϣ';
  VS_DEVICE_NULL = '��';
  VS_BUTTON_NEXT = '��һ��(N) >';
  VS_BUTTON_FINISH = '���(&F)';

  SET_MYINFO = '��������';
  SET_BASESETTINGS = '��������';
  SET_STATEREPLYTO = '״̬ת���ͻظ�';
  SET_SOUND = '��ʾ��������';
  SET_SAFEUSERADDMODE = '�˺ź���֤ģʽ';
  
implementation

end.
