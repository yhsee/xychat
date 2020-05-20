//******************************************************************************
//            处理定义
//******************************************************************************

unit AnalyzerCommonUnt;

interface

type
//------------------------------------------------------------------------------
// 简单数据包格式
//------------------------------------------------------------------------------
  TSocketInfor=Packed record
    PeerIP:String[15];
    PeerPort:Word;
    end;

  PRawData = ^TRawData;
  TRawData = packed record
    DataLen:Word;     //信息长度
    DataBuf : array[0..High(Word)-1] of Byte;   //信息体
    UserSocket:TSocketInfor;
    end;

implementation


end.
