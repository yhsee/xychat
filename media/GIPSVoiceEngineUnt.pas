unit GIPSVoiceEngineUnt;

interface

uses
  SysUtils, Classes, Windows;


type
{/*
所有的函数都应该返回true，否则出错，应该使用GIPSVE_LastError来取得出错的原因。
*/}

PCodec=^TCodec;
TCodec=Record
	pltype:Integer;
	plname:array[0..31] of char;
	plfreq:Integer;
	pacsize:Integer;
	channels:Integer;
	rate:Integer;
  end;

Transport=function(channel:Integer; const data:pointer; len:Integer):Integer;cdecl;

//必需先调用这个函数，并且确保返回值是0，否则以后所有的调用都可能引起异常.本函数多次调用不会有异常
function GIPSVoiceEngine_Init():Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//如果调用了GIPSVoiceEngine_Init()，则最后必须调用这个函数，否则会有大量的资源泄露
procedure GIPSVoiceEngine_UnInit();cdecl; external 'GIPSVoiceEngine.dll';


//创建一个Channel,Channel的值必须>= 0 ,否则出错
function GIPSVoiceEngine_CreateChannel():Integer; cdecl; external 'GIPSVoiceEngine.dll';
//删除一个Channel
function GIPSVoiceEngine_DeleteChannel(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

function GIPSVoiceEngine_RegisterExternalTransport(channel:integer;SendPacket,SendRTCPPacket:Transport):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

function GIPSVoiceEngine_DeRegisterExternalTransport(channel:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

function GIPSVoiceEngine_ReceivedRTPPacket(channel:integer; const data:Pointer;length:Integer):Integer; cdecl; external 'GIPSVoiceEngine.dll';

function GIPSVoiceEngine_ReceivedRTCPPacket(channel:integer; const data:Pointer;length:Integer):Integer; cdecl; external 'GIPSVoiceEngine.dll';


//取得当前的codec类型
function GIPSVoiceEngine_GetSendCodec(channel:Integer;var codec:TCodec):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//设置codec的类型
function GIPSVoiceEngine_SetSendCodec(channel:Integer;const codec:PCodec):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


function GIPSVoiceEngine_SetRecPayloadType(channel:integer; const codec:PCodec):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

function GIPSVoiceEngine_GetRecPayloadType(channel:integer; var codec:TCodec):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


//开始播放声音
function GIPSVoiceEngine_StartPlayout(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//停止播放声音
function GIPSVoiceEngine_StopPlayout(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


//开始发送数据
function GIPSVoiceEngine_StartSend(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//停止发送数据
function GIPSVoiceEngine_StopSend(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//开始接收数据
function GIPSVoiceEngine_StartReceive(channel:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//停止接收数据
function GIPSVoiceEngine_StopReceive(channel:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


// Stops or resumes playout and transmission on a temporary basis.
function GIPSVoiceEngine_SetOnHoldStatus(channel:integer;enabled:boolean;mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

// Gets the current playout and transmission status.
function GIPSVoiceEngine_GetOnHoldStatus(channel:integer;var enabled:boolean;var mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

// Sets the NetEQ playout mode for a specified |channel| number.
function GIPSVoiceEngine_SetNetEQPlayoutMode(channel:integer;mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

// Gets the NetEQ playout mode for a specified |channel| number.
function GIPSVoiceEngine_GetNetEQPlayoutMode(channel:integer;var mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//静音抑制
{/*
设置degree of bandwidth reduction
0 lowest reduction
1
2
3 means highest reduction
set = false means not set, true means set.
*/}
function GIPSVoiceEngine_SetVadMode(channel:Integer; bEnabled:Boolean;mode:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
function GIPSVoiceEngine_GetVadMode(channel:Integer; var bEnabled:Boolean;var mode:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//设置静音
function GIPSVoiceEngine_SetInputMute(channel:Integer;mute:bool):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
function GIPSVoiceEngine_GetInputMute(channel:Integer;var mute:bool):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//设定设备静音
function GIPSVoiceEngine_SetSystemInputMute(mute:bool):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//返回设备静音状态
function GIPSVoiceEngine_GetSystemInputMute(var mute:bool):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//设备回放静音
function GIPSVoiceEngine_SetSystemOutputMute(mute:bool):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//返回设备回放静音状态
function GIPSVoiceEngine_GetSystemOutputMute(var mute:bool):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

{/*
设置接收端的Automatic Gain Control(AGC)的类型
0 预设模式
1 平台默认
2 adaptive mode for use when analog volume control exists (e.g. for PC softphone)
3 scaling takes place in the digital domain (e.g. for conference servers and embedded devices)
4 can be used on embedded devices where the the capture signal is level is predictable
*/}
function GIPSVoiceEngine_SetRxAgcMode(channel:Integer; bEnabled:Boolean; mode:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//取得接收端的Automatic Gain Control(AGC)的类型
function GIPSVoiceEngine_GetRxAgcMode(channel:Integer; var bEnabled:Boolean; mode:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
function GIPSVoiceEngine_SetAgcMode(bEnabled:Boolean; mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
function GIPSVoiceEngine_GetAgcMode(var bEnabled:Boolean; var mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

{/*
设置接收端的Noise Suppression级别
0  previously set mode
1,         // platform default
2,      // conferencing default
3,  // lowest suppression
4,
5,
6,     // highest suppression
*/}
function GIPSVoiceEngine_SetRxNsMode(channel:Integer; bEnabled:Boolean; mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
function GIPSVoiceEngine_GetRxNsMode(channel:Integer; var bEnabled:Boolean; var mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
function GIPSVoiceEngine_SetNsMode( bEnabled:Boolean;  mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
function GIPSVoiceEngine_GetNsMode(var bEnabled; var mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


{/*
设置发送方的Echo Control (EC)类型
0  previously set mode
1  platform default
2  conferencing default (aggressive AEC)
3  Acoustic Echo Cancellation
4  AEC mobile
*/}
function GIPSVoiceEngine_SetEcMode(bEnabled:Boolean; mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
function GIPSVoiceEngine_GetEcMode(var bEnabled:Boolean; var mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


{
获取 CODEC信息
}
//取得Codec总数
function GIPSVoiceEngine_GetNumberOfCodecs():integer; cdecl; external 'GIPSVoiceEngine.dll';
//取得指定index的Codec
function GIPSVoiceEngine_GetCodec(index:integer; var codec:TCodec):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


{
获取设备名称及数量
}

//取得Playout设备的数目
function GIPSVoiceEngine_GetNumberOfPlayoutDevice(var nb:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//取得指定index的Playout设备的名字   PChar length=128
function GIPSVoiceEngine_GetPlayoutDeviceName(index:integer; name:PChar; guid:PChar):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//取得Recording设备的数目
function GIPSVoiceEngine_GetNumberOfRecordingDevice(var nb:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//取得指定index的Recording设备的名字  PChar length=128
function GIPSVoiceEngine_GetRecordingDeviceName(index:Integer; name:PChar; guid:PChar):Boolean; cdecl; external 'GIPSVoiceEngine.dll';



{
音量控制
}
//取得当前speaker的volume，值位于0-255之间
function GIPSVoiceEngine_GetMicVolume(var volume:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//设置Speaker的音量，volume必须位于0-255之间
function GIPSVoiceEngine_SetMicVolume(volume:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//取得当前speaker的volume，值位于0-255之间
function GIPSVoiceEngine_GetSpeakerVolume(var volume:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//设置Speaker的音量，volume必须位于0-255之间
function GIPSVoiceEngine_SetSpeakerVolume(volume:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


//取得当前输入的声音水平 0-9
function GIPSVoiceEngine_GetSpeechInputLevel(var level:LongWord):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//取得指定 channel 的声音输出水平  0-9
function GIPSVoiceEngine_GetSpeechOutputLevel(channel:integer;var level:LongWord):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//取得当前输入声音的范围 [0,32768]
function GIPSVoiceEngine_GetSpeechInputLevelFullRange(var level:LongWord):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//取得指定 channel 的声音范围  [0,32768]
function GIPSVoiceEngine_GetSpeechOutputLevelFullRange(channel:integer;var level:LongWord):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


{/*
文件相关的函数
*/ }
//  fileNameUTF8 [1024]
function GIPSVoiceEngine_StartPlayingFileLocally(
        channel:Integer;
        const fileNameUTF8:PChar;
        loop:boolean= false;
        iformat:integer=7;
        volumeScaling:double=1.0;
        startPointMs:integer=0;
        stopPointMs:integer=0):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

    // Stops playback of a file on a specific |channel|.
function GIPSVoiceEngine_StopPlayingFileLocally(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

    // Returns the current file playing state for a specific |channel|.
function GIPSVoiceEngine_IsPlayingFileLocally(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

    // Sets the volume scaling for a speaker file that is already playing.
function GIPSVoiceEngine_ScaleLocalFilePlayout(channel:Integer;scale:double):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

    // Starts reading data from a file and transmits the data either
    // mixed with or instead of the microphone signal.
// fileNameUTF8 [1024]
function GIPSVoiceEngine_StartPlayingFileAsMicrophone(
        channel:Integer;
        const fileNameUTF8:PChar;
        loop:boolean=false;
        mixWithMicrophone:boolean= false;
        iformat:integer=7;
        volumeScaling:double= 1.0):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

    // Stops playing of a file as microphone signal for a specific |channel|.
function GIPSVoiceEngine_StopPlayingFileAsMicrophone(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

    // Returns whether the |channel| is currently playing a file as microphone.
function GIPSVoiceEngine_IsPlayingFileAsMicrophone(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

    // Sets the volume scaling for a microphone file that is already playing.
function GIPSVoiceEngine_ScaleFileAsMicrophonePlayout(channel:integer;scale:double):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

    // Starts recording the mixed playout audio.
function GIPSVoiceEngine_StartRecordingPlayout(channel:Integer;
                                      const fileNameUTF8:PChar;
                                      compression:PCodec =nil;
                                      maxSizeBytes:integer= -1):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

    // Stops recording the mixed playout audio.
function GIPSVoiceEngine_StopRecordingPlayout(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

    // Starts recording the microphone signal to a file.
function GIPSVoiceEngine_StartRecordingMicrophone(const fileNameUTF8:PChar;
                                         compression:PCodec = nil;
                                         maxSizeBytes:integer= -1):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

    // Stops recording the microphone signal.
function GIPSVoiceEngine_StopRecordingMicrophone():Boolean; cdecl; external 'GIPSVoiceEngine.dll';

    // Gets the current played position of a file on a specific |channel|.
function GIPSVoiceEngine_GetPlaybackPosition(channel:Integer; var positionMs:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


{
版本及返回错误原因
}

//设置跟踪文件
function GIPSVoiceEngine_SetTraceFile(const fileNameUTF8:PChar):boolean; cdecl; external 'GIPSVoiceEngine.dll';

//返回版本(该版本的编译时间)  PChar length=1024
function GIPSVoiceEngine_GetVersion(version:PChar):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//如果任何函数的调用返回了非0值，可以调用这个函数来取得错误的原因
function GIPSVoiceEngine_LastError():integer; cdecl; external 'GIPSVoiceEngine.dll';

implementation


end.




























































