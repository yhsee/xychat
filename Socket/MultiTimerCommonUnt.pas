unit MultiTimerCommonUnt;

interface

{*******************************************************}
{                                                       }
{       ��ʱ���������ṹ                                }
{                                                       }
{	           email: yihuas@163.com                      }
{		         2012.11.7                                  }
{                                                       }
{*******************************************************}

uses
  Classes;

type
  //��ʱ���ṹ
  PSingleTime = ^TSingleTime;
  TSingleTime = Packed Record
  
    iActive,               //��ʱ���Ƿ�״̬
    iDelete: Boolean;      //��ʱ���Ƿ���Ҫɾ��

    iTime,                 //��ʱ����(����)
    iCount: Word;          //���ڼ�����

    iStartTick: LongWord;  //��ʱ��ʼʱ��

    Data:Pointer;          //�Ĵ�����
    Sender: TNotifyEvent;  //�����¼�
  end;

implementation

end.
