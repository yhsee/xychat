object FrmMain: TFrmMain
  Left = 341
  Top = -6
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Gagaku IM'
  ClientHeight = 543
  ClientWidth = 266
  Color = clBtnFace
  Constraints.MaxHeight = 1024
  Constraints.MaxWidth = 1280
  Constraints.MinHeight = 200
  Constraints.MinWidth = 265
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = TntFormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 12
  object Panel_Frame: TPanelEx
    Left = 5
    Top = 27
    Width = 256
    Height = 502
    Picture.Data = {
      0A544A504547496D61676582010000FFD8FFE000104A46494600010200006400
      640000FFEC00114475636B7900010004000000510000FFEE000E41646F626500
      64C000000001FFDB008400020202020202020202020302020203040302020304
      0404040404040406040505050504060607070707070609090A0A09090C0C0C0C
      0C0C0C0C0C0C0C0C0C0C0C01020303050405090606090D0A080A0D0F0E0E0E0E
      0F0F0C0C0C0C0C0F0F0C0C0C0C0C0C0F0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C
      0C0C0C0C0C0C0C0C0C0C0C0CFFC0001108000B010103011100021101031101FF
      C400590001010100000000000000000000000000000409010101010000000000
      000000000000000000010310010001040300000000000000000000000001B203
      3405710282110100030000000000000000000000000000013203FFDA000C0301
      0002110311003F00DEFD7E25BE7BD72D74B242D64A0000000000000000000000
      00000000000000000000000023D7E25AF55CB4D2C90B19A80000000000000000
      000000000000000000000000000000FFD9}
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
  end
  object Panel_Title: TPanelEx
    Left = 0
    Top = 0
    Width = 266
    Height = 27
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    OnDblClick = Lab_MaxClick
    OnMouseDown = Image_TitleCenterMouseDown
    object Image_TitleLeft: TImage
      Left = 0
      Top = 0
      Width = 117
      Height = 27
      Align = alLeft
      AutoSize = True
      OnDblClick = Lab_MaxClick
      OnMouseDown = Image_TitleLeftMouseDown
    end
    object Image_TitleRight: TImage
      Left = 137
      Top = 0
      Width = 129
      Height = 27
      Align = alRight
      OnMouseDown = Image_TitleRightMouseDown
    end
    object Lab_Min: TTntLabel
      Left = 156
      Top = 1
      Width = 29
      Height = 22
      Cursor = crHandPoint
      Hint = #26368#23567#21270
      AutoSize = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
      OnMouseEnter = Lab_MinMouseEnter
      OnMouseLeave = Lab_MinMouseLeave
    end
    object Lab_Max: TTntLabel
      Left = 185
      Top = 1
      Width = 30
      Height = 22
      Cursor = crHandPoint
      Hint = #26368#22823#21270
      AutoSize = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
      OnClick = Lab_MaxClick
      OnMouseEnter = Lab_MaxMouseEnter
      OnMouseLeave = Lab_MaxMouseLeave
    end
    object Lab_Close: TTntLabel
      Left = 214
      Top = 1
      Width = 50
      Height = 23
      Cursor = crHandPoint
      Hint = #20851#38381
      AutoSize = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
      OnClick = Lab_CloseClick
      OnMouseEnter = Lab_CloseMouseEnter
      OnMouseLeave = Lab_CloseMouseLeave
    end
  end
  object Panel_Left: TPanelEx
    Left = 0
    Top = 27
    Width = 5
    Height = 502
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 2
  end
  object Panel_Right: TPanelEx
    Left = 261
    Top = 27
    Width = 5
    Height = 502
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 3
  end
  object Panel_Bottom: TPanelEx
    Left = 0
    Top = 529
    Width = 266
    Height = 14
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    object Image_BottomLeft: TImage
      Left = 0
      Top = 0
      Width = 13
      Height = 14
      Align = alLeft
      AutoSize = True
    end
    object Image_BottomRight: TImage
      Left = 248
      Top = 0
      Width = 18
      Height = 14
      Cursor = crSizeNWSE
      Align = alRight
      AutoSize = True
      OnMouseDown = Image_BottomRightMouseDown
    end
  end
end
