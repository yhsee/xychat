unit SunIMTreeList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, StdCtrls, Forms,
  ExtCtrls, ComCtrls, Graphics, StrUtils, XPMan, Math, CommCtrl,ShellApi,
  {Tnt Control}
  TntClasses, TntSysUtils, TntStdCtrls, TntComCtrls, TntGraphics,
  TntForms, TntExtCtrls, TntMenus;

type
  PGroupData = ^TGroupData;
  TGroupData = Record
    swGroup : WideString;
    bSystem : Boolean;
    iCounts : Integer;
    iOnlineCounts : Integer;
    lGroupList : TList;
    nGroup : TTntTreeNode;
    bChildFlash : Boolean;
    iFlashState : Integer;
  end;

  PUserInfo = ^TUserInfo;
  TUserInfo = Record
    ID : WideString;
    State : Integer;
    StateInfo : WideString;
    Group : WideString;
    NickName : WideString;
    Sex : DWord;//0 男 1 女, 默认 0
    Age : Integer;
    Constellation : WideString;
    Address : WideString;
    Phone : WideString;
    Communication : WideString;
    QQMSN : WideString;
    Memo : WideString;
    Reserved : WideString;//保留字
    iImgIndex : Integer;
    nNode : TTntTreeNode;
    nNewlyNode : TTntTreeNode;
    FlashIt : Boolean;
    iFlashState : Integer;
  end;

  tFlashUser = Class(TThread)
  private
//    iIconMoveIndent : Integer;//图标跳转

    lsFlashList : TList;
    tvList : TTntTreeView;

    procedure tfiFlash;
  protected
    Procedure Execute; override;
  public
    Constructor Create(Suspended :Boolean; lsList: TList; tvTree: TTntTreeView);
    Destructor Destroy; override;
  end;

  TDropEvent = procedure(Sender :TObject; const sParams: Widestring) of object;
  TGroupDeleteNotifyEvent = procedure(Sender: TObject;swGroup:WideString;bCanDelete:Boolean) of object;
  TGroupRenameNotifyEvent = procedure(Sender: TObject;swOldGroup, swNewGroup:WideString; var bCanRename:Boolean) of object;
  TUserDeleteNotifyEvent = procedure(Sender: TObject;swID, swNickName:WideString;bCanDelete:Boolean) of object;
  TUserRenameNotifyEvent = procedure(Sender: TObject;swID, swOldNickName,swNewNickName:WideString)of object;

  TSIMTreeList = class(TTntTreeView)
  private
    _STATE_ONLINE, _STATE_LEAVE, _STATE_HIDE, _STATE_OFFLINE,
    _GROUP_EXPANDED_IMAGEINDEX, _GROUP_NONEXPANDED_IMAGEINDEX,
    _MAN_ONLINE_IMAGEINDEX, _MAN_LEAVE_IMAGEINDEX, _MAN_OFFLINE_IMAGEINDEX,
    _WOMEN_ONLINE_IMAGEINDEX, _WOMEN_LEAVE_IMAGEINDEX, _WOMEN_OFFLINE_IMAGEINDEX : Integer;
    
    FImageList : TImageList;
    FItemHeigth, FLevelIndent : Integer;
    FOnlyShowOnline,
    FSelectFullLine : Boolean;

//    nNode : TTntTreeNode;

    //Color
    cSelectedColor, cSelectedBorderColor : TColor;

    //Record
    lsGroup : TList;
    lsUser : TList;
        
    //Flash Thread
    tfuFlash : tFlashUser;

    //Even
    FOnDropFile:TDropEvent;
    FOnClick, FOnDblClick: TNotifyEvent;
//    FOnEdited : TTntTVEditedEvent;
    FOnDeletingGroup : TGroupDeleteNotifyEvent;
    FOnRenameGroup : TGroupRenameNotifyEvent;
    FOnDeletingUser : TUserDeleteNotifyEvent;
    FOnRenameUser : TUserRenameNotifyEvent;

    procedure SetImageLists(Value: TImageList);
    procedure SetFItemHeigth(Value: Integer);
    procedure SetItemHeight(tvTree: TTntTreeview; dItemHeight: DWord);
    procedure smCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    function GetGroupNameWithStat(gdInfo: PGroupData): WideString;
    function GetGroupNameStatWithGroupName(
      swGroup: WideString): WideString;    
    procedure ClearGroupListDatas;
    procedure ClearUserListDatas;
    function GetImageWideUserState(iState, iSex: Integer): Integer;
    procedure StatGroupNodeInfo(nGroup:TTntTreeNode);
    procedure smOnExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure smOnExpanded(Sender: TObject; Node: TTreeNode);
    procedure smOnCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure smOnCollapsed(Sender: TObject; Node: TTreeNode);
    procedure smOnClick(Sender: TObject);
    procedure smOnDblClick(Sender: TObject);
    procedure smOnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure smOnEditing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);      
    procedure smOnEdited(Sender: TObject; Node: TTntTreeNode; var S: WideString);
    procedure smOnCancelEdit(Sender: TObject; Node: TTreeNode);
    function GetNewGroupName: WideString;
    function GetGroupNodeInListIndex(nNode: TTntTreeNode):Integer;
    procedure DropfilesProcess(var Msg:TMessage);Message WM_DROPFILES;
  protected
    procedure SetOnlyShowOnline(Value:Boolean);
    procedure RefreshGroupList;
    {protected}
  public
    {public}    
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;

    function AddGroup(swGroup: WideString; bSystemGroup:Boolean; nInsertNode:TTntTreeNode=Nil): Boolean;
    procedure AddGroupWithInput(nInsertNode: TTntTreeNode=Nil);
    function DeleteGroupWithName(swGroup, swMoveToBaseGroup: WideString): Boolean;
    function ItsSystemGroupWithName(swGroup: WideString): Boolean;
    function ItsSystemGroupWithNode(nGroup: TTntTreeNode): Boolean;
    function GetGroupNode(swGroup: WideString): TTntTreeNode;
    function GetSelectedGroup(nNode: TTntTreeNode): WideString;
    function GetGroupList: WideString;
    function GroupExists(swGroup:WideString):Boolean;
    procedure RenameGroup;

    procedure RenameUser;
    procedure ClearAlllist;
    procedure ExpanedGroup(swGroup:WideString);
    function GroupIsExpaned(swGroup:WideString):Boolean;
    function adduserex(swGroup,swuserid:WideString):boolean;
    function GroupClear(swGroup:WideString):Boolean;
    procedure UserMoveing(swUserid,swNewGroup:WideString);

    function AddUser(swGroup: WideString; udUser: TUserInfo): Boolean;
    function GetSelectedUser(nNode: TTntTreeNode): WideString;
    function GetUserNodeWithID(swID: WideString): TTntTreeNode;
    function GetSelectedUserID(nNode: TTntTreeNode): WideString;
    function GetSelectedUserState(nNode: TTntTreeNode): Integer;
    function GetSelectedUserInfo(nNode: TTntTreeNode):PUserInfo;
    function SetUserStateWithNode(nNode: TTntTreeNode; iState: Integer): Boolean;        
    function SelectedIsUser(nNode: TTntTreeNode): Boolean;
    function DeleteUserWithNode(nNode: TTntTreeNode): Boolean;

    procedure SetNodeFlashState(nNode: TTntTreeNode; bFlash: Boolean);
    procedure SetUserFlashState(swID: WideString; bFlash: Boolean);    
    procedure ClearTUserInfo(Var uiRecord : TUserInfo);
  published
    property S_ONLINE : Integer Read _STATE_ONLINE;
    property S_LEAVE : Integer Read _STATE_LEAVE;
    property S_HIDE : Integer Read _STATE_HIDE;
    property S_OFFLINE : Integer Read _STATE_OFFLINE;
    property OnDropFile:TDropEvent Write FOnDropFile;

    property IMAGE_GROUP_EXPANDED : Integer Read _GROUP_EXPANDED_IMAGEINDEX Write _GROUP_EXPANDED_IMAGEINDEX;
    property IMAGE_GROUP_NONEXPANDED : Integer Read _GROUP_NONEXPANDED_IMAGEINDEX Write _GROUP_NONEXPANDED_IMAGEINDEX;

    property IMAGE_MAN_ONLINE : Integer Read _MAN_ONLINE_IMAGEINDEX Write _MAN_ONLINE_IMAGEINDEX;
    property IMAGE_MAN_OFFLINE : Integer Read _MAN_OFFLINE_IMAGEINDEX Write _MAN_OFFLINE_IMAGEINDEX;
    property IMAGE_MAN_LEAVE : Integer Read _MAN_LEAVE_IMAGEINDEX Write _MAN_LEAVE_IMAGEINDEX;    
    property IMAGE_WOMEN_ONLINE : Integer Read _WOMEN_ONLINE_IMAGEINDEX Write _WOMEN_ONLINE_IMAGEINDEX;
    property IMAGE_WOMEN_OFFLINE : Integer Read _WOMEN_OFFLINE_IMAGEINDEX Write _WOMEN_OFFLINE_IMAGEINDEX;
    property IMAGE_WOMEN_LEAVE : Integer Read _WOMEN_LEAVE_IMAGEINDEX Write _WOMEN_LEAVE_IMAGEINDEX;

    property SelectFullLine : Boolean Read FSelectFullLine Write FSelectFullLine;    
    property ItemHeigth : Integer Read FItemHeigth Write SetFItemHeigth;
    property LevelIndent : Integer Read FLevelIndent Write FLevelIndent;
    property ImageList : TImageList Read FImageList Write SetImageLists;

    property SelectedColor : TColor Read cSelectedColor Write cSelectedColor;
    property SelectedBorderColor : TColor Read cSelectedBorderColor Write cSelectedBorderColor;

    property OnlyShowOnline:Boolean Read FOnlyShowOnline Write SetOnlyShowOnline;

    property OnDeletingGroup : TGroupDeleteNotifyEvent Read FOnDeletingGroup Write FOnDeletingGroup;
    property OnDeletingUser : TUserDeleteNotifyEvent Read FOnDeletingUser Write FOnDeletingUser;
    property OnRenameGroup : TGroupRenameNotifyEvent Read FOnRenameGroup Write FOnRenameGroup;
    property OnRenameUser : TUserRenameNotifyEvent Read FOnRenameUser Write FOnRenameUser;
  end;

  procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Sunwards Software', [TSIMTreeList]);
end;

////////////////////////////////////////////////////////////////////////////////
//                           Flash User Thread 1.0                            //
//                     CopyRight(C) Sunwards SOftware,Inc.                    //
////////////////////////////////////////////////////////////////////////////////

Constructor tFlashUser.Create(Suspended :Boolean; lsList: TList; tvTree: TTntTreeView);
begin
  inherited Create(Suspended);

  lsFlashList := lsList;
  tvList := tvTree;

  Priority := tpLowest;
  FreeOnTerminate := True;
end;

Destructor tFlashUser.Destroy;
begin
  inherited Destroy;
end;

procedure tFlashUser.Execute;
begin
  While Not Terminated do
  begin
    tfiFlash;
    Sleep(300);
  end;
end;

procedure tFlashUser.tfiFlash;
Var
  i : Integer;
  gdRecord : PGroupData;
begin
  if Not Assigned(lsFlashList) then Exit;

  for i := 0 to lsFlashList.Count-1 do
  begin
    if PUserInfo(lsFlashList.Items[i]).FlashIt then
    begin
      if PUserInfo(lsFlashList.Items[i]).nNode.Parent.Expanded then
      begin
        if PUserInfo(lsFlashList.Items[i]).iFlashState=0 then PUserInfo(lsFlashList.Items[i]).iFlashState := -1
          else if PUserInfo(lsFlashList.Items[i]).iFlashState=-1 then PUserInfo(lsFlashList.Items[i]).iFlashState := 1
            else PUserInfo(lsFlashList.Items[i]).iFlashState := 0;
        PGroupData(PUserInfo(lsFlashList.Items[i]).nNode.Parent.Data).bChildFlash := False;
      end
      else
      begin
        gdRecord := PGroupData(PUserInfo(lsFlashList.Items[i]).nNode.Parent.Data);
        gdRecord.bChildFlash := True;
        if gdRecord.iFlashState = 0 then gdRecord.iFlashState := 1
          else gdRecord.iFlashState := 0;
      end;
      tvList.Repaint;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//                            Control Unit                                    //
////////////////////////////////////////////////////////////////////////////////

constructor TSIMTreeList.Create(AOwner: TComponent);
begin 
  _STATE_ONLINE := 0; //0:在线  1 :离开  2:隐身  3:下线
  _STATE_LEAVE := 1;
  _STATE_HIDE := 2;
  _STATE_OFFLINE := 3;
  
  lsGroup := TList.Create;
  lsUser := TList.Create;
  
  inherited Create(AOwner);
  SetItemHeight(Self, 24);  
  FLevelIndent := 20;
  FSelectFullLine := True;
  cSelectedColor := $00FEF7E9;
  cSelectedBorderColor := $00FEDCB6;

  Self.Ctl3D := False;
  Self.ShowLines := False;
  Self.BorderStyle := bsNone;
  Self.ShowRoot := False;
  Self.ShowButtons := True;
  Self.RightClickSelect := True;
  Self.ReadOnly := True;
  Self.RowSelect := True;
  Self.HideSelection := False;
  Self.DoubleBuffered := True; 
  Self.OnCustomDrawItem := smCustomDrawItem;
  Self.AutoExpand := False;
  Self.OnExpanding := smOnExpanding;
  Self.OnExpanded := smOnExpanded;
  Self.OnCollapsing := smOnCollapsing;
  Self.OnCollapsed := smOnCollapsed;
  Self.OnClick := smOnClick;
  Self.OnDblClick := smOnDblClick;
  Self.OnMouseUp := smOnMouseUp;
  Self.OnEditing := smOnEditing;
  Self.OnEdited := smOnEdited;
  Self.OnCancelEdit := smOnCancelEdit;

  tfuFlash := tFlashUser.Create(False, lsUser, Self);
end;

destructor TSIMTreeList.Destroy;
begin
  tfuFlash.Terminate;
  
  ClearGroupListDatas;
  ClearUserListDatas;
  
  inherited Destroy;
end;

procedure TSIMTreeList.ClearGroupListDatas;
Var
  i : LongInt;
begin
  try
    if lsGroup.Count>0 then
    begin
      for i := (lsGroup.Count-1) downto 0 do
      begin
        PGroupData(lsGroup.Items[i]).lGroupList.Clear;
        FreeAndNil(PGroupData(lsGroup.Items[i]).lGroupList);
        Dispose(PGroupData(lsGroup.Items[i]));
      end;
    end;
  finally
    lsGroup.Clear;
  end;
end;

procedure TSIMTreeList.ClearUserListDatas;
Var
  i : LongInt;
begin
  try
    if lsUser.Count>0 then
    begin
      for i := (lsUser.Count-1) downto 0 do
        Dispose(PUserInfo(lsUser.Items[i]));
    end;
  finally
    lsUser.Clear;
  end;
end;

procedure TSIMTreeList.SetImageLists(Value: TImageList);
begin
  FImageList := Value;
  Self.Images := FImageList;
end;

procedure TSIMTreeList.SetFItemHeigth(Value: Integer);
begin
  FItemHeigth := Value;
  SetItemHeight(Self, FItemHeigth);
end;

procedure TSIMTreeList.SetItemHeight(tvTree:TTntTreeview;dItemHeight:DWord);
begin
  Self.Perform(TVM_SETITEMHEIGHT, dItemHeight, 0);
  FItemHeigth := dItemHeight;
end;

function TSIMTreeList.GetGroupNameWithStat(gdInfo:PGroupData):WideString;
begin
  Result := '';
  if Not Assigned(gdInfo) then Exit;

  Result := WideFormat('%s [%d/%d]', [gdInfo.swGroup, gdInfo.iOnlineCounts, gdInfo.iCounts]);
end;

function TSIMTreeList.GetGroupNameStatWithGroupName(swGroup:WideString):WideString;
Var
  i : Integer;
begin
  Result := swGroup;

  for i := 0 to lsGroup.Count-1 do
  begin
    if WideCompareText(PGroupData(lsGroup.Items[i]).swGroup, swGroup)=0 then
    begin
      Result := WideFormat('%s [%d/%d]', [swGroup, PGroupData(lsGroup.Items[i]).iOnlineCounts,
        PGroupData(lsGroup.Items[i]).iCounts]);
      Break;
    end;
  end;
end;

function TSIMTreeList.AddGroup(swGroup:WideString; bSystemGroup:Boolean; nInsertNode:TTntTreeNode=Nil):Boolean;
Var
  gdRecord : PGroupData;
  nNode : TTntTreeNode;
begin
  Result := False;
  if GetGroupNode(swGroup)<>Nil then Exit;

  try
    New(gdRecord);
    gdRecord.swGroup := swGroup;
    gdRecord.bSystem := bSystemGroup;
    gdRecord.iCounts := 0;
    gdRecord.iOnlineCounts := 0;
    gdRecord.lGroupList := TList.Create;

    if nInsertNode=Nil then
    begin
      nNode := Self.Items.Add(Nil, GetGroupNameWithStat(gdRecord));
      nNode.ImageIndex := IMAGE_GROUP_NONEXPANDED;
      nNode.SelectedIndex := IMAGE_GROUP_NONEXPANDED;
      nNode.Data := gdRecord;
      gdRecord.nGroup := nNode;
      lsGroup.Add(gdRecord);
    end
    else
    begin
      nNode := Self.Items.Insert(nInsertNode, GetGroupNameWithStat(gdRecord));
      nNode.ImageIndex := IMAGE_GROUP_NONEXPANDED;
      nNode.SelectedIndex := IMAGE_GROUP_NONEXPANDED;
      nNode.Data := gdRecord;
      gdRecord.nGroup := nNode;
      lsGroup.Insert(GetGroupNodeInListIndex(nInsertNode), gdRecord);
    end;

    Result := True;
  except
    Result := False;
  end;
end;

procedure TSIMTreeList.AddGroupWithInput(nInsertNode:TTntTreeNode=Nil);
Var
  nNode : TTntTreeNode;
  swName : WideString;
  gdRecord : PGroupData;
begin
  Self.ReadOnly := False;

  swName := GetNewGroupName;
  New(gdRecord);
  gdRecord.swGroup := swName;
  gdRecord.bSystem := False;
  gdRecord.iCounts := 0;
  gdRecord.iOnlineCounts := 0;
  gdRecord.lGroupList := TList.Create;

  if nInsertNode=Nil then
  begin
    nNode := Self.Items.Add(Nil, swName);
    nNode.ImageIndex := IMAGE_GROUP_NONEXPANDED;
    nNode.SelectedIndex := IMAGE_GROUP_NONEXPANDED;
    gdRecord.nGroup := nNode;
    nNode.Data := gdRecord;
    lsGroup.Add(gdRecord);
  end
  else
  begin
    nNode := Self.Items.Insert(nInsertNode, GetNewGroupName);
    nNode.ImageIndex := IMAGE_GROUP_NONEXPANDED;
    nNode.SelectedIndex := IMAGE_GROUP_NONEXPANDED;
    gdRecord.nGroup := nNode;
    nNode.Data := gdRecord;
    lsGroup.Insert(GetGroupNodeInListIndex(nInsertNode), gdRecord);
  end;
  nNode.EditText;
end;

function TSIMTreeList.GetNewGroupName:WideString;
Const
  fName : WideString = '新建组 %d';
Var
  i : Integer;
begin
  for i := 1 to 1000 do
  begin
    Result := WideFormat(fName, [i]);
    if Not GroupExists(Result) then Break;
  end;
end;

function TSIMTreeList.GetGroupNodeInListIndex(nNode:TTntTreeNode):Integer;
Var
  i : Integer;
begin
  Result := 0;
  for i := 0 to lsGroup.Count-1 do
  begin
    if WideCompareText(PGroupData(lsGroup.Items[i]).swGroup, PGroupData(nNode.Data).swGroup)=0 then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TSIMTreeList.GetGroupList:WideString;
Var
  i : Integer;
  slwGroup : TTntStringList;
begin
  try
    slwGroup := TTntStringList.Create;
    for i := 0 to lsGroup.Count-1 do
      slwGroup.Add(PGroupData(lsGroup.Items[i]).swGroup);

    Result := slwGroup.Text;
  finally
    if Assigned(slwGroup) then FreeAndNil(slwGroup);
  end;
end;

function TSIMTreeList.GroupExists(swGroup:WideString):Boolean;
Var
  i : Integer;
begin
  Result := False;

  for i := 0 to lsGroup.Count-1 do
  begin
    if WideCompareText(PGroupData(lsGroup.Items[i]).swGroup, swGroup)=0 then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TSIMTreeList.DeleteGroupWithName(swGroup, swMoveToBaseGroup:WideString):Boolean;
Var
  i, iGroupIndex : Integer;
  gdRecord, gdBase : PGroupData;
  uiRecord : PUserInfo;
  bUserCanDelete : Boolean;
begin
  Result := False;

  gdRecord:=nil; gdBase:=nil;
  if Trim(swGroup)='' then Exit;
  if Trim(swMoveToBaseGroup)='' then Exit;
  if WideCompareText(swGroup, swMoveToBaseGroup)=0 then Exit;

  iGroupIndex := -1;
  for i := 0 to lsGroup.Count-1 do
  begin
    if WideCompareText(PGroupData(lsGroup.Items[i]).swGroup, swMoveToBaseGroup)=0 then
    begin
      iGroupIndex := i;
      gdBase := PGroupData(lsGroup.Items[i]);
      Break;
    end;
  end;
  if iGroupIndex=-1 then Exit;

  iGroupIndex := -1;
  for i := 0 to lsGroup.Count-1 do
  begin
    if WideCompareText(PGroupData(lsGroup.Items[i]).swGroup, swGroup)=0 then
    begin
      iGroupIndex := i;
      gdRecord := PGroupData(lsGroup.Items[i]);
      if gdRecord.bSystem then iGroupIndex := -1;
      Break;
    end;
  end;
  if iGroupIndex=-1 then Exit;

  bUserCanDelete := True;
  if Assigned(FOnDeletingGroup) then FOnDeletingGroup(Self, swGroup, bUserCanDelete);
  if Not bUserCanDelete then Exit;

  try
    Self.Items.BeginUpdate;
    try
      for i := 0 to gdRecord.lGroupList.Count-1 do
      begin
        uiRecord := PUserInfo(gdRecord.lGroupList.Items[i]);
        uiRecord.Group := swMoveToBaseGroup;
        if (uiRecord.State=_STATE_ONLINE) Or (uiRecord.State=_STATE_LEAVE) then
        begin
          uiRecord.nNode.MoveTo(gdBase.nGroup, naAddChildFirst);
          gdBase.lGroupList.Insert(0, uiRecord);
        end
        else
        begin
          uiRecord.nNode.MoveTo(gdBase.nGroup, naAddChild);
          gdBase.lGroupList.Add(uiRecord);
        end;
      end;
      gdRecord.nGroup.Delete;
      Dispose(gdRecord);      
      lsGroup.Delete(iGroupIndex);
      Result := True;
    except
      Result := False;
    end;
  finally
    Self.Items.EndUpdate;
  end;
end;

procedure TSIMTreeList.UserMoveing(swUserid,swNewGroup:WideString);
Var
  i, n,iGroupIndex ,iUserIndex : Integer;
  gdNewGroup,gdOldGroup : PGroupData;
  uiUser : PUserInfo;
begin
  if Trim(swUserid)='' then Exit;
  if Trim(swNewGroup)='' then Exit;

  iUserIndex := -1; uiUser:=nil;  gdNewGroup:=nil; gdOldGroup:=nil;
  for i := 0 to lsUser.Count-1 do
  begin
    if WideCompareText(PUserInfo(lsUser.Items[i]).ID, swUserid)=0 then
    begin
      uiUser := PUserInfo(lsUser.Items[i]);
      iUserIndex := i;
      Break;
    end;
  end;
  if iUserIndex=-1 then Exit;  //帐号不存在也退出

  iGroupIndex := -1;
  for i := 0 to lsGroup.Count-1 do
  begin
    if WideCompareText(PGroupData(lsGroup.Items[i]).swGroup, swNewGroup)=0 then
    begin
      iGroupIndex := i;
      gdNewGroup := PGroupData(lsGroup.Items[i]);
      Break;
    end;
  end;
  if iGroupIndex=-1 then Exit; //目标组不存在就退出

  iGroupIndex := -1;
  for i := 0 to lsGroup.Count-1 do
  begin
    if WideCompareText(PGroupData(lsGroup.Items[i]).swGroup, uiUser.Group)=0 then
    begin
      iGroupIndex := i;
      gdOldGroup := PGroupData(lsGroup.Items[i]);
      Break;
    end;
  end;
  if iGroupIndex=-1 then Exit; //源组不存在就退出

  try
    Self.Items.BeginUpdate;
    try

      n:=gdOldGroup.lGroupList.IndexOf(uiUser);
      gdOldGroup.lGroupList.Delete(n);

      uiUser.Group:=swNewGroup;
      
      if (uiUser.State=_STATE_ONLINE) Or (uiUser.State=_STATE_LEAVE) then
        begin
        uiUser.nNode.MoveTo(gdNewGroup.nGroup, naAddChildFirst);
        gdNewGroup.lGroupList.Insert(0, uiUser);
        end else begin
        uiUser.nNode.MoveTo(gdNewGroup.nGroup, naAddChild);
        gdNewGroup.lGroupList.Add(uiUser);
        end;

    except

    end;
  finally
    Self.Items.EndUpdate;
  end;

  StatGroupNodeInfo(gdOldGroup.nGroup);
  gdOldGroup.nGroup.Text := GetGroupNameWithStat(PGroupData(gdOldGroup.nGroup.Data));

  StatGroupNodeInfo(gdNewGroup.nGroup);
  gdNewGroup.nGroup.Text := GetGroupNameWithStat(PGroupData(gdNewGroup.nGroup.Data));
end;


procedure TSIMTreeList.SetOnlyShowOnline(Value:Boolean);
begin
if Value<>OnlyShowOnline then
   begin
   OnlyShowOnline:=Value;
   //RefreshGroupList;
   end;
end;

procedure TSIMTreeList.RefreshGroupList;
begin

end;

function TSIMTreeList.ItsSystemGroupWithName(swGroup : WideString):Boolean;
Var
  i : Integer;
begin
  Result := False;
  for i := 0 to lsGroup.Count-1 do
  begin
    if WideCompareText(PGroupData(lsGroup.Items[i]).swGroup, swGroup)=0 then
    begin
      Result := PGroupData(lsGroup.Items[i]).bSystem;
      Break;
    end;
  end;
end;

function TSIMTreeList.ItsSystemGroupWithNode(nGroup : TTntTreeNode):Boolean;
//Var
//  i : Integer;
begin
  Result := False;
  if nGroup.Data=Nil then Exit;
  Result := PGroupData(nGroup.Data).bSystem;
end;

procedure TSIMTreeList.RenameGroup;
begin
  if Self.Selected=Nil then Exit;
  if Self.Selected.Level<>0 then Exit;

  Self.ReadOnly := False;
  Self.Selected.Text := PGroupData(Self.Selected.Data).swGroup;
  Self.Selected.EditText;
end;

procedure TSIMTreeList.RenameUser;
begin
  if Self.Selected=Nil then Exit;
  if Self.Selected.Level<>1 then Exit;

  Self.ReadOnly := False;
  Self.Selected.Text := PUserInfo(Self.Selected.Data).NickName;
  Self.Selected.EditText;
end;

function TSIMTreeList.adduserex(swGroup,swuserid:widestring):boolean;
Var
  i, iIndex : Integer;
  nGroup, nUser : TTntTreeNode;
  uiRecord : PUserInfo;
begin
  Result := False;
  //检查组是否存在，不存在就跳出。
  nGroup := GetGroupNode(swGroup);
  if nGroup=Nil then Exit;
  //检查用户是否存在
  iIndex := -1;
  for i := 0 to lsUser.Count-1 do
  begin
    if WideCompareText(PUserInfo(lsUser.Items[i]).ID, swuserid)=0 then
    begin
      iIndex := i;
      Break;
    end;
  end;
  //如果用户不存在就跳出
  if iIndex=-1 then Exit;
  uiRecord := PUserInfo(lsUser.Items[iIndex]);

  if (uiRecord.State=_STATE_ONLINE) Or (uiRecord.State=_STATE_LEAVE) then
  begin
    PGroupData(nGroup.Data).lGroupList.Insert(0, uiRecord);
    
    nUser := Self.Items.AddChildFirst(nGroup, uiRecord.NickName);
    nUser.ImageIndex := uiRecord.iImgIndex;
    nUser.SelectedIndex := uiRecord.iImgIndex;
    nUser.Data := uiRecord;
  end;
  if (uiRecord.State=_STATE_OFFLINE) Or (uiRecord.State=_STATE_HIDE) then
  begin
    PGroupData(nGroup.Data).lGroupList.Add(uiRecord);

    nUser := Self.Items.AddChild(nGroup, uiRecord.NickName);
    nUser.ImageIndex := uiRecord.iImgIndex;
    nUser.SelectedIndex := uiRecord.iImgIndex;
    nUser.Data := uiRecord;
  end;
  Result := True;
  StatGroupNodeInfo(nGroup);
  nGroup.Text := GetGroupNameWithStat(PGroupData(nGroup.Data));
  nGroup.Expanded:=True; 
end;

function TSIMTreeList.GroupClear(swGroup:WideString):Boolean;
Var
  nGroup : TTntTreeNode;
begin
  Result := False;
  //检查组是否存在，不存在就跳出。
  nGroup := GetGroupNode(swGroup);
  if nGroup=Nil then Exit;
  nGroup.Delete;
  Result:=true;
end;

function TSIMTreeList.AddUser(swGroup: WideString; udUser:TUserInfo):Boolean;
Var
  i, iIndex : Integer;
  nGroup, nUser : TTntTreeNode;
  uiRecord : PUserInfo;
begin
  Result := False;
  //检查组是否存在，不存在就跳出。
  nGroup := GetGroupNode(swGroup);
  if nGroup=Nil then Exit;
  //检查用户是否存在
  iIndex := -1;
  for i := 0 to lsUser.Count-1 do
  begin
    if WideCompareText(PUserInfo(lsUser.Items[i]).ID, udUser.ID)=0 then
    begin
      iIndex := i;
      Break;
    end;
  end;

  if iIndex=-1 then
  begin
    //如果用户不存在就插入
    New(uiRecord);
    uiRecord.ID := udUser.ID;
    uiRecord.State := udUser.State;
    uiRecord.StateInfo := udUser.StateInfo;
    uiRecord.Group := swGroup;
    uiRecord.NickName := udUser.NickName;
    uiRecord.Sex := udUser.Sex;
    uiRecord.Age := udUser.Age;
    uiRecord.Constellation := udUser.Constellation;
    uiRecord.Address := udUser.Address;
    uiRecord.Phone := udUser.Phone;
    uiRecord.Communication := udUser.Communication;
    uiRecord.QQMSN := udUser.QQMSN;
    uiRecord.Memo := udUser.Memo;
    uiRecord.Reserved := udUser.Reserved;
    uiRecord.FlashIt := udUser.FlashIt;
    uiRecord.iFlashState := 0;
    uiRecord.iImgIndex := GetImageWideUserState(udUser.State, udUser.Sex);
    uiRecord.nNode := Nil;
    uiRecord.nNewlyNode := Nil;

    if (udUser.State=_STATE_ONLINE) Or (udUser.State=_STATE_LEAVE) then
    begin
      PGroupData(nGroup.Data).lGroupList.Insert(0, uiRecord);
      lsUser.Insert(0, uiRecord);

      nUser := Self.Items.AddChildFirst(nGroup, uiRecord.NickName);
      
      nUser.ImageIndex := uiRecord.iImgIndex;
      nUser.SelectedIndex := uiRecord.iImgIndex;
      uiRecord.nNode := nUser;
      nUser.Data := uiRecord;
    end;
    if (udUser.State=_STATE_OFFLINE) Or (udUser.State=_STATE_HIDE) then
    begin
      PGroupData(nGroup.Data).lGroupList.Add(uiRecord);
      lsUser.Add(uiRecord);

      nUser := Self.Items.AddChild(nGroup, uiRecord.NickName);
      nUser.ImageIndex := uiRecord.iImgIndex;
      nUser.SelectedIndex := uiRecord.iImgIndex;
      uiRecord.nNode := nUser;
      nUser.Data := uiRecord;
    end;
    Result := True;
  end
  else
  begin
    //如果存在就更新
    uiRecord := PUserInfo(lsUser.Items[iIndex]);
    //Change Location
    if (udUser.State=_STATE_ONLINE) Or (udUser.State=_STATE_LEAVE) then
    begin
      if (uiRecord.State = _STATE_HIDE)
        Or (uiRecord.State = _STATE_OFFLINE) then
      begin
        uiRecord.nNode.MoveTo(uiRecord.nNode.Parent, naAddChildFirst);
      end;
    end;
    if (udUser.State=_STATE_HIDE) Or (udUser.State=_STATE_OFFLINE) then
    begin
      if (uiRecord.State = _STATE_ONLINE)
        Or (uiRecord.State = _STATE_LEAVE) then
      begin
        uiRecord.nNode.MoveTo(uiRecord.nNode.Parent, naAddChild);
      end;
    end;

    uiRecord.State := udUser.State;
    uiRecord.StateInfo := udUser.StateInfo;
    uiRecord.Group := swGroup;
    uiRecord.NickName := udUser.NickName;
    uiRecord.Sex := udUser.Sex;
    uiRecord.Age := udUser.Age;
    uiRecord.Constellation := udUser.Constellation;
    uiRecord.Address := udUser.Address;
    uiRecord.Phone := udUser.Phone;
    uiRecord.Communication := udUser.Communication;
    uiRecord.QQMSN := udUser.QQMSN;
    uiRecord.Memo := udUser.Memo;
    uiRecord.Reserved := udUser.Reserved;
    uiRecord.FlashIt := udUser.FlashIt;
    uiRecord.iFlashState := 0;
    uiRecord.iImgIndex := GetImageWideUserState(udUser.State, udUser.Sex);
    //刷新显示
    uiRecord.nNode.Text := uiRecord.NickName;
    uiRecord.nNode.ImageIndex := uiRecord.iImgIndex;
    uiRecord.nNode.SelectedIndex := uiRecord.iImgIndex;

    if uiRecord.nNewlyNode<>Nil then
    begin
      uiRecord.nNewlyNode.Text := uiRecord.NickName;
      uiRecord.nNewlyNode.ImageIndex := uiRecord.iImgIndex;
      uiRecord.nNewlyNode.SelectedIndex := uiRecord.iImgIndex;
    end;
    Result := True;
  end;

  StatGroupNodeInfo(nGroup);
  nGroup.Text := GetGroupNameWithStat(PGroupData(nGroup.Data));
end;

function TSIMTreeList.GetGroupNode(swGroup:WideString):TTntTreeNode;
Var
  nNode : TTntTreeNode;
//  swKey : WideString;
begin
  Result := Nil;

  nNode := Self.Items.GetFirstNode;
  While nNode<>Nil do
  begin
    if nNode.Data=Nil then
    begin
      nNode := nNode.getNextSibling;
      Continue;
    end;
    if WideCompareStr(PGroupData(nNode.Data).swGroup, swGroup)=0 then
    begin
      Result := nNode;
      Break;
    end;
    nNode := nNode.getNextSibling;
  end;
end;

function TSIMTreeList.GetSelectedGroup(nNode:TTntTreeNode):WideString;
begin
  Result := '';
  if nNode=Nil then Exit;
  if nNode.Data=Nil then Exit;
  if nNode.Level<>0 then Exit;

  Result := PGroupData(nNode.Data).swGroup;
end;

function TSIMTreeList.GetSelectedUser(nNode:TTntTreeNode):WideString;
begin
  Result := '';
  if nNode=Nil then Exit;
  if nNode.Data=Nil then Exit;
  if nNode.Level=0 then Exit;

  Result := PUserInfo(nNode.Data).NickName;
end;

function TSIMTreeList.GetUserNodeWithID(swID: WideString): TTntTreeNode;
Var
  i : Integer;
begin
  Result := Nil;
  if Trim(swID)='' then Exit;

  for i := 0 to lsUser.Count-1 do
  begin
    if WideCompareText(PUserInfo(lsUser.Items[i]).ID, swID)=0 then
    begin
      Result := PUserInfo(lsUser.Items[i]).nNode;
      Break;
    end;
  end;
end;

function TSIMTreeList.GetSelectedUserState(nNode:TTntTreeNode):Integer;
begin
  Result := -1;
  if nNode=Nil then Exit;
  if nNode.Data=Nil then Exit;
  if nNode.Level=0 then Exit;

  Result := PUserInfo(nNode.Data).State;
end;

function TSIMTreeList.GetSelectedUserInfo(nNode: TTntTreeNode):PUserInfo;
begin
  Result := Nil;
  if nNode=Nil then Exit;
  if nNode.Data=Nil then Exit;
  if nNode.Level=0 then Exit;

  Result := PUserInfo(nNode.Data);
end;

function TSIMTreeList.SetUserStateWithNode(nNode:TTntTreeNode; iState:Integer):Boolean;
begin
  Result := False;
  if nNode=Nil then Exit;
  if nNode.Data=Nil then Exit;
  if nNode.Level=0 then Exit;
  if Not (iState In [0..3]) then Exit;

  try
    Self.Items.BeginUpdate;
    //Change Location
    if (iState=_STATE_ONLINE) Or (iState=_STATE_LEAVE) then
    begin
      if (PUserInfo(nNode.Data).State = _STATE_HIDE)
        Or (PUserInfo(nNode.Data).State = _STATE_OFFLINE) then
      begin
        nNode.MoveTo(nNode.Parent, naAddChildFirst);
        if PUserInfo(nNode.Data).nNewlyNode<>Nil then
        begin
          PUserInfo(nNode.Data).nNewlyNode.Text := '';
          PUserInfo(nNode.Data).nNewlyNode.MoveTo(Nil, naAddFirst);
          PUserInfo(nNode.Data).nNewlyNode.Text := PUserInfo(nNode.Data).NickName;
        end;
      end;
    end;
    if (iState=_STATE_HIDE) Or (iState=_STATE_OFFLINE) then
    begin
      if (PUserInfo(nNode.Data).State = _STATE_ONLINE)
        Or (PUserInfo(nNode.Data).State = _STATE_LEAVE) then
      begin
        nNode.MoveTo(nNode.Parent, naAddChild);
        if PUserInfo(nNode.Data).nNewlyNode<>Nil then
        begin
          PUserInfo(nNode.Data).nNewlyNode.Text := '';
          PUserInfo(nNode.Data).nNewlyNode.MoveTo(Nil, naAdd);
          PUserInfo(nNode.Data).nNewlyNode.Text := PUserInfo(nNode.Data).NickName;
        end;        
      end;
    end;

    PUserInfo(nNode.Data).State := iState;
    PUserInfo(nNode.Data).iImgIndex := GetImageWideUserState(iState, PUserInfo(nNode.Data).Sex);
    PUserInfo(nNode.Data).FlashIt := False;
    nNode.ImageIndex := PUserInfo(nNode.Data).iImgIndex;
    nNode.SelectedIndex := PUserInfo(nNode.Data).iImgIndex;
    if PUserInfo(nNode.Data).nNewlyNode<>Nil then
    begin
      PUserInfo(nNode.Data).nNewlyNode.ImageIndex := PUserInfo(nNode.Data).iImgIndex;
      PUserInfo(nNode.Data).nNewlyNode.SelectedIndex := PUserInfo(nNode.Data).iImgIndex;
    end;
    Result := True;
  finally
    Self.Items.EndUpdate;
  end;
end;

function TSIMTreeList.GetSelectedUserID(nNode:TTntTreeNode):WideString;
begin
  Result := '';
  if nNode=Nil then Exit;
  if nNode.Data=Nil then Exit;
  if nNode.Level=0 then Exit;

  Result := PUserInfo(nNode.Data).ID;
end;

function TSIMTreeList.SelectedIsUser(nNode:TTntTreeNode):Boolean;
begin
  Result := False;
  if nNode=Nil then Exit;
  if nNode.Level=0 then Exit;

  Result := True;
end;

function TSIMTreeList.DeleteUserWithNode(nNode: TTntTreeNode): Boolean;
Var
  i, iUserIndex : Integer;
  swCurID : WideString;
  nGroup : TTntTreeNode;
  uiUser : PUserInfo;
  bUserCanDelete : Boolean;
begin
  Result := False;
  if nNode=Nil then Exit;
  if nNode.Level=0 then Exit;
  if nNode.Data=Nil then Exit;

  iUserIndex := -1;  uiUser:=nil;
  swCurID := PUserInfo(nNode.Data).ID;
  for i := 0 to lsUser.Count-1 do
  begin
    if WideCompareText(PUserInfo(lsUser.Items[i]).ID, swCurID)=0 then
    begin
      uiUser := PUserInfo(lsUser.Items[i]);
      iUserIndex := i;
      Break;
    end;
  end;
  if iUserIndex=-1 then Exit;

  Result := False;
  //Group Process       
  nGroup := uiUser.nNode.Parent;
  if nGroup=Nil then Exit;
  if nGroup.Data=Nil then Exit;

  bUserCanDelete := True;
  if Assigned(FOnDeletingUser) then FOnDeletingUser(Self, swCurID, uiUser.NickName, bUserCanDelete);
  if Not bUserCanDelete then Exit;

  try
    for i := 0 to PGroupData(nGroup.Data).lGroupList.Count-1 do
    begin
      if WideCompareText(PUserInfo(PGroupData(nGroup.Data).lGroupList.Items[i]).ID, swCurID)=0 then
      begin
        PGroupData(nGroup.Data).lGroupList.Delete(i);
        Break;
      end;
    end;

    if PUserInfo(uiUser.nNode.Data).nNewlyNode<>Nil then
      PUserInfo(uiUser.nNode.Data).nNewlyNode.Delete;
    uiUser.nNode.Delete;
    Dispose(PUserInfo(lsUser.Items[iUserIndex]));
    lsUser.Delete(iUserIndex);
    Result := True;

    StatGroupNodeInfo(nGroup);
    nGroup.Text := GetGroupNameWithStat(PGroupData(nGroup.Data));
  except
    Result := False;
  end;
end;

procedure TSIMTreeList.ClearAlllist;
begin
ClearUserListDatas;
ClearGroupListDatas;
self.items.Clear;
end;

procedure TSIMTreeList.ExpanedGroup(swGroup:WideString);
Var
  i : Integer;
  nGroup: TTntTreeNode;
begin
  //检查组是否存在，不存在就跳出。
  nGroup := GetGroupNode(swGroup);
  if nGroup=Nil then Exit;

  for i := 0 to lsGroup.Count-1 do
    PGroupData(lsGroup.Items[i]).nGroup.Expanded:=False;

  nGroup.Expanded:=True;
end;

function TSIMTreeList.GroupIsExpaned(swGroup:WideString):Boolean;
Var
  nGroup: TTntTreeNode;
begin
  Result:=True;
  //检查组是否存在，不存在就跳出。
  nGroup := GetGroupNode(swGroup);
  if nGroup=Nil then Exit;
  Result:=nGroup.Expanded;
end;

procedure TSIMTreeList.ClearTUserInfo(Var uiRecord : TUserInfo);
begin
  uiRecord.ID := '';
  uiRecord.State := S_LEAVE;
  uiRecord.StateInfo := '';
  uiRecord.Group := '';
  uiRecord.NickName := '';
  uiRecord.Sex := 0;
  uiRecord.Age := 0;
  uiRecord.Constellation := '';
  uiRecord.Address := '';
  uiRecord.Phone := '';
  uiRecord.Communication := '';
  uiRecord.QQMSN := '';
  uiRecord.Memo := '';
  uiRecord.Reserved := '';
  uiRecord.FlashIt := False;
  uiRecord.iFlashState := 0;
end;

procedure TSIMTreeList.SetNodeFlashState(nNode: TTntTreeNode; bFlash:Boolean);
begin
  if nNode=Nil then Exit;
  if nNode.Level=0 then Exit;
  PUserInfo(nNode.Data).FlashIt := bFlash;
  PUserInfo(nNode.Data).iFlashState := 0;
  if Not bFlash then PUserInfo(nNode.Data).iFlashState := 0;
  Self.Repaint;
end;

procedure TSIMTreeList.SetUserFlashState(swID: WideString; bFlash:Boolean);
Var
  i : Integer;
begin
  if Trim(swID)='' then Exit;

  for i := 0 to lsUser.Count-1 do
  begin
    if WideCompareText(PUserInfo(lsUser.Items[i]).ID, swID)=0 then
    begin
      PUserInfo(lsUser.Items[i]).FlashIt := bFlash;
      PUserInfo(lsUser.Items[i]).iFlashState := 0;
      if Not bFlash then PUserInfo(lsUser.Items[i]).iFlashState := 0;
      Break;
    end;
  end;

  Self.Repaint;
end;

function TSIMTreeList.GetImageWideUserState(iState, iSex:Integer):Integer;
begin
  Case iSex Of
    1://Women
      begin
        if iState=_STATE_ONLINE then Result := _WOMEN_ONLINE_IMAGEINDEX
          else if iState=_STATE_LEAVE then Result := _WOMEN_LEAVE_IMAGEINDEX
            else if (iState=_STATE_HIDE) Or (iState=_STATE_OFFLINE) then Result := _WOMEN_OFFLINE_IMAGEINDEX
              else Result := _WOMEN_OFFLINE_IMAGEINDEX;
      end;
    else//Man 默认
      begin
        if iState=_STATE_ONLINE then Result := _MAN_ONLINE_IMAGEINDEX
          else if iState=_STATE_LEAVE then Result := _MAN_LEAVE_IMAGEINDEX
            else if (iState=_STATE_HIDE) Or (iState=_STATE_OFFLINE) then Result := _MAN_OFFLINE_IMAGEINDEX
              else Result := _MAN_OFFLINE_IMAGEINDEX;
      end;
  end;
end;

procedure TSIMTreeList.StatGroupNodeInfo(nGroup:TTntTreeNode);
Var
  i, iOnlines, iCounts : Integer;
  gdList : PGroupData;
begin
  if nGroup=Nil then Exit;

  iOnlines := 0;
  iCounts := 0;

  gdList := PGroupData(nGroup.Data);
  for i := 0 to gdList.lGroupList.Count-1 do
  begin
    if (PUserInfo(gdList.lGroupList.Items[i]).State=_STATE_ONLINE)
      Or (PUserInfo(gdList.lGroupList.Items[i]).State=_STATE_LEAVE) then Inc(iOnlines);
    Inc(iCounts);
  end;

  gdList.iOnlineCounts := iOnlines;
  gdList.iCounts := iCounts;
end;

////////////////////////////////////////////////////////////////////////////////
//                      Draw Item With Sunwards GM 1.0                        //
//                Copyright(C) Sunwards Software, 2007.08.27                  //
////////////////////////////////////////////////////////////////////////////////

procedure TSIMTreeList.smCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
Var
  rRect : TRect;
  icoIcon : TIcon;
  swText, swIdiograph : WideString;
  iImgIndex, iFalseRect : Integer;
  //bFlash,
   bFlashGroup : Boolean;
begin
  bFlashGroup:=False;
  if Node=Nil then Exit;
  if Node.Data=Nil then Exit;

  swText := Node.Text;
  if Node.Level>0 then      
  begin
    swIdiograph := PUserInfo(Node.Data).Reserved;
    iImgIndex := Node.ImageIndex;                
//    bFlash := PUserInfo(Node.Data).FlashIt;
    iFalseRect := PUserInfo(Node.Data).iFlashState;
    bFlashGroup := False;
  end
  else
  begin
    if Node.Expanded then iImgIndex := _GROUP_EXPANDED_IMAGEINDEX        
      else iImgIndex := _GROUP_NONEXPANDED_IMAGEINDEX;
    if Node.Data<>Nil then
      bFlashGroup := PGroupData(Node.Data).bChildFlash And (PGroupData(Node.Data).iFlashState=1);
//    bFlash := False;
    iFalseRect := 0;
  end;

  with Self.Canvas do
  begin
    DefaultDraw := False;

    if (cdsselected in State) then
    begin
      Brush.Color := cSelectedColor;
      Font.Color := clBlack;
      rRect := Node.DisplayRect(False);
      if Not FSelectFullLine then rRect.Left := rRect.Left + (Node.Level * FLevelIndent) + 20;
      FillRect(rRect);
      rRect := Node.DisplayRect(False);
      //Draw NickName
      if bFlashGroup then swText := '';
      WideCanvasTextOut(Self.Canvas, rRect.Left + (Node.Level * FLevelIndent) + 24,
        rRect.Top + (FItemHeigth - 17), swText);
      //Draw Idiograph
      if (Node.Level=1) And (Trim(swIdiograph)<>'') then
      begin
        Font.Color := clGray;
        Refresh;
        swIdiograph := WideFormat('(%s)', [swIdiograph]);
        WideCanvasTextOut(Self.Canvas, rRect.Left + (Node.Level * FLevelIndent) +
        WideCanvasTextWidth(Self.Canvas, swText) + 28, rRect.Top + (FItemHeigth - 17), swIdiograph);
      end;
      //Draw Selected Box
      Brush.Color := cSelectedBorderColor;
      if Not FSelectFullLine then
        rRect.Left := rRect.Left + (Node.Level * FLevelIndent) + 20;
      FrameRect(rRect);
      //Draw Icon
      icoIcon := TIcon.Create;
      try
        FImageList.GetIcon(iImgIndex, icoIcon);
        DrawIconEx(Handle, rRect.Left + (Node.Level * FLevelIndent) + 2 - Abs(iFalseRect),
          rRect.Top + (FItemHeigth - 19) - iFalseRect, icoIcon.Handle, 0, 0, 0, 0, DI_NORMAL);
      finally
        if Assigned(icoIcon) then FreeAndNil(icoIcon);
      end;
    end
    else
    begin
      Brush.Style := bsClear;
      Font.Color := clBlack;
      rRect := Node.DisplayRect(False);
      FillRect(rRect);
      //Draw Icon
      icoIcon := TIcon.Create;
      try
        FImageList.GetIcon(iImgIndex, icoIcon);
        DrawIconEx(Handle, rRect.Left + (Node.Level * FLevelIndent) + 2 - Abs(iFalseRect),
          rRect.Top + (FItemHeigth - 19) - iFalseRect, icoIcon.Handle, 0, 0, 0, 0, DI_NORMAL);
      finally
        if Assigned(icoIcon) then FreeAndNil(icoIcon);
      end;
      //Draw NickName
      if bFlashGroup then swText := '';
      WideCanvasTextOut(Self.Canvas, rRect.Left + (Node.Level * FLevelIndent) + 24,
        rRect.Top + (FItemHeigth - 17), swText);
      //Draw Idiograph
      if (Node.Level=1) And (Trim(swIdiograph)<>'') then
      begin
        Font.Color := clGray;
        Refresh;
        swIdiograph := WideFormat('(%s)', [swIdiograph]);
        WideCanvasTextOut(Self.Canvas, rRect.Left + (Node.Level * FLevelIndent) +
        WideCanvasTextWidth(Self.Canvas, swText) + 28 , rRect.Top + (FItemHeigth - 17), swIdiograph);
      end;
    end;
  end;
end;

procedure TSIMTreeList.smOnExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
begin
  Self.Items.BeginUpdate;
end;

procedure TSIMTreeList.smOnExpanded(Sender: TObject; Node: TTreeNode);
begin
  Self.Items.EndUpdate;
end;

procedure TSIMTreeList.smOnCollapsing(Sender: TObject; Node: TTreeNode;
  var AllowCollapse: Boolean);
begin
  Self.Items.BeginUpdate;
end;

procedure TSIMTreeList.smOnCollapsed(Sender: TObject; Node: TTreeNode);
begin
  Self.Items.EndUpdate;
end;

procedure TSIMTreeList.smOnClick(Sender: TObject);
begin
  if Assigned(FOnClick) Then FOnClick(Sender);
end;

procedure TSIMTreeList.smOnDblClick(Sender: TObject);
begin
  if Assigned(FOnDblClick) Then FOnDblClick(Sender);
end;

procedure TSIMTreeList.smOnMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (htOnItem in Self.GetHitTestInfoAt(X, Y)) then
  begin
    if Self.Selected<>Nil then
    begin
      if Self.Selected.Level=0 then
        Self.Selected.Expanded := Not Self.Selected.Expanded;
    end;
  end;
end;

procedure TSIMTreeList.smOnEditing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);
begin
 case Node.Level of
  0:AllowEdit := (Not PGroupData(Node.Data).bSystem);
  1:AllowEdit := True;
  end;
end;

procedure TSIMTreeList.smOnEdited(Sender: TObject; Node: TTntTreeNode;
  var S: WideString);
Var
  bGroupCanRename:Boolean;
  gdRecord : PGroupData;
  uiRecord : PUserInfo;
begin
 if node.Level=0 then   //修改组
   begin
    if length(s)=0 then
    begin
      S := Node.Text;
      Node.EditText;
      S := GetGroupNameStatWithGroupName(S);
      Self.ReadOnly := True;
      Exit;
    end;

    if GroupExists(S) then
    begin
      MessageBox(Handle, PChar(Format('组 %s 已经存在，请重新输入新的名称。', [S])), '错误', MB_ICONERROR);
      S := Node.Text;
      Node.EditText;
      S := GetGroupNameStatWithGroupName(S);
      Self.ReadOnly := True;
      Exit;
    end;

    bGroupCanRename := True;
    if Assigned(FOnRenameGroup) then FOnRenameGroup(Sender, Node.Text, S,bGroupCanRename);
    if Not bGroupCanRename then
       begin
       S := Node.Text;
       Node.EditText;
       S := GetGroupNameStatWithGroupName(S);
       Self.ReadOnly := True;
       Exit;
       end;

    gdRecord := PGroupData(Node.Data);
    gdRecord.swGroup := S;

    S := GetGroupNameStatWithGroupName(S);
    Self.ReadOnly := True;
   end;

 if node.Level=1 then  //修改用户昵称
   begin
    if length(s)=0 then
    begin
      S := Node.Text;
      Node.EditText;
      Self.ReadOnly := True;
      Exit;
    end;
    
   uiRecord:=PUserInfo(Node.Data);

   if Assigned(FOnRenameUser) then FOnRenameUser(Sender,uiRecord.ID, Node.Text, S);

   uiRecord.NickName:=s;

   Self.ReadOnly := True;
   end;
end;

procedure TSIMTreeList.smOnCancelEdit(Sender: TObject; Node: TTreeNode);
begin
  TTntTreeNode(Node).Text := GetGroupNameStatWithGroupName(TTntTreeNode(Node).Text);
end;

procedure TSIMTreeList.DropfilesProcess(var Msg:TMessage);
var
  i,iCount:integer;
  iBuffer: Integer;
	sFileName:PWideChar;
  sFileList:WideString;
begin
  try
  iCount := DragQueryFileW(Msg.WParam, $FFFFFFFF, nil, 0);
  For i := 0 To iCount - 1 Do
    begin
    iBuffer := DragQueryFileW(Msg.WParam, i, nil, 0);
    sFileName := AllocMem((iBuffer+1) * 2);
      try
      DragQueryFileW(Msg.WParam, i, sFileName, iBuffer+1);
      sFileList:=ConCat(sFileList,#13,sFileName);
      finally
      FreeMem(sFileName);
      end;
    end;
  if Length(sFileList)>0 then SysTem.Delete(sFileList,1,1);

  if Assigned(FOnDropFile)  then
    FOnDropFile(nil,sFileList);
  finally
  DragFinish(Msg.WParam);
  end;
end;

end.
