unit SelectDirUnt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus, ComCtrls, StdCtrls,
  Buttons, TntButtons, Dialogs, TntDialogs, ShellControls, JAMControls,
  ShellLink, JAMDialogs, ImgList, ToolWin, Menus;

type
  TfrmSelectDir = class(TTntForm)
    JamShellLink: TJamShellLink;
    Lab_Path: TTntLabel;
    JamShellList: TJamShellList;
    But_Select: TTntButton;
    TntButton2: TTntButton;
    JamShellCombo: TJamShellCombo;
    ImgList_Toolbar: TImageList;
    ImgList_ToolbarDisabled: TImageList;
    TntToolBar1: TTntToolBar;
    But_Back: TTntToolButton;
    But_GoUp: TTntToolButton;
    But_ChangeView: TTntToolButton;
    JamShellTree: TJamShellTree;
    PopMenu_View: TTntPopupMenu;
    PopMenu_View_View0: TTntMenuItem;
    PopMenu_View_View1: TTntMenuItem;
    PopMenu_View_View2: TTntMenuItem;
    PopMenu_View_View3: TTntMenuItem;
    PopMenu_View_View4: TTntMenuItem;
    procedure TntFormCreate(Sender: TObject);
    procedure TntButton2Click(Sender: TObject);
    procedure But_GoUpClick(Sender: TObject);
    procedure But_BackClick(Sender: TObject);
    procedure JamShellTreeChange(Sender: TObject; Node: TTreeNode);
    procedure PopMenu_View_View0Click(Sender: TObject);
    procedure PopMenu_View_View1Click(Sender: TObject);
    procedure PopMenu_View_View2Click(Sender: TObject);
    procedure PopMenu_View_View3Click(Sender: TObject);
    procedure PopMenu_View_View4Click(Sender: TObject);
    procedure But_ChangeViewClick(Sender: TObject);
    procedure JamShellListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure But_SelectClick(Sender: TObject);
  private
    procedure ViewClick(Sender: TObject);
    { Private declarations }
  public
    InitialDir, Selectfiles : WideString;
    { Public declarations }
  end;

implementation
Uses ShareUnt;

{$R *.dfm}

procedure TfrmSelectDir.TntFormCreate(Sender: TObject);
begin
  JamShellCombo.SelectedFolder := DefaultOpenDir;
end;

procedure TfrmSelectDir.TntButton2Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectDir.But_GoUpClick(Sender: TObject);
begin
  JamShellLink.GoUp;
end;

procedure TfrmSelectDir.But_BackClick(Sender: TObject);
begin
  JamShellTree.MoveInHistory(-1);
end;

procedure TfrmSelectDir.JamShellTreeChange(Sender: TObject;
  Node: TTreeNode);
begin
  But_Back.Enabled := JamShellTree.IsMovePossible(-1);
  But_GoUp.Enabled := Assigned(Node) And (Node.Level>0);
end;

procedure TfrmSelectDir.ViewClick(Sender: TObject);
Var
  iIndex : Integer;
begin
  if Sender is TTntMenuItem then
  begin
    iIndex := (Sender as TTntMenuItem).Tag;
    (Sender as TTntMenuItem).Checked := True;
    Case iIndex of
      0: JamShellList.Thumbnails := True;
      1: JamShellList.ViewStyle := vsSmallIcon;
      2: JamShellList.ViewStyle := vsIcon;
      3: JamShellList.ViewStyle := vsList;
      4: JamShellList.ViewStyle := vsReport;
    end;
  end;
end;

procedure TfrmSelectDir.PopMenu_View_View0Click(Sender: TObject);
begin
  ViewClick(Sender);
end;

procedure TfrmSelectDir.PopMenu_View_View1Click(Sender: TObject);
begin
  ViewClick(Sender);
end;

procedure TfrmSelectDir.PopMenu_View_View2Click(Sender: TObject);
begin
  ViewClick(Sender);
end;

procedure TfrmSelectDir.PopMenu_View_View3Click(Sender: TObject);
begin
  ViewClick(Sender);
end;

procedure TfrmSelectDir.PopMenu_View_View4Click(Sender: TObject);
begin
  ViewClick(Sender);
end;

procedure TfrmSelectDir.But_ChangeViewClick(Sender: TObject);
Var
  i, iTagIndex : Integer;
begin
  iTagIndex:=0;
  for i := 0 to PopMenu_View.Items.Count-1 do
  begin
    if PopMenu_View.Items[i].Checked then
    begin
      iTagIndex := i + 1;
      if iTagIndex>4 then iTagIndex := 0;
      Break;
    end;
  end;
  if Not (iTagIndex in [0..4]) then Exit;
  PopMenu_View.Items[iTagIndex].Click;
end;

procedure TfrmSelectDir.JamShellListSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  But_Select.Enabled := JamShellList.SelectedFiles.Count>0;
end;

procedure TfrmSelectDir.But_SelectClick(Sender: TObject);
Var
  slwSelectLists : TTntStringList;
  i : Integer;
begin
  if JamShellList.SelectedFiles.Count>0 then
  begin
    try
      Screen.Cursor := crHourGlass;
      slwSelectLists := TTntStringList.Create;
      for i := (JamShellList.SelectedFiles.Count-1) Downto 0 do
        slwSelectLists.Add(JamShellList.Path + JamShellList.SelectedFiles.Strings[i]);

      InitialDir := JamShellList.Path;
      SelectFiles := slwSelectLists.Text;
    finally
      if Assigned(slwSelectLists) then FreeAndNil(slwSelectLists);
      Screen.Cursor := crDefault;      
      Close;
    end;
  end;
end;

end.
