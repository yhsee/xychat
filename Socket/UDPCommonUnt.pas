unit UDPCommonUnt;

interface

{*******************************************************}
{                                                       }
{       UDP Socket 常量及结构                           }
{                                                       }
{	           email: yihuas@163.com                      }
{		         2012.11.7                                  }
{                                                       }
{*******************************************************}

uses Classes;

const
  UD_Handshake_Firstly                                                =1;    //第一次握手
  UD_Handshake_Secondly                                               =2;    //第二次握手
  UD_Handshake_Thirdly                                                =3;    //第三次握手

  UD_Heartbeat                                                        =4;    //心跳
  UD_Response                                                         =5;    //心跳响应
  UD_Block                                                            =6;    //块信息
  UD_Start                                                            =7;    //开始发送
  UD_Send                                                             =8;    //发送数据
  UD_Recv                                                             =9;    //确认发送
  UD_RecvOver                                                         =10;   //结束发送
  UD_SendOver                                                         =11;   //结束发送
  UD_Simple                                                           =12;   //发后不管的数所包

  UD_Pull_Heartbeat                                                   =13;    //P2P心跳
  UD_Pull_Response                                                    =14;   //回应P2P心跳

  Block_Ready                                                         =0;   //准备
  Block_Sending                                                       =1;   //正在发送
  Block_Pause                                                         =2;   //暂停
  Block_Complete                                                      =3;   //完成

  UD_Init_Error                                                       =0;   //初始块错误
  UD_Send_Error                                                       =1;   //发送块错误
  UD_Recv_Error                                                       =2;   //接收块错误

  //----------------------------------------------------------------------------

  Max_WindowSize                                                      =High(Word);

Type
  //连接信息结构
  PSocketHandle=^TSocketHandle;
  TSocketHandle=Record
    IP:String[15]; //IP地超址
    Port:Word;     //端口号
    end;

  //数据包头信息结构
  PUDataHead=^TUDataHead;
  TUDataHead=Packed Record
    iAction:Byte;          //动作
    iLen:Word;             //包长度
    end;

  //数据包完整结构
  PUDataPack=^TUDataPack;
  TUDataPack=Packed Record
    DataHead:TUDataHead;  //数据包头
    Data:Array[0..High(Word)] of Byte;  //数据内容
    end;

  //日志事件
  TWriteLogEvent=procedure(Sender:TObject;iErrorCode:Integer;sLog:WideString) of Object;
  //接收数据事件
  TRecvReadyEvent=procedure(Sender:TObject;var AData:TStream; iSize:Int64) of Object;
  //数据接收完成事件
  TRecvCompleteEvent=procedure(Sender:TObject;AData:TStream) of Object;
  //传输速率事件
  TSpeedProcessEvent=procedure(Sender:TObject;iPosition,iCount:LongWord;iSize:Int64) of Object;
  //数据接收事件
  TUDPReadEvent=procedure(Sender: TObject; var buf;bufSize:Word;ABinding: TSocketHandle) of Object;
  //加密回调事件
  TUDPTranEvent=procedure(Sender: TObject; var buf; var bufSize:Word) of Object;

implementation


end.
