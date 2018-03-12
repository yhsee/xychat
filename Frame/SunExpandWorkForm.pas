unit SunExpandWorkForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls,PanelEx,
  ConstUnt,
  {Tnt Control}
  TntClasses, TntSysUtils, TntStdCtrls, TntComCtrls, TntGraphics, TntForms,
  TntExtCtrls, TntMenus, ComCtrls, ToolWin;

type
  TFrmSunExpandWorkForm = class(TTntForm)
    Img_ControlBkg: TPanelEx;
    Panel_WorkArea: TPanelEx;
    Img_BorderTop: TPanelEx;
    Img_BorderLeft: TPanelEx;
    Img_BorderRight: TPanelEx;
    Img_BorderDown: TPanelEx;
    Panel_WorkBox: TPanelEx;
    Panel_TitleBox: TPanelEx;
    Img_TitleBar: TPanelEx;
    Image_PageTitle0: TImage;
    Lab_PageTitle0: TTntLabel;
    Img_WhiteBackGroup: TPanelEx;
    Panel_Page0: TPanelEx;
    Img_UserImage: TImage;
    Img_UserInfoIcon: TImage;
    Lab_UserName: TTntLabel;
    Lab_MobileTelephone: TTntLabel;
    Lab_Telephone: TTntLabel;
    Lab_NetInfo: TTntLabel;
    Panel_Page1: TPanelEx;
    Lab_PageTitle1: TTntLabel;
    Image_PageTitle1: TImage;
    Lab_PageTitle2: TTntLabel;
    Image_PageTitle2: TImage;
    Panel_Page2: TPanelEx;
    sbTransfersBox: TScrollBox;
    Lab_Button_ViewUserInfo: TTntLabel;
    Panel_Page3: TPanelEx;
    Image_PageTitle3: TImage;
    Lab_PageTitle3: TTntLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image_PageTitle0Click(Sender: TObject);
    procedure Img_BorderDownResize(Sender: TObject);
  private
    { Private declarations }
    swSkinPath : WideString;
    iDefWidth, iFSWidth, iVSWidth, iRMWidth,
    iVSHeigth, iRecordHeigth, iUserInfoHeigth, iLabTitleTop : Integer;
    lFSList : TList;
    fMainForm : TTntForm;
    FLock: TRTLCriticalSection;

    RemotePanel,
    AVideoPanel:TTntForm;
    
    procedure ShowContactUserPage;
    procedure ShowTransfersPage;
    procedure ResizePageTitleButton;
    procedure LoadImgRes(ImgControl: TImage; swImage: WideString);
    procedure SetPageActive(iPage: Integer);
    procedure HideTransfersPage;
    procedure ShowVideoPage;
    procedure ShowRemotePage;
  public
    { Public declarations }
    procedure SetMainForm(fForm: TTntForm);
    procedure SetUserViewInfo(swUser, swMPhone, swPhone, swNetContact,
      swImagePath: WideString);
    //TransferReceive
    procedure CreateTransfer;
    procedure AjustTransfer(TransPanel:TTntForm);
    procedure ClosePanel(hwnd:longword);
    //Video Sound
    procedure CreateVideoSoundPage;
    procedure AdjustVideoSoundPage(TransPanel:TTntForm);
    procedure CloseVideoSoundPage;
    //Remote
    procedure CreateRemotePage;
    procedure AdjustRemotePage(TransPanel:TTntForm);
    procedure CloseRemotePage;
    function ExistsTransfersPage:Boolean;
    function ExistsVideoSound:boolean;
    function ExistsRemotePage:Boolean;
  end;


implementation

{$R *.dfm}

function TFrmSunExpandWorkForm.ExistsTransfersPage:Boolean;
begin
  Result:=lFSList.Count>0;
end;

function TFrmSunExpandWorkForm.ExistsVideoSound:boolean;
begin
  Result:=assigned(AVideoPanel);
end;

function TFrmSunExpandWorkForm.ExistsRemotePage:Boolean;
begin
  Result:=Assigned(RemotePanel);
end;

procedure TFrmSunExpandWorkForm.SetMainForm(fForm:TTntForm);
begin
  fMainForm := fForm;
end;

procedure TFrmSunExpandWorkForm.FormCreate(Sender: TObject);
begin
  InitializeCriticalSection(FLock);
  lFSList := TList.Create;

  iDefWidth := 160;
  iFSWidth := 280;
  iRMWidth := 300;
  iVSWidth := 350;
  iVSHeigth := 510;
  iLabTitleTop := 4;
  iUserInfoHeigth := 220;
  
  Self.Width := iDefWidth;
  Panel_WorkArea.Top := 0;
  Panel_WorkArea.Left := 9;
  Panel_WorkArea.Height := iUserInfoHeigth;

  sbTransfersBox.DoubleBuffered:=True;

  swSkinPath := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\';
  Img_BorderTop.Picture.LoadFromFile(swSkinPath + 'Dis043.jpg');  
  Img_BorderDown.Picture.LoadFromFile(swSkinPath + 'Dis042.jpg');

  Img_TitleBar.Transparent:=False;
  
  ShowContactUserPage; 
end;

procedure TFrmSunExpandWorkForm.FormResize(Sender: TObject);
begin
  Panel_WorkArea.Width := Self.Width - 12;
  Img_UserImage.Left := (Panel_Page0.Width-Img_UserImage.Width) Div 2;
  Lab_UserName.Width := Panel_Page0.Width - 30;
  Lab_MobileTelephone.Width := Lab_UserName.Width;
  Lab_Telephone.Width := Lab_UserName.Width;
  Lab_NetInfo.Width := Lab_UserName.Width;
  if (Assigned(lFSList) And (lFSList.Count>0)) Or
    (Lab_PageTitle2.Visible) or (Lab_PageTitle3.Visible) then Panel_WorkArea.Height := Self.Height;
end;

procedure TFrmSunExpandWorkForm.SetUserViewInfo(swUser, swMPhone, swPhone, swNetContact, swImagePath : WideString);
Var
  swPath : WideString;
begin
  //设置USER面板显示信息及图像

  Lab_UserName.Caption := swUser;
  Lab_UserName.Hint := swUser;

  if swMPhone='' then
     begin
     Lab_MobileTelephone.Font.Color:=clGray;
     swMPhone:='无信息';
     end else Lab_MobileTelephone.Font.Color:=$00A66617;
  Lab_MobileTelephone.Caption := swMPhone;
  Lab_MobileTelephone.Hint := swMPhone;

  if swPhone='' then
     begin
     swPhone:='无信息';
     Lab_Telephone.Font.Color:=clGray;
     end else Lab_Telephone.Font.Color:=$00A66617;
  Lab_Telephone.Caption := swPhone;
  Lab_Telephone.Hint := swPhone;

  if swNetContact='' then
     begin
     swNetContact:='无信息';
     Lab_NetInfo.Font.Color:=clGray;
     end else Lab_NetInfo.Font.Color:=$00A66617;
  Lab_NetInfo.Caption := swNetContact;
  Lab_NetInfo.Hint := swNetContact;

  if WideFileExists(swImagePath) then swPath := swImagePath
    else swPath := swSkinPath + 'DefUser.jpg';

  Img_UserImage.Stretch := False;
  Img_UserImage.AutoSize := True;
  if WideFileExists(swPath) then Img_UserImage.Picture.LoadFromFile(swPath);
  if (Img_UserImage.Width>106)
    Or (Img_UserImage.Height>106) then
  begin
    Img_UserImage.AutoSize := False;
    Img_UserImage.Stretch := True;
    if Img_UserImage.Width>106 then
      Img_UserImage.Width := 106;
    if Img_UserImage.Height>106 then
      Img_UserImage.Height := 106;
  end
  else Img_UserImage.AutoSize := True;
  FormResize(Self);
end;

procedure TFrmSunExpandWorkForm.CreateTransfer;
begin
  ShowTransfersPage;
end;

procedure TFrmSunExpandWorkForm.AjustTransfer(TransPanel:TTntForm);
var
  iIndex:integer;
begin
  TransPanel.Left:=0;
  if lFSList.Count=0 then TransPanel.Top:=0
     else begin
     iIndex := lFSList.Count-1;
     if iIndex>=0 then
     TransPanel.Top := TTntForm(lFSList.Items[iIndex]).Top + TTntForm(lFSList.Items[iIndex]).Height + 1;
     end;
  TransPanel.Parent:=sbTransfersBox;
  lFSList.Add(TransPanel);
  TransPanel.Align:=alTop;
end;

procedure TFrmSunExpandWorkForm.AdjustVideoSoundPage(TransPanel:TTntForm);
begin
  TransPanel.Left:=0;
  TransPanel.Top:=0;
  TransPanel.Parent:=Panel_Page2;
  AVideoPanel:=TransPanel;
end;

procedure TFrmSunExpandWorkForm.AdjustRemotePage(TransPanel:TTntForm);
begin
  TransPanel.Left:=0;
  TransPanel.Top:=0;
  TransPanel.Parent:=Panel_Page3;
  RemotePanel:=TransPanel;
end;

procedure TFrmSunExpandWorkForm.ClosePanel(hwnd:longword);
Var
  i : Integer;
  TmpPanel:TTntForm;
begin
  try
  EnterCriticalSection(FLock);
  if hwnd>0 then
  for i := lFSList.Count-1 downto 0 do
    begin
    TmpPanel:=TTntForm(lFSList.Items[i]);
    if TmpPanel.Handle =hwnd then
        begin
        lFSList.Delete(i);
        freeandnil(TmpPanel);
        Break;
        end;
    end;
  finally
  LeaveCriticalSection(FLock);
  end;
if lFSList.Count<=0 then HideTransfersPage;
end;


procedure TFrmSunExpandWorkForm.ShowVideoPage;
begin
  CreateVideoSoundPage;
end;

procedure TFrmSunExpandWorkForm.ShowRemotePage;
begin
  CreateRemotePage;
end;

procedure TFrmSunExpandWorkForm.CreateVideoSoundPage;
begin
  if not Self.Visible then Self.Visible:=True;

  if Panel_Page2.Visible then Exit;

  try
    if Image_PageTitle2.Visible then
    begin
      LockWindowUpdate(Panel_TitleBox.Handle);

      Panel_TitleBox.Visible := True;
      Panel_Page2.Visible := True;
      Panel_Page0.Visible := False;
      Panel_Page1.Visible := False;
      Panel_Page3.Visible := False;

      Image_PageTitle2.Visible := True;
      Lab_PageTitle2.Visible := True;

      ResizePageTitleButton;
      SetPageActive(2);
    end
    else
    begin
      LockWindowUpdate(fMainForm.Handle);

      Img_BorderTop.Picture.LoadFromFile(swSkinPath + 'Dis044.jpg');
      Img_BorderDown.Picture.LoadFromFile(swSkinPath + 'Dis041.jpg');

      Panel_TitleBox.Visible := True;
      Panel_Page2.Visible := True;
      Panel_Page0.Visible := False;
      Panel_Page1.Visible := False;
      Panel_Page3.Visible := False;

      Image_PageTitle2.Visible := True;
      Lab_PageTitle2.Visible := True;

      if Assigned(fMainForm) And (Self.Width<iVSWidth) then
      begin
        Panel_WorkArea.Width := Panel_WorkArea.Width + (iVSWidth - Self.Width);
        Panel_WorkArea.Height := Self.Height;
        fMainForm.Width := fMainForm.Width + (iVSWidth - Self.Width);
        Self.Width := iVSWidth;
      end;
      if fMainForm.Height<iVSHeigth then
      begin
        iRecordHeigth := fMainForm.Height ;
        fMainForm.Height := iVSHeigth;
      end;

      ResizePageTitleButton;
      SetPageActive(2);
    end;
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TFrmSunExpandWorkForm.CreateRemotePage;
begin
  if not Self.Visible then Self.Visible:=True;

  if Panel_Page3.Visible then Exit;

  try
    if Image_PageTitle3.Visible then
    begin
      LockWindowUpdate(Panel_TitleBox.Handle);

      Panel_TitleBox.Visible := True;
      Panel_Page3.Visible := True;
      Panel_Page0.Visible := False;
      Panel_Page1.Visible := False;
      Panel_Page2.Visible := False;

      Image_PageTitle3.Visible := True;
      Lab_PageTitle3.Visible := True;

      ResizePageTitleButton;
      SetPageActive(3);
    end
    else
    begin
      LockWindowUpdate(fMainForm.Handle);

      Img_BorderTop.Picture.LoadFromFile(swSkinPath + 'Dis044.jpg');
      Img_BorderDown.Picture.LoadFromFile(swSkinPath + 'Dis041.jpg');

      Panel_TitleBox.Visible := True;
      Panel_Page3.Visible := True;
      Panel_Page0.Visible := False;
      Panel_Page1.Visible := False;
      Panel_Page2.Visible := False;

      Image_PageTitle3.Visible := True;
      Lab_PageTitle3.Visible := True;

      if Assigned(fMainForm) And (Self.Width<iRMWidth) then
      begin
        Panel_WorkArea.Width := Panel_WorkArea.Width + (iRMWidth - Self.Width);
        Panel_WorkArea.Height := Self.Height;
        fMainForm.Width := fMainForm.Width + (iRMWidth - Self.Width);
        Self.Width := iRMWidth;
      end;
      if fMainForm.Height<iVSHeigth then
      begin
        iRecordHeigth := fMainForm.Height ;
        fMainForm.Height := iVSHeigth;
      end;

      ResizePageTitleButton;
      SetPageActive(3);
    end;
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TFrmSunExpandWorkForm.FormDestroy(Sender: TObject);
Var
  i : Integer;
  TmpPanel:TTntForm;
begin
  try
  if Assigned(lFSList) then
  if lFSList.Count>0 then
  for i := lFSList.Count-1 downto 0 do
    try
    TmpPanel:=TTntForm(lFSList.Items[i]);
    finally
    freeandnil(TmpPanel);
    end;
  finally
  DeleteCriticalSection(FLock);
  if assigned(AVideoPanel) then freeandnil(AVideoPanel);
  if assigned(RemotePanel) then freeandnil(RemotePanel);
  if Assigned(lFSList) then FreeAndNil(lFSList);
  end;
end;

procedure TFrmSunExpandWorkForm.ShowContactUserPage;
begin
  Panel_Page0.Visible := True;
  Panel_Page1.Visible := False;
  Panel_Page2.Visible := False;
  Panel_Page3.Visible := False;

  Image_PageTitle0.Visible := True;
  Lab_PageTitle0.Visible := True;

  ResizePageTitleButton;
  SetPageActive(0);
  FormResize(Self);
end;

procedure TFrmSunExpandWorkForm.LoadImgRes(ImgControl:TImage;swImage:WideString);
begin
  if WideFileExists(swSkinPath + swImage) then
    ImgControl.Picture.LoadFromFile(swSkinPath + swImage);
end;

procedure TFrmSunExpandWorkForm.SetPageActive(iPage:Integer);
begin
  Case iPage of
    0:
      begin
        LoadImgRes(Image_PageTitle0, 'TabSheet.bmp');
        LoadImgRes(Image_PageTitle1, 'TabSheetNA.bmp');
        LoadImgRes(Image_PageTitle2, 'TabSheetNA.bmp');
        LoadImgRes(Image_PageTitle3, 'TabSheetNA.bmp');
      end;
    1:
      begin
        LoadImgRes(Image_PageTitle1, 'TabSheet.bmp');
        LoadImgRes(Image_PageTitle0, 'TabSheetNA.bmp');
        LoadImgRes(Image_PageTitle2, 'TabSheetNA.bmp');
        LoadImgRes(Image_PageTitle3, 'TabSheetNA.bmp');
      end;
    2:
      begin
        LoadImgRes(Image_PageTitle2, 'TabSheet.bmp');
        LoadImgRes(Image_PageTitle0, 'TabSheetNA.bmp');
        LoadImgRes(Image_PageTitle1, 'TabSheetNA.bmp');
        LoadImgRes(Image_PageTitle3, 'TabSheetNA.bmp');
      end;

    3:
      begin
        LoadImgRes(Image_PageTitle3, 'TabSheet.bmp');
        LoadImgRes(Image_PageTitle0, 'TabSheetNA.bmp');
        LoadImgRes(Image_PageTitle1, 'TabSheetNA.bmp');
        LoadImgRes(Image_PageTitle2, 'TabSheetNA.bmp');
      end;
  end;
end;

procedure TFrmSunExpandWorkForm.HideTransfersPage;
begin
  try
    LockWindowUpdate(fMainForm.Handle);

    Panel_Page1.Visible := False;
    Image_PageTitle1.Visible := False;
    Lab_PageTitle1.Visible := False;

    if Assigned(fMainForm) and Assigned(AVideoPanel) then
      begin

      end else
    if Assigned(fMainForm) And Assigned(RemotePanel) then
      begin

      end else begin
      if Self.Width<>iDefWidth then
        begin
        fMainForm.Width := fMainForm.Width - (Self.Width - iDefWidth);
        Panel_TitleBox.Visible := False;
        Panel_WorkArea.Height := iUserInfoHeigth;
        Panel_WorkArea.Width := Panel_WorkArea.Width - (Self.Width - iDefWidth);
        Self.Width := iDefWidth;
        end;
      end;

    if fMainForm.Height>=iVSHeigth then
      fMainForm.Height := iRecordHeigth;

    ShowContactUserPage;
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TFrmSunExpandWorkForm.CloseVideoSoundPage;
begin
  try
    LockWindowUpdate(fMainForm.Handle);

    if assigned(AVideoPanel) then freeandnil(AVideoPanel);

    Img_BorderTop.Picture.LoadFromFile(swSkinPath + 'Dis043.jpg');
    Img_BorderDown.Picture.LoadFromFile(swSkinPath + 'Dis042.jpg');

    Panel_Page2.Visible := False;
    Image_PageTitle2.Visible := False;
    Lab_PageTitle2.Visible := False;

    if Assigned(fMainForm) and Assigned(RemotePanel) then
      begin
      fMainForm.Width := fMainForm.Width - (iVSWidth - iRMWidth);
      Panel_WorkArea.Width := Panel_WorkArea.Width - (iVSWidth - iRMWidth);
      Self.Width := iRMWidth;
      end else
    if Assigned(fMainForm) And (lFSList.Count>0) then
      begin
      fMainForm.Width := fMainForm.Width - (iVSWidth - iFSWidth);
      Panel_WorkArea.Width := Panel_WorkArea.Width - (iVSWidth - iFSWidth);
      Self.Width := iFSWidth;
      end else begin
      if Self.Width<>iDefWidth then
        begin
        fMainForm.Width := fMainForm.Width - (Self.Width - iDefWidth);
        Panel_TitleBox.Visible := False;
        Panel_WorkArea.Height := iUserInfoHeigth;
        Panel_WorkArea.Width := Panel_WorkArea.Width - (Self.Width - iDefWidth);
        Self.Width := iDefWidth;
        end;
      end;

    if fMainForm.Height>=iVSHeigth then
      fMainForm.Height := iRecordHeigth;

    ShowContactUserPage;
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TFrmSunExpandWorkForm.CloseRemotePage;
begin
  try
    LockWindowUpdate(fMainForm.Handle);

    if assigned(RemotePanel) then freeandnil(RemotePanel);

    Img_BorderTop.Picture.LoadFromFile(swSkinPath + 'Dis043.jpg');
    Img_BorderDown.Picture.LoadFromFile(swSkinPath + 'Dis042.jpg');

    Panel_Page3.Visible := False;
    Image_PageTitle3.Visible := False;
    Lab_PageTitle3.Visible := False;


    if Assigned(fMainForm) and Assigned(AVideoPanel) then
      begin

      end else
    if Assigned(fMainForm) And (lFSList.Count>0) then
      begin
      fMainForm.Width := fMainForm.Width - (iRMWidth - iFSWidth);
      Panel_WorkArea.Width := Panel_WorkArea.Width - (iRMWidth - iFSWidth);
      Self.Width := iFSWidth;
      end else begin
      if Self.Width<>iDefWidth then
        begin
        fMainForm.Width := fMainForm.Width - (Self.Width - iDefWidth);
        Panel_TitleBox.Visible := False;
        Panel_WorkArea.Height := iUserInfoHeigth;
        Panel_WorkArea.Width := Panel_WorkArea.Width - (Self.Width - iDefWidth);
        Self.Width := iDefWidth;
        end;
      end;

    ShowContactUserPage;
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TFrmSunExpandWorkForm.ResizePageTitleButton;
Var
  iBaseLeft : Integer;
begin
  iBaseLeft := 0;
  if Image_PageTitle0.Visible then
  begin
    Image_PageTitle0.Left := iBaseLeft;
    Lab_PageTitle0.Left := iBaseLeft + ((Image_PageTitle0.Width - Lab_PageTitle0.Width) Div 2) + 1;
    iBaseLeft := (iBaseLeft + Image_PageTitle0.Width) + 2;
  end;
  if Image_PageTitle1.Visible then
  begin
    Image_PageTitle1.Left := iBaseLeft;
    Lab_PageTitle1.Left := iBaseLeft + ((Image_PageTitle1.Width - Lab_PageTitle1.Width) Div 2) + 1;
    iBaseLeft := (iBaseLeft + Image_PageTitle1.Width) + 2;
  end;
  if Image_PageTitle2.Visible then
  begin
    Image_PageTitle2.Left := iBaseLeft;
    Lab_PageTitle2.Left := iBaseLeft + ((Image_PageTitle2.Width - Lab_PageTitle2.Width) Div 2) + 1;
    iBaseLeft := (iBaseLeft + Image_PageTitle2.Width) + 2;
  end;

  if Image_PageTitle3.Visible then
  begin
    Image_PageTitle3.Left := iBaseLeft;
    Lab_PageTitle3.Left := iBaseLeft + ((Image_PageTitle3.Width - Lab_PageTitle3.Width) Div 2) + 1;
  end;
end;

procedure TFrmSunExpandWorkForm.ShowTransfersPage;
begin
  if not Self.Visible then Self.Visible:=True;

  if Panel_Page1.Visible then Exit;

  try
    if Image_PageTitle1.Visible then
    begin
      LockWindowUpdate(Panel_TitleBox.Handle);

      Panel_TitleBox.Visible := True;
      Panel_Page1.Visible := True;
      Panel_Page0.Visible := False;
      Panel_Page2.Visible := False;
      Panel_Page3.Visible := False;

      Image_PageTitle1.Visible := True;
      Lab_PageTitle1.Visible := True;

      ResizePageTitleButton;
      SetPageActive(1);
    end
    else
    begin
      LockWindowUpdate(fMainForm.Handle);

      Panel_TitleBox.Visible := True;
      Panel_Page0.Visible := False;
      Panel_Page1.Visible := True;
      Panel_Page2.Visible := False;
      Panel_Page3.Visible := False;

      Image_PageTitle1.Visible := True;
      Lab_PageTitle1.Visible := True;

      if Assigned(fMainForm) And (Self.Width<iFSWidth) then
      begin
        Panel_WorkArea.Width := Panel_WorkArea.Width + (iFSWidth - Self.Width);
        Panel_WorkArea.Height := Self.Height;
        fMainForm.Width := fMainForm.Width + (iFSWidth - Self.Width);
        Self.Width := iFSWidth;
      end;      

      ResizePageTitleButton;
      SetPageActive(1);
    end;
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TFrmSunExpandWorkForm.Image_PageTitle0Click(Sender: TObject);
Var
  iTag : Integer;
begin
  iTag := -1;
  
  if Sender is TTntLabel then iTag := (Sender as TTntLabel).Tag;
  if Sender is TImage then iTag := (Sender as TImage).Tag;

  Case iTag Of
    0: ShowContactUserPage;
    1: ShowTransfersPage;
    2: ShowVideoPage;
    3: ShowRemotePage;
  end;
end;

procedure TFrmSunExpandWorkForm.Img_BorderDownResize(Sender: TObject);
begin
  Lab_Button_ViewUserInfo.Left:=Img_BorderDown.Width-Lab_Button_ViewUserInfo.Width-3;
end;

end.
