unit funVolume;

interface 

uses MMSystem, Dialogs, windows; 

Type TDeviceName = (dnMaster, Microphone, WaveOut, Synth, linein);

function  GetVolume(DN:TDeviceName) : DWord ;
procedure SetVolume(DN:TDeviceName; Value:Word);
function  GetVolumeMute(DN:TDeviceName) : Boolean; 
procedure SetVolumeMute(DN:TDeviceName; Value:Boolean);

implementation 

//获取音量 
function GetVolume(DN:TDeviceName) : DWord; 
var
 hMix: HMIXER;
 mxlc: MIXERLINECONTROLS;
 mxcd: TMIXERCONTROLDETAILS;
 vol: TMIXERCONTROLDETAILS_UNSIGNED;
 mxc: MIXERCONTROL;
 mxl: TMixerLine;
 nMixerDevs: Integer;
begin
 Result:=0;
 // Check if Mixer is available
 nMixerDevs := mixerGetNumDevs(); 
 if (nMixerDevs < 1) then Exit;


 // open the mixer
 if mixerOpen(@hMix, 0, 0, 0, 0) = MMSYSERR_NOERROR then
 begin 
   case DN of 
     dnMaster :  mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_DST_SPEAKERS; 
     Microphone : mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE; 
     WaveOut : mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_WAVEOUT;
     Synth  :  mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_SYNTHESIZER;
     linein :  mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_LINE;
   end;
   mxl.cbStruct := SizeOf(mxl);

   // get line info

   if mixerGetLineInfo(hMix, @mxl, MIXER_GETLINEINFOF_COMPONENTTYPE) = MMSYSERR_NOERROR then
   begin 
     FillChar(mxlc, SizeOf(mxlc),0); 
     mxlc.cbStruct := SizeOf(mxlc); 
     mxlc.dwLineID := mxl.dwLineID; 
     mxlc.dwControlType := MIXERCONTROL_CONTROLTYPE_VOLUME;
     mxlc.cControls := 1; 
     mxlc.cbmxctrl := SizeOf(mxc); 

     mxlc.pamxctrl := @mxc;

     if mixerGetLineControls(hMix, @mxlc, MIXER_GETLINECONTROLSF_ONEBYTYPE) = MMSYSERR_NOERROR then
     begin 
       FillChar(mxcd, SizeOf(mxcd),0); 
       mxcd.dwControlID := mxc.dwControlID;
       mxcd.cbStruct := SizeOf(mxcd); 
       mxcd.cMultipleItems := 0; 
       mxcd.cbDetails := SizeOf(Vol);
       mxcd.paDetails := @vol;
       mxcd.cChannels := 1; 


       if mixerGetControlDetails(hMix, @mxcd,MIXER_SETCONTROLDETAILSF_VALUE)=MMSYSERR_NOERROR then
          Result := vol.dwValue ;

     end;
   end; 
   mixerClose(hMix);
 end; 
end;

//设置音量
procedure SetVolume(DN:TDeviceName; Value : Word);
var
 hMix: HMIXER;
 mxlc: MIXERLINECONTROLS;
 mxcd: TMIXERCONTROLDETAILS;
 vol: TMIXERCONTROLDETAILS_UNSIGNED;
 mxc: MIXERCONTROL;
 mxl: TMixerLine;

 nMixerDevs: Integer; 
begin 
 // Check if Mixer is available 
 nMixerDevs := mixerGetNumDevs(); 
 if (nMixerDevs < 1) then  Exit;


 // open the mixer

 if mixerOpen(@hMix, 0, 0, 0, 0) = MMSYSERR_NOERROR then
 begin 
   case DN of 
     dnMaster :  mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_DST_SPEAKERS; 
     Microphone : mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE;
     WaveOut : mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_WAVEOUT; 
     Synth  :  mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_SYNTHESIZER;
     linein :  mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_LINE;
   end; 
   mxl.cbStruct := SizeOf(mxl); 

   // get line info


   if mixerGetLineInfo(hMix, @mxl, MIXER_GETLINEINFOF_COMPONENTTYPE) = MMSYSERR_NOERROR then
   begin 
     FillChar(mxlc, SizeOf(mxlc),0); 
     mxlc.cbStruct := SizeOf(mxlc); 
     mxlc.dwLineID := mxl.dwLineID; 
     mxlc.dwControlType := MIXERCONTROL_CONTROLTYPE_VOLUME; 
     mxlc.cControls := 1; 
     mxlc.cbmxctrl := SizeOf(mxc); 

     mxlc.pamxctrl := @mxc;


     if mixerGetLineControls(hMix, @mxlc, MIXER_GETLINECONTROLSF_ONEBYTYPE) = MMSYSERR_NOERROR then
     begin 
       FillChar(mxcd, SizeOf(mxcd),0); 
       mxcd.dwControlID := mxc.dwControlID; 
       mxcd.cbStruct := SizeOf(mxcd); 
       mxcd.cMultipleItems := 0; 
       mxcd.cbDetails := SizeOf(Vol); 
       mxcd.paDetails := @vol; 
       mxcd.cChannels := 1; 

       vol.dwValue := Value; 

       mixerSetControlDetails(hMix, @mxcd,MIXER_SETCONTROLDETAILSF_VALUE);

     end;
   end; 
   mixerClose(hMix);
 end; 
end; 

//获取静音 
function  GetVolumeMute(DN:TDeviceName) : Boolean; 
var 
 hMix: HMIXER; 
 mxlc: MIXERLINECONTROLS; 
 mxcd: TMIXERCONTROLDETAILS;
 mxc: MIXERCONTROL; 
 mxl: TMixerLine;
 nMixerDevs: Integer; 
 mcdMute: MIXERCONTROLDETAILS_BOOLEAN; 
begin
 result:=false;
 // Check if Mixer is available 
 nMixerDevs := mixerGetNumDevs(); 
 if (nMixerDevs < 1) then Exit;


 // open the mixer 

 if mixerOpen(@hMix, 0, 0, 0, 0) = MMSYSERR_NOERROR then
 begin 
   case DN of 
     dnMaster :  mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_DST_SPEAKERS; 
     Microphone : mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE;
     WaveOut : mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_WAVEOUT; 
     Synth  :  mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_SYNTHESIZER;
     linein :  mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_LINE;
   end; 
    mxl.cbStruct        := SizeOf(mxl); 

   // mixerline info

   if mixerGetLineInfo(hMix, @mxl, MIXER_GETLINEINFOF_COMPONENTTYPE) = MMSYSERR_NOERROR then
   begin 
     FillChar(mxlc, SizeOf(mxlc),0); 
     mxlc.cbStruct := SizeOf(mxlc); 
     mxlc.dwLineID := mxl.dwLineID; 
     mxlc.dwControlType := MIXERCONTROL_CONTROLTYPE_MUTE; 
     mxlc.cControls := 1; 
     mxlc.cbmxctrl := SizeOf(mxc); 
     mxlc.pamxctrl := @mxc; 

     // Get the mute control


     if mixerGetLineControls(hMix, @mxlc, MIXER_GETLINECONTROLSF_ONEBYTYPE) = MMSYSERR_NOERROR then
     begin 
       FillChar(mxcd, SizeOf(mxcd),0); 
       mxcd.cbStruct := SizeOf(TMIXERCONTROLDETAILS); 
       mxcd.dwControlID := mxc.dwControlID; 
       mxcd.cChannels := 1; 
       mxcd.cbDetails := SizeOf(MIXERCONTROLDETAILS_BOOLEAN); 
       mxcd.paDetails := @mcdMute; 

       // Get  mute

       if mixerGetControlDetails(hMix, @mxcd, MIXER_SETCONTROLDETAILSF_VALUE)=MMSYSERR_NOERROR then
          begin
          if mcdMute.fValue = 0 then
              Result:=false
            else Result := True;
          end;

     end;
   end; 
   mixerClose(hMix);
 end; 
end; 

//设置静音 
procedure SetVolumeMute(DN:TDeviceName; Value:Boolean); 
var 
 hMix: HMIXER; 
 mxlc: MIXERLINECONTROLS; 
 mxcd: TMIXERCONTROLDETAILS;
 mxc: MIXERCONTROL; 
 mxl: TMixerLine;
 nMixerDevs: Integer; 
 mcdMute: MIXERCONTROLDETAILS_BOOLEAN; 
begin 
 // Check if Mixer is available 
 nMixerDevs := mixerGetNumDevs(); 
 if (nMixerDevs < 1) then Exit;

 // open the mixer

 if mixerOpen(@hMix, 0, 0, 0, 0) = MMSYSERR_NOERROR then
 begin 
   case DN of 
     dnMaster :  mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_DST_SPEAKERS; 
     Microphone : mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE;
     WaveOut : mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_WAVEOUT; 
     Synth  :  mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_SYNTHESIZER;
     linein :  mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_LINE;
   end; 
    mxl.cbStruct        := SizeOf(mxl); 

   // mixerline info

   if mixerGetLineInfo(hMix, @mxl, MIXER_GETLINEINFOF_COMPONENTTYPE) = MMSYSERR_NOERROR then
   begin 
     FillChar(mxlc, SizeOf(mxlc),0); 
     mxlc.cbStruct := SizeOf(mxlc); 
     mxlc.dwLineID := mxl.dwLineID; 
     mxlc.dwControlType := MIXERCONTROL_CONTROLTYPE_MUTE; 
     mxlc.cControls := 1; 
     mxlc.cbmxctrl := SizeOf(mxc); 
     mxlc.pamxctrl := @mxc; 

     // Get the mute control

     if mixerGetLineControls(hMix, @mxlc, MIXER_GETLINECONTROLSF_ONEBYTYPE) = MMSYSERR_NOERROR then
     begin 
       FillChar(mxcd, SizeOf(mxcd),0); 
       mxcd.cbStruct := SizeOf(TMIXERCONTROLDETAILS); 
       mxcd.dwControlID := mxc.dwControlID; 
       mxcd.cChannels := 1; 
       mxcd.cbDetails := SizeOf(MIXERCONTROLDETAILS_BOOLEAN); 
       mxcd.paDetails := @mcdMute; 

       // Set and UnSet  mute 
       mcdMute.fValue := Ord(Value); 
       mixerSetControlDetails(hMix, @mxcd, MIXER_SETCONTROLDETAILSF_VALUE);
     end;
   end; 

  mixerClose(hMix);
 end; 
end;

end.