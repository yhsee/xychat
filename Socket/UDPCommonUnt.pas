unit UDPCommonUnt;

interface

{*******************************************************}
{                                                       }
{       UDP Socket �������ṹ                           }
{                                                       }
{	           email: yihuas@163.com                      }
{		         2012.11.7                                  }
{                                                       }
{*******************************************************}

uses Classes;

const
  UD_Handshake_Firstly                                                =1;    //��һ������
  UD_Handshake_Secondly                                               =2;    //�ڶ�������
  UD_Handshake_Thirdly                                                =3;    //����������

  UD_Heartbeat                                                        =4;    //����
  UD_Response                                                         =5;    //������Ӧ
  UD_Block                                                            =6;    //����Ϣ
  UD_Start                                                            =7;    //��ʼ����
  UD_Send                                                             =8;    //��������
  UD_Recv                                                             =9;    //ȷ�Ϸ���
  UD_RecvOver                                                         =10;   //��������
  UD_SendOver                                                         =11;   //��������
  UD_Simple                                                           =12;   //���󲻹ܵ�������

  UD_Pull_Heartbeat                                                   =13;    //P2P����
  UD_Pull_Response                                                    =14;   //��ӦP2P����

  Block_Ready                                                         =0;   //׼��
  Block_Sending                                                       =1;   //���ڷ���
  Block_Pause                                                         =2;   //��ͣ
  Block_Complete                                                      =3;   //���

  UD_Init_Error                                                       =0;   //��ʼ�����
  UD_Send_Error                                                       =1;   //���Ϳ����
  UD_Recv_Error                                                       =2;   //���տ����

  //----------------------------------------------------------------------------

  Max_WindowSize                                                      =High(Word);

Type
  //������Ϣ�ṹ
  PSocketHandle=^TSocketHandle;
  TSocketHandle=Record
    IP:String[15]; //IP�س�ַ
    Port:Word;     //�˿ں�
    end;

  //���ݰ�ͷ��Ϣ�ṹ
  PUDataHead=^TUDataHead;
  TUDataHead=Packed Record
    iAction:Byte;          //����
    iLen:Word;             //������
    end;

  //���ݰ������ṹ
  PUDataPack=^TUDataPack;
  TUDataPack=Packed Record
    DataHead:TUDataHead;  //���ݰ�ͷ
    Data:Array[0..High(Word)] of Byte;  //��������
    end;

  //��־�¼�
  TWriteLogEvent=procedure(Sender:TObject;iErrorCode:Integer;sLog:WideString) of Object;
  //���������¼�
  TRecvReadyEvent=procedure(Sender:TObject;var AData:TStream; iSize:Int64) of Object;
  //���ݽ�������¼�
  TRecvCompleteEvent=procedure(Sender:TObject;AData:TStream) of Object;
  //���������¼�
  TSpeedProcessEvent=procedure(Sender:TObject;iPosition,iCount:LongWord;iSize:Int64) of Object;
  //���ݽ����¼�
  TUDPReadEvent=procedure(Sender: TObject; var buf;bufSize:Word;ABinding: TSocketHandle) of Object;
  //���ܻص��¼�
  TUDPTranEvent=procedure(Sender: TObject; var buf; var bufSize:Word) of Object;

implementation


end.
