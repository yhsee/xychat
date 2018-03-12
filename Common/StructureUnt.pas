unit structureunt;

interface

type

//------------------------------------------------------------------------------
// MyConfig 结构
//------------------------------------------------------------------------------
  PMyConfig=^TMyConfig;
  TMyConfig=Packed Record 
    UserID:String[16];    //帐号
    PassWord:String[32];  //密码
    ColorLevel:Byte;
    showonline:Boolean;
    showupdownhint:Boolean;
    AllowPlaywave:Boolean;
    newmsgpopup:Boolean;
    pressentersend:Boolean;
    closetomin:Boolean;
    filevention:Boolean;
    newpictext:Boolean;
    allow_auto_status:Boolean;
    auto_status:Byte;
    status_outtime:Word;
    systemkey:LongWord;
    bosskey:LongWord;
    video_index:Byte;
    audio_index:Byte;
    mic_index:Byte;
    DefaultOpenDir:WideString;
    DefaultSaveDir:WideString;
    ClientMsgWave:WideString;
    SystemMsgWave:WideString;
    NewFirendWave:WideString;
    GroupMsgWave:WideString;
    revertmsg:WideString;
    fontname:WideString;
    fontsize:Word;
    fontcolor:Integer;
    fontstyle:String[4];
    end;


//------------------------------------------------------------------------------
// 用户信息
//------------------------------------------------------------------------------
  Pfirendinfo=^Tfirendinfo;
  Tfirendinfo=Packed record
   UserSign:String[32];    //唯一标识符
   UserID:String[16];     //帐号
   UName:array[0..31] of widechar;      //昵称 
   MyText:array[0..127] of widechar;    //简介
   GName:array[0..31] of widechar;       //组ID
   Visualize:string[34];  //自定义形像
   Status:Shortint;       //状态
   CheckUp:Shortint;      //验证状态  0任意,1验证 2禁止
   Ulevel:Shortint;       //用户级别
   Sex:array[0..3] of widechar;         //
   Age:array[0..3] of widechar;         //
   Constellation:array[0..7] of widechar; //
   Signing:array[0..63] of widechar;      //
   Area:array[0..47] of widechar;         //
   Phone:array[0..31] of widechar;        //
   Communication:array[0..31] of widechar; //
   QQmsn:array[0..31] of widechar;         //
   Email:array[0..47] of widechar;
   Lanip:string[15];
   Macstr:string[17];
   Lastdt:tdatetime;   
   //---------------------------------------------------------------------------
   Pwd:String[32];          //密码
   SName:array[0..31] of widechar;      //备注昵称 
   HideIsVisable:Shortint;  //设置用户是否可见
   chatdlg:Pointer;  //聊天窗口
   end;

//------------------------------------------------------------------------------
// 聊天记录
//------------------------------------------------------------------------------
  pchatrec=^tchatrec;
  tchatrec=Packed record
    PLink:Pointer;
    UserSign:string[32];
    MsgText:array[0..1967] of widechar;
    readok:boolean;
    sendok:boolean;
    msgtime:Tdatetime;
    end;
//------------------------------------------------------------------------------
// 图片
//------------------------------------------------------------------------------
  PImageInfo=^TImageInfo;
  TImageInfo=Packed record
    md5:string[34];       //md5唯一标识符
    filename:WideString;      //文件名称..
    end;

//------------------------------------------------------------------------------
// Dat 文件头结构
//------------------------------------------------------------------------------
  Tdatfile=Packed record
    DatHeader:String[16];
    DatType:Word;
    Version:Integer;
    end;
      
implementation

end.
