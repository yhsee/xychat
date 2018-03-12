Unit RichEditCommUnt;

{*
 *	RICHOLE.H
 *
 *	Purpose:
 *		OLE Extensions to the Rich Text Editor
 *
 *	Copyright (c) 1985-1996, Microsoft Corporation
 *}

{WEAKPACKAGEUNIT}
{$MINENUMSIZE 4}

interface

uses Windows, ActiveX,RichEdit,Graphics;

const
  Default_ImageOle_Native_MD5   =1;
  Default_ImageOle_Replace_MD5  =2;
// Flags to specify which interfaces should be returned in the structure above
  REO_GETOBJ_NO_INTERFACES	= $00000000;
  REO_GETOBJ_POLEOBJ		= $00000001;
  REO_GETOBJ_PSTG		= $00000002;
  REO_GETOBJ_POLESITE		= $00000004;
  REO_GETOBJ_ALL_INTERFACES	= $00000007;

// Place object at selection
  REO_CP_SELECTION = $FFFFFFFF;

// Use character position to specify object instead of index
  REO_IOB_SELECTION = $FFFFFFFF;
  REO_IOB_USE_CP  = $FFFFFFFF;

// Object flags
  REO_NULL		= $00000000;	// No flags
  REO_READWRITEMASK	= $0000003F;	// Mask out RO bits
  REO_DONTNEEDPALETTE	= $00000020;	// Object doesn't need palette
  REO_BLANK		= $00000010;	// Object is blank
  REO_DYNAMICSIZE	= $00000008;	// Object defines size always
  REO_INVERTEDSELECT	= $00000004;	// Object drawn all inverted if sel
  REO_BELOWBASELINE	= $00000002;	// Object sits below the baseline
  REO_RESIZABLE		= $00000001;	// Object may be resized
  REO_LINK		= $80000000;	// Object is a link (RO)
  REO_STATIC		= $40000000;	// Object is static (RO)
  REO_SELECTED		= $08000000;	// Object selected (RO)
  REO_OPEN		= $04000000;	// Object open in its server (RO)
  REO_INPLACEACTIVE	= $02000000;	// Object in place active (RO)
  REO_HILITED		= $01000000;	// Object is to be hilited (RO)
  REO_LINKAVAILABLE	= $00800000;	// Link believed available (RO)
  REO_GETMETAFILE	= $00400000;	// Object requires metafile (RO)

// flags for IRichEditOle::GetClipboardData(),
// IRichEditOleCallback::GetClipboardData() and
// IRichEditOleCallback::QueryAcceptData()
  RECO_PASTE			= $00000000;	// paste from clipboard
  RECO_DROP			= $00000001;	// drop
  RECO_COPY			= $00000002;	// copy to the clipboard
  RECO_CUT			= $00000003;	// cut to the clipboard
  RECO_DRAG			= $00000004;	// drag

  IID_IGifAnimator: TGUID = '{0C1CF2DF-05A3-4FEF-8CD4-F5CFC4355A16}';
  CLASS_GifAnimator: TGUID = '{06ADA938-0FB0-4BC0-B19B-0A38AB17F182}';

  IID_IUnknown:   TGUID = (D1:$00000000;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleObject: TGUID = (D1:$00000112;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));

{*
 *	IRichEditOle
 *
 *	Purpose:
 *		Interface used by the client of RichEdit to perform OLE-related
 *		operations.
 *
 *	//$ REVIEW:
 *		The methods herein may just want to be regular Windows messages.
 *}
// Structure passed to GetObject and InsertObject

Const
  DefaultTmpPath        = 'Richedit';
  Default_Flag_Name     = 'Image Information';
  FBitmapFormatEtc:    TFormatEtc = ( cfFormat: CF_BITMAP; ptd: Nil; dwAspect: DVASPECT_CONTENT; lindex: - 1; tymed: TYMED_GDI);
  FDropFormatEtc:      TFormatEtc = ( cfFormat: CF_HDROP; ptd: Nil; dwAspect: DVASPECT_CONTENT; lindex: - 1; tymed: TYMED_HGLOBAL);

type
//------------------------------------------------------------------------------
// OLE RICHEDIT URL  结构
//------------------------------------------------------------------------------
  TLinkType = (lFile,lMedia,lRemote,lNetMeeting,lOther);
  Tplace =Packed record
    AStartPos: Integer;
    ALength: Integer;
  end;

  POleLink=^TOleLink;
  TOleLink=Packed record
   LinkID:LongWord;
   lType:TLinkType;
   Status, {0:Waiting, 1:Run}
   State:Byte;{0:accept, 1:acceptex, 2:Cancel }
   Accept,
   AcceptEx,
   Cancel:Tplace;
   params:WideString;
   end;

  PImageOleInfor=^TImageOleInfor;
  TImageOleInfor=Record
    md5:String[34];
    iStart:Integer;
    end;

//------------------------------------------------------------------------------
// font 结构
//------------------------------------------------------------------------------
  TFontFormat=Record
    FontName,
    FontColor:String;
    FontStyle:String[4];
    FontSize:Integer;
    end;

  TClickEvent = procedure(Sender :TObject; const sParams: Widestring) of object;
  TDropEvent = TClickEvent;
  TLinkClickEvent = procedure(Sender :TObject; const URL: Widestring;AStartPos, ALength: Integer) of object;

type
  TCHARFORMAT2 = record
    cbSize: UINT;
    dwMask: DWORD;
    dwEffects: DWORD;
    yHeight: Longint;
    yOffset: Longint;
    crTextColor: TColorRef;
    bCharSet: Byte;
    bPitchAndFamily: Byte;
    szFaceName: array[0..LF_FACESIZE - 1] of AnsiChar;
    wWeight: Word;                   { Font weight (LOGFONT value)		 }
    sSpacing: Smallint;              { Amount to space between letters	 }
    crBackColor: TColorRef;          { Background color					 }
    lid: LCID;                       { Locale ID						 }
    dwReserved: DWORD;               { Reserved. Must be 0				 }
    sStyle: Smallint;                { Style handle						 }
    wKerning: Word;                  { Twip size above which to kern char pair }
    bUnderlineType: Byte;            { Underline type					 }
    bAnimation: Byte;                { Animated text like marching ants	 }
    bRevAuthor: Byte;                { Revision author index			 }
    bReserved1: Byte;
  end;
  
  TREOBJECT = packed record
    cbStruct: DWORD;			// Size of structure
    cp: integer;			// Character position of object
    clsid: TCLSID;			// Class ID of object
    oleobj: IOleObject;			// OLE object interface
    stg: IStorage;			// Associated storage interface
    olesite: IOLEClientSite;		// Associated client site interface
    sizel: TSize;			// Size of object (may be 0,0)
    dvaspect: DWORD;			// Display aspect to use
    dwFlags: DWORD;			// Object status flags
    dwUser: DWORD;			// Dword for user's use
  end;
// *********************************************************************//
// Interface: IGifAnimator
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0C1CF2DF-05A3-4FEF-8CD4-F5CFC4355A16}
// *********************************************************************//
  IGifAnimator = interface(IDispatch)
    ['{0C1CF2DF-05A3-4FEF-8CD4-F5CFC4355A16}']
    procedure LoadFromFile(const FileName: WideString); safecall;
    function  TriggerFrameChange: WordBool; safecall;
    function  GetFilePath: WideString; safecall;
    procedure ShowText(const Text: WideString); safecall;
  end;

// *********************************************************************//
// DispIntf:  IGifAnimatorDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0C1CF2DF-05A3-4FEF-8CD4-F5CFC4355A16}
// *********************************************************************//
  IGifAnimatorDisp = dispinterface
    ['{0C1CF2DF-05A3-4FEF-8CD4-F5CFC4355A16}']
    procedure LoadFromFile(const FileName: WideString); dispid 1;
    function  TriggerFrameChange: WordBool; dispid 2;
    function  GetFilePath: WideString; dispid 3;
    procedure ShowText(const Text: WideString); dispid 4;
  end;

  IRichEditOle = interface(System.IUnknown)
    ['{00020D00-0000-0000-C000-000000000046}']
    function GetClientSite(out lplpolesite: IOLECLIENTSITE): HResult; stdcall;
    function GetObjectCount: longint; stdcall;
    function GetLinkCount: longint; stdcall;
    function GetObject(iob: longint; out reobject: TREOBJECT; dwFlags: DWORD): HRESULT; stdcall;
    function InsertObject(const reobject: TREOBJECT): HResult; stdcall;
    function ConvertObject(iob: longint; const clsidNew: TCLSID;
       lpStrUserTypeNew: POleStr): HRESULT; stdcall;
    function ActivateAs(const clsid, clsidAs: TCLSID): HRESULT; stdcall;
    function SetHostNames(lpstrContainerApp, lpstrContainerObj: POleStr): HRESULT; stdcall;
    function SetLinkAvailable(iob: longint; fAvailable: BOOL): HRESULT; stdcall;
    function SetDvaspect(iob: longint; dvaspect: DWORD): HRESULT; stdcall;
    function HandsOffStorage(iob: longint): HRESULT; stdcall;
    function SaveCompleted(iob: longint; stg: IStorage): HRESULT; stdcall;
    function InPlaceDeactivate: HRESULT; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HRESULT; stdcall;
    function GetClipboardData(const chrg: TCharRange; reco: DWORD;
         out dataobj: IDataObject): HRESULT; stdcall;
    function ImportDataObject(dataobj: IDataObject; cf: TClipFormat;
         hMetaPict: HGLOBAL): HRESULT; stdcall;
  end;

{*
 *	IRichEditOleCallback
 *
 *	Purpose:
 *		Interface used by the RichEdit to get OLE-related stuff from the
 *		application using RichEdit.
 *}
  IRichEditOleCallback = interface(System.IUnknown)
    ['{00020D03-0000-0000-C000-000000000046}']
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
  end;


function RichEdit_SetOleCallback(RichEdit: HWnd; OleInterface: IRichEditOleCallback): BOOL;
function RichEdit_GetOleInterface(RichEdit: HWnd; out OleInterface: IRichEditOle): BOOL;
//------------------------------------------------------------------------------
function InitFontFormat:TFontFormat;
function DeStyle(TmpStyle:TFontStyles):String;
function EnStyle(sTmpStr:string):TFontStyles;
procedure ChangeFontFormat(TmpFont:TFont;var TmpFontFormat:TFontFormat);
procedure ChangeFont(TmpFont:TFont;TmpFontFormat:TFontFormat);
//------------------------------------------------------------------------------
function RegisterOleFile (sFileName : WideString; OleAction : Byte ) : Boolean;

implementation


function RichEdit_SetOleCallback(RichEdit: HWnd; OleInterface: IRichEditOleCallback): BOOL;
begin
  Result:= BOOL(SendMessage(RichEdit, EM_SETOLECALLBACK, 0, longint(OleInterface)));
end;

function RichEdit_GetOleInterface(RichEdit: HWnd; out OleInterface: IRichEditOle): BOOL;
begin
  Result:= BOOL(SendMessage(RichEdit, EM_GETOLEINTERFACE, 0, longint(@OleInterface)));
end;

function InitFontFormat:TFontFormat;
begin
  Result.FontName:='宋体';
  Result.FontSize:=9;
  Result.FontColor:='clBlack';
  Result.FontStyle:='0000';
end;

//------------------------------------------------------------------------------
//字体解析
//------------------------------------------------------------------------------
function DeStyle(TmpStyle:TFontStyles):String;
begin
  Result:='0000';
  if fsbold in TmpStyle then Result[1]:='1';
  if fsitalic in TmpStyle then Result[2]:='1';
  if fsunderline in TmpStyle then Result[3]:='1';
  if fsstrikeout in TmpStyle then Result[4]:='1';
end;

function EnStyle(sTmpStr:string):TFontStyles;
begin
  Result:=[];
  if length(sTmpStr)=4 then
   begin
   if sTmpStr[1]='1' then Result:=Result+[fsbold];
   if sTmpStr[2]='1' then Result:=Result+[fsitalic];
   if sTmpStr[3]='1' then Result:=Result+[fsunderline];
   if sTmpStr[4]='1' then Result:=Result+[fsstrikeout];
   end;
end;

procedure ChangeFontFormat(TmpFont:TFont;var TmpFontFormat:TFontFormat);
begin
  TmpFontFormat.FontName:=TmpFont.Name;
  TmpFontFormat.FontSize:=TmpFont.Size;
  TmpFontFormat.FontColor:=ColorToString(TmpFont.Color);
  TmpFontFormat.FontStyle:=DeStyle(TmpFont.style);
end;

procedure ChangeFont(TmpFont:TFont;TmpFontFormat:TFontFormat);
begin
  TmpFont.Name:=TmpFontFormat.FontName;
  TmpFont.Size:=TmpFontFormat.FontSize;
  TmpFont.Color:=StringToColor(TmpFontFormat.FontColor);
  TmpFont.Style:=EnStyle(TmpFontFormat.FontStyle);  
end;

//------------------------------------------------------------------------------
// 注册 imageole.dll
//------------------------------------------------------------------------------
function RegisterOleFile (sFileName : WideString; OleAction : Byte ) : Boolean;
const
    RegisterOle = 1;//注册
    UnRegisterOle = 0;//卸载
type
    TOleRegisterFunction = function : HResult;//注册或卸载函数的原型
var
    hLibraryHandle : THandle;//由LoadLibrary返回的DLL或OCX句柄
    hFunctionAddress: TFarProc;//DLL或OCX中的函数句柄，由GetProcAddress返回
    RegFunction : TOleRegisterFunction;//注册或卸载函数指针
begin
Result := FALSE;
//打开OLE/DCOM文件，返回的DLL或OCX句柄
hLibraryHandle := LoadLibraryW(PWideChar(sFileName));
if (hLibraryHandle > 0) then//DLL或OCX句柄正确
   try
      //返回注册或卸载函数的指针
      if (OleAction = RegisterOle) then
          hFunctionAddress := GetProcAddress(hLibraryHandle, pchar('DllRegisterServer')) //返回注册函数的指针
      else  hFunctionAddress := GetProcAddress(hLibraryHandle, pchar('DllUnregisterServer')); //返回卸载函数的指针
      if (hFunctionAddress <> NIL) then//注册或卸载函数存在
          begin
          RegFunction := TOleRegisterFunction(hFunctionAddress);//获取操作函数的指针
          if RegFunction >= 0 then //执行注册或卸载操作，返回值>=0表示执行成功
              result := true;
          end;
   finally
      FreeLibrary(hLibraryHandle);//关闭已打开的OLE/DCOM文件
   end;
end;

initialization


end.

