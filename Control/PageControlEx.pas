unit PageControlEx;

interface

uses Windows,Messages,Classes,Controls,ComCtrls,Themes,Graphics;

type
  TPageControlEx=class(TPageControl)
  private
    procedure WMEraseBkGnd(var Message: TWMEraseBkGnd); message WM_ERASEBKGND;
  protected
    procedure DrawTab(TabIndex: Integer; const Rect: TRect; Active: Boolean);override;
  public
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HotTrack;
    property Images;
    property MultiLine;
    property OwnerDraw;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property RaggedRight;
    property ScrollOpposite;
    property ShowHint;
    property Style;
    property TabHeight;
    property TabIndex stored False;
    property TabOrder;
    property TabPosition;
    property TabStop;
    property TabWidth;
    property Visible;
    property OnChange;
    property OnChanging;
    property OnContextPopup;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawTab;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImageIndex;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TPageControlEx]);
end;

procedure TPageControlEx.WMEraseBkGnd(var Message: TWMEraseBkGnd);
begin
  SetBkMode(Message.DC,TRANSPARENT);
  ThemeServices.DrawParentBackground(Handle, Message.DC, nil, False);
  Message.Result := 1;
end;

procedure TPageControlEx.DrawTab(TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  sTmpStr:String;
  L,T,W,H:Integer;
begin
  sTmpStr:=Pages[TabIndex].Caption;
  Canvas.Brush.Style:=bsClear;
  W:=Canvas.TextWidth(sTmpStr);
  H:=Canvas.TextHeight(sTmpStr);
  L:=((Rect.Right-Rect.Left)-W) div 2;
  T:=((Rect.Bottom-Rect.Top)-H) div 2;
  if not Active then Inc(T,2);
  Canvas.TextOut(Rect.Left+L,Rect.Top+T,sTmpStr);
end;

end.
