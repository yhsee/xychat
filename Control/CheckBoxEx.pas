Unit CheckBoxEx;

Interface

uses Windows, Messages, Classes, Controls, StdCtrls,Graphics, Themes;

Type
  TCheckBoxEx=class(TCustomCheckBox)
  private
    procedure   WMEraseBkGnd(var Message: TWMEraseBkGnd); message WM_ERASEBKGND;
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure DrawParentImage(Sender:TObject; DC: HDC);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Action;
    property Alignment;
    property AllowGrayed;
    property Anchors;
    property BiDiMode;
    property Caption;
    property Checked;
    property Color nodefault;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property State;
    property TabOrder;
    property TabStop;
    property Visible;
    property WordWrap;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TCheckBoxEx]);
end;

constructor TCheckBoxEx.Create(AOwner: TComponent);
begin
  Inherited;
  DoubleBuffered:=True;
end;

procedure TCheckBoxEx.WMEraseBkGnd(var Message: TWMEraseBkGnd);
begin
  SetBkMode(Message.DC,TRANSPARENT);
  ThemeServices.DrawParentBackground(Handle, Message.DC, nil, False);
  Message.Result := 0;
end;

procedure TCheckBoxEx.WndProc(var Message: TMessage);
var
  TmpDc:Integer;
begin
  if Message.Msg = WM_PAINT then
    begin
    if not ThemeServices.ThemesEnabled then
      begin
      Perform(WM_SetRedraw, 0, 0);
      inherited;
      Perform(WM_SetRedraw, 1, 0);
      //------------------------------------------------------------------------
      TmpDC:=GetDc(Handle);
      DrawParentImage(self,TmpDC);
      ReleaseDc(Handle,TmpDc);
      end else inherited;
    end else inherited;
end;

procedure TCheckBoxEx.DrawParentImage(Sender:TObject; DC: HDC);
var
  iCheck:Integer;
  sTmpStr:String;
  BoxRect,TextRect:TRect;
begin
  iCheck:=0;
  TextRect:=GetClientRect;
  BoxRect:=TextRect;
  BoxRect.right:=BoxRect.left +14;
  TextRect.Left:=TextRect.left + 20;
  sTmpStr:=TCheckBoxEx(Sender).Caption;
  if TCheckBoxEx(Sender).Checked then iCheck:=DFCS_CHECKED;
  DrawFrameControl(dc,BoxRect,DFC_BUTTON,DFCS_BUTTONCHECK or iCheck);
  SetBkMode(DC,TRANSPARENT);
  SelectObject(dc,TCheckBoxEx(Sender).Font.Handle);
  DrawText(DC,PChar(sTmpStr),Length(sTmpStr),TextRect,DT_LEFT or DT_VCENTER or DT_SINGLELINE);
end;

end.
