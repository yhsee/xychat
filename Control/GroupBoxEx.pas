Unit GroupBoxEx;

Interface

uses Windows, Messages, Classes, Controls, StdCtrls,Graphics, Themes;

Type
  TGroupBoxEx=class(TCustomGroupBox)
  private
    procedure   WMEraseBkGnd(var Message: TWMEraseBkGnd); message WM_ERASEBKGND;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property Caption;
    property Color;
    property Constraints;
    property Ctl3D;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentBackground default True;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDockDrop;
    property OnDockOver;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TGroupBoxEx]);
end;

constructor TGroupBoxEx.Create(AOwner: TComponent);
begin
  Inherited;
  DoubleBuffered:=True;
end;

procedure TGroupBoxEx.WMEraseBkGnd(var Message: TWMEraseBkGnd);
begin
  SetBkMode(Message.DC,TRANSPARENT);
  ThemeServices.DrawParentBackground(Handle, Message.DC, nil, False);
  Message.Result := 1;
end;

procedure TGroupBoxEx.Paint;
begin
  if not ThemeServices.ThemesEnabled then
    color:=Canvas.Pixels[8,4];
  Inherited;
end;

end.
