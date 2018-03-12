unit MultiTimerCommonUnt;

interface

{*******************************************************}
{                                                       }
{       计时器常量及结构                                }
{                                                       }
{	           email: yihuas@163.com                      }
{		         2012.11.7                                  }
{                                                       }
{*******************************************************}

uses
  Classes;

type
  //计时器结构
  PSingleTime = ^TSingleTime;
  TSingleTime = Packed Record
  
    iActive,               //计时器是否活动状态
    iDelete: Boolean;      //计时器是否需要删除

    iTime,                 //计时周期(毫秒)
    iCount: Word;          //周期计数器

    iStartTick: LongWord;  //计时开始时间

    Data:Pointer;          //寄存数据
    Sender: TNotifyEvent;  //触发事件
  end;

implementation

end.
