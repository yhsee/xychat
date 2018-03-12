object copy_screen: Tcopy_screen
  Left = 404
  Top = 185
  BorderIcons = []
  BorderStyle = bsNone
  Caption = #25130#21462#23631#24149#31383#21475
  ClientHeight = 174
  ClientWidth = 314
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Scaled = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ScreenImg: TImage
    Left = 0
    Top = 0
    Width = 313
    Height = 172
    Cursor = crCross
    Hint = #21452#20987#25130#21462','#21491#38190#21462#28040
    Center = True
    ParentShowHint = False
    ShowHint = True
    OnDblClick = ScreenImgDblClick
    OnMouseDown = ScreenImgMouseDown
    OnMouseMove = ScreenImgMouseMove
    OnMouseUp = ScreenImgMouseUp
  end
  object coordinate: TLabel
    Left = 40
    Top = 72
    Width = 3
    Height = 13
    Transparent = True
    Layout = tlCenter
  end
end
