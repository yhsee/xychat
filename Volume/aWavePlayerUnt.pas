unit aWavePlayerUnt;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, ExtCtrls,
  Graphics, Math, MMSystem,pngimage;

type
  TMPModes = (mpNotReady, mpStopped, mpPlaying, mpRecording, mpSeeking,
    mpPaused, mpOpen);

  TawBtnType = (btPlay, btStop, btMute, btTrack, btVol);
  TaWButton = record
    BtnType:TawBtnType;
    CurModel,X,Y,Max,Min,Position:Integer;
    Graphics: array of TObject;
  end;
  
  { Audio Volume Control }
  TAudioVolume = class(TCustomControl)
  constructor Create(AOwner: TComponent);override;
  destructor Destroy;override;
  private
    BackGround:TObject;
    TimeVolume:TTimer;
    FCurrentButton:Pointer;
    awMuteButtons,
    awVolumeButtons:TaWButton;

    FPressed:Boolean;
    procedure LoadGraphics;
    procedure DestroyGraphics;
    procedure InitialTimer;
    procedure FinitialTimer;
    //--------------------------------------------------------------------------
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LButtonDown;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LButtonDblClk;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MouseMove;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LButtonUp;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    //--------------------------------------------------------------------------
    function GetMouseInButton(XPos, YPos: Integer):Pointer;
    procedure DoMouseDown(XPos, YPos: Integer);
    procedure DoMouseMove(XPos, YPos: Integer);
    procedure DoMouseEnter(TmpButton:Pointer);
    procedure DoMouseLeave(TmpButton:Pointer);
    procedure DoMouseUp(XPos, YPos: Integer);
    procedure DoMoveButton(XPos, YPos: Integer);
    procedure GetVolumeInfor(Sender:TObject);
    procedure SetVolumeInfor;
    { Private declarations }
  protected
    procedure Paint; override;     
    procedure CreateParams(var params:TCreateParams);override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

  { Wave Player Control }
  EMCIDeviceError = class(Exception);
  TAWavePlayer = class(TCustomControl)
  constructor Create(AOwner: TComponent);override;
  destructor Destroy;override;
  private
    TimePlayer:TTimer;
    BackGround:TObject;
    FCurrentButton:Pointer;
    awPlayButtons,
    awStopButtons,
    awTrackBarButtons:TaWButton;
    //--------------------------------------------------------------------------
    FDeviceID: Word;
    FFlags,FError,
    aStart,aLength,aPosition: Longint;
    FPressed,FCanPlay,FRefresh,
    MCIOpened:Boolean;
    FElementName:String;
    FOnOverPlay,
    FOnStartPlay:TNotifyEvent;
    procedure InitialTimer;
    procedure FinitialTimer;
    procedure LoadGraphics;
    procedure DestroyGraphics;
    //--------------------------------------------------------------------------
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LButtonDown;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LButtonDblClk;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MouseMove;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LButtonUp;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    //--------------------------------------------------------------------------
    function GetMouseInButton(XPos, YPos: Integer):Pointer;
    procedure DoMouseDown(XPos, YPos: Integer);
    procedure DoMouseMove(XPos, YPos: Integer);
    procedure DoMouseEnter(TmpButton:Pointer);
    procedure DoMouseLeave(TmpButton:Pointer);
    procedure DoMouseUp(XPos, YPos: Integer);
    procedure DoMoveButton(XPos, YPos: Integer);
    procedure DoReTrackPosition(Sender:TObject);
    procedure DoChangeTrackPosition;
    procedure DoReadying;
    procedure DoPlaying;
    //--------------------------------------------------------------------------
    procedure GetDeviceCaps;
    function GetStart:Longint;
    function GetLength: Longint;
    function GetPosition: Longint;
    function GetMode: TMPModes;
    procedure SetPosition(Value: Longint);
    //--------------------------------------------------------------------------
    procedure Play(Const isPause:Boolean=False);
    procedure Pause;
    procedure Resume;
    //--------------------------------------------------------------------------
    { Private declarations }
  protected
    procedure Paint;override;
    procedure CreateParams(var params:TCreateParams);override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    { Protected declarations }
  public
    procedure Open;
    procedure AutoPlay;
    procedure Close;
    { Public declarations }
  published
    property FileName: string read FElementName write FElementName;
    property OnStartPlay:TNotifyEvent Read FOnStartPlay Write FOnStartPlay;
    property OnOverPlay:TNotifyEvent Read FOnOverPlay Write FOnOverPlay;
    { Published declarations }
  end;

procedure Register;

implementation

uses funVolume;

{$R aWave.res}

procedure Register;
begin
  RegisterComponents('Samples', [TAWavePlayer,TAudioVolume]);
end;

procedure DrawParentImage(Control: TControl; TmpBitmap:TBitmap);
var
  SaveIndex: Integer;
  DC: HDC;
  Position: TPoint;
begin
  with Control do
    begin
    if Parent = nil then Exit;
    //--------------------------------------------------------------------------
    TmpBitmap.Height := ClientRect.Bottom;
    TmpBitmap.Width := ClientRect.Right;
    //--------------------------------------------------------------------------
    DC := TmpBitmap.Canvas.Handle;
    SaveIndex := SaveDC(DC);
    GetViewportOrgEx(DC, Position);
    SetViewportOrgEx(DC, Position.X - Left, Position.Y - Top, nil);
    IntersectClipRect(DC, 0, 0, Parent.ClientWidth, Parent.ClientHeight);
    Parent.Perform(WM_ERASEBKGND, DC, 0);
    Parent.Perform(WM_PAINT, DC, 0);
    RestoreDC(DC, SaveIndex);
    //--------------------------------------------------------------------------
    end;
end;

{ Audio Volume Control }
constructor TAudioVolume.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 142; Height := 24;
  DoubleBuffered:=True;
  LoadGraphics;
  InitialTimer;
end;

destructor TAudioVolume.Destroy;
begin
  FinitialTimer;
  DestroyGraphics;
  inherited Destroy;
end;

procedure TAudioVolume.LoadGraphics;
begin
  BackGround:=TPngObject.Create;
  TPngObject(BackGround).LoadFromResourceName(hinstance,'aVPanel');
  //----------------------------------------------------------------------------
  SetLength(awMuteButtons.Graphics,4);
  awMuteButtons.BtnType:=btMute;
  awMuteButtons.CurModel:=0;
  awMuteButtons.X:=1;
  awMuteButtons.Y:=1;
  awMuteButtons.Graphics[0]:=TPngObject.Create;
  TPngObject(awMuteButtons.Graphics[0]).LoadFromResourceName(hinstance,'aMute');
  awMuteButtons.Graphics[1]:=TPngObject.Create;
  TPngObject(awMuteButtons.Graphics[1]).LoadFromResourceName(hinstance,'aMute');
  awMuteButtons.Graphics[2]:=TPngObject.Create;
  TPngObject(awMuteButtons.Graphics[2]).LoadFromResourceName(hinstance,'aDMute');
  awMuteButtons.Graphics[3]:=TPngObject.Create;
  TPngObject(awMuteButtons.Graphics[3]).LoadFromResourceName(hinstance,'aDMute');
  //----------------------------------------------------------------------------
  SetLength(awVolumeButtons.Graphics,4);
  awVolumeButtons.BtnType:=btVol;
  awVolumeButtons.CurModel:=0;
  awVolumeButtons.X:=40; //274
  awVolumeButtons.Y:=1;

  awVolumeButtons.Min:=40;
  awVolumeButtons.Max:=124;

  awVolumeButtons.Graphics[0]:=TPngObject.Create;
  TPngObject(awVolumeButtons.Graphics[0]).LoadFromResourceName(hinstance,'aTVol');
  awVolumeButtons.Graphics[1]:=TPngObject.Create;
  TPngObject(awVolumeButtons.Graphics[1]).LoadFromResourceName(hinstance,'aMTVol');
  awVolumeButtons.Graphics[2]:=TPngObject.Create;
  TPngObject(awVolumeButtons.Graphics[2]).LoadFromResourceName(hinstance,'aTVol');
  //----------------------------------------------------------------------------  
  awVolumeButtons.Graphics[3]:=TPngObject.Create;
  TPngObject(awVolumeButtons.Graphics[3]).LoadFromResourceName(hinstance,'aMVPanel');
  //----------------------------------------------------------------------------
end;

procedure TAudioVolume.DestroyGraphics;
var
  i:Integer;
begin
  for i:=0 to 3 do
    freeandnil(awMuteButtons.Graphics[i]);
  for i:=0 to 3 do
    freeandnil(awVolumeButtons.Graphics[i]);
  freeandnil(BackGround);
end;

procedure TAudioVolume.InitialTimer;
begin
  TimeVolume:=TTimer.Create(self);
  TimeVolume.Interval:=40;
  TimeVolume.OnTimer:=GetVolumeInfor;
  TimeVolume.Enabled:=True;
end;

procedure TAudioVolume.FinitialTimer;
begin
  TimeVolume.Enabled:=False;
  freeandnil(TimeVolume);
end;

procedure TAudioVolume.GetVolumeInfor(Sender:TObject);
var
  rLen,l,r:Integer;
begin
  if FPressed then exit;
  
  rLen:=awVolumeButtons.Max-awVolumeButtons.Min;
  l:=GetVolume(dnMaster)+1;
  r:=Round(rlen*l/65536)+awVolumeButtons.Min;
  r:=Min(r,awVolumeButtons.Max);
  awVolumeButtons.X:=r;

  if GetVolumeMute(dnMaster) then
    begin
    awMuteButtons.CurModel:=3;
    end else begin
    if awMuteButtons.CurModel=3 then
      awMuteButtons.CurModel:=0;
    end;
  Paint;
end;

procedure TAudioVolume.SetVolumeInfor;
var
  rlen,l,r:Integer;
begin
  rLen:=awVolumeButtons.Max-awVolumeButtons.Min;
  l:=awVolumeButtons.X-awVolumeButtons.Min;
  r:=Round(65536*l/rlen)+awVolumeButtons.Min-1;
  r:=Min(r,65535);
  SetVolume(dnMaster,r);
end;

procedure TAudioVolume.Paint;
var
  TrackBitmap,
  TmpBitmap:TBitmap;
begin
  if assigned(Parent) and Visible then
    try
    TmpBitmap:=TBitmap.Create;
    TrackBitmap:=TBitmap.Create;
    DrawParentImage(self,TmpBitmap);
    //----------------------------------------------------------------------------
    TPngObject(BackGround).Draw(TmpBitmap.Canvas,Rect(40,6,0,0));
    //----------------------------------------------------------------------------
    With awMuteButtons do
      TPngObject(Graphics[CurModel]).Draw(TmpBitmap.Canvas,Rect(x,y,0,0));

    TrackBitmap.Assign(TmpBitmap);

    With awVolumeButtons do
      TPngObject(Graphics[3]).Draw(TrackBitmap.Canvas,Rect(41,8,0,0));

    With awVolumeButtons do
      TmpBitmap.Canvas.CopyRect(Rect(41,8,x+7,15),TrackBitmap.Canvas,Rect(41,8,x+7,15));
    //----------------------------------------------------------------------------
    With awVolumeButtons do
      TPngObject(Graphics[CurModel]).Draw(TmpBitmap.Canvas,Rect(x,4,0,0));

    Self.Canvas.CopyRect(ClientRect, TmpBitmap.Canvas, ClientRect);
    finally
    freeandnil(TrackBitmap);
    freeandnil(TmpBitmap);
    end;
end;

function TAudioVolume.GetMouseInButton(XPos, YPos: Integer):Pointer;
begin
  Result:=nil;
  with awMuteButtons do
    begin
    if (XPos >= X) and (XPos <= X + TPngObject(Graphics[CurModel]).Width) then
    if (YPos >= Y) and (YPos <= Y + TPngObject(Graphics[CurModel]).Height) then
      Result:=@awMuteButtons;
    end;

  with awVolumeButtons do
    begin
    if (XPos >= X) and (XPos <= X + TPngObject(Graphics[CurModel]).Width) then
    if (YPos >= Y) and (YPos <= Y + TPngObject(Graphics[CurModel]).Height) then
      Result:=@awVolumeButtons;
    end;
end;

procedure TAudioVolume.DoMouseMove(XPos, YPos: Integer);
var
  TmpButton:Pointer;
begin
  if FPressed then DoMoveButton(XPos, YPos)
    else begin
    TmpButton:=GetMouseInButton(XPos,YPos);
    if Assigned(TmpButton) then
      begin
      if TmpButton<>FCurrentButton then
        DoMouseEnter(TmpButton);
      end else begin
      DoMouseLeave(FCurrentButton);
      end;
    end;
end;

procedure TAudioVolume.DoMoveButton(XPos, YPos: Integer);
var
  L:Integer;
begin
  if not Assigned(FCurrentButton) then exit;
  L:=XPos-TawButton(FCurrentButton^).Position;
  case TawButton(FCurrentButton^).BtnType of
    btVol:
      begin
      if (L>=TawButton(FCurrentButton^).Min)and
         (L<=TawButton(FCurrentButton^).Max) then
        begin
        TawButton(FCurrentButton^).X:=L;
        SetVolumeInfor;
        Paint;
        end;
      end;
    end;
end;

procedure TAudioVolume.DoMouseEnter(TmpButton:Pointer);
begin
  Cursor:=crHandPoint;
  if Assigned(TmpButton) then
    begin
    FCurrentButton:=TmpButton;
    case TawButton(TmpButton^).BtnType of
      btMute:
        begin
        if TawButton(TmpButton^).CurModel=0 then
          TawButton(TmpButton^).CurModel:=1;
        end;
        
      btVol:
        TawButton(TmpButton^).CurModel:=1;
      end;
    Paint;
    end;
end;

procedure TAudioVolume.DoMouseLeave(TmpButton:Pointer);
begin
  Cursor:=crDefault;
  if Assigned(FCurrentButton) then FCurrentButton:=nil;
  if awMuteButtons.CurModel=1 then awMuteButtons.CurModel:=0;
  if awVolumeButtons.CurModel=1 then awVolumeButtons.CurModel:=0;
  Paint;
end;

procedure TAudioVolume.DoMouseDown(XPos, YPos: Integer);
begin
  FCurrentButton:=GetMouseInButton(XPos,YPos);
  if Assigned(FCurrentButton) then
    begin
    case TawButton(FCurrentButton^).BtnType of
      btMute:
        begin
        if TawButton(FCurrentButton^).CurModel=1 then
          TawButton(FCurrentButton^).CurModel:=2
          else TawButton(FCurrentButton^).CurModel:=3;
        end;
        
      btVol:
        begin
        TawButton(FCurrentButton^).Position:=XPos-TawButton(FCurrentButton^).X;
        TawButton(FCurrentButton^).CurModel:=0;
        end;
      end;
    FPressed := True;
    MouseCapture := True;
    Paint;
    end;
end;

procedure TAudioVolume.DoMouseUp(XPos, YPos: Integer);
var
  TmpButton:Pointer;
begin
  TmpButton:=GetMouseInButton(XPos,YPos);
  if assigned(FCurrentButton) then
    begin
    case TawButton(FCurrentButton^).BtnType of
      btMute:
        begin
        if TawButton(FCurrentButton^).CurModel=2 then
          begin
          TawButton(FCurrentButton^).CurModel:=3;
          SetVolumeMute(dnMaster,True);
          end else begin
          SetVolumeMute(dnMaster,False);
          if Assigned(TmpButton) then
            TawButton(FCurrentButton^).CurModel:=1
            else TawButton(FCurrentButton^).CurModel:=0;
          end;
        FCurrentButton:=TmpButton;
        end;
        
      btVol:
        begin
        if Assigned(TmpButton) then
          TawButton(FCurrentButton^).CurModel:=1
          else TawButton(FCurrentButton^).CurModel:=0;
        FCurrentButton:=TmpButton;
        end;
      end;
    Paint;
    end;
  MouseCapture := False;
  FPressed := False;
end;


procedure TAudioVolume.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
end;

procedure TAudioVolume.CreateParams(var params:TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    begin
    //完全重画
    Style := Style and not WS_CLIPCHILDREN;
    Style := Style and not WS_CLIPSIBLINGS;
    // 增加透明
    ExStyle := ExStyle or WS_EX_TRANSPARENT;
    end;
end;

procedure TAudioVolume.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  DoMouseDown(Message.XPos, Message.YPos);
end;

procedure TAudioVolume.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  inherited;
  DoMouseDown(Message.XPos, Message.YPos);
end;

procedure TAudioVolume.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  DoMouseMove(Message.XPos, Message.YPos);
end;

procedure TAudioVolume.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  DoMouseUp(Message.XPos, Message.YPos);
end;

procedure TAudioVolume.WMSetFocus(var Message: TWMSetFocus);
begin
  Paint;
end;

procedure TAudioVolume.WMKillFocus(var Message: TWMKillFocus);
begin
  Paint;
end;

procedure TAudioVolume.CMMouseEnter(var Message: TMessage);
begin
  inherited;
end;

procedure TAudioVolume.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  DoMouseLeave(FCurrentButton);
end;

procedure TAudioVolume.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS;
end;

procedure TAudioVolume.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
begin
  Msg.Result:=1;
end;

{ Wave Player Control }
constructor TAWavePlayer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 288; Height := 26;
  DoubleBuffered:=True;
  LoadGraphics;
  InitialTimer;
end;

destructor TAWavePlayer.Destroy;
begin
  Close;
  FinitialTimer;
  DestroyGraphics;
  inherited Destroy;
end;

procedure TAWavePlayer.InitialTimer;
begin
  TimePlayer:=TTimer.Create(self);
  TimePlayer.Interval:=40;
  TimePlayer.OnTimer:=DoReTrackPosition;
  TimePlayer.Enabled:=True;
end;

procedure TAWavePlayer.FinitialTimer;
begin
  TimePlayer.Enabled:=False;
  freeandnil(TimePlayer);
end;

procedure TAWavePlayer.LoadGraphics;
begin
  BackGround:=TPngObject.Create;
  TPngObject(BackGround).LoadFromResourceName(hinstance,'aPanel');
  //----------------------------------------------------------------------------
  SetLength(awPlayButtons.Graphics,6);
  awPlayButtons.BtnType:=btPlay;
  awPlayButtons.CurModel:=0;
  awPlayButtons.X:=1;
  awPlayButtons.Y:=1;
  awPlayButtons.Graphics[0]:=TPngObject.Create;
  TPngObject(awPlayButtons.Graphics[0]).LoadFromResourceName(hinstance,'aPlay');
  awPlayButtons.Graphics[1]:=TPngObject.Create;
  TPngObject(awPlayButtons.Graphics[1]).LoadFromResourceName(hinstance,'aMPlay');
  awPlayButtons.Graphics[2]:=TPngObject.Create;
  TPngObject(awPlayButtons.Graphics[2]).LoadFromResourceName(hinstance,'aDPlay');
  awPlayButtons.Graphics[3]:=TPngObject.Create;
  TPngObject(awPlayButtons.Graphics[3]).LoadFromResourceName(hinstance,'aPause');
  awPlayButtons.Graphics[4]:=TPngObject.Create;
  TPngObject(awPlayButtons.Graphics[4]).LoadFromResourceName(hinstance,'aMPause');
  awPlayButtons.Graphics[5]:=TPngObject.Create;
  TPngObject(awPlayButtons.Graphics[5]).LoadFromResourceName(hinstance,'aDPause');
  //----------------------------------------------------------------------------
  SetLength(awStopButtons.Graphics,4);
  awStopButtons.BtnType:=btStop;
  awStopButtons.CurModel:=3;
  awStopButtons.X:=35;
  awStopButtons.Y:=1;
  awStopButtons.Graphics[0]:=TPngObject.Create;
  TPngObject(awStopButtons.Graphics[0]).LoadFromResourceName(hinstance,'aStop');
  awStopButtons.Graphics[1]:=TPngObject.Create;
  TPngObject(awStopButtons.Graphics[1]).LoadFromResourceName(hinstance,'aMStop');
  awStopButtons.Graphics[2]:=TPngObject.Create;
  TPngObject(awStopButtons.Graphics[2]).LoadFromResourceName(hinstance,'aDStop');
  awStopButtons.Graphics[3]:=TPngObject.Create;
  TPngObject(awStopButtons.Graphics[3]).LoadFromResourceName(hinstance,'aStop');
  //----------------------------------------------------------------------------
  SetLength(awTrackBarButtons.Graphics,4);
  awTrackBarButtons.BtnType:=btTrack;
  awTrackBarButtons.CurModel:=2;
  awTrackBarButtons.X:=76;
  awTrackBarButtons.Y:=8;

  awTrackBarButtons.Min:=76;
  awTrackBarButtons.Max:=272;

  awTrackBarButtons.Graphics[0]:=TPngObject.Create;
  TPngObject(awTrackBarButtons.Graphics[0]).LoadFromResourceName(hinstance,'aTPos');
  awTrackBarButtons.Graphics[1]:=TPngObject.Create;
  TPngObject(awTrackBarButtons.Graphics[1]).LoadFromResourceName(hinstance,'aMTPos');
  awTrackBarButtons.Graphics[2]:=TPngObject.Create;
  TPngObject(awTrackBarButtons.Graphics[2]).LoadFromResourceName(hinstance,'aTPos');
  //----------------------------------------------------------------------------
  awTrackBarButtons.Graphics[3]:=TPngObject.Create;
  TPngObject(awTrackBarButtons.Graphics[3]).LoadFromResourceName(hinstance,'aMPanel');
  //----------------------------------------------------------------------------
end;

procedure TAWavePlayer.DestroyGraphics;
var
  i:Integer;
begin
  if assigned(BackGround) then freeandnil(BackGround);
  for i:=0 to 5 do
    freeandnil(awPlayButtons.Graphics[i]);
  for i:=0 to 3 do
    freeandnil(awStopButtons.Graphics[i]);
  for i:=0 to 3 do
    freeandnil(awTrackBarButtons.Graphics[i]);
end;

procedure TAWavePlayer.Paint;
var
  TrackBitmap,
  TmpBitmap:TBitmap;
begin
  if assigned(Parent) and Visible then
    try
    TmpBitmap:=TBitmap.Create;
    TrackBitmap:=TBitmap.Create;
    DrawParentImage(self,TmpBitmap);
    //----------------------------------------------------------------------------
    TPngObject(BackGround).Draw(TmpBitmap.Canvas,Rect(75,8,0,0));
    //----------------------------------------------------------------------------
    with awPlayButtons do
      TPngObject(Graphics[CurModel]).Draw(TmpBitmap.Canvas,Rect(x,y,0,0));
    //----------------------------------------------------------------------------
    with awStopButtons do
      TPngObject(Graphics[CurModel]).Draw(TmpBitmap.Canvas,Rect(x,y,0,0));
    //----------------------------------------------------------------------------
    TrackBitmap.Assign(TmpBitmap);

    With awTrackBarButtons do
      TPngObject(Graphics[3]).Draw(TrackBitmap.Canvas,Rect(76,11,0,0));
      
    With awTrackBarButtons do
    TmpBitmap.Canvas.CopyRect(Rect(76,11,x+7,18),TrackBitmap.Canvas,Rect(76,11,x+7,18));
    //----------------------------------------------------------------------------
    With awTrackBarButtons do
      TPngObject(Graphics[CurModel]).Draw(TmpBitmap.Canvas,Rect(x,8,0,0));

    Self.Canvas.CopyRect(ClientRect, TmpBitmap.Canvas, ClientRect);
    finally
    freeandnil(TrackBitmap);
    freeandnil(TmpBitmap);
    end;
end;

procedure TAWavePlayer.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
end;

procedure TAWavePlayer.DoPlaying;
begin
  awPlayButtons.CurModel:=3;
  awStopButtons.CurModel:=0;
  DoMouseLeave(FCurrentButton);
end;

procedure TAWavePlayer.DoReadying;
begin
  awPlayButtons.CurModel:=0;
  awStopButtons.CurModel:=3;
  awTrackBarButtons.X:=awTrackBarButtons.Min;
  DoMouseLeave(FCurrentButton);
end;

procedure TAWavePlayer.DoReTrackPosition;
var
  rLen,l:Integer;
begin

  if FPressed then exit;

  if MCIOpened then
    begin
    if GetMode = mpStopped then Close;
    if GetMode = mpPlaying then
      begin
      aPosition:=GetPosition;
      rLen:=awTrackBarButtons.Max-awTrackBarButtons.Min;
      l:=awTrackBarButtons.Min+Round(rLen*aPosition/aLength);
      l:=Min(l,awTrackBarButtons.Max);
      awTrackBarButtons.X:=l;
      FRefresh:=True;
      end;
    end;
  if FRefresh then Paint;
end;

procedure TAWavePlayer.DoChangeTrackPosition;
var
  rLen,l,n:Integer;
begin
  if MCIOpened and (GetMode in [mpPlaying,mpPaused]) then
    begin
    rLen:=awTrackBarButtons.Max-awTrackBarButtons.Min;
    n:=awTrackBarButtons.X-awTrackBarButtons.Min;
    l:=aStart+Trunc(aLength*n/rLen);
    l:=Min(l,aLength+aStart);
    if GetMode in [mpPlaying] then Pause;
    SetPosition(l);
    Resume;
    DoPlaying;
    end;
end;

procedure TAWavePlayer.DoMouseEnter(TmpButton:Pointer);
begin
  Cursor:=crHandPoint;
  if Assigned(TmpButton) then
    begin
    FCurrentButton:=TmpButton;
    case TawButton(TmpButton^).BtnType of
      btPlay:
        begin
        if TawButton(TmpButton^).CurModel=0 then
          TawButton(TmpButton^).CurModel:=1;
        if TawButton(TmpButton^).CurModel=3 then
          TawButton(TmpButton^).CurModel:=4;
        end;

      btStop:
        TawButton(TmpButton^).CurModel:=1;

      end;
    Paint;
    end;
end;

procedure TAWavePlayer.DoMouseLeave(TmpButton:Pointer);
begin
  Cursor:=crDefault;
  if Assigned(FCurrentButton) then FCurrentButton:=nil;
  if awPlayButtons.CurModel=1 then awPlayButtons.CurModel:=0;
  if awPlayButtons.CurModel=4 then awPlayButtons.CurModel:=3;
  if awStopButtons.CurModel=1 then awStopButtons.CurModel:=0;
  if awTrackBarButtons.CurModel=1 then awTrackBarButtons.CurModel:=0;
  Paint;
end;

function TAWavePlayer.GetMouseInButton(XPos, YPos: Integer):Pointer;
begin
  Result:=nil;
  with awPlayButtons do
    begin
    if (XPos >= X) and (XPos <= X + TPngObject(Graphics[CurModel]).Width) then
    if (YPos >= Y) and (YPos <= Y + TPngObject(Graphics[CurModel]).Height) then
      Result:=@awPlayButtons;
    end;

  with awStopButtons do
    begin
    if (XPos >= X) and (XPos <= X + TPngObject(Graphics[CurModel]).Width) then
    if (YPos >= Y) and (YPos <= Y + TPngObject(Graphics[CurModel]).Height) then
    if CurModel<>3 then
      Result:=@awStopButtons;
    end;

  with awTrackBarButtons do
    begin
    if (XPos >= X) and (XPos <= X + TPngObject(Graphics[CurModel]).Width) then
    if (YPos >= Y) and (YPos <= Y + TPngObject(Graphics[CurModel]).Height) then
      Result:=@awTrackBarButtons;
    end;
end;

procedure TAWavePlayer.DoMouseMove(XPos, YPos: Integer);
var
  TmpButton:Pointer;
begin
  if FPressed then DoMoveButton(XPos, YPos)
    else begin
    TmpButton:=GetMouseInButton(XPos, YPos);
    if Assigned(TmpButton) then
      begin
      if TmpButton<>FCurrentButton then
        DoMouseEnter(TmpButton);
      end else begin
      DoMouseLeave(FCurrentButton);
      end;
    end;
end;

procedure TAWavePlayer.DoMoveButton(XPos, YPos: Integer);
var
  L:Integer;
begin
  if not Assigned(FCurrentButton) then exit;
  L:=XPos-TawButton(FCurrentButton^).Position;
  case TawButton(FCurrentButton^).BtnType of
    btTrack:
      begin
      if MCIOpened then
      if (L>=TawButton(FCurrentButton^).Min)and
         (L<=TawButton(FCurrentButton^).Max) then
        begin
        TawButton(FCurrentButton^).X:=L;
        Paint;
        end;
      end;
    end;
end;

procedure TAWavePlayer.DoMouseDown(XPos, YPos: Integer);
begin
  FCurrentButton:=GetMouseInButton(XPos, YPos);
  if Assigned(FCurrentButton) then
    begin
    case TawButton(FCurrentButton^).BtnType of
      btPlay:
        begin
        if TawButton(FCurrentButton^).CurModel=1 then
          TawButton(FCurrentButton^).CurModel:=2
          else TawButton(FCurrentButton^).CurModel:=5;
        end;
      btStop:
        TawButton(FCurrentButton^).CurModel:=2;

      btTrack:
        begin
        TawButton(FCurrentButton^).Position:=XPos-TawButton(FCurrentButton^).X;
        TawButton(FCurrentButton^).CurModel:=0;
        end;
      end;
    FPressed := True;
    MouseCapture := True;
    Paint;
    end;
end;

procedure TAWavePlayer.DoMouseUp(XPos, YPos: Integer);
var
  TmpButton:Pointer;
begin
  TmpButton:=GetMouseInButton(XPos, YPos);
  if assigned(TmpButton) then
    begin
    case TawButton(TmpButton^).BtnType of
      btPlay:
        begin
        if awPlayButtons.CurModel=2 then
          begin
          if Assigned(TmpButton) then
            awPlayButtons.CurModel:=4
            else awPlayButtons.CurModel:=3;
          awStopButtons.CurModel:=0;
          if GetMode=mpPaused then Resume else Play;
          end else begin
          if Assigned(TmpButton) then
            awPlayButtons.CurModel:=1
            else awPlayButtons.CurModel:=0;
          awStopButtons.CurModel:=3;
          Pause;
          end;
        FCurrentButton:=TmpButton;
        end;
        
      btStop:
        begin
        awPlayButtons.CurModel:=0;
        awStopButtons.CurModel:=3;
        FCurrentButton:=nil;
        Close;
        end;

      btTrack:
        begin
        if Assigned(TmpButton) then
          TawButton(FCurrentButton^).CurModel:=1
          else TawButton(FCurrentButton^).CurModel:=0;
        DoChangeTrackPosition;
        FCurrentButton:=TmpButton;
        end;
      end;
    Paint;
    end;
  MouseCapture := False;
  FPressed := False;
end;

procedure TAWavePlayer.CreateParams(var params:TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    begin
    //完全重画
    Style := Style and not WS_CLIPCHILDREN;
    Style := Style and not WS_CLIPSIBLINGS;
    // 增加透明
    ExStyle := ExStyle or WS_EX_TRANSPARENT;
    end;
end;

procedure TAWavePlayer.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  DoMouseDown(Message.XPos, Message.YPos);
end;

procedure TAWavePlayer.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  inherited;
  DoMouseDown(Message.XPos, Message.YPos);
end;

procedure TAWavePlayer.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  DoMouseMove(Message.XPos, Message.YPos);
end;

procedure TAWavePlayer.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  DoMouseUp(Message.XPos, Message.YPos);
end;

procedure TAWavePlayer.WMSetFocus(var Message: TWMSetFocus);
begin
  Paint;
end;

procedure TAWavePlayer.WMKillFocus(var Message: TWMKillFocus);
begin
  Paint;
end;

procedure TAWavePlayer.CMMouseEnter(var Message: TMessage);
begin
  inherited;
end;

procedure TAWavePlayer.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  DoMouseLeave(FCurrentButton);
end;

procedure TAWavePlayer.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS;
end;

procedure TAWavePlayer.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
begin
  Msg.Result:=1;
end;

procedure TAWavePlayer.AutoPlay;
begin
  Play;
end;
{ ********* MCI  Control ********* }
//------------------------------------------------------------------------------
procedure TAWavePlayer.Open;
var
  OpenParm: TMCI_Open_Parms;
begin
  { zero out memory }
  FillChar(OpenParm, SizeOf(TMCI_Open_Parms), 0);
  if MCIOpened then Close;

  if not fileexists(FElementName) then exit;

  OpenParm.dwCallback := 0;
  OpenParm.lpstrDeviceType := '';
  OpenParm.lpstrElementName := PChar(FElementName);

  FFlags := 0;
  FFlags := FFlags or mci_Wait or mci_Notify or MCI_OPEN_ELEMENT;

  OpenParm.dwCallback := Handle;

  FError := mciSendCommand(0, mci_Open, FFlags, Longint(@OpenParm));

  if FError = 0 then {device successfully opened}
  begin
    MCIOpened := True;
    FDeviceID := OpenParm.wDeviceID;
    GetDeviceCaps; {must first get device capabilities}
  end;
end;

procedure TAWavePlayer.Play(Const isPause:Boolean=False);
var
  PlayParm: TMCI_Play_Parms;
begin
  if Not isPause then 
  if assigned(FOnStartPlay) then FOnStartPlay(Self);
  if MCIOpened then
    begin
    FFlags := 0;
    FFlags := FFlags or mci_Notify;
    PlayParm.dwCallback := Handle;
    PlayParm.dwFrom:=6000; 
    FError := mciSendCommand( FDeviceID, mci_Play, FFlags, Longint(@PlayParm));
    end else DoReadying;
end;

procedure TAWavePlayer.Pause;
var
  GenParm: TMCI_Generic_Parms;
begin
  if MCIOpened then
    begin
    FFlags := 0;
    FFlags := FFlags or mci_Wait or mci_Notify;
    GenParm.dwCallback := Handle;
    FError := mciSendCommand( FDeviceID, mci_Pause, FFlags, Longint(@GenParm));
    end;
end;

procedure TAWavePlayer.Resume;
var
  GenParm: TMCI_Generic_Parms;
begin
  if MCIOpened then
    begin
    FFlags := 0;
    FFlags := FFlags or mci_Wait or mci_Notify;
    GenParm.dwCallback := Handle;
    FError := mciSendCommand( FDeviceID, mci_Resume, FFlags, Longint(@GenParm));
    {if error calling resume (resume not supported),  call Play}
    if FError <> 0 then Play(True); {FUseNotify & FUseWait reset by Play}
    end;
end;

procedure TAWavePlayer.Close;
var
  GenParm: TMCI_Generic_Parms;
begin
  if FDeviceID <> 0 then
  begin
    FFlags := 0;
    FFlags := FFlags or mci_Wait or mci_Notify;
    GenParm.dwCallback := Handle;
    FError := mciSendCommand( FDeviceID, mci_Close, FFlags, Longint(@GenParm));
    if FError = 0 then
    begin
      MCIOpened := False;
      FDeviceID := 0;
      DoReadying;
      if assigned(FOnOverPlay) then FOnOverPlay(Self);
    end;
  end; 
end;

{ fills in static properties upon opening MCI Device }
procedure TAWavePlayer.GetDeviceCaps;
var
  DevCapParm: TMCI_GetDevCaps_Parms;
begin
  FFlags := mci_Wait or mci_GetDevCaps_Item;
  DevCapParm.dwItem := mci_GetDevCaps_Can_Play;
  mciSendCommand(FDeviceID, mci_GetDevCaps, FFlags,  Longint(@DevCapParm) );
  FCanPlay := Boolean(DevCapParm.dwReturn);
  aStart:=GetStart;
  aLength:=GetLength;
end; {GetDeviceCaps}

function TAWavePlayer.GetStart: Longint;
var
  StatusParm: TMCI_Status_Parms;
begin
  Result:=-1;
  if MCIOpened then
    begin
    FFlags := mci_Wait or mci_Status_Item or mci_Status_Start;
    StatusParm.dwItem := mci_Status_Position;
    FError := mciSendCommand( FDeviceID, mci_Status, FFlags, Longint(@StatusParm));
    Result := StatusParm.dwReturn;
    end;
end;

function TAWavePlayer.GetLength: Longint;
var
  StatusParm: TMCI_Status_Parms;
begin
  Result:=-1;
  if MCIOpened then
    begin
    FFlags := mci_Wait or mci_Status_Item;
    StatusParm.dwItem := mci_Status_Length;
    FError := mciSendCommand( FDeviceID, mci_Status, FFlags, Longint(@StatusParm));
    Result := StatusParm.dwReturn;
    end;
end;

function TAWavePlayer.GetPosition: Longint;
var
  StatusParm: TMCI_Status_Parms;
begin
  Result:=-1;
  if MCIOpened then
    begin
    FFlags := mci_Wait or mci_Status_Item;
    StatusParm.dwItem := mci_Status_Position;
    FError := mciSendCommand( FDeviceID, mci_Status, FFlags, Longint(@StatusParm));
    Result := StatusParm.dwReturn;
    end;
end;

function TAWavePlayer.GetMode: TMPModes;
var
  StatusParm: TMCI_Status_Parms;
begin
  Result:=mpNotReady;
  if MCIOpened then
    begin
    FFlags := mci_Wait or mci_Status_Item;
    StatusParm.dwItem := mci_Status_Mode;
    FError := mciSendCommand( FDeviceID, mci_Status, FFlags, Longint(@StatusParm));
    Result := TMPModes(StatusParm.dwReturn - 524); {MCI Mode #s are 524+enum}
    end;
end;

procedure TAWavePlayer.SetPosition(Value: Longint);
var
  SeekParm: TMCI_Seek_Parms;
begin
  if MCIOpened then
    begin
    FFlags :=0;
    FFlags := FFlags or mci_Wait or mci_To or mci_Notify;
    SeekParm.dwCallback := Handle;
    SeekParm.dwTo :=Value;
    FError := mciSendCommand( FDeviceID, mci_Seek,FFlags, Longint(@SeekParm));
    end;
end;

end.
