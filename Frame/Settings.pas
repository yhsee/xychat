unit Settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Mask,
  ConstUnt,
  {Tnt Control}
  TntStdCtrls, TntGraphics, Spin, Buttons;

type
  TFrmSettings = class(TForm)
    But_Yes: TTntButton;
    But_Cancel: TTntButton;
    But_Apply: TTntButton;
    Ls_Options: TTntListBox;
    Panel_Work_MyInfo: TPanel;
    Img_Self: TImage;
    Panel_BaseSettings: TPanel;
    Chk_BootWithWin: TTntCheckBox;
    Chk_AutoDockHide: TTntCheckBox;
    Chk_UseImageChar: TTntCheckBox;
    Chk_AutoPopChat: TTntCheckBox;
    Chk_CloseToTray: TTntCheckBox;
    Chk_AutoContinueTsf: TTntCheckBox;
    Hotkey_SysHotkey: THotKey;
    Hotkey_HideHotkey: THotKey;
    Panel_ReplyTo: TPanel;
    Chk_AutoChangeState: TTntCheckBox;
    Chk_AutoReplyInfo: TTntCheckBox;
    But_AddAutoReply: TTntButton;
    But_DelAutoReply: TTntButton;
    But_AddQuickReply: TTntButton;
    But_DelQuickReply: TTntButton;
    Panel_SoundSettings: TPanel;
    Chk_OpenSound: TTntCheckBox;
    But_PlaySound: TTntButton;
    Panel_IDandValidate: TPanel;
    But_ChangePass: TTntButton;
    Rb_AllAdd: TTntRadioButton;
    Rb_CheckAdd: TTntRadioButton;
    Rb_NonAdd: TTntRadioButton;
    Chk_StartMini: TTntCheckBox;
    Panel_OptionBox: TPanel;
    Panel_WorkBox: TPanel;
    Panel_WorkTitle: TPanel;
    Ed_OldPassword: TTntEdit;
    Lab_OldPassword: TTntLabel;
    Lab_NewPassword: TTntLabel;
    Lab_ConfigPassword: TTntLabel;
    Ed_NewPassword: TTntEdit;
    Ed_ConfigPassword: TTntEdit;
    Lab_SysHotkey: TTntLabel;
    Lab_HideHotkey: TTntLabel;
    Lab_AutoChangeState: TTntLabel;
    Se_AutoChangeState_Times: TSpinEdit;
    Cmb_AutoChangeState_State: TTntComboBox;
    Memo_AutoReply: TTntMemo;
    Memo_QuickReply: TTntMemo;
    Lab_QuickReply: TTntLabel;
    Gb_AutoStateChange: TTntGroupBox;
    Gb_AutoReply: TTntGroupBox;
    Gb_QuickReply: TTntGroupBox;
    Gb_Settings: TTntGroupBox;
    Gb_HotKey: TTntGroupBox;
    Gb_UserPassChange: TTntGroupBox;
    Gb_AddFirendMode: TTntGroupBox;
    Gb_SoundSettings: TTntGroupBox;
    Lab_SoundInformation: TTntLabel;
    Ls_SoundTypeList: TTntListBox;
    Be_SoundPath: TTntEdit;
    Bevel_IMG: TBevel;
    Lab_UserID: TTntLabel;
    Lab_NickName: TTntLabel;
    Lab_Signing: TTntLabel;
    Lab_Sex: TTntLabel;
    Lab_Constellation: TTntLabel;
    Lab_Age: TTntLabel;
    Lab_Communication: TTntLabel;
    Lab_Phone: TTntLabel;
    Lab_QQMSN: TTntLabel;
    Lab_Email: TTntLabel;
    Lab_Address: TTntLabel;
    Lab_Memo: TTntLabel;
    Ed_UserID: TTntEdit;
    Ed_NickName: TTntEdit;
    Memo_Signing: TTntMemo;
    Ed_Communication: TTntEdit;
    Ed_Phone: TTntEdit;
    Ed_QQMSN: TTntEdit;
    Ed_Email: TTntEdit;
    Ed_Address: TTntEdit;
    Ed_Memo: TTntMemo;
    Ed_Age: TTntEdit;
    Cmb_Sex: TTntComboBox;
    Cmb_Constellation: TTntComboBox;
    Lab_SetMyImage: TTntLabel;
    Cmb_AutoReplyIndex: TTntComboBox;
    Cmb_QuickReplyIndex: TTntComboBox;
    Be_SoundBtn: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure But_CancelClick(Sender: TObject);
    procedure Ls_OptionsClick(Sender: TObject);
    procedure Ls_OptionsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Ed_UserIDKeyPress(Sender: TObject; var Key: Char);
    procedure Chk_AutoReplyInfoClick(Sender: TObject);
    procedure Chk_AutoChangeStateClick(Sender: TObject);
    procedure Chk_OpenSoundClick(Sender: TObject);
    procedure Ed_NickNameChange(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ShowPage(iPage: Integer);
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFrmSettings.FormCreate(Sender: TObject);
begin
  Ls_Options.ItemHeight := 22;

  Ls_Options.Items.Append(SET_MYINFO);
  Ls_Options.Items.Append(SET_BASESETTINGS);
  Ls_Options.Items.Append(SET_STATEREPLYTO);
  Ls_Options.Items.Append(SET_SOUND);
  Ls_Options.Items.Append(SET_SAFEUSERADDMODE);

end;

procedure TFrmSettings.ShowPage(iPage:Integer);
begin
  But_Apply.Enabled:=False;
  Ls_Options.ItemIndex := iPage;
  Case iPage of
    0:
      begin
        Panel_Work_MyInfo.Visible := True;
        Panel_BaseSettings.Visible := False;
        Panel_ReplyTo.Visible := False;
        Panel_SoundSettings.Visible := False;
        Panel_IDandValidate.Visible := False;

        Panel_WorkTitle.Caption := SET_MYINFO;
      end;
    1:
      begin
        Panel_BaseSettings.Visible := True;
        Panel_Work_MyInfo.Visible := False;        
        Panel_ReplyTo.Visible := False;
        Panel_SoundSettings.Visible := False;
        Panel_IDandValidate.Visible := False;

        Panel_WorkTitle.Caption := SET_BASESETTINGS;
      end;
    2:
      begin
        Panel_ReplyTo.Visible := True;
        Panel_Work_MyInfo.Visible := False;        
        Panel_BaseSettings.Visible := False;
        Panel_SoundSettings.Visible := False;
        Panel_IDandValidate.Visible := False;

        Panel_WorkTitle.Caption := SET_STATEREPLYTO;
      end;    
    3:
      begin
        Panel_SoundSettings.Visible := True;
        Panel_Work_MyInfo.Visible := False;        
        Panel_BaseSettings.Visible := False;
        Panel_ReplyTo.Visible := False;
        Panel_IDandValidate.Visible := False;

        Panel_WorkTitle.Caption := SET_SOUND;
      end;        
    4:
      begin
        Panel_IDandValidate.Visible := True;
        Panel_Work_MyInfo.Visible := False;        
        Panel_BaseSettings.Visible := False;
        Panel_SoundSettings.Visible := False;
        Panel_ReplyTo.Visible := False;

        Panel_WorkTitle.Caption := SET_SAFEUSERADDMODE;
      end;        
  end;
end;

procedure TFrmSettings.But_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmSettings.Ls_OptionsClick(Sender: TObject);
begin
  if Ls_Options.ItemIndex<>-1 then
    ShowPage(Ls_Options.ItemIndex);
end;

procedure TFrmSettings.Ls_OptionsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  With Ls_Options.Canvas do
  begin
    if (odSelected in State) then
    begin
      Brush.Color := $00FEF7E9;
      Font.Color := $00FF8000;
      FillRect(Rect);
      WideCanvasTextOut(Ls_Options.Canvas, Rect.Left + 16,
        Rect.Top + 5, Ls_Options.Items.Strings[Index]);
      Brush.Color := $00FEDCB6;
      FrameRect(Rect);
      if(odFocused in State) then DrawFocusRect(Rect);
    end
    else
    begin
      Brush.Style := bsClear;
      Brush.Color := clWhite;
      Font.Color := clBlack;
      FillRect(Rect);
      WideCanvasTextOut(Ls_Options.Canvas, Rect.Left + 16,
        Rect.Top + 5, Ls_Options.Items.Strings[Index]);
    end;
  end;
end;

procedure TFrmSettings.Ed_UserIDKeyPress(Sender: TObject; var Key: Char);
begin
If Key = #13 Then
  Begin
  If HiWord(GetKeyState(VK_SHIFT)) <> 0 then
     SelectNext(Sender as TWinControl,False,True)
  else
   SelectNext(Sender as TWinControl,True,True);
   Key := #0
  end;
end;

procedure TFrmSettings.Chk_AutoReplyInfoClick(Sender: TObject);
begin
Memo_AutoReply.Enabled:=Chk_AutoReplyInfo.Checked;
Cmb_AutoReplyIndex.Enabled:=Chk_AutoReplyInfo.Checked;
But_AddAutoReply.Enabled:=Chk_AutoReplyInfo.Checked;
But_DelAutoReply.Enabled:=Chk_AutoReplyInfo.Checked;
Ed_NickNameChange(nil);
end;

procedure TFrmSettings.Chk_AutoChangeStateClick(Sender: TObject);
begin
Cmb_AutoChangeState_State.Enabled:=Chk_AutoChangeState.Checked;
Se_AutoChangeState_Times.Enabled:=Chk_AutoChangeState.Checked;
Ed_NickNameChange(nil);
end;

procedure TFrmSettings.Chk_OpenSoundClick(Sender: TObject);
begin
Be_SoundPath.Enabled:=Chk_OpenSound.Checked;
But_PlaySound.Enabled:=Chk_OpenSound.Checked;
Ls_SoundTypeList.Enabled:=Chk_OpenSound.Checked;
Ed_NickNameChange(nil);
end;

procedure TFrmSettings.Ed_NickNameChange(Sender: TObject);
begin
But_Apply.Enabled:=True;
end;

end.
