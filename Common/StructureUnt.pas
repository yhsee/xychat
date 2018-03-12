unit structureunt;

interface

type

//------------------------------------------------------------------------------
// MyConfig �ṹ
//------------------------------------------------------------------------------
  PMyConfig=^TMyConfig;
  TMyConfig=Packed Record 
    UserID:String[16];    //�ʺ�
    PassWord:String[32];  //����
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
// �û���Ϣ
//------------------------------------------------------------------------------
  Pfirendinfo=^Tfirendinfo;
  Tfirendinfo=Packed record
   UserSign:String[32];    //Ψһ��ʶ��
   UserID:String[16];     //�ʺ�
   UName:array[0..31] of widechar;      //�ǳ� 
   MyText:array[0..127] of widechar;    //���
   GName:array[0..31] of widechar;       //��ID
   Visualize:string[34];  //�Զ�������
   Status:Shortint;       //״̬
   CheckUp:Shortint;      //��֤״̬  0����,1��֤ 2��ֹ
   Ulevel:Shortint;       //�û�����
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
   Pwd:String[32];          //����
   SName:array[0..31] of widechar;      //��ע�ǳ� 
   HideIsVisable:Shortint;  //�����û��Ƿ�ɼ�
   chatdlg:Pointer;  //���촰��
   end;

//------------------------------------------------------------------------------
// �����¼
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
// ͼƬ
//------------------------------------------------------------------------------
  PImageInfo=^TImageInfo;
  TImageInfo=Packed record
    md5:string[34];       //md5Ψһ��ʶ��
    filename:WideString;      //�ļ�����..
    end;

//------------------------------------------------------------------------------
// Dat �ļ�ͷ�ṹ
//------------------------------------------------------------------------------
  Tdatfile=Packed record
    DatHeader:String[16];
    DatType:Word;
    Version:Integer;
    end;
      
implementation

end.
