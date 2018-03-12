unit copyscreen;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,jpeg,clipbrd, StdCtrls,TntClasses;

type
  Tcopy_screen = class(TForm)
    ScreenImg: TImage;
    coordinate: TLabel;
    procedure ScreenImgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ScreenImgMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ScreenImgMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ScreenImgDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    bComplete,
    status_compile,copy_compile:boolean;
    WW,HH,newx,newy,oldx,oldy,w,h: Integer;
    FFileName:WideString;
    procedure refresh_image;
    { Private declarations }
  public
    { Public declarations }
  end;

function GetCopyScreen(var sFileName:WideString):Boolean;

implementation
uses udpcores,ShareUnt,md5unt;
{$R *.DFM}

function GetCopyScreen(var sFileName:WideString):Boolean;
begin
  with TCopy_screen.Create(nil) do
    try
    showmodal;
    sFilename:=FFileName;
    Result:=bComplete;
    finally
    free;
    end;
end;

procedure Tcopy_screen.ScreenImgMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
if button=mbleft then
if not copy_compile then
  begin
  status_compile:=true;
  copy_compile:=false;
  newx := x; newy := y;
  oldx := x; oldy := y;
  end;
end;

procedure Tcopy_screen.refresh_image;
var
  hScrDC, hMemDC : HDC;
  hBmp, hOldBmp : HBitmap;
begin

hScrDC := CreateDC('DISPLAY', nil, nil, nil);
hMemDC := CreateCompatibleDC(hScrDC);
try
  ww := GetDeviceCaps(hScrDC, HORZRES);
  hh := GetDeviceCaps(hScrDC, VERTRES);

  hBmp := CreateCompatibleBitmap(hScrDC, ww, hh);

  hOldBmp := SelectObject(hMemDC, hBmp);

  BitBlt(hMemDC, 0, 0, ww, hh, hScrDC, 0, 0, SRCCOPY);

  hBmp := SelectObject(hMemDC, hOldBmp);

  ScreenImg.left:=0;
  ScreenImg.top:=0;
  ScreenImg.Width:=WW;
  ScreenImg.Height:=HH;

  ScreenImg.Picture.Bitmap.Handle:=hBmp;
finally
  DeleteDC(hScrDC);
  DeleteDC(hMemDC);
end;

end;

procedure Tcopy_screen.FormCreate(Sender: TObject);
begin
DoubleBuffered:=True;
refresh_image;
end;

procedure Tcopy_screen.FormShow(Sender: TObject);
begin
udpcore.setwindowstopmost(handle,true);
ScreenImg.Canvas.Pen.mode:=pmnot;//笔的模式为取反
ScreenImg.canvas.pen.color := clblack;//笔为黑色
ScreenImg.canvas.brush.Style := bsclear;//空白刷子
ScreenImg.Canvas.Lock;
end;

procedure Tcopy_screen.ScreenImgMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if button=mbleft then
if not copy_compile then
  begin
  status_compile:=false;
  copy_compile:=true;
  end;

if button=mbRight then
if copy_compile then
  begin
  coordinate.caption:='';
  status_compile:=false;
  copy_compile:=false;
  with ScreenImg.canvas do
   rectangle(newx,newy,oldx,oldy);
  end else close;
end;

procedure Tcopy_screen.ScreenImgMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var Txt:string;
begin
if status_compile then//是否在追踪鼠标？
  begin
   with ScreenImg.canvas do
     begin
     rectangle(newx,newy,oldx,oldy);
     Rectangle(newx,newy,x,y);
     oldx:=x;oldy:=y;
     end;
  Txt:='图片大小:'+inttostr(abs(x-newx))+':'+inttostr(abs(y-newy));
  if x>(WW div 2) then
      coordinate.Left:=x-101 else coordinate.Left:=x+1;
  if y>(HH div 2) then
     coordinate.Top:=y-16 else coordinate.top:=y+1;
  coordinate.caption:=Txt;
  end;
end;

procedure Tcopy_screen.ScreenImgDblClick(Sender: TObject);
var swp:integer;
    bitmap:tbitmap;
    tmpstream:TTntMemoryStream;
begin
if oldx<newx then begin swp:=newx;newx:=oldx;oldx:=swp; end;
if oldy<newy then begin swp:=newy;newy:=oldy;oldy:=swp; end;
w:=oldx-newx;h:=oldy-newy;
if (w<=0)or(h<=0) then exit;
if copy_compile then
  begin
  coordinate.caption:='';
  with ScreenImg.canvas do
   rectangle(newx,newy,oldx,oldy);
  with tjpegimage.Create do
    try
      tmpstream:=TTntMemoryStream.create;
      bitmap:=tbitmap.Create;
      try
      bitmap.width:=w;bitmap.height:=h;
      bitmap.canvas.CopyRect(rect(0,0,w,h),ScreenImg.canvas,rect(newx,newy,oldx,oldy));
      assign(bitmap);
      clipboard.Assign(bitmap);

      CompressionQuality:=85;
      compress;
      savetostream(tmpstream);
      FFileName:=ConCat(Application_Path,'UserData\',loginuser,'\images\{',md5encodeStream(tmpstream),'}.jpg');
      tmpstream.savetofile(FFileName);
      finally
      bitmap.free;
      tmpstream.free;
      end;
    finally
    free;
    end;
  bComplete:=True;
  close;
  end;
end;

procedure Tcopy_screen.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if key=27 then
if copy_compile then
  begin
  coordinate.caption:='';
  status_compile:=false;
  copy_compile:=false;
  with ScreenImg.canvas do
   rectangle(newx,newy,oldx,oldy);
  end else close;
end;

procedure Tcopy_screen.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
Visible:=False;
end;

end.
