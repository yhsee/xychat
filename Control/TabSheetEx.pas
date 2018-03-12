unit TabSheetEx;

interface

uses ComCtrls,Messages,Windows,Classes,Themes,Graphics;

type
  TTabSheetEx=class(TTabSheet)
  private
    procedure WMEraseBkGnd(var Message: TWMEraseBkGnd); message WM_ERASEBKGND;
  protected
  published
  
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TTabSheetEx]);
end;

procedure TTabSheetEx.WMEraseBkGnd(var Message: TWMEraseBkGnd);
begin
  SetBkMode(Message.DC,TRANSPARENT);
  ThemeServices.DrawParentBackground(Handle, Message.DC, nil, False);
  Message.Result := 1;
end;

end.
