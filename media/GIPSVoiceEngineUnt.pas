unit GIPSVoiceEngineUnt;

interface

uses
  SysUtils, Classes, Windows;


type
{/*
���еĺ�����Ӧ�÷���true���������Ӧ��ʹ��GIPSVE_LastError��ȡ�ó����ԭ��
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

//�����ȵ����������������ȷ������ֵ��0�������Ժ����еĵ��ö����������쳣.��������ε��ò������쳣
function GIPSVoiceEngine_Init():Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//���������GIPSVoiceEngine_Init()����������������������������д�������Դй¶
procedure GIPSVoiceEngine_UnInit();cdecl; external 'GIPSVoiceEngine.dll';


//����һ��Channel,Channel��ֵ����>= 0 ,�������
function GIPSVoiceEngine_CreateChannel():Integer; cdecl; external 'GIPSVoiceEngine.dll';
//ɾ��һ��Channel
function GIPSVoiceEngine_DeleteChannel(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

function GIPSVoiceEngine_RegisterExternalTransport(channel:integer;SendPacket,SendRTCPPacket:Transport):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

function GIPSVoiceEngine_DeRegisterExternalTransport(channel:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

function GIPSVoiceEngine_ReceivedRTPPacket(channel:integer; const data:Pointer;length:Integer):Integer; cdecl; external 'GIPSVoiceEngine.dll';

function GIPSVoiceEngine_ReceivedRTCPPacket(channel:integer; const data:Pointer;length:Integer):Integer; cdecl; external 'GIPSVoiceEngine.dll';


//ȡ�õ�ǰ��codec����
function GIPSVoiceEngine_GetSendCodec(channel:Integer;var codec:TCodec):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//����codec������
function GIPSVoiceEngine_SetSendCodec(channel:Integer;const codec:PCodec):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


function GIPSVoiceEngine_SetRecPayloadType(channel:integer; const codec:PCodec):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

function GIPSVoiceEngine_GetRecPayloadType(channel:integer; var codec:TCodec):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


//��ʼ��������
function GIPSVoiceEngine_StartPlayout(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//ֹͣ��������
function GIPSVoiceEngine_StopPlayout(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


//��ʼ��������
function GIPSVoiceEngine_StartSend(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//ֹͣ��������
function GIPSVoiceEngine_StopSend(channel:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//��ʼ��������
function GIPSVoiceEngine_StartReceive(channel:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//ֹͣ��������
function GIPSVoiceEngine_StopReceive(channel:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


// Stops or resumes playout and transmission on a temporary basis.
function GIPSVoiceEngine_SetOnHoldStatus(channel:integer;enabled:boolean;mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

// Gets the current playout and transmission status.
function GIPSVoiceEngine_GetOnHoldStatus(channel:integer;var enabled:boolean;var mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

// Sets the NetEQ playout mode for a specified |channel| number.
function GIPSVoiceEngine_SetNetEQPlayoutMode(channel:integer;mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

// Gets the NetEQ playout mode for a specified |channel| number.
function GIPSVoiceEngine_GetNetEQPlayoutMode(channel:integer;var mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//��������
{/*
����degree of bandwidth reduction
0 lowest reduction
1
2
3 means highest reduction
set = false means not set, true means set.
*/}
function GIPSVoiceEngine_SetVadMode(channel:Integer; bEnabled:Boolean;mode:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
function GIPSVoiceEngine_GetVadMode(channel:Integer; var bEnabled:Boolean;var mode:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//���þ���
function GIPSVoiceEngine_SetInputMute(channel:Integer;mute:bool):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
function GIPSVoiceEngine_GetInputMute(channel:Integer;var mute:bool):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//�趨�豸����
function GIPSVoiceEngine_SetSystemInputMute(mute:bool):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//�����豸����״̬
function GIPSVoiceEngine_GetSystemInputMute(var mute:bool):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//�豸�طž���
function GIPSVoiceEngine_SetSystemOutputMute(mute:bool):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//�����豸�طž���״̬
function GIPSVoiceEngine_GetSystemOutputMute(var mute:bool):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

{/*
���ý��ն˵�Automatic Gain Control(AGC)������
0 Ԥ��ģʽ
1 ƽ̨Ĭ��
2 adaptive mode for use when analog volume control exists (e.g. for PC softphone)
3 scaling takes place in the digital domain (e.g. for conference servers and embedded devices)
4 can be used on embedded devices where the the capture signal is level is predictable
*/}
function GIPSVoiceEngine_SetRxAgcMode(channel:Integer; bEnabled:Boolean; mode:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//ȡ�ý��ն˵�Automatic Gain Control(AGC)������
function GIPSVoiceEngine_GetRxAgcMode(channel:Integer; var bEnabled:Boolean; mode:Integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
function GIPSVoiceEngine_SetAgcMode(bEnabled:Boolean; mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
function GIPSVoiceEngine_GetAgcMode(var bEnabled:Boolean; var mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

{/*
���ý��ն˵�Noise Suppression����
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
���÷��ͷ���Echo Control (EC)����
0  previously set mode
1  platform default
2  conferencing default (aggressive AEC)
3  Acoustic Echo Cancellation
4  AEC mobile
*/}
function GIPSVoiceEngine_SetEcMode(bEnabled:Boolean; mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
function GIPSVoiceEngine_GetEcMode(var bEnabled:Boolean; var mode:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


{
��ȡ CODEC��Ϣ
}
//ȡ��Codec����
function GIPSVoiceEngine_GetNumberOfCodecs():integer; cdecl; external 'GIPSVoiceEngine.dll';
//ȡ��ָ��index��Codec
function GIPSVoiceEngine_GetCodec(index:integer; var codec:TCodec):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


{
��ȡ�豸���Ƽ�����
}

//ȡ��Playout�豸����Ŀ
function GIPSVoiceEngine_GetNumberOfPlayoutDevice(var nb:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//ȡ��ָ��index��Playout�豸������   PChar length=128
function GIPSVoiceEngine_GetPlayoutDeviceName(index:integer; name:PChar; guid:PChar):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//ȡ��Recording�豸����Ŀ
function GIPSVoiceEngine_GetNumberOfRecordingDevice(var nb:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//ȡ��ָ��index��Recording�豸������  PChar length=128
function GIPSVoiceEngine_GetRecordingDeviceName(index:Integer; name:PChar; guid:PChar):Boolean; cdecl; external 'GIPSVoiceEngine.dll';



{
��������
}
//ȡ�õ�ǰspeaker��volume��ֵλ��0-255֮��
function GIPSVoiceEngine_GetMicVolume(var volume:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//����Speaker��������volume����λ��0-255֮��
function GIPSVoiceEngine_SetMicVolume(volume:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//ȡ�õ�ǰspeaker��volume��ֵλ��0-255֮��
function GIPSVoiceEngine_GetSpeakerVolume(var volume:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//����Speaker��������volume����λ��0-255֮��
function GIPSVoiceEngine_SetSpeakerVolume(volume:integer):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


//ȡ�õ�ǰ���������ˮƽ 0-9
function GIPSVoiceEngine_GetSpeechInputLevel(var level:LongWord):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//ȡ��ָ�� channel ���������ˮƽ  0-9
function GIPSVoiceEngine_GetSpeechOutputLevel(channel:integer;var level:LongWord):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//ȡ�õ�ǰ���������ķ�Χ [0,32768]
function GIPSVoiceEngine_GetSpeechInputLevelFullRange(var level:LongWord):Boolean; cdecl; external 'GIPSVoiceEngine.dll';

//ȡ��ָ�� channel ��������Χ  [0,32768]
function GIPSVoiceEngine_GetSpeechOutputLevelFullRange(channel:integer;var level:LongWord):Boolean; cdecl; external 'GIPSVoiceEngine.dll';


{/*
�ļ���صĺ���
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
�汾�����ش���ԭ��
}

//���ø����ļ�
function GIPSVoiceEngine_SetTraceFile(const fileNameUTF8:PChar):boolean; cdecl; external 'GIPSVoiceEngine.dll';

//���ذ汾(�ð汾�ı���ʱ��)  PChar length=1024
function GIPSVoiceEngine_GetVersion(version:PChar):Boolean; cdecl; external 'GIPSVoiceEngine.dll';
//����κκ����ĵ��÷����˷�0ֵ�����Ե������������ȡ�ô����ԭ��
function GIPSVoiceEngine_LastError():integer; cdecl; external 'GIPSVoiceEngine.dll';

implementation


end.




























































