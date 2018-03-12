unit RichEditOleUnt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,ComCtrls,
  ComObj, ActiveX, Dialogs,TntClasses,TntComCtrls,TntSysUtils,
  RichEdit, RichEditCommUnt,Jpeg,Gifimage,pngimage;

type
  TRichEditOle = class(TTntCustomRichEdit)
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  private
    FOnDropFile:TDropEvent;
    FOnPasteImage:TClickEvent;
    FOnURLClick: TLinkClickEvent;
    FRichEditOle: IRichEditOLE;
    FRichEditOleCallback: IRichEditOleCallback;
    { Private declarations }
    procedure WMDestroy(var Msg: TMessage); message WM_DESTROY;
    procedure CNNotify(var Msg: TWMNotify); message CN_NOTIFY;
  protected
    { Protected declarations }
    procedure CreateWnd; override;
    procedure DoURLClick (const URL : Widestring; place:TCharRange);
    procedure SelectText(AStartPos, ALength: Integer);
    procedure SetLineSpacing(iLineSpacing: Byte);    
    procedure IHideCaret(Bool:Boolean);
    procedure InsertLink(AStartPos, ALength: Integer);
    procedure DeleteLink(AStartPos, ALength: Integer);

    function ObjectSelected:Boolean;    
    function GetOleObjectInfor(var sTmpStr:String):Boolean;
    procedure CloseObjectSelect;
    procedure CloseObjects;

    procedure FormatOleToText;
    procedure FormatCustomFaceToText;
    procedure FormatCharTextToOle(iStart:Integer);
    procedure FormatCustomTextToOle(iStart:Integer);
  public
    { Public declarations }
    procedure Clear; override;
    procedure InsertImageFile(sFileName:WideString;const sMD5:String='';const bWait:Boolean=False);
    function GetImageFileName:WideString;
    function GetNeedDownFileSign(var sTmpStr:String):Boolean;
    //--------------------------------------------------------------------------
    procedure InitRichEditOle(Bool:Boolean);
    procedure RollToLineEnd(Bool:Boolean);
    procedure RollToLineBegin;
    procedure RollToPageEnd;
    procedure RichVisibleDraw(bVisible:boolean);
    //--------------------------------------------------------------------------
    procedure SetFontFormat(TmpFontFormat:TFontFormat);
    procedure FontHtmlLinkFormat;
    procedure FontUserNameFormat(bLoginUser:boolean);
    procedure FontMessageFormat(TmpFontFormat:TFontFormat);
    //--------------------------------------------------------------------------
    function GetOleText:WideString;
    procedure FormatTextToOle(iStart:Integer);
    procedure ReplacePicture(sTmpStr:string);
    //--------------------------------------------------------------------------
    procedure FormatHtmltext(startpos:integer;iStart,iover:WideString);overload;
    procedure FormatHtmltext(startpos:integer);overload;
    procedure FormatSignalment(startpos:integer;var ol:ToleLink);overload;
    procedure FormatSignalment(startpos:integer;iStart,iover:WideString;var place:Tplace);overload;
    procedure CancelHtml(ol:ToleLink);
    //--------------------------------------------------------------------------
  published
    property OnURLClick : TLinkClickEvent read FOnURLClick write FOnURLClick;
    property OnPasteImage : TClickEvent read FOnPasteImage write FOnPasteImage;
    property OnDropFile:TDropEvent Read FOnDropFile Write FOnDropFile;
    property Align;
    property Alignment;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind default bkNone;
    property BevelWidth;
    property BiDiMode;
    property BorderStyle;
    property BorderWidth;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property HideScrollBars;
    property ImeMode;
    property ImeName;
    property Constraints;
    property Lines;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PlainText;
    property PopupMenu;
    property ReadOnly;
    property ScrollBars;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property WantTabs;
    property WantReturns;
    property WordWrap;
    property OnChange;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnProtectChange;
    property OnResizeRequest;
    property OnSaveClipboard;
    property OnSelectionChange;
    property OnStartDock;
    property OnStartDrag;
    property OnDblClick;
  end;

  TRichEditOleCallback = class(TInterfacedObject, IRichEditOleCallback)
  private
    FOwner: TRichEditOle;
    procedure PasteImage(StgMedium: TStgMedium);
    procedure DropFiles(StgMedium: TStgMedium);
    procedure CustomContextMenu(bObject:Boolean);
  protected
    function GetNewStorage(out stg: IStorage): HRESULT; stdcall;
    function GetInPlaceContext(out Frame: IOleInPlaceFrame;
         out Doc: IOleInPlaceUIWindow; var FrameInfo: TOleInPlaceFrameInfo): HRESULT; stdcall;
    function ShowContainerUI(fShow: BOOL): HRESULT; stdcall;
    function QueryInsertObject(const clsid: TCLSID; stg: IStorage; cp: longint): HRESULT; stdcall;
    function DeleteObject(oleobj: IOLEObject): HRESULT; stdcall;
    function QueryAcceptData(dataobj: IDataObject; var cfFormat: TClipFormat;
         reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HRESULT; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HRESULT; stdcall;
    function GetClipboardData(const chrg: TCharRange; reco: DWORD;
         out dataobj: IDataObject): HRESULT; stdcall;
    function GetDragDropEffect(fDrag: BOOL; grfKeyState: DWORD;
         var dwEffect: DWORD): HRESULT; stdcall;
    function GetContextMenu(seltype: Word; oleobj: IOleObject;
         const chrg: TCharRange; var menu: HMENU): HRESULT; stdcall;
  public
    constructor Create(AOwner: TRichEditOle);
  end;

implementation
uses ShellApi,MD5Unt,ConstUnt,StructureUnt,ShareUnt,ImageOleUnt;

//------------------------------------------------------------------------------
//  RicheditOle
//------------------------------------------------------------------------------
constructor TRichEditOle.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRichEditOleCallback := TRichEditOleCallback.Create(Self);
end;

destructor TRichEditOle.Destroy;
begin
  inherited Destroy;
end;

procedure TRichEditOle.CreateWnd;
var
  mask: Word;
begin
  inherited CreateWnd;
  if not RichEdit_GetOleInterface(Handle, FRichEditOle) then
    raise Exception.Create('Unable to get interface');
  if not RichEdit_SetOleCallback(Handle, FRichEditOlecallback) then
    raise Exception.Create('Unable to set callback');

  SendMessage(Handle, EM_AUTOURLDETECT,1, 0);
  mask := SendMessage(Handle, EM_GETEVENTMASK, 0, 0);
  SendMessage(Handle, EM_SETEVENTMASK, 0, mask or ENM_CHANGE or ENM_SELCHANGE or
     ENM_REQUESTRESIZE or ENM_PROTECTED or ENM_LINK);  
end;

procedure TRichEditOle.DoURLClick(const URL : Widestring; place:TCharRange);
begin
  if Assigned(FOnURLClick) then
     OnURLClick(Self, URL,EmulatedCharPos(place.cpMin),place.cpMax-place.cpMin);
end;

procedure TRichEditOle.CNNotify(var Msg: TWMNotify);
var
  p: TENLink;
begin
  if (Msg.NMHdr^.code = EN_LINK) then
    begin
    p := TENLink(Pointer(Msg.NMHdr)^);
    if (p.Msg = WM_LBUTTONDOWN) then
      try
       Perform(EM_EXSETSEL, 0, Longint(@(p.chrg)));
       DoURLClick(SelText,p.chrg);
      except
      end;
    end;

 inherited;
end;

procedure TRichEditOle.WMDestroy(var Msg: TMessage);
begin
  CloseObjects;
  FRichEditOle:=nil;
  inherited;
end;

//------------------------------------------------------------------------------
// richedit 行距调整
//------------------------------------------------------------------------------
procedure TRichEditOle.SetLineSpacing(iLineSpacing: Byte);
var
  pf2: ParaFormat2;
begin
  FillChar(pf2, SizeOf(pf2), 0);
  pf2.cbSize := SizeOf(PARAFORMAT2);
  pf2.dwMask := PFM_LINESPACING;
  pf2.bLineSpacingRule := iLineSpacing;
  PostMessage(Handle, EM_SETPARAFORMAT, 0,  Longint(@pf2));
end;

//------------------------------------------------------------------------------
// 光标滚动开头
//------------------------------------------------------------------------------
procedure TRichEditOle.RollToLineBegin;
begin
  SelLength:=0;
  Selstart:=0;
  PostMessage(Handle,EM_SCROLLCARET, 0, 0);
  PostMessage(Handle,WM_VSCROLL, SB_TOP, 0);
end;

//------------------------------------------------------------------------------
// 光标滚动到尾
//------------------------------------------------------------------------------
procedure TRichEditOle.RollToLineEnd(Bool:Boolean);
begin
  SelStart:=Length(Text);
  if SelStart>0 then
  if bool then
    begin
    SelLength:=1;
    SelText:=Widechar(10);
    end else begin
    SelLength:=-1;
    SelText:='';
    end;
  RollToPageEnd;
end;

procedure TRichEditOle.RollToPageEnd;
begin
  SelLength:=0;
  SelStart:=Length(Text);
  PostMessage(Handle,EM_SCROLLCARET, 0, 0);
  PostMessage(Handle,WM_VSCROLL, SB_BOTTOM, 0);
end;

//------------------------------------------------------------------------------
// 设置richedit font
//------------------------------------------------------------------------------
procedure TRichEditOle.FontHtmlLinkFormat;
begin
  SelAttributes.Size:=9;
  SelAttributes.Name:='宋体';
  SelAttributes.Style :=[];
  SelAttributes.Color:=clNavy;
  Paragraph.FirstIndent:=4;
end;

procedure TRichEditOle.FontUserNameFormat(bLoginUser:boolean);
begin
  SelAttributes.Size:=9;
  SelAttributes.Name:='宋体';
  SelAttributes.Style :=[];
  SelAttributes.Color:=clActiveCaption;
  if bLoginUser then
    SelAttributes.Color:=$00017E62;
  Paragraph.FirstIndent:=0;
end;

procedure TRichEditOle.SetFontFormat(TmpFontFormat:TFontFormat);
begin
  SelAttributes.Size:=TmpFontFormat.FontSize;
  SelAttributes.Name:=TmpFontFormat.FontName;
  SelAttributes.Style:=EnStyle(TmpFontFormat.FontStyle);
  SelAttributes.Color:=StringToColor(TmpFontFormat.FontColor);
end;

procedure TRichEditOle.FontMessageFormat(TmpFontFormat:TFontFormat);
begin
  SetFontFormat(TmpFontFormat);
  Paragraph.FirstIndent:=10;
end;

procedure TRichEditOle.RichVisibleDraw(bVisible:boolean);
begin
  if not bVisible then
    begin
    Perform(WM_SetRedraw, 1, 0);
    RePaint;
    end else Perform(WM_SetRedraw, 0, 0);
end;


function TRichEditOle.GetOleObjectInfor(var sTmpStr:String):Boolean;
var
  TmpInfor:TImageOleInfor;
  TmpObject:TReObject;
  TmpStream:IStream;
begin
  Result:=False;
  FillMemory(@TmpObject,SizeOf(TReObject),0);
  TmpObject.cbStruct:= SizeOf(TReObject);
  if FRichEditOle.GetObject(Integer(REO_IOB_SELECTION), TmpObject, REO_GETOBJ_PSTG) = S_OK then
  if Assigned(TmpObject.stg) then
    begin
    TmpObject.stg.OpenStream(Default_Flag_Name,nil,STGM_READ or STGM_SHARE_EXCLUSIVE,0,TmpStream);
    if Assigned(TmpStream) then
      begin
      FillMemory(@TmpInfor,SizeOf(TImageOleInfor),0);
      TmpStream.Read(@TmpInfor,SizeOf(TImageOleInfor),nil);
      sTmpStr:=TmpInfor.md5;
      TmpStream:=nil;
      Result:=True;
      end;
    TmpObject.stg:=nil;
    end;
end;

//------------------------------------------------------------------------------
//  将快捷转义符转换成 MD5
//------------------------------------------------------------------------------
procedure TRichEditOle.FormatCustomFaceToText;
var
  sTmpStr:String;
  sParams:WideString;
  Foundat,FStartPos,FLength:longint;
  i,n:integer;
begin
  if FaceList.Count>0 then
  for i:=1 to FaceList.count do
    begin
    sParams:=FaceList.strings[i-1];
    sTmpStr:=copy(sParams,1,34);
    n:=pos('/',sParams);
    delete(sParams,1,n-1);
    FStartPos:=0;
    FLength:=Length(Text)-FStartPos;
    Foundat:=FindText(sParams,FStartPos,FLength,[stMatchCase]);
    while Foundat<>-1 do
      begin
      FStartPos:=Foundat;
      SelStart:=FStartPos;
      SelLength:=length(sParams);
      SelText:=sTmpStr;
      SelLength:=0;
      FLength:=Length(Text)-FStartPos;
      Foundat:=FindText(sParams,FStartPos,FLength,[stMatchCase]);
      end;
    end;
end;

//------------------------------------------------------------------------------
//  将OLE转换成 MD5
//------------------------------------------------------------------------------
procedure TRichEditOle.FormatOleToText;
var
  i,iLen:integer;
  sTmpStr:String;
begin
  if FRichEditOle.GetObjectCount>0 then
    begin
    iLen:=Length(Text);
    for i:=iLen downto 1 do
    if Text[i]=Widechar(32) then
      begin
      SelStart:=i;
      SelLength:=-1;
      if GetOleObjectInfor(sTmpStr) then
        begin
        CloseObjectSelect;
        SelText:=sTmpStr;
        end;
      end;
    end;
end;

//------------------------------------------------------------------------------
// 将文字符号转换成OLE符号
//------------------------------------------------------------------------------
procedure TRichEditOle.FormatCharTextToOle(iStart:Integer);
var
  sTmpStr:String;
  TmpInfor:PImageInfo;
  sParams:WideString;
  foundat,FStartPos,Flength,i:longint;
begin
  if charlist.Count>0 then
  for i:=1 to charlist.count do
    begin
    sParams:=charlist.strings[i-1];
    sTmpStr:=copy(sParams,1,34);
    if ImageOle.Find(sTmpStr,TmpInfor) and Widefileexists(TmpInfor.filename) then
      begin
      delete(sParams,1,34);
      FStartPos:=iStart;
      Flength:=length(Text)-FStartPos;
      foundat:=FindText(sParams,FStartPos,Flength,[]);
      while foundat<>-1 do
        begin
        FStartPos:=foundat;
        SelStart:=FStartPos;
        SelLength:=length(sParams);
        SelText:='';
        SelLength:=0;
        InsertImageFile(TmpInfor.filename,TmpInfor.md5);
        Flength:=length(Text)-FStartPos;
        foundat:=FindText(sParams,FStartPos,Flength,[]);
        end;
      end;
    end;
end;

//------------------------------------------------------------------------------
// 将MD5转换成OLE符号
//------------------------------------------------------------------------------
procedure TRichEditOle.FormatCustomTextToOle(iStart:Integer);
var
  sTmpStr:String;
  TmpInfor:PImageInfo;
  foundat,FStartPos,Flengths:longint;
begin
  FStartPos:=iStart;
  Flengths:=length(Text)-iStart;
  foundat:=FindText(WideString('{'),FStartPos,Flengths,[]);
  while foundat<>-1 do
    begin
    SelStart:=foundat;
    SelLength:=34;
    sTmpStr:=SelText;
    if sTmpStr[34]='}' then
      begin
      if ImageOle.Find(sTmpStr,TmpInfor)and WideFileExists(TmpInfor.filename) then
        begin
        SelText:='';
        SelLength:=0;
        InsertImageFile(TmpInfor.filename,TmpInfor.md5);
        end else begin
        SelText:='';
        SelLength:=0;
        if ImageOle.Find(receivpic,TmpInfor)and WideFileExists(TmpInfor.filename) then
          InsertImageFile(TmpInfor.filename,sTmpStr,True);
        end;
       end else FStartPos:=foundat+1;
    Flengths:=length(Text)-FStartPos;
    foundat:=FindText(WideString('{'),FStartPos,Flengths,[]);
    end;
end;

procedure TRichEditOle.FormatTextToOle(iStart:Integer);
begin
  FormatCustomTextToOle(iStart); //首先将明文中的MD5转换成图片
  if newpictext_ok then
    FormatCharTextToOle(iStart); //文字图片转换
end;

//------------------------------------------------------------------------------
//  替换等候图片
//------------------------------------------------------------------------------
function TRichEditOle.GetOleText:WideString;
begin
  FormatCustomFaceToText;  //转义符替换成图片
  FormatOleToText;
  Result:=Text;
  Clear;
end;

//------------------------------------------------------------------------------
// 翻译HTML标记
//------------------------------------------------------------------------------
procedure TRichEditOle.FormatHtmltext(startpos:integer;iStart,iover:WideString);
var
  foundat,
  FStartPos,
  Flengths,
  AstartPos,Alength:integer;
begin
  FStartPos:=startpos;
  Flengths:=length(Text)-startpos;
  foundat:=FindText(iStart,FStartPos,Flengths,[]);
  while foundat<>-1 do
    begin
    SelStart:=foundat;
    SelLength:=length(iStart);
    SelText:=widechar(32);
    AstartPos:=foundat+1;
    FStartPos:=AstartPos;
    Flengths:=length(Text)-FStartPos;
    foundat:=FindText(iover,FStartPos,Flengths,[]);
    if foundat<>-1 then
       begin
       SelStart:=foundat;
       SelLength:=length(iover);
       SelText:=widechar(32);
       Alength:=foundat-FStartPos;
       InsertLink(AstartPos,Alength);
       end;
    Flengths:=length(Text)-FStartPos;
    foundat:=FindText(iStart,FStartPos,Flengths,[]);
    end;
end;

procedure TRichEditOle.FormatHtmltext(startpos:integer);
begin
  FormatHtmltext(startpos,widestring('<a>'),widestring('</a>'));
end;

//------------------------------------------------------------------------------
// 翻译特别标记
//------------------------------------------------------------------------------
procedure TRichEditOle.FormatSignalment(startpos:integer;iStart,iover:WideString;var place:Tplace);
var
  foundat,
  FStartPos,
  Flengths,
  AstartPos,Alength:integer;
begin
  FStartPos:=startpos;
  Flengths:=length(Text)-startpos;
  foundat:=FindText(iStart,FStartPos,Flengths,[]);
  if foundat<>-1 then
    begin
    SelStart:=foundat;
    SelLength:=length(iStart);
    SelText:=WideChar(32);
    AstartPos:=foundat+1;
    FStartPos:=AstartPos;
    Flengths:=length(Text)-FStartPos;
    foundat:=FindText(iover,FStartPos,Flengths,[]);
    if foundat<>-1 then
       begin
       SelStart:=foundat;
       SelLength:=length(iover);
       SelText:=WideChar(32);
       Alength:=foundat-FStartPos;
       InsertLink(AstartPos,Alength);
       place.AStartPos:=AstartPos;
       place.ALength:=ALength;
       end;
    end;
end;

procedure TRichEditOle.FormatSignalment(startpos:integer;var ol:ToleLink);
begin
  FormatSignalment(startpos,widestring('<Accept>'),widestring('</Accept>'),ol.Accept);
  FormatSignalment(startpos,widestring('<SaveAs>'),widestring('</SaveAs>'),ol.AcceptEx);
  FormatSignalment(startpos,widestring('<Cancel>'),widestring('</Cancel>'),ol.Cancel);
end;

procedure TRichEditOle.CancelHtml(ol:ToleLink);
begin
  if ol.Accept.ALength>0 then
   DeleteLink(ol.Accept.AStartPos,ol.Accept.ALength);
  if ol.AcceptEx.ALength>0 then
   DeleteLink(ol.AcceptEx.AStartPos,ol.AcceptEx.ALength);
  if ol.Cancel.ALength>0 then
   DeleteLink(ol.Cancel.AStartPos,ol.Cancel.ALength);
  SelLength:=0;
end;

//------------------------------------------------------------------------------
// 初始化 RichEditOle
//------------------------------------------------------------------------------
procedure TRichEditOle.InitRichEditOle(Bool:Boolean);
begin
  Clear;
  if Bool then
  with Paragraph do
    begin
    FirstIndent:=6;
    RightIndent:=6;
    end;
  SetLineSpacing(5);
end;

//------------------------------------------------------------------------------
// 返回 所选是否OLE
//------------------------------------------------------------------------------
function TRichEditOle.ObjectSelected:Boolean;
var
  ReObject:TReObject;
begin
  try
    result:=false;
    ReObject.cbStruct:= sizeof(TReObject);
    if FRichEditOle.GetObject(integer(REO_IOB_SELECTION), ReObject, REO_GETOBJ_POLEOBJ) = S_OK then
      begin
      result:=Assigned(ReObject.oleobj);
      ReObject.oleobj:=nil;
      end;
  except
    result:=false;
  end;
end;

procedure TRichEditOle.CloseObjectSelect;
var
  ReObject:TReObject;
begin
  try
    ReObject.cbStruct:= sizeof(TReObject);
    if FRichEditOle.GetObject(integer(REO_IOB_SELECTION), ReObject, REO_GETOBJ_POLEOBJ) = S_OK then
      begin
      if ReObject.dwFlags and REO_INPLACEACTIVE <> 0 then
        IRichEditOle(FRichEditOle).InPlaceDeactivate;
      ReObject.oleobj.Close(OLECLOSE_NOSAVE);
      ReObject.oleobj:=nil;
      end;
  except
  end;
end;
//------------------------------------------------------------------------------
// 关闭所有OLE对像
//------------------------------------------------------------------------------
procedure TRichEditOle.CloseObjects;
var
  I: Integer;
  ReObject: TReObject;
begin
  if Assigned(FRichEditOle) then begin
    FillChar(ReObject, SizeOf(ReObject), 0);
    ReObject.cbStruct := SizeOf(ReObject);
    with IRichEditOle(FRichEditOle) do begin
      for I := GetObjectCount - 1 downto 0 do
        if Succeeded(GetObject(I, ReObject, REO_GETOBJ_POLEOBJ)) then begin
          if ReObject.dwFlags and REO_INPLACEACTIVE <> 0 then
            IRichEditOle(FRichEditOle).InPlaceDeactivate;
          ReObject.oleobj.Close(OLECLOSE_NOSAVE);
          ReObject.oleobj:=nil;
        end;
    end;
  end;
end;

procedure TRichEditOle.Clear;
begin
  CloseObjects;
  inherited Clear;
end;

procedure TRichEditOle.IHideCaret(Bool:Boolean);
begin
  if Bool then HideCaret(Handle) else ShowCaret(Handle);
end;

procedure TRichEditOle.SelectText(AStartPos, ALength: Integer);
var
  Selection: TCharRange;
begin
  Perform(EM_SETSEL, RawWin32CharPos(AStartPos), RawWin32CharPos(AStartPos));
  Selection.cpMin := RawWin32CharPos(AStartPos);
  Selection.cpMax := RawWin32CharPos(AStartPos +ALength);
  Perform(EM_GETSEL, Longint(@Selection.cpMin), Longint(@Selection.cpMax));
  Selection.cpMax := RawWin32CharPos(AStartPos +ALength);
  Perform(EM_SETSEL, Selection.cpMin, Selection.cpMax);
end;


procedure TRichEditOle.InsertLink(AStartPos, ALength: Integer);
var
  cf2:TCharFormat2W;
begin
  SelectText(AStartPos, ALength);
  ZeroMemory(@cf2,sizeof(TCharFormat2W));
  cf2.cbSize := sizeof(TCharFormat2W);
  cf2.dwMask := CFM_LINK;
  cf2.dwEffects := CFE_LINK;
  Perform(EM_SETCHARFORMAT, SCF_SELECTION,Longint(@cf2));
end;

procedure TRichEditOle.DeleteLink(AStartPos, ALength: Integer);
var
  cf2:TCharFormat2W;
begin
  SelectText(AStartPos, ALength);
  ZeroMemory(@cf2,sizeof(TCharFormat2W));
  cf2.cbSize := sizeof(TCharFormat2W);
  cf2.dwMask := CFM_LINK;
  cf2.dwEffects := CFM_FACE;
  Perform(EM_SETCHARFORMAT, SCF_SELECTION,integer(@cf2));
end;

procedure TRichEditOle.ReplacePicture(sTmpStr:String);
var
  sFileName:WideString;
  ReObject:TReObject;
  TmpInfor:TImageOleInfor;
  TmpStream:IStream;
  i,iCount:Integer;
begin
  if not ImageOle.GetImageFileName(sTmpStr,sFileName) then
  if not ImageOle.GetImageFileName(blackpic,sFileName) then exit;

  try
  iCount:=FRichEditOle.GetObjectCount;
  for i:=iCount downto 1 do
    begin
    FillChar(ReObject,SizeOf(TReObject),#0);
    ReObject.cbStruct:= sizeof(TReObject);
    if FRichEditOle.GetObject(i-1,ReObject, REO_GETOBJ_PSTG or REO_GETOBJ_POLEOBJ) = S_OK then
    if ReObject.dwUser=1 then
      begin
      ReObject.stg.OpenStream(Default_Flag_Name,nil,STGM_READ or STGM_SHARE_EXCLUSIVE,0,TmpStream);
      if Assigned(TmpStream) then
        begin
        FillMemory(@TmpInfor,SizeOf(TImageOleInfor),0);
        TmpStream.Read(@TmpInfor,SizeOf(TImageOleInfor),nil);
        if CompareText(sTmpStr,TmpInfor.md5)=0 then
          begin
          if ReObject.dwFlags and REO_INPLACEACTIVE <> 0 then
            IRichEditOle(FRichEditOle).InPlaceDeactivate;
          ReObject.oleobj.Close(OLECLOSE_NOSAVE);
          SelStart:=TmpInfor.iStart;
          SelLength:=1;
          SelText:='';
          SelLength:=0;
          InsertImageFile(sFileName,sTmpStr);
          end;
        TmpStream:=nil;
        end;
      ReObject.oleobj:=nil;
      ReObject.stg:=nil;
      end;
    end;
  except

  end;
end;

//------------------------------------------------------------------------------
// 返回PIC文件名
//------------------------------------------------------------------------------
function TRichEditOle.GetImageFileName:widestring;
var
  ReObject:TReObject;
  FGifAnimator:IGifAnimator;
begin
  try
  result:='';
  ReObject.cbStruct:= sizeof(REObject);
  if FRichEditOle.GetObject(integer(REO_IOB_SELECTION), ReObject, REO_GETOBJ_POLEOBJ) = S_OK then
    begin
    ReObject.oleobj.QueryInterface(IID_IUnknown,FGifAnimator);
    if assigned(FGifAnimator) then
      result:=FGifAnimator.GetFilePath;
    ReObject.oleobj:=nil;
    FGifAnimator:=nil;
    end;
  except

  end;
end;

function TRichEditOle.GetNeedDownFileSign(var sTmpStr:String):Boolean;
var
  ReObject:TReObject;
  TmpInfor:TImageOleInfor;
  TmpStream:IStream;
  i:Integer;
begin
  try
  Result:=False;
  for i:=1 to FRichEditOle.GetObjectCount do
    begin
    FillChar(ReObject,SizeOf(TReObject),#0);
    ReObject.cbStruct:= sizeof(TReObject);
    if FRichEditOle.GetObject(i-1,ReObject, REO_GETOBJ_PSTG) = S_OK then
    if ReObject.dwUser=1 then
      begin
      ReObject.stg.OpenStream(Default_Flag_Name,nil,STGM_READ or STGM_SHARE_EXCLUSIVE,0,TmpStream);
      if Assigned(TmpStream) then
        begin
        FillMemory(@TmpInfor,SizeOf(TImageOleInfor),0);
        TmpStream.Read(@TmpInfor,SizeOf(TImageOleInfor),nil);
        sTmpStr:=TmpInfor.md5;
        TmpStream:=nil;
        Result:=True;
        Break;        
        end;
      ReObject.stg:=nil;
      end;
    end;
  except
  Result:=False;
  end;
end;

//------------------------------------------------------------------------------
// 插入 pic
//------------------------------------------------------------------------------
procedure TRichEditOle.InsertImageFile(sFileName:WideString;const sMD5:String='';const bWait:Boolean=False);
var
  fole:ioleobject;
  FStorage:ISTORAGE;
  TmpStream:IStream;
  FClientSite:IOleClientSite;
  ReObject:TReObject;
  clsid:TGuid;
  Fanimator:IGifAnimator;
  TmpInfor:TImageOleInfor;
begin
  if WidefileExists(sFileName) then
    try
    FRichEditOleCallback.GetNewStorage(FStorage);
    FRichEditOle.GetClientSite(FClientSite);
    Fanimator:=IUnknown(CreateComObject(CLASS_GifAnimator)) as IGifAnimator;
    Fanimator.LoadFromFile(sFileName);
    Fanimator.QueryInterface(IID_IOleObject,fole);
    OleSetContainedObject(FOle,TRUE);

    Fillchar(ReObject, sizeof(TReObject), 0);
    ReObject.cbStruct := sizeof(TReObject);
    FOle.GetUserClassID(clsid);
    ReObject.clsid := clsid;
    ReObject.cp := integer(REO_CP_SELECTION);
    ReObject.dvaspect := DVASPECT_CONTENT;
    ReObject.dwFlags := ULong(REO_STATIC) or ULong(REO_BELOWBASELINE) ;
    ReObject.oleobj := FOle;
    ReObject.olesite := FClientSite;
    ReObject.stg := FStorage;
    ReObject.sizel.cx:=0;
    ReObject.sizel.cy:=0;

    //--------------------------------------------------------------------------
    // bWait 表示文件不存在需要等待停等待
    //--------------------------------------------------------------------------
    FillMemory(@TmpInfor,SizeOf(TImageOleInfor),0);
    if bWait then
      begin
      ReObject.dwUser := 1;
      TmpInfor.iStart:=SelStart;
      end;

    TmpInfor.md5:=sMD5;
    FStorage.CreateStream(Default_Flag_Name,STGM_CREATE or STGM_READWRITE or STGM_SHARE_EXCLUSIVE,0,0,TmpStream);
    if assigned(TmpStream) then
      TmpStream.Write(@TmpInfor,SizeOf(TImageOleInfor),nil);

    FRichEditOle.InsertObject(ReObject);
    except
    FClientSite:=nil;
    TmpStream:=nil;
    FStorage:=nil;
    FOle:=nil;
    end;
end;

//------------------------------------------------------------------------------
//  RicheditOle CallBack
//------------------------------------------------------------------------------
constructor TRichEditOleCallback.Create(AOwner: TRichEditOle);
begin
  inherited Create;
  FOwner:= AOwner;
end;

function TRichEditOleCallback.GetNewStorage(out stg: IStorage): HRESULT;
var
  LockBytes: ILockBytes;
begin
  try
    Result:= S_OK;  
    OleCheck(CreateILockBytesOnHGlobal(0, True, LockBytes));
    OleCheck(StgCreateDocfileOnILockBytes(LockBytes, STGM_READWRITE
      or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, stg));
    LockBytes:=nil;
  except
    LockBytes:=nil;
    Result:= E_OUTOFMEMORY;
  end;
end;

function TRichEditOleCallback.GetInPlaceContext(out Frame: IOleInPlaceFrame;
       out Doc: IOleInPlaceUIWindow; var FrameInfo: TOleInPlaceFrameInfo): HRESULT;
begin
  Result:= E_NOTIMPL;
end;

function TRichEditOleCallback.ShowContainerUI(fShow: BOOL): HRESULT;
begin
  Result:= E_NOTIMPL;
end;

function TRichEditOleCallback.QueryInsertObject(const clsid: TCLSID; stg: IStorage;
       cp: longint): HRESULT;
begin
  Result:= S_OK;
end;

function TRichEditOleCallback.DeleteObject(oleobj: IOLEObject): HRESULT;
begin
  if Assigned(oleobj) then
    begin
    oleobj.Close(OLECLOSE_NOSAVE);
    oleobj:=nil;
    end;
  Result:= S_OK;
end;


function TRichEditOleCallback.ContextSensitiveHelp(fEnterMode: BOOL): HRESULT;
begin
  Result:= E_NOTIMPL;
end;

function TRichEditOleCallback.GetClipboardData(const chrg: TCharRange; reco: DWORD;
         out dataobj: IDataObject): HRESULT;
begin
  Result:= E_NOTIMPL;
end;

function TRichEditOleCallback.GetDragDropEffect(fDrag: BOOL; grfKeyState: DWORD;
         var dwEffect: DWORD): HRESULT;
begin
  Result:= E_NOTIMPL;
end;


function GetTempDirectory: string;
var
  TempDir: array[0..255] of Char;
begin
  GetTempPath(255, @TempDir);
  Result := StrPas(TempDir);
end;

procedure TRichEditOleCallback.PasteImage(StgMedium: TStgMedium);
var
  sFileName:String;
  TmpBitmap:TBitmap;
begin
  try
  TmpBitmap:=TBitmap.Create;
  TmpBitmap.Handle:=StgMedium.hBitmap;
  sFileName:=ConCat(GetTempDirectory,DefaultTmpPath,'\',IntToStr(GetTickCount()),'.bmp');
  ForceDirectories(ExtractFilePath(sFileName));
  if FileExists(sFileName) then DeleteFile(sFileName);
  TmpBitmap.SaveToFile(sFileName);
  if Assigned(FOwner.FOnPasteImage)then
    FOwner.OnPasteImage(nil,sFileName);
  finally
  freeandnil(TmpBitmap);
  end;
end;

procedure TRichEditOleCallback.DropFiles(StgMedium: TStgMedium);
var
  i,iCount:integer;
  iBuffer: Integer;
	sFileName:PWideChar;
  sFileList:WideString;
begin
  try
  iCount := DragQueryFileW(StgMedium.hGlobal, $FFFFFFFF, nil, 0);
  For i := 0 To iCount - 1 Do
    begin
    iBuffer := DragQueryFileW(StgMedium.hGlobal, i, nil, 0);
    sFileName := AllocMem((iBuffer+1) * 2);
      try
      DragQueryFileW(StgMedium.hGlobal, i, sFileName, iBuffer+1);
      sFileList:=ConCat(sFileList,#13,sFileName);
      finally
      FreeMem(sFileName);
      end;
    end;
  if Length(sFileList)>0 then Delete(sFileList,1,1);
  if Assigned(FOwner.FOnDropFile)  then
    FOwner.FOnDropFile(nil,sFileList);
  finally
  DragFinish(StgMedium.hGlobal);
  end;
end;

function TRichEditOleCallback.QueryAcceptData(dataobj: IDataObject; var cfFormat: TClipFormat;
         reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HRESULT;
var
  StgMedium: TStgMedium;
begin
  if (dataobj.GetData(FBitmapFormatEtc, StgMedium)) = S_OK then
     begin
     PasteImage(StgMedium);
     ReleaseStgMedium(StgMedium);
     Result:=S_FALSE;
     exit;
     end;

  if (dataobj.GetData(FDropFormatEtc, StgMedium)) = S_OK then
     begin
     if fReally then DropFiles(StgMedium);
     ReleaseStgMedium(StgMedium);
     Result:=S_FALSE;
     exit;
     end;

  Result:= E_NOTIMPL;
end;

procedure TRichEditOleCallback.CustomContextMenu(bObject:Boolean);
var
  P:TPoint;
begin
  GetCursorPos(P);
  if assigned(Fowner.OnContextPopup) then
    Fowner.OnContextPopup(nil,P,bObject);
  if Assigned(Fowner.PopupMenu) then
    FOwner.PopupMenu.Popup(P.x,P.y);
end;

function TRichEditOleCallback.GetContextMenu(seltype: Word; oleobj: IOleObject;
         const chrg: TCharRange; var menu: HMENU): HRESULT;
begin
  CustomContextMenu(seltype=SEL_OBJECT);
  Result:= E_NOTIMPL;
end;


initialization
  CoInitialize(nil);
  
finalization
  CoUnInitialize;
end.
