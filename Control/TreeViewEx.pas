Unit TreeViewEx;

Interface

uses Windows, Messages, Classes, Controls, ComCtrls, Commctrl;

const
  TVIS_CHECKED                                                           =$2000;

Type
  TTreeViewEx = class(TCustomTreeView)
    procedure CreateParams(var Params: TCreateParams);override;
  private
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure SetNodeCheck(TmpNode: TtreeNode;const Value:Boolean);
    procedure TravelChild(TmpNode: TTreeNode;const Value:Boolean);
    procedure TravelSiblingAndParent(TmpNode: TTreeNode;const Value:Boolean);
  protected
  public
    function GetNodeChecked(TmpNode: TTreeNode): Boolean;
    procedure SetNodeChecked(TmpNode: TtreeNode;const Value:Boolean);
  published
    property Align;
    property Anchors;
    property AutoExpand;
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind default bkNone;
    property BevelWidth;
    property BiDiMode;
    property BorderStyle;
    property BorderWidth;
    property ChangeDelay;
    property Color;
    property Ctl3D;
    property Constraints;
    property DragKind;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property HotTrack;
    property Images;
    property Indent;
    property MultiSelect;
    property MultiSelectStyle;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property RightClickSelect;
    property RowSelect;
    property ShowButtons;
    property ShowHint;
    property ShowLines;
    property ShowRoot;
    property SortType;
    property StateImages;
    property TabOrder;
    property TabStop default True;
    property ToolTips;
    property Visible;
    property OnAddition;
    property OnAdvancedCustomDraw;
    property OnAdvancedCustomDrawItem;
    property OnChange;
    property OnChanging;
    property OnClick;
    property OnCollapsed;
    property OnCollapsing;
    property OnCompare;
    property OnContextPopup;
    property OnCreateNodeClass;
    property OnCustomDraw;
    property OnCustomDrawItem;
    property OnDblClick;
    property OnDeletion;
    property OnDragDrop;
    property OnDragOver;
    property OnEdited;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnExpanding;
    property OnExpanded;
    property OnGetImageIndex;
    property OnGetSelectedIndex;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    { Items must be published after OnGetImageIndex and OnGetSelectedIndex }
    property Items;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TTreeViewEx]);
end;

procedure TTreeViewEx.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style:=Params.Style or TVS_CHECKBOXES;   
end;

procedure TTreeViewEx.WMLButtonDown(var Message: TWMLButtonDown);
var
  R:TRect;
  P:TPoint;
  TmpNode:TTreeNode;
  FChecked:Boolean;
begin
  TmpNode:=GetNodeAt(Message.XPos, Message.YPos);
  if TmpNode=nil then Exit;
  R:=TmpNode.DisplayRect(true);
  R.Left:=R.Left-16;
  R.Right:=R.Left+16;
  GetCursorPos(P);
  P:=SCreenToClient(P);
  if PtInRect(R,P) then
    begin
    FChecked:=GetNodeChecked(TmpNode);
    TmpNode.Selected:=True;
    SetNodeChecked(TmpNode,not FChecked);
    end;
  inherited;
end;

function TTreeViewEx.GetNodeChecked(TmpNode: TtreeNode): Boolean;
var
  ItemState:TTVITEM;
begin
  FillChar(ItemState,sizeof(ItemState),0);
  ItemState.Mask  := TVIF_STATE;
  ItemState.hItem := TmpNode.ItemId;
  ItemState.StateMask := TVIS_STATEIMAGEMASK;
  TreeView_GetItem(TmpNode.Handle, ItemState);
  Result :=(ItemState.State and TVIS_CHECKED) = TVIS_CHECKED;
end;

procedure TTreeViewEx.SetNodeCheck(TmpNode: TtreeNode;const Value:Boolean);
const
  IsCheck:array [Boolean] of Dword=(TVIS_CHECKED,TVIS_CHECKED shr 1);
var
  ItemState:TTVITEM;
begin
  FillChar(ItemState,sizeof(ItemState),0);
  ItemState.mask:=TVIF_STATE;
  ItemState.hItem := TmpNode.ItemId;
  ItemState.StateMask := TVIS_STATEIMAGEMASK;
  ItemState.state:=ItemState.state or IsCheck[Value];
  TreeView_SetItem(TmpNode.Handle,ItemState);
end;

procedure TTreeViewEx.SetNodeChecked(TmpNode: TtreeNode;const Value:Boolean);
begin
  if TmpNode.Selected then
    SetNodeCheck(TmpNode,Value)
    else SetNodeCheck(TmpNode,not Value);
  TravelChild(TmpNode,not Value);
  TravelSiblingAndParent(TmpNode,not Value);
end;

procedure TTreeViewEx.TravelChild(TmpNode: TTreeNode;const Value:Boolean);
var
  SubNode:TTreeNode;
begin
	//查找子节点，没有就结束
	if TmpNode.HasChildren then
    begin
    SubNode:=TmpNode.GetFirstChild;
    while Assigned(SubNode) do
      begin
      SetNodeCheck(SubNode,Value);
      //递归处理子节点的子节点
      TravelChild(SubNode,Value);
      //再处理子节点兄弟节点
      SubNode:=SubNode.GetNextSibling;
      end;
    end;
end;

procedure TTreeViewEx.TravelSiblingAndParent(TmpNode: TTreeNode;const Value:Boolean);
var
  TmpBool:Boolean;
  SubNode:TTreeNode;
begin
	//查找父节点，没有就结束
  if assigned(TmpNode.Parent) then
    begin
    TmpBool:=True;
    if not Value then
      begin
      SetNodeCheck(TmpNode.Parent,Value);
      TravelSiblingAndParent(TmpNode.Parent,Value);
      end else begin
      //查看兄弟节点状态是否全部一样
      SubNode:=TmpNode.Parent.GetFirstChild;
      while Assigned(SubNode) do
        begin
        if not (SubNode=TmpNode) then
        if GetNodeChecked(SubNode) then
          begin
          TmpBool:=False;
          break;
          end;
        SubNode:=SubNode.GetNextSibling;
        end;

      if TmpBool then
        begin
        SetNodeCheck(TmpNode.Parent,Value);
        TravelSiblingAndParent(TmpNode.Parent,Value);
        end;
      end;
    end;
end;

end.
