Unit PanelEx;

Interface

uses Windows, Messages, SysUtils, Classes,Controls,Themes,
     Graphics,ExtCtrls,jpeg;

Type
  TPanelEx=Class(TCustomPanel)
    private
      FPicture:TPicture;
      FTile,FTransparent:Boolean;
      procedure SetPicture(Value: TPicture);
    protected
      procedure WMEraseBkgnd(var Message:TMessage); message WM_ERASEBKGND;
      procedure Paint; Override;
    public
      constructor Create(AOwner: TComponent);override;
      destructor  Destroy;override;
      property DockManager;
    published
      property Picture: TPicture read FPicture write SetPicture;
      property Align;
      property Alignment;
      property Anchors;
      property AutoSize;
      property BevelInner;
      property BevelOuter;
      property BevelWidth;
      property BiDiMode;
      property BorderWidth;
      property BorderStyle;
      property Caption;
      property Color;
      property Constraints;
      property Ctl3D;
      property UseDockManager default True;
      property DockSite;
      property DragCursor;
      property DragKind;
      property DragMode;
      property Enabled;
      property FullRepaint;
      property Font;
      property Locked;
      property ParentBiDiMode;
      property ParentBackground;
      property ParentColor;
      property ParentCtl3D;
      property ParentFont;
      property ParentShowHint;
      property PopupMenu;
      property ShowHint;
      property TabOrder;
      property TabStop;
      property Visible;
      property OnCanResize;
      property OnClick;
      property OnConstrainedResize;
      property OnContextPopup;
      property OnDockDrop;
      property OnDockOver;
      property OnDblClick;
      property OnDragDrop;
      property OnDragOver;
      property OnEndDock;
      property OnEndDrag;
      property OnEnter;
      property OnExit;
      property OnGetSiteInfo;
      property OnMouseDown;
      property OnMouseMove;
      property OnMouseUp;
      property OnResize;
      property OnStartDock;
      property OnStartDrag;
      property OnUnDock;
      property Transparent:Boolean read FTransparent write FTransparent;
      property Tile:Boolean read FTile write FTile;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TPanelEx]);
end;

constructor TPanelEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPicture := TPicture.Create;
  ControlStyle := ControlStyle - [csOpaque];
  DoubleBuffered:=True;
  FTransparent:=True;
end;

destructor TPanelEx.Destroy;
begin
  Freeandnil(FPicture);
  inherited Destroy;
end;

procedure TPanelEx.WMEraseBkgnd(var Message:TMessage);
begin
  Message.Result := 1;
end;


procedure TPanelEx.SetPicture(Value: TPicture);
begin
  FPicture.Assign(Value);
end;

procedure DrawParentImage(Control: TControl; Source: TCanvas);
var
  SaveIndex: Integer;
  DC: HDC;
  Position: TPoint;
  Bitmap: TBitmap;
begin
  try
  Bitmap := TBitmap.Create;
  with Control do
    begin
    if Parent = nil then Exit;
    //--------------------------------------------------------------------------
    Bitmap.Height := ClientRect.Bottom;
    Bitmap.Width := ClientRect.Right;
    //--------------------------------------------------------------------------
    DC := Bitmap.Canvas.Handle;
    SaveIndex := SaveDC(DC);
    GetViewportOrgEx(DC, Position);
    SetViewportOrgEx(DC, Position.X - Left, Position.Y - Top, nil);
    IntersectClipRect(DC, 0, 0, Parent.ClientWidth, Parent.ClientHeight);
    Parent.Perform(WM_ERASEBKGND, DC, 0);
    Parent.Perform(WM_PAINT, DC, 0);
    RestoreDC(DC, SaveIndex);
    //--------------------------------------------------------------------------
    Source.CopyRect(ClientRect, Bitmap.Canvas, ClientRect);
    end;
  finally
  freeandnil(Bitmap);
  end;
end;


procedure TPanelEx.Paint;
var
  R,C,Rows,Cols:Integer;
begin
  if assigned(FPicture.Graphic) then
    begin
    DrawParentImage(Self,Self.Canvas);
    FPicture.Graphic.Transparent:=FTransparent;
    if FTile then
      begin
      Rows := (Self.Height div FPicture.Height) + 1;
      Cols := (Self.Width div FPicture.Width) + 1;

      for R := 1 to Rows do
      for C := 1 to Cols do
       Canvas.Draw((C - 1) * FPicture.Width, (R - 1) * FPicture.Height, FPicture.Graphic);

      end else Self.Canvas.StretchDraw(self.GetClientRect,FPicture.Graphic);
    end else begin
    if FTransparent then
      DrawParentImage(Self,Self.Canvas)
      else Inherited;
    end;
end;

end.
