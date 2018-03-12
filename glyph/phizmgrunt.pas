unit phizmgrunt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls,Gifimage,pngimage,jpeg, ExtCtrls,
  ImgList, phizmodifyunt, RzPanel,
  {String Res}
  ConstUnt,
  {Tnt_Unicode}
  TntForms, TntWideStrUtils, TntSysUtils, TntWindows, TntSystem, TntComCtrls,
  TntClasses, TntStdCtrls, TntExtCtrls, TntMenus,TntButtons, TntDialogs,TntGraphics,
  Grids, Buttons;

type
  TImage = class(TTntImage);
  TListView = class(TTntListView);
  TlistItem = class(TTntlistItem);
  Tfrmphizmgr = class(TForm)
    Shape1: TShape;
    pbImgs: TPaintBox;
    TntButton7: TTntButton;
    TntButton1: TTntButton;
    TntButton2: TTntButton;
    TntButton3: TTntButton;
    lblPages: TLabel;
    bttnPrior: TSpeedButton;
    bttnNext: TSpeedButton;
    TntButton4: TTntButton;
    TntButton5: TTntButton;
    pnlPreview: TPanel;
    Shape2: TShape;
    imgPreview: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TntButton1Click(Sender: TObject);
    procedure TntButton7Click(Sender: TObject);
    procedure pbImgsPaint(Sender: TObject);
    procedure bttnPriorClick(Sender: TObject);
    procedure bttnNextClick(Sender: TObject);
    procedure pbImgsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Shape1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure pbImgsClick(Sender: TObject);
    procedure TntButton3Click(Sender: TObject);
    procedure TntButton2Click(Sender: TObject);
  private
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
    procedure SaveCustomFaceList;
    procedure MakeList;
    procedure UpdatePreview;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmphizmgr: Tfrmphizmgr;

implementation
uses ShareUnt,md5unt, udpcores,ImageOleUnt;

{$R *.dfm}

procedure Tfrmphizmgr.FormCreate(Sender: TObject);
begin
  FGif := TTntPicture.Create;
  FBmp := TBitmap.Create;
  FSelBmp := TBitmap.Create;
  FSelBmp.Width := 60;
  FSelBmp.Height := 60;
  FGridSize := 70;
  FRowCount := 4;
  FColCount := 8;
  FSelected := -1;
  FFocusIndex := -1;
  FPreviewIndex := -1;
end;

procedure Tfrmphizmgr.MakeList;
var
  i , x, y, p : integer;
  sMd5:String;
  sTmpstr,sFileName:WideString;
begin
  FItemCount := facelist.Count-96;
  FPageCount := (FItemCount + FRowCount * FColCount) div
               (FRowCount * FColCount);
               
  FPageIndex := 0;

  FBmp.Width := FGridSize * FColCount * FPageCount;
  FBmp.Height := FGridSize * FRowCount + 1;
  pbImgs.Width := FGridSize * FColCount + 1;
  pbImgs.Height := FBmp.Height;

  FBmp.Canvas.FillRect(Rect(0,0,FBmp.Width,FBmp.Height));

  lblPages.Caption := format('%d/%d', [FPageIndex + 1, FPageCount]);

  if facelist.Count>96 then
  for i:=0 to facelist.Count-97 do
  begin
    sTmpstr:=facelist.Strings[i+96];
    sMd5:=copy(sTmpstr,1,34);
    delete(sTmpstr,1,34);
    if ImageOle.GetImageFileName(sMD5,sFileName) then
    begin
      FGif.LoadFromFile(sFileName);
      p := i div (FRowCount * FColCount);
      x := i mod (FRowCount * FColCount) mod FColCount;
      y := i mod (FRowCount * FColCount) div FColCount;
      x := p * FColCount * FGridSize + x * FGridSize + (FGridSize - 60) div 2;
      y := y * FGridSize + (FGridSize - 60) div 2;
      FBmp.Canvas.StretchDraw(Rect(x,y,x+60,y+60),TBitmap(FGif.Graphic));
    end;
  end;
  pbImgs.Invalidate;
end;

procedure Tfrmphizmgr.pbImgsPaint(Sender: TObject);
var
  x, y : integer;
begin
  pbImgs.Canvas.Draw(-FPageIndex * FColCount * FGridSize, 0, FBmp);
  
  pbImgs.Canvas.Pen.Color := RGB(210, 210, 210);
  pbImgs.Canvas.Pen.Width:=1;
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
end;

procedure Tfrmphizmgr.UpdatePreview;
var
  sMD5,sTmpstr,sFileName: Widestring;
  x : integer;
  CurPos:Tpoint;
begin

  if (FFocusIndex <> FPreviewIndex) and (FFocusIndex < FItemCount) then
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
    sTmpstr:=facelist.Strings[FPreviewIndex+96];
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

procedure Tfrmphizmgr.FormDestroy(Sender: TObject);
begin
if assigned(FGif) then freeandnil(FGif);
if assigned(FBmp) then freeandnil(FBmp);
if assigned(FSelBmp) then freeandnil(FSelBmp);
end;

procedure Tfrmphizmgr.FormShow(Sender: TObject);
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
    bttnNext.Click;
    except
    break;
    end;
end;

procedure Tfrmphizmgr.SaveCustomFaceList;
var
  filenames:WideString;
begin
  filenames:=ConCat(application_Path,'UserData\basepic.txt');
  facelist.SaveToFile(filenames);
end;

procedure Tfrmphizmgr.TntButton1Click(Sender: TObject);
var picfile,newfilename,img_path,
    FaceName,FaceQuick:widestring;
    md5str:WideString;
begin
if NewPhizInfor(PicFile,FaceQuick,FaceName) then
if widefileexists(picfile)then
if (getfilesize(picfile)div 1024)<=1024 then
   begin
   img_path:=ConCat(application_Path+'Images\Custom\');
   md5str:=ConCat('{',md5encodefile(picfile),'}');
   if (wideextractfilepath(picfile)<>img_path)
       and(not ImageOle.CheckImageExists(md5str)) then
       begin
       newfilename:=ConCat(img_path,md5str,wideextractfileext(picfile));
       if not WideDirectoryExists(newfilename) then
          WideForceDirectories(wideextractfilepath(newfilename));
       wideCopyFile(picfile,newfilename,true);
       ImageOle.AddFileToImageOle(newfilename);
       end;
   facelist.Append(ConCat(md5str,FaceName,'/',FaceQuick));
   MakeList;
   end
   else MessageBox(Handle, PChar(MSGBOX_ERROR_ADDICONBIGEST), PChar(MSGBOX_TYPE_ERROR), MB_ICONERROR);
end;

procedure Tfrmphizmgr.TntButton7Click(Sender: TObject);
var picfile,img_path,newfilename:Widestring;
    md5str:string; i:integer;
begin
with TTntOpenDialog.Create(self) do
  try
  Title:='Ñ¡ÔñÍ¼Æ¬';
  Filter:='Í¼Æ¬ÎÄ¼þ|*.bmp;*.jpg;*.jpeg;*.gif;*.png';
  InitialDir:=DefaultOpenDir;
  Options:=[ofAllowMultiSelect];
  if execute and (Files.Count>0) then
     begin
     for i:=Files.Count downto 1 do
       try
       picfile:=Files.Strings[i-1];
       if (getfilesize(picfile)div 1024)<=1024 then
         begin
         img_path:=ConCat(application_Path,'Images\Custom\');
         md5str:=ConCat('{',md5encodefile(picfile),'}');
         if (wideextractfilepath(picfile)<>img_path)
             and(not ImageOle.CheckImageExists(md5str)) then
             begin
             newfilename:=img_path+md5str+wideextractfileext(picfile);
             if not WideDirectoryExists(newfilename) then
                WideForceDirectories(wideextractfilepath(newfilename));
             wideCopyFile(picfile,newfilename,true);
             ImageOle.AddFileToImageOle(newfilename);
             end;
         facelist.Append(ConCat(md5str,WideExtractFileName(picfile)));
         end;
       except
       end;
     MakeList;
     end;
  finally
  free;
  end;
end;


procedure Tfrmphizmgr.bttnPriorClick(Sender: TObject);
begin
  if FPageIndex > 0 then
  begin
    Dec(FPageIndex);
    pbImgs.Invalidate;
    lblPages.Caption := format('%d/%d', [FPageIndex + 1, FPageCount]);
  end;
end;

procedure Tfrmphizmgr.bttnNextClick(Sender: TObject);
begin
  if FPageIndex < (FPageCount - 1) then
  begin
    inc(FPageIndex);
    pbImgs.Invalidate;
    lblPages.Caption := format('%d/%d', [FPageIndex + 1, FPageCount]);
  end;
end;

procedure Tfrmphizmgr.pbImgsMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
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
    pbImgs.Canvas.Pen.Width:=1;
    pbImgs.Canvas.Brush.Style := bsClear;
    pbImgs.Canvas.Rectangle(x, y, x + FGridSize + 1, y + FGridSize + 1);

    FFocusIndex := i;

    x := FFocusIndex mod (FRowCount * FColCount) mod FColCount * FGridSize;
    y := FFocusIndex mod (FRowCount * FColCount) div FColCount * FGridSize;
    pbImgs.Canvas.Pen.Color := $00FF8000;
    pbImgs.Canvas.Pen.Width:=1;
    pbImgs.Canvas.Brush.Style := bsClear;
    pbImgs.Canvas.Rectangle(x, y, x + FGridSize + 1, y + FGridSize + 1);

   if FSelected>=0 then
    begin
      x := FSelected mod (FRowCount * FColCount) mod FColCount * FGridSize;
      y := FSelected mod (FRowCount * FColCount) div FColCount * FGridSize;
      pbImgs.Canvas.Pen.Color := clGreen;
      pbImgs.Canvas.Pen.Width:=2;
      pbImgs.Canvas.Brush.Style := bsClear;
      pbImgs.Canvas.Rectangle(x+2, y+2, x + FGridSize - 1, y + FGridSize - 1);
    end;
    
    UpdatePreview;
  end;
end;

procedure Tfrmphizmgr.Shape1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  pbImgs.Hint:='';
  pnlPreview.Visible := False;
end;

procedure Tfrmphizmgr.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveCustomFaceList;
end;

procedure Tfrmphizmgr.pbImgsClick(Sender: TObject);
var
  x,y:Integer;
begin
  pbImgsPaint(nil);
  FSelected := FFocusIndex;
  x := FSelected mod (FRowCount * FColCount) mod FColCount * FGridSize;
  y := FSelected mod (FRowCount * FColCount) div FColCount * FGridSize;
  pbImgs.Canvas.Pen.Color := clGreen;
  pbImgs.Canvas.Pen.Width:=2;
  pbImgs.Canvas.Brush.Style := bsClear;
  pbImgs.Canvas.Rectangle(x+2, y+2, x + FGridSize - 1, y + FGridSize - 1);
end;

procedure Tfrmphizmgr.TntButton3Click(Sender: TObject);
begin
  if FSelected>=0 then
    begin
    faceList.Delete(96+FSelected);
    FSelected:=-1;
    MakeList;
    end;
end;

procedure Tfrmphizmgr.TntButton2Click(Sender: TObject);
var
  n:Integer;
  sTmpStr,sMd5,
  sFileName,sName:WideString;
begin
  sTmpStr:=facelist.Strings[FSelected+96];
  sMd5:=copy(sTmpStr,1,34);
  Delete(sTmpStr,1,34);
  n:=Pos('/',sTmpStr);
  if n>0 then
    begin
    sName:=Copy(sTmpStr,1,n-1);
    delete(sTmpStr,1,n);
    end;
  if ImageOle.GetImageFileName(sMd5,sFileName) then
  if EditPhizInfor(sFileName,sTmpStr,sName) then
    facelist.Strings[FSelected+96]:=ConCat(sMd5,sName,'/',sTmpStr);
end;

end.
