unit phizunt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons,Gifimage,pngimage,jpeg,constunt,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus,TntButtons, TntDialogs,TntGraphics;

type
  TPaintBox = class(TTntPaintBox);
  TImage = class(TTntImage);
  Tphizfrm = class(TForm)
    pbImgs : TPaintBox;
    Shape1 : TShape;
    bttnPrior : TSpeedButton;
    bttnNext : TSpeedButton;
    lblPages : TLabel;
    pnlPreview : TPanel;
    Shape2 : TShape;
    imgPreview : TImage;
    Label1: TLabel;
    procedure FormCreate(Sender : TObject);
    procedure FormDestroy(Sender : TObject);
    procedure pbImgsPaint(Sender : TObject);
    procedure pbImgsMouseMove(Sender : TObject; Shift : TShiftState; X,
      Y : Integer);
    procedure bttnPriorClick(Sender : TObject);
    procedure bttnNextClick(Sender : TObject);
    procedure FormShow(Sender : TObject);
    procedure pbImgsClick(Sender : TObject);
    procedure FormDeactivate(Sender : TObject);
    procedure Shape1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Label1Click(Sender: TObject);
  private
    { Private declarations }
    Initial_ok:Boolean;
    FGif : TTntPicture;
    FBmp : TBitMap;
    FSelBmp : TBitmap;
    FGridSize : integer;
    FRowCount, FColCount : integer;
    FPageCount : integer;
    FPageIndex : integer;
    FSelected : integer;
    FFocusIndex : integer;
    FPreviewIndex : integer;
    FItemCount : integer;
    FUserSign:String;
    procedure UpdatePreview;
  public
    procedure MakeList;
    Procedure ShowIconWindows(sUserSign:String);
  end;

var phizfrm: Tphizfrm;

implementation
uses ShareUnt, udpcores,ImageOleUnt,eventunt,EventCommonUnt;

{$R *.dfm}

procedure Tphizfrm.FormCreate(Sender : TObject);
begin
  FGif := TTntPicture.Create;
  FBmp := TBitmap.Create;
  FSelBmp := TBitmap.Create;
  FSelBmp.Width := 20;
  FSelBmp.Height := 20;
  FGridSize := 30;
  FRowCount := 6;
  FColCount := 16;
  FSelected := -1;
  FFocusIndex := -1;
  FPreviewIndex := -1;
end;

procedure Tphizfrm.FormDestroy(Sender : TObject);
begin
if assigned(FGif) then freeandnil(FGif);
if assigned(FBmp) then freeandnil(FBmp);
if assigned(FSelBmp) then freeandnil(FSelBmp);
end;

procedure Tphizfrm.MakeList;
var
  i, x, y, p : integer;
  sTmpstr,sFileName:WideString;
begin
  FItemCount := facelist.Count;
  FPageCount := (FItemCount + FRowCount * FColCount) div
               (FRowCount * FColCount);
  FPageIndex := 0;

  FBmp.Width := FGridSize * FColCount * FPageCount;
  FBmp.Height := FGridSize * FRowCount + 1;
  pbImgs.Width := FGridSize * FColCount + 1;
  pbImgs.Height := FBmp.Height;

  FBmp.Canvas.FillRect(Rect(0,0,FBmp.Width,FBmp.Height));

  lblPages.Caption := format('%d/%d', [FPageIndex + 1, FPageCount]);

  if facelist.Count>0 then
  for i:=0 to facelist.Count-1 do
  begin
    sTmpstr:=facelist.Strings[i];
    sTmpstr:=copy(sTmpstr,1,34);
    if ImageOle.GetImageFileName(sTmpstr,sFileName) then
    begin
      FGif.LoadFromFile(sFileName);
      p := i div (FRowCount * FColCount);
      x := i mod (FRowCount * FColCount) mod FColCount;
      y := i mod (FRowCount * FColCount) div FColCount;
      x := p * FColCount * FGridSize + x * FGridSize + (FGridSize - 20) div 2;
      y := y * FGridSize + (FGridSize - 20) div 2;
      //FBmp.Canvas.Draw(x,y,TBitmap(FGif.Graphic));
      FBmp.Canvas.StretchDraw(Rect(x,y,x+20,y+20),TBitmap(FGif.Graphic));
    end;
  end;
  pbImgs.Invalidate;
end;

procedure Tphizfrm.pbImgsPaint(Sender : TObject);
var
  x, y : integer;
begin
  pbImgs.Canvas.Draw(-FPageIndex * FColCount * FGridSize, 0, FBmp);
  pbImgs.Canvas.Pen.Color := RGB(210, 210, 210);
  for x := 0 to FColCount do
  begin
    pbImgs.Canvas.MoveTo(x * FGridSize, 0);
    pbImgs.Canvas.LineTo(x * FGridSize, FRowCount * FGridSize);
  end;

  for y := 0 to FRowCount do
  begin
    pbImgs.Canvas.MoveTo(0, y * FGridSize);
    pbImgs.Canvas.LineTo(FColCount * FGridSize, y * FGridSize);
  end;

  if FFocusIndex >= 0 then
  begin
    x := FFocusIndex mod (FRowCount * FColCount) mod FColCount * FGridSize;
    y := FFocusIndex mod (FRowCount * FColCount) div FColCount * FGridSize;
    pbImgs.Canvas.Pen.Color := $00FF8000;
    pbImgs.Canvas.Brush.Style := bsClear;
    pbImgs.Canvas.Rectangle(x, y, x + FGridSize + 1, y + FGridSize + 1);
  end;
end;

procedure Tphizfrm.pbImgsMouseMove(Sender : TObject; Shift : TShiftState; X,
  Y : Integer);
var
  _x, _y, i : integer;
begin
  _x := x div FGridSize;
  _y := y div FGridSize;
  i := _y * FColCount + _x + FPageIndex * FRowCount * FColCount;
  if i <> FFocusIndex then
  begin
    x := FFocusIndex mod (FRowCount * FColCount) mod FColCount * FGridSize;
    y := FFocusIndex mod (FRowCount * FColCount) div FColCount * FGridSize;
    pbImgs.Canvas.Pen.Color := RGB(210, 210, 210);
    pbImgs.Canvas.Brush.Style := bsClear;
    pbImgs.Canvas.Rectangle(x, y, x + FGridSize + 1, y + FGridSize + 1);
    FFocusIndex := i;
    x := FFocusIndex mod (FRowCount * FColCount) mod FColCount * FGridSize;
    y := FFocusIndex mod (FRowCount * FColCount) div FColCount * FGridSize;
    pbImgs.Canvas.Pen.Color := $00FF8000;
    pbImgs.Canvas.Brush.Style := bsClear;
    pbImgs.Canvas.Rectangle(x, y, x + FGridSize + 1, y + FGridSize + 1);
    UpdatePreview;
  end;
end;

procedure Tphizfrm.bttnPriorClick(Sender : TObject);
begin
  if FPageIndex > 0 then
  begin
    Dec(FPageIndex);
    pbImgs.Invalidate;
    lblPages.Caption := format('%d/%d', [FPageIndex + 1, FPageCount]);
  end;
end;

procedure Tphizfrm.bttnNextClick(Sender : TObject);
begin
  if FPageIndex < (FPageCount - 1) then
  begin
    inc(FPageIndex);
    pbImgs.Invalidate;
    lblPages.Caption := format('%d/%d', [FPageIndex + 1, FPageCount]);
  end;
end;

procedure Tphizfrm.FormShow(Sender : TObject);
begin
  if not Initial_ok then
     begin
     Initial_ok:=True;
     MakeList;
     end;

  if FItemCount <> facelist.Count then MakeList;

  pnlPreview.Visible := false;
  while FPageIndex > 0 do
    try
    bttnPrior.Click;
    except
    break;
    end;
end;

procedure Tphizfrm.UpdatePreview;
var
  sMD5,sTmpstr,sFileName: Widestring;
  x : integer;
  CurPos:Tpoint;
begin

  if (FFocusIndex <> FPreviewIndex) and (FFocusIndex < FItemCount)  then
  begin
    x := FFocusIndex mod (FRowCount * FColCount) mod FColCount;
    if x < 4 then
    begin
      pnlPreview.Left := pbImgs.Left + pbImgs.Width - pnlPreview.Width;
      pnlPreview.Top := pbImgs.Top;
    end
    else
      if x > FColCount - 5 then
      begin
        pnlPreview.Left := pbImgs.Left;
        pnlPreview.Top := pbImgs.Top;
      end;
    if not pnlPreview.Visible then
      pnlPreview.Visible := true;

    FPreviewIndex := FFocusIndex;
    sTmpstr:=facelist.Strings[FPreviewIndex];
    sMD5:=copy(sTmpstr,1,34);
    if ImageOle.GetImageFileName(sMD5,sFileName) then
       begin
       delete(sTmpstr,1,34);
       pbImgs.hint:=sTmpstr;
       imgPreview.Picture.LoadFromFile(sFileName);
       imgPreview.Stretch:=imgPreview.Picture.Graphic.Width>imgPreview.Width;
       imgPreview.Invalidate;
       GetCursorPos(CurPos);
       Application.ActivateHint(CurPos);
       end;
  end;
end;


procedure Tphizfrm.pbImgsClick(Sender : TObject);
var
  sTmpStr:WideString;
begin
  if (FPreviewIndex >= 0) and (FFocusIndex = FPreviewIndex) then
    begin
    sTmpStr:=facelist.Strings[FPreviewIndex];
    sTmpStr:=copy(sTmpStr,1,34);
    Event.CreateDialogEvent(Dialog_Phiz_Image,FUserSign,sTmpStr);
    Close;
    end;
end;

procedure Tphizfrm.FormDeactivate(Sender : TObject);
begin
  Close;
end;

procedure Tphizfrm.Shape1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
pbImgs.Hint:='';
pnlPreview.Visible := False;
end;

Procedure Tphizfrm.ShowIconWindows(sUserSign:String);
var mouse:tpoint;
    rt1,rt2,rt3:TRect;
begin
FUserSign:=sUserSign;
getcursorpos(mouse);
SetRectEmpty(rt2);
SetRectEmpty(rt3);
rt2.Right:=460;
rt2.Bottom:=226;
OffsetRect(rt2,mouse.X,mouse.Y);
SystemParametersInfo(SPI_GETWORKAREA,0,@rt1,0);
IntersectRect(rt3,rt2,rt1);
if not EqualRect(rt3,rt2) then
   begin
   if rt3.BottomRight.X=rt1.BottomRight.X then
      OffsetRect(rt2,-460,0);
   if rt3.BottomRight.Y=rt1.BottomRight.Y then
      OffsetRect(rt2,0,-226);
   end;
left:=rt2.Left;
top:=rt2.Top;
show;
end;

procedure Tphizfrm.Label1Click(Sender: TObject);
begin
UdpCore.ShowPhizMgr;
Close;
end;

end.

