Unit RadioButtonEx;

Interface

uses Windows, Messages, Classes, Controls, StdCtrls,Graphics, Themes;

Type
  TRadioButtonEx=class(TRadioButton)
  private
    procedure   WMEraseBkGnd(var Message: TWMEraseBkGnd); message WM_ERASEBKGND;
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure DrawParentImage(Sender:TObject; DC: HDC);
  public
    constructor Create(AOwner: TComponent); override;
  published
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TRadioButtonEx]);
end;

constructor TRadioButtonEx.Create(AOwner: TComponent);
begin
  Inherited;
  DoubleBuffered:=True;
end;

procedure TRadioButtonEx.WMEraseBkGnd(var Message: TWMEraseBkGnd);
begin
  SetBkMode(Message.DC,TRANSPARENT);
  ThemeServices.DrawParentBackground(Handle, Message.DC, nil, False);
  Message.Result := 0;
end;

procedure TRadioButtonEx.WndProc(var Message: TMessage);
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

procedure TRadioButtonEx.DrawParentImage(Sender:TObject; DC: HDC);
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
  sTmpStr:=TRadioButtonEx(Sender).Caption;
  if TRadioButtonEx(Sender).Checked then iCheck:=DFCS_CHECKED;
  DrawFrameControl(dc,BoxRect,DFC_BUTTON,DFCS_BUTTONRADIO or iCheck);
  SetBkMode(DC,TRANSPARENT);
  SelectObject(dc,TRadioButtonEx(Sender).Font.Handle);
  DrawText(DC,PChar(sTmpStr),Length(sTmpStr),TextRect,DT_LEFT or DT_VCENTER or DT_SINGLELINE);
end;

end.
