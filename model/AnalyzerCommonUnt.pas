//******************************************************************************
//            ������
//******************************************************************************

unit AnalyzerCommonUnt;

interface

type
//------------------------------------------------------------------------------
// �����ݰ���ʽ
//------------------------------------------------------------------------------
  TSocketInfor=Packed record
    PeerIP:String[15];
    PeerPort:Word;
    end;

  PRawData = ^TRawData;
  TRawData = packed record
    DataLen:Word;     //��Ϣ����
    DataBuf : array[0..High(Word)-1] of Byte;   //��Ϣ��
    UserSocket:TSocketInfor;
    end;

implementation


end.
