unit trackunt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls;

type
  Ttrackfrm = class(TForm)
    TrackBar1: TTrackBar;
    CheckBox1: TCheckBox;
    procedure TrackBar1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure notfocuse(var Msg: TMessage); message WM_ACTIVATE;
    procedure focusenot(var Msg: TMessage); message WM_KILLFOCUS;
  private
    procedure setwaveaudio;
    procedure setwavemute;
    procedure getwaveaudio;
    procedure getwavemute;
    { Private declarations }
  public
    waveaudio:boolean;
    { Public declarations }
  end;

var
  trackfrm: Ttrackfrm;

implementation
uses funVolume,shareunit;

{$R *.DFM}

procedure Ttrackfrm.focusenot(var Msg: TMessage);
begin
inherited ;
close;
end;

procedure Ttrackfrm.notfocuse(var Msg: TMessage);
begin
inherited ;
if msg.WParam=WA_INACTIVE then close;
end;

procedure Ttrackfrm.setwaveaudio;
begin
if waveaudio then
 SetVolume(dnMaster,trackbar1.position)
 else SetVolume(Microphone,trackbar1.position);
end;

procedure Ttrackfrm.setwavemute;
begin
if waveaudio then
 SetVolumeMute(dnMaster,checkbox1.checked)
 else SetVolumeMute(Microphone,checkbox1.checked);
end;

procedure Ttrackfrm.getwavemute;
begin
if waveaudio then
  checkbox1.checked:=GetVolumeMute(dnMaster)
  else  checkbox1.checked:=GetVolumeMute(Microphone);
end;


procedure Ttrackfrm.getwaveaudio;
begin
if waveaudio then
  trackbar1.position:=GetVolume(dnMaster)
  else  trackbar1.position:=GetVolume(Microphone);
end;

procedure Ttrackfrm.TrackBar1Change(Sender: TObject);
begin
setwaveaudio;
end;

procedure Ttrackfrm.FormShow(Sender: TObject);
begin
getwaveaudio;
getwavemute;
end;

procedure Ttrackfrm.CheckBox1Click(Sender: TObject);
begin
setwavemute;
end;

end.
