unit AutoShrinkForm;

interface

uses
  Classes, Controls, ExtCtrls, Forms, Windows, Messages, SysUtils;

type
  TDockPos = (dpNone, dpTop, dpLeft, dpRight);
  TDockEvent = procedure (const nDockPos: TDockPos) of Object;

  TAutoShrinkForm = class(TComponent)
  private
    { Private declarations }
    FWnd: Hwnd;
    FIdle: Cardinal;

    FIsHide: Boolean;
    FDockPos: TDockPos;
    FAlwaysTop: boolean;

    FAutoDock: boolean;
    FEdgeSpace: integer;
    FValidSpace: integer;

    FMainForm: TForm;
    FFormRect: TRect;
    FFormProc: TWndMethod;

    FDockEvent: TDockEvent;
    FHideEvent: TDockEvent;
    FShowEvent: TDockEvent;
  protected
    { Protected declarations }
    function FindMainForm: TForm;
    procedure WndProc(var nMsg: TMessage);

    procedure SetFormShow;
    procedure SetFormHide;
    function IsMouseLeave: boolean;

    procedure CaptureMsg(var Message: TMessage);
    procedure DockFormToEdge(const nRect: PRect);

    procedure SetAutoDock(const nValue: boolean);
    procedure SetAlwaysTop(const nValue: boolean);
    
    procedure SetEdgeSpace(const nSpace: integer);
    procedure SetValidSpace(const nSpace: integer);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
  published
    { Published declarations }
    property DockPos: TDockPos read FDockPos;
    property AutoDock: Boolean read FAutoDock write SetAutoDock;
    property AlwaysTop: Boolean read FAlwaysTop write SetAlwaysTop;

    property EdgeSpace: integer read FEdgeSpace write SetEdgeSpace;
    property ValidSpace: integer read FValidSpace write SetValidSpace;

    property DockEvent: TDockEvent read FDockEvent write FDockEvent;
    property OnHideForm: TDockEvent read FHideEvent write FHideEvent;
    property OnShowForm: TDockEvent read FShowEvent write FShowEvent; 
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Sunwards', [TAutoShrinkForm]);
end;

constructor TAutoShrinkForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMainForm := FindMainForm;
  if not Assigned(FMainForm) then raise Exception.Create('Î´ÕÒµ½Ö÷´°Ìå');

  FIdle := 0;
  FEdgeSpace := 3;
  FValidSpace := 10;
 
  FDockPos := dpNone;  
  FAutoDock := False;
end;

destructor TAutoShrinkForm.Destroy;
begin
  SetAutoDock(False);
  inherited Destroy;
end;

function TAutoShrinkForm.FindMainForm: TForm;
var nComponent: TComponent;
begin
  Result := nil;
  nComponent := Self.Owner;

  while Assigned(nComponent) do
  begin
     if (nComponent is TForm) then
     begin
        Result := nComponent as TForm;
        Break;
     end;
     nComponent := nComponent.GetParentComponent;
  end;
end;

procedure TAutoShrinkForm.SetAutoDock(const nValue: boolean);
begin
  if not (csDesigning in ComponentState) and (FAutoDock <> nValue) then
  begin
     if nValue then
     begin
        FFormRect := FMainForm.BoundsRect;
        FFormProc := FMainForm.WindowProc;
        FMainForm.WindowProc := CaptureMsg;

        FWnd := Classes.AllocateHWnd(WndProc);
        SetTimer(FWnd, 1, 558, nil);
     end else
     begin
        if FWnd > 0 then
        begin
           KillTimer(FWnd, 1);
           Classes.DeallocateHWnd(FWnd);
        end;

        if Assigned(FMainForm) and
           Assigned(FFormProc) then FMainForm.WindowProc := FFormProc;

        FFormProc := nil;
        FWnd := 0; FIdle := 0; FDockPos := dpNone;
      end;
  end;
  FAutoDock := nValue;
end;

procedure TAutoShrinkForm.SetAlwaysTop(const nValue: boolean);
begin
  if not (csDesigning in Self.ComponentState) and (FAlwaysTop <> nValue) then
  begin
     if nValue then
     begin
        SetWindowPos( FMainForm.Handle, HWND_TOPMOST,
                      0,0,0,0, SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);

{        ShowWindow( Application.Handle, SW_Hide);
        SetWindowLong(Application.Handle,GWL_EXSTYLE,
         GetWindowLong(Application.Handle,GWL_EXSTYLE)
          and (not WS_EX_APPWINDOW) or WS_EX_TOOLWINDOW);}
     end else
     begin
        SetWindowPos( FMainForm.Handle, HWND_NOTOPMOST,
                      0,0,0,0,SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);

{        SetWindowLong(Application.Handle,GWL_EXSTYLE,
         GetWindowLong(Application.Handle,GWL_EXSTYLE)
          and (not WS_EX_TOOLWINDOW) or WS_EX_APPWINDOW);
        ShowWindow( Application.Handle, SW_Show); }
     end;
  end;
  FAlwaysTop := nValue;
end;

procedure TAutoShrinkForm.WndProc(var nMsg: TMessage);
begin
  with nMsg do
  begin
    if Msg = WM_TIMER then
      Inc(FIdle)
    else Result := DefWindowProc(FWnd, Msg, wParam, lParam);
  end;
end;

procedure TAutoShrinkForm.DockFormToEdge(const nRect: PRect);
begin
  if (nRect.Top < FValidSpace) and (nRect.Top <= FFormRect.Top) then
  //Top
  begin
    nRect.Bottom := nRect.Bottom - nRect.Top;
    nRect.Top := 0;
  end else

  if (nRect.Left < FValidSpace) and (nRect.Left <= FFormRect.Left) then
  //Left
  begin
    nRect.Right := nRect.Right - nRect.Left;
    nRect.Left := 0;
  end else

  if (Screen.Width - nRect.Right < FValidSpace) and (nRect.Left >= FFormRect.Left) then
  //Right
  begin
    nRect.Left := Screen.Width - (nRect.Right - nRect.Left);
    nRect.Right := Screen.Width;
  end;

  if nRect.Top = 0 then
    FDockPos := dpTop else
  if nRect.Left = 0 then
    FDockPos := dpLeft else
  if nRect.Right = Screen.Width then
  FDockPos := dpRight else FDockPos := dpNone;

  FFormRect := nRect^; //Save MainForm Rects
  if (FDockPos <> dpNone) and Assigned(FDockEvent) then FDockEvent(FDockPos);
end;

function TAutoShrinkForm.IsMouseLeave: boolean;
var nPt: TPoint;
begin
  GetCursorPos(nPt);
  if PtInRect(FFormRect, nPt) then
       Result := False
  else Result := True;
end;

procedure TAutoShrinkForm.SetFormHide;
begin
  if IsMouseLeave then
  begin
     FIsHide := True;
     if Assigned(FHideEvent) then
     begin
        FHideEvent(FDockPos); Exit;
     end;

     if FDockPos = dpTop then
        FMainForm.Top := -FMainForm.Height + FEdgeSpace else
     if FDockPos = dpLeft then
        FMainForm.Left := -FMainForm.Width + FEdgeSpace else
     if FDockPos = dpRight then
        FMainForm.Left := Screen.Width - FEdgeSpace;
     SetAlwaysTop(true);
  end;
end;

procedure TAutoShrinkForm.SetFormShow;
begin
  FIsHide := False;
  if Assigned(FShowEvent) then
  begin
     FShowEvent(FDockPos); Exit;
  end;

  if FDockPos = dpTop then
     FMainForm.Top := 0 else
  if FDockPos = dpLeft then
     FMainForm.Left := 0 else
  if FDockPos = dpRight then
     FMainForm.Left := Screen.Width - FMainForm.Width;
  SetAlwaysTop(false);
end;

procedure TAutoShrinkForm.SetEdgeSpace(const nSpace: integer);
begin
  if (nSpace > 0) and (nSpace < 51) then
    FEdgeSpace := nSpace;
end;

procedure TAutoShrinkForm.SetValidSpace(const nSpace: integer);
begin
  if (nSpace > 4) and (nSpace < 51) then
    FValidSpace := nSpace;
end;

procedure TAutoShrinkForm.CaptureMsg(var Message: TMessage);
begin
  if Assigned(FFormProc) then FFormProc(Message);
  
  if FAutoDock then
  case Message.Msg of
    CM_MOUSEENTER : if FIsHide then SetFormShow;
    CM_MOUSELEAVE : if FDockPos <> dpNone then SetFormHide;
    WM_MOVING : DockFormToEdge(PRect(Message.lParam));
  end;
end;

end.
