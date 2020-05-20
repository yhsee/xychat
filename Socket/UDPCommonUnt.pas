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
  UD_Handshake_Firstly                                                =01;    //��һ������
  UD_Handshake_Secondly                                               =02;    //�ڶ�������
  UD_Handshake_Thirdly                                                =03;    //����������

  UD_Heartbeat                                                        =04;    //����
  UD_Response                                                         =05;    //������Ӧ
  UD_Block                                                            =06;    //����Ϣ
  UD_Start                                                            =07;    //��ʼ����
  UD_Send                                                             =08;    //��������
  UD_Recv                                                             =09;    //ȷ�Ϸ���
  UD_RecvOver                                                         =10;   //��������
  UD_SendOver                                                         =11;   //��������
  UD_Simple                                                           =12;   //���󲻹ܵ�������

  UD_Pull_Heartbeat                                                   =21;    //P2P����
  UD_Pull_Response                                                    =22;   //��ӦP2P����


  Block_Ready                                                         =0;   //׼��
  Block_Sending                                                       =1;   //���ڷ���
  Block_Pause                                                         =2;   //��ͣ
  Block_Complete                                                      =3;   //���

  UD_Init_Error                                                       =0;   //��ʼ�����
  UD_Send_Error                                                       =1;   //���Ϳ����
  UD_Recv_Error                                                       =2;   //���տ����

  //----------------------------------------------------------------------------

Type
  //������Ϣ�ṹ
  PSocketHandle=^TSocketHandle;
  TSocketHandle=Record
    PeerIP:String[15]; //IP�س�ַ
    PeerPort:Word;     //�˿ں�
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
    Data:Array[0..High(Word)-sizeof(TUDataHead)] of Byte;  //��������
    end;

  //��־�¼�
  TWriteLogEvent=procedure(Sender:TObject;iErrorCode:Integer;sLog:WideString) of Object;
  //׼�����������¼�
  TRecvReadyEvent=procedure(Sender:TObject;var sNewFileName:WideString; iSize:Int64) of Object;
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
