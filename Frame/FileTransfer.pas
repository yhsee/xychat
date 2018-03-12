unit FileTransfer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, Math, Gauges, ComCtrls, ExtCtrls, jpeg, StdCtrls, ShellAPI, StrUtils,
  ImgList, ConstUnt,PanelEx,
  {Tnt Control}
  TntWindows, TntSysUtils, TntClasses, TntForms, TntStdCtrls, TntComCtrls,
  TntGraphics;

type
  TFreame_FileTrans = class(TTntForm)
    Lab_State: TTntLabel;
    PaintProcess: TPaintBox;
    ImgList32_Shell: TImageList;
    Img_FileType: TImage;
    Lab_Yes: TTntLabel;
    Lab_Cancel: TTntLabel;
    PaintBoxTitle: TPanelEx;
    Lab_Speed: TTntLabel;
    Lab_FileName: TTntLabel;
    Lab_FileSize: TTntLabel;
    Lab_SaveAs: TTntLabel;
    procedure TntFrameResize(Sender: TObject);
    procedure PaintProcessPaint(Sender: TObject);
  private
    iMax,iPos:Int64;
    FSendAndRevice:Boolean;
    procedure UpdateFilename;
  public
    { Public declarations }
    procedure InitializeBox(SendAndRevice:Boolean);
    procedure ChangeIconImage(Fileinfo:Widestring);
    procedure UpdateProcess(iCountSize,iPosition:Int64;Const Checked:Boolean=false);
  end;

implementation
uses ShareUnt;
{$R *.dfm}

function GetShareFileIconIndex(Const AFile: WideString; Attrs: DWORD): Integer;
var
  SFI:  TSHFileInfo;
  SFIW: TSHFileInfoW;
  sFilePath : String;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    FillChar(SFIW, Sizeof(TSHFileInfoW), #0);
    Tnt_SHGetFileInfoW(PWideChar(AFile), Attrs, SFIW, SizeOf(TSHFileInfoW),
      SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES);
    Result := SFIW.iIcon;  
  end
  else
  begin
    sFilePath := AFile;
    FillChar(SFI, Sizeof(TSHFileInfo), #0);
    SHGetFileInfo(PChar(sFilePath), Attrs, SFI, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES);
    Result := SFI.iIcon;
  end;
end;

procedure TFreame_FileTrans.InitializeBox(SendAndRevice:Boolean);
Var
  SysSIL : THandle;
  SFI : TSHFileInfo;
begin

  FSendAndRevice:=SendAndRevice;

  Lab_Yes.Visible:=False;
  Lab_Cancel.Visible:=False;
  Lab_SaveAs.Visible:=False;
  if FSendAndRevice then
     Lab_State.Caption:='发送文件'
     else Lab_State.Caption:='接收文件';
  lab_Filename.Caption:='正在初始化...';
  lab_FileSize.Caption:='请稍候...';

  if Self.Parent<>Nil then
  begin
    if Self.Parent is TScrollBox then
      Self.Font := (Self.Parent as TScrollBox).Font;
  end;

  With ImgList32_Shell do
  begin
    Width := 32;
    Height := 32;
    SysSIL := ShellAPI.SHGetFileInfo('', 0, SFI, SizeOf(SFI),
      ShellAPI.SHGFI_SYSICONINDEX or ShellAPI.SHGFI_LARGEICON);
    if SysSIL <> 0 then
    begin
      Handle := SysSIL;
      ShareImages := True;
    end;
  end;
end;

procedure TFreame_FileTrans.ChangeIconImage(Fileinfo:Widestring);
Var
  bmpPic : TBitmap;
begin
  try                                    
    bmpPic := TBitmap.Create;
    if WideDirectoryExists(Fileinfo) then
       ImgList32_Shell.GetBitmap(GetShareFileIconIndex('*', FILE_ATTRIBUTE_DIRECTORY), bmpPic)
       else ImgList32_Shell.GetBitmap(GetShareFileIconIndex(Fileinfo, FILE_ATTRIBUTE_NORMAL), bmpPic);
    Img_FileType.Picture.Bitmap.Assign(bmpPic);
  finally
    freeandnil(bmpPic);
  end;
end;


procedure TFreame_FileTrans.TntFrameResize(Sender: TObject);
begin
  PaintProcess.Width := Self.Width - 22;
  Lab_FileName.Width := Self.Width - 64;
  PaintProcessPaint(Self);
  UpdateFilename;
  Lab_Cancel.Left := PaintProcess.Width - 12;
  Lab_Yes.Left := Lab_Cancel.Left - 32;
  Lab_SaveAs.Left:= Lab_Yes.Left -48;
end;

procedure TFreame_FileTrans.UpdateProcess(iCountSize,iPosition:Int64;Const Checked:Boolean=false);
begin
  try
  if Checked and (iPosition<iPos) then exit;
  iMax:=iCountSize;
  iPos:=iPosition;
  PaintProcessPaint(self);
  except

  end;
end;

procedure TFreame_FileTrans.UpdateFilename;
begin
  if length(Lab_filename.Hint)>0 then
   Lab_filename.Caption:=GetShortFilename(Lab_filename.Hint,Lab_filename.width);
end;

procedure TFreame_FileTrans.PaintProcessPaint(Sender: TObject);
var
  TmpBitmap:TBitmap;
  WW,HH,nWidth:Integer;
begin
  try
  TmpBitmap:=TBitmap.Create;

  WW:=PaintProcess.Width;
  HH:=PaintProcess.Height;

  TmpBitmap.Width:=WW;
  TmpBitmap.Height:=HH;
  //画边框
  TmpBitmap.Canvas.Brush.Style:=bsSolid;
  TmpBitmap.Canvas.Pen.Color:=RGB(162,179,165);
  TmpBitmap.Canvas.Brush.Color:=RGB(244,246,245);
  TmpBitmap.Canvas.RoundRect(0,0,WW,HH,5,5);
  //画背景
  TmpBitmap.Canvas.Pen.Color:=RGB(212,208,200);;
  TmpBitmap.Canvas.Brush.Color:=RGB(196,195,193);
  TmpBitmap.Canvas.Rectangle(2,2,WW-2,HH-2);
  //画进度
  if iMax>0 then
    begin
    nWidth:=Round((ww / 100)*(iPos/iMax)*100);
    if nWidth>WW then nWidth:=WW;
    if nWidth>2 then
      begin
      TmpBitmap.Canvas.Pen.Color:=RGB(212,208,200);;
      TmpBitmap.Canvas.Brush.Color:=RGB(24,177,50);
      TmpBitmap.Canvas.Rectangle(2,2,nWidth-2,HH-2);
      end;
    end;

  PaintProcess.Canvas.Draw(0,0,TmpBitmap);
  finally
  freeandnil(TmpBitmap);
  end;
end;

end.
