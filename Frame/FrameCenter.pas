unit FrameCenter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, jpeg, Gifimage, StdCtrls, ExtCtrls, StrUtils, SunIMTreeList, SunNewlyList,
  {String Res}
  ConstUnt,
  PanelEx,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus, ComCtrls, ImgList;

type
  TTreeView = class(TSIMTreeList);
  TTntTreeView = class(TSIMNewlyList);
  
  TFrame_ControlCenter = class(TTntFrame)
    Image_InfoCenter: TPanelEx;
    Image_UserImgBorder: TImage;
    Image_UserImg: TImage;
    Lab_UserNickNameAndState: TTntLabel;
    Lab_Idiograph: TTntLabel;
    Panel_Search: TPanelEx;
    Image_Search0: TPanelEx;
    Image_Search2: TPanelEx;
    Image_Search1: TPanelEx;
    Lab_Search: TTntLabel;
    Ed_SearchKey: TTntEdit;
    Panel_PageHearder: TPanelEx;
    Image_Page: TPanelEx;
    Image_PageLine: TPanelEx;
    Lab_Page1Button: TTntLabel;
    Lab_Page2Button: TTntLabel;
    Image_ControlBkg: TPanelEx;
    Image_MainMenu: TImage;
    Lab_MainMenu: TTntLabel;
    Panel_List: TPanelEx;
    Page_Control: TPageControl;
    Ts_UserList: TTabSheet;
    Ts_NewlyUserList: TTabSheet;
    Ts_MySafeSpace: TTabSheet;
    Image_Search: TImage;
    Image_MySpace: TImage;
    Si_IMUserList: TTreeView;
    Sn_IMNewlyList: TTntTreeView;
    Image_EditBorder: TImage;
    Ed_Key: TTntEdit;
    procedure Lab_SearchMouseEnter(Sender: TObject);
    procedure Lab_SearchMouseLeave(Sender: TObject);
    procedure Ed_SearchKeyEnter(Sender: TObject);
    procedure Ed_SearchKeyExit(Sender: TObject);
    procedure Lab_Page1ButtonClick(Sender: TObject);
    procedure Lab_Page2ButtonClick(Sender: TObject);
    procedure Lab_Page1ButtonMouseEnter(Sender: TObject);
    procedure Lab_Page1ButtonMouseLeave(Sender: TObject);
    procedure Panel_SearchResize(Sender: TObject);
    procedure Lab_MainMenuMouseEnter(Sender: TObject);
    procedure Lab_MainMenuMouseLeave(Sender: TObject);
    procedure Panel_InfoCenterResize(Sender: TObject);
  private
    procedure ShowPage(iPage: Integer);
    procedure MouseEnterPageHeader(iPage: Integer);
    procedure MouseLeavePageHeader;
    { Private declarations }
  public
    { Public declarations }
    procedure InitializeControlCenter;
  end;

implementation
uses ShareUnt;
{$R *.dfm}

procedure TFrame_ControlCenter.InitializeControlCenter;
begin
  Image_Page.Transparent:=False;
  Page_Control.DoubleBuffered:=True;
  Ed_SearchKey.DoubleBuffered:=True;
  _CUR_PAGE := 0;
  Image_InfoCenter.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis012.jpg');
  Image_UserImgBorder.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis013.jpg');
  Image_Search0.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis015.jpg');
  Image_Search1.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis016.jpg');
  Image_Search2.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Search.BMP');
  Image_ControlBkg.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis017.jpg');
  Image_MainMenu.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\MenuMain.bmp');
  Image_EditBorder.Picture.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Dis033.jpg');
  ShowPage(0);//SHOW DEF PAGE
end;

procedure TFrame_ControlCenter.ShowPage(iPage:Integer);
Var
  bmpBuffer : TBitmap;
begin
  Case iPage Of
    0://联系人
      begin
        try
          bmpBuffer := TBitmap.Create;
          bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Page0.bmp');
          Image_Page.Picture.Assign(bmpBuffer);
          Image_Page.Repaint;
          Page_Control.Pages[0].Show;
          _CUR_PAGE := 0;
        finally
          if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
        end;
      end;
    1://最近联系人
      begin
        try
          bmpBuffer := TBitmap.Create;
          bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Page1.bmp');
          Image_Page.Picture.Assign(bmpBuffer);
          Image_Page.Repaint;
          Page_Control.Pages[1].Show;
          _CUR_PAGE := 1;
        finally
          if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
        end;
      end;
    2://空间
      begin
        try
          bmpBuffer := TBitmap.Create;
          bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Page2.bmp');
          Image_Page.Picture.Assign(bmpBuffer);
          Image_Page.Repaint;
          Page_Control.Pages[2].Show;          
          _CUR_PAGE := 2;
        finally
          if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
        end;
      end;
  end;
end;

procedure TFrame_ControlCenter.MouseEnterPageHeader(iPage:Integer);
Var
  swHotImage : WideString;
  bmpBuffer : TBitmap;
begin
  if Integer(_CUR_PAGE)=iPage then Exit;

  Case _CUR_PAGE Of
    0:
      begin
        if iPage=1 then swHotImage := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Page01Hot.bmp';
        if iPage=2 then swHotImage := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Page02Hot.bmp';
      end;
    1:
      begin
        if iPage=0 then swHotImage := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Page10Hot.bmp';
        if iPage=2 then swHotImage := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Page12Hot.bmp';
      end;
  end;

  if Not WideFileExists(swHotImage) then Exit;
  
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swHotImage);
    Image_Page.Picture.Assign(bmpBuffer);
    Image_Page.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TFrame_ControlCenter.MouseLeavePageHeader;
Var
  swDefImage : WideString;
  bmpBuffer : TBitmap;
begin
  Case _CUR_PAGE Of
    0: swDefImage := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Page0.bmp';
    1: swDefImage := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Page1.bmp';
    2: swDefImage := WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Page2.bmp';
  end;

  if Not WideFileExists(swDefImage) then Exit;

  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(swDefImage);
    Image_Page.Picture.Assign(bmpBuffer);
    Image_Page.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;  
end;

procedure TFrame_ControlCenter.Lab_SearchMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\SearchHot.BMP');
    Image_Search2.Picture.Assign(bmpBuffer);
    Image_Search2.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TFrame_ControlCenter.Lab_SearchMouseLeave(Sender: TObject);
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\Search.BMP');
    Image_Search2.Picture.Assign(bmpBuffer);
    Image_Search2.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TFrame_ControlCenter.Ed_SearchKeyEnter(Sender: TObject);
begin
  Ed_SearchKey.Font.Color := clBlack;
  if WideCompareText(Ed_SearchKey.Text, SEARCH_KEY_HINT)=0 then
    Ed_SearchKey.Text := '';
end;

procedure TFrame_ControlCenter.Ed_SearchKeyExit(Sender: TObject);
begin
  Ed_SearchKey.Font.Color := clGray;
  if Trim(Ed_SearchKey.Text)='' then
    Ed_SearchKey.Text := SEARCH_KEY_HINT;
end;

procedure TFrame_ControlCenter.Lab_Page1ButtonClick(Sender: TObject);
begin
  ShowPage(0);
end;

procedure TFrame_ControlCenter.Lab_Page2ButtonClick(Sender: TObject);
begin
  ShowPage(1);
end;

procedure TFrame_ControlCenter.Lab_Page1ButtonMouseEnter(Sender: TObject);
begin
  MouseEnterPageHeader((Sender As TTntLabel).Tag);
end;

procedure TFrame_ControlCenter.Lab_Page1ButtonMouseLeave(Sender: TObject);
begin
  MouseLeavePageHeader;
end;

procedure TFrame_ControlCenter.Panel_SearchResize(Sender: TObject);
begin
  Ed_SearchKey.Width := Image_Search1.Width;
end;

procedure TFrame_ControlCenter.Lab_MainMenuMouseEnter(Sender: TObject);
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\MenuMainHot.bmp');
    Image_MainMenu.Picture.Assign(bmpBuffer);
    Image_MainMenu.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TFrame_ControlCenter.Lab_MainMenuMouseLeave(Sender: TObject);
Var
  bmpBuffer : TBitmap;
begin
  try
    bmpBuffer := TBitmap.Create;
    bmpBuffer.LoadFromFile(WideExtractFilePath(ParamStr(0)) + 'Skins\BlueSky\MenuMain.bmp');
    Image_MainMenu.Picture.Assign(bmpBuffer);
    Image_MainMenu.Repaint;
  finally
    if Assigned(bmpBuffer) then FreeAndNil(bmpBuffer);
  end;
end;

procedure TFrame_ControlCenter.Panel_InfoCenterResize(Sender: TObject);
begin
  Ed_Key.Width:=Image_InfoCenter.Width-84;
end;

end.
