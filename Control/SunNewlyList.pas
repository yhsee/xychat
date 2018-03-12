unit SunNewlyList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, StdCtrls, Forms,
  ExtCtrls, ComCtrls, Graphics, StrUtils, XPMan, Math, CommCtrl,
  SunIMTreeList,ShellApi,
  {Tnt Control}
  TntClasses, TntSysUtils, TntStdCtrls, TntComCtrls, TntGraphics,
  TntForms, TntExtCtrls, TntMenus;

type
  tFlashUser = Class(TThread)
  private
 //   iIconMoveIndent : Integer;//图标跳转

    tvList : TTntTreeView;

    procedure tfiFlash;
  protected
    Procedure Execute; override;
  public
    Constructor Create(Suspended :Boolean; tvTree: TTntTreeView);
    Destructor Destroy;override;
  end;

  TDropEvent = procedure(Sender :TObject; const sParams: Widestring) of object;
  TSIMNewlyList = class(TTntTreeView)
  private
    _STATE_ONLINE, _STATE_LEAVE, _STATE_HIDE, _STATE_OFFLINE : Integer;
    
    FImageList : TImageList;
    FItemHeigth, FLevelIndent : Integer;
    FSelectFullLine : Boolean;

    //Color
    cSelectedColor, cSelectedBorderColor : TColor;
    FOnDropFile:TDropEvent;
    tfuFlash : tFlashUser;

    procedure DropfilesProcess(var Msg:TMessage);Message WM_DROPFILES;
    procedure smCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure SetItemHeight(tvTree: TTntTreeview; dItemHeight: DWord);
    procedure SetFItemHeigth(Value: Integer);
    procedure SetImageLists(const Value: TImageList);
    {private}
  protected
    {protected}
  public
    {public}
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;

    function AddNewlyUser(nNode: TTntTreeNode): Boolean;
    function DeleteNewlyUser(nNode:TTntTreeNode):Boolean;
    function GetSelectedUser(nNode: TTntTreeNode): WideString;
    function GetSelectedUserID(nNode: TTntTreeNode): WideString;
  published
    property S_ONLINE : Integer Read _STATE_ONLINE;
    property S_LEAVE : Integer Read _STATE_LEAVE;
    property S_HIDE : Integer Read _STATE_HIDE;
    property S_OFFLINE : Integer Read _STATE_OFFLINE;

    property OnDropFile:TDropEvent Write FOnDropFile;

    property SelectFullLine : Boolean Read FSelectFullLine Write FSelectFullLine;    
    property ItemHeigth : Integer Read FItemHeigth Write SetFItemHeigth;
    property LevelIndent : Integer Read FLevelIndent Write FLevelIndent;    
    property ImageList : TImageList Read FImageList Write SetImageLists;
      
    property SelectedColor : TColor Read cSelectedColor Write cSelectedColor;
    property SelectedBorderColor : TColor Read cSelectedBorderColor Write cSelectedBorderColor;  
  end;

  procedure Register;  

implementation

procedure Register;
begin
  RegisterComponents('Sunwards Software', [TSIMNewlyList]);
end;

////////////////////////////////////////////////////////////////////////////////
//                           Flash User Thread 1.0                            //
//                     CopyRight(C) Sunwards SOftware,Inc.                    //
////////////////////////////////////////////////////////////////////////////////

Constructor tFlashUser.Create(Suspended :Boolean; tvTree: TTntTreeView);
begin
  inherited Create(Suspended);

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
  uiRecord : PUserInfo;
//  gdRecord : PGroupData;
begin
  for i := 0 to tvList.Items.Count-1 do
  begin
    uiRecord := PUserInfo(tvList.Items[i].Data);
    
    if uiRecord.FlashIt then
      tvList.Repaint;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//                            Control Unit                                    //
////////////////////////////////////////////////////////////////////////////////

constructor TSIMNewlyList.Create(AOwner: TComponent);
begin
  _STATE_ONLINE := 0; //0:在线  1 :离开  2:隐身  3:下线
  _STATE_LEAVE := 1;
  _STATE_HIDE := 2;
  _STATE_OFFLINE := 3;
  
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
  Self.AutoExpand := False;
  Self.OnCustomDrawItem := smCustomDrawItem;

  tfuFlash := tFlashUser.Create(False, Self);
end;

destructor TSIMNewlyList.Destroy;
begin
  tfuFlash.Terminate;
  
  inherited Destroy;
end;

function TSIMNewlyList.AddNewlyUser(nNode:TTntTreeNode):Boolean;
Var
 // nNewlyNode : TTntTreeNode;
  uiUser : PUserInfo;
begin
  Result := False;
  if nNode=Nil then Exit;
  if nNode.Data=Nil then Exit;

  uiUser := PUserInfo(nNode.Data);
  if uiUser.nNewlyNode<>Nil then Exit;

  if (uiUser.State=_STATE_ONLINE) Or (uiUser.State=_STATE_LEAVE) then
    uiUser.nNewlyNode := Self.Items.AddFirst(Nil, uiUser.NickName)
  else uiUser.nNewlyNode := Self.Items.Add(Nil, uiUser.NickName);
  uiUser.nNewlyNode.ImageIndex := nNode.ImageIndex;
  uiUser.nNewlyNode.SelectedIndex := nNode.ImageIndex;
  uiUser.nNewlyNode.Data := nNode.Data;
  Result := True;
end;

function TSIMNewlyList.DeleteNewlyUser(nNode:TTntTreeNode):Boolean;
//Var
//  nNewlyNode : TTntTreeNode;
begin
  Result := False;
  if nNode=Nil then Exit;
  if nNode.Data=Nil then Exit;

  nNode.Delete;
  PUserInfo(nNode.Data).nNewlyNode := Nil;
  Result := True;
end;

function TSIMNewlyList.GetSelectedUser(nNode:TTntTreeNode):WideString;
begin
  Result := '';
  if nNode=Nil then Exit;
  if nNode.Data=Nil then Exit;

  Result := PUserInfo(nNode.Data).NickName;
end;

function TSIMNewlyList.GetSelectedUserID(nNode:TTntTreeNode):WideString;
begin
  Result := '';
  if nNode=Nil then Exit;
  if nNode.Data=Nil then Exit;
//  if nNode.Level=0 then Exit;

  Result := PUserInfo(nNode.Data).ID;
end;

////////////////////////////////////////////////////////////////////////////////
//                      Draw Item With Sunwards GM 1.0                        //
//                Copyright(C) Sunwards Software, 2007.08.27                  //
////////////////////////////////////////////////////////////////////////////////

procedure TSIMNewlyList.smCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
Var
  rRect : TRect;
  icoIcon : TIcon;
  swText, swIdiograph : WideString;
  iImgIndex, iFalseRect : Integer;
  bFlashGroup : Boolean;
begin
  bFlashGroup:=False;
  if Node=Nil then Exit;
  if Node.Data=Nil then Exit;

  swText := Node.Text;
  swIdiograph := PUserInfo(Node.Data).Reserved;
  iImgIndex := PUserInfo(Node.Data).iImgIndex;
//  bFlash := PUserInfo(Node.Data).FlashIt;
  iFalseRect := PUserInfo(Node.Data).iFlashState;

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
      if (Trim(swIdiograph)<>'') then
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
      if (Trim(swIdiograph)<>'') then
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

procedure TSIMNewlyList.SetFItemHeigth(Value: Integer);
begin
  FItemHeigth := Value;
  SetItemHeight(Self, FItemHeigth);
end;

procedure TSIMNewlyList.SetItemHeight(tvTree:TTntTreeview;dItemHeight:DWord);
begin
  Self.Perform(TVM_SETITEMHEIGHT, dItemHeight, 0);
  FItemHeigth := dItemHeight;
end;

procedure TSIMNewlyList.SetImageLists(const Value: TImageList);
begin
  FImageList := Value;
end;

procedure TSIMNewlyList.DropfilesProcess(var Msg:TMessage);
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
