object addfirendFrame: TaddfirendFrame
  Left = 368
  Top = 162
  BorderStyle = bsNone
  ClientHeight = 225
  ClientWidth = 348
  Color = clBtnFace
  TransparentColorValue = clWhite
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
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 12
  object Panel_Frame: TTntPanel
    Left = 5
    Top = 27
    Width = 338
    Height = 184
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object Image_BackGroup: TImage
      Left = 0
      Top = 0
      Width = 338
      Height = 184
      Align = alClient
      AutoSize = True
      Stretch = True
    end
    object Image_Close: TImage
      Left = 237
      Top = 152
      Width = 77
      Height = 24
      Cursor = crHandPoint
      Hint = #20851#38381
      AutoSize = True
      ParentShowHint = False
      ShowHint = True
      OnClick = Lab_CloseClick
    end
    object Bevel1: TBevel
      Left = 8
      Top = 8
      Width = 321
      Height = 137
      Shape = bsFrame
    end
    object Lab_Caption: TLabel
      Left = 16
      Top = 16
      Width = 174
      Height = 12
      Caption = #30830#23450#35201#28155#21152' firendid '#20026#22909#21451#21527'?'
      Transparent = True
    end
    object Lab_userid: TLabel
      Left = 24
      Top = 32
      Width = 66
      Height = 12
      Caption = #24080#21495':userid'
      Transparent = True
    end
    object Lab_uname: TLabel
      Left = 176
      Top = 32
      Width = 90
      Height = 12
      Caption = #26165#31216':firendname'
      Transparent = True
    end
    object Lab_prompt: TLabel
      Left = 16
      Top = 56
      Width = 108
      Height = 12
      Caption = #39564#35777#20449#24687'(25'#23383#20197#20869')'
      Transparent = True
    end
    object Image_Yes: TImage
      Left = 156
      Top = 152
      Width = 77
      Height = 24
      Cursor = crHandPoint
      Hint = #30830#23450
      AutoSize = True
      ParentShowHint = False
      ShowHint = True
    end
    object main_memo: TRichEdit
      Left = 16
      Top = 72
      Width = 305
      Height = 65
      BevelInner = bvNone
      BevelOuter = bvNone
      Ctl3D = True
      Font.Charset = GB2312_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      HideScrollBars = False
      Lines.Strings = (
        'RichEdit1')
      MaxLength = 50
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
    end
  end
  object Panel_Title: TPanelEx
    Left = 0
    Top = 0
    Width = 348
    Height = 27
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    OnMouseDown = Image_TitleCenterMouseDown
    object Image_TitleLeft: TImage
      Left = 0
      Top = 0
      Width = 116
      Height = 27
      Align = alLeft
      AutoSize = True
      OnMouseDown = Image_TitleLeftMouseDown
    end
    object Image_TitleRight: TImage
      Left = 207
      Top = 0
      Width = 141
      Height = 27
      Align = alRight
      AutoSize = True
      OnMouseDown = Image_TitleRightMouseDown
    end
    object Lab_Min: TTntLabel
      Left = 237
      Top = 0
      Width = 29
      Height = 27
      Cursor = crHandPoint
      Hint = #26368#23567#21270
      AutoSize = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
      OnClick = Lab_MinClick
      OnMouseEnter = Lab_MinMouseEnter
      OnMouseLeave = Lab_MinMouseLeave
    end
    object Lab_Max: TTntLabel
      Left = 266
      Top = 0
      Width = 30
      Height = 27
      Cursor = crHandPoint
      Hint = #26368#22823#21270
      AutoSize = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
      OnMouseEnter = Lab_MaxMouseEnter
      OnMouseLeave = Lab_MaxMouseLeave
    end
    object Lab_Close: TTntLabel
      Left = 296
      Top = 0
      Width = 50
      Height = 27
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
    object Lab_FormCaption: TTntLabel
      Left = 32
      Top = 8
      Width = 52
      Height = 12
      Caption = #36523#20221#39564#35777
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      OnMouseDown = Image_TitleLeftMouseDown
    end
  end
  object Panel_Left: TPanelEx
    Left = 0
    Top = 27
    Width = 5
    Height = 184
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 2
  end
  object Panel_Right: TPanelEx
    Left = 343
    Top = 27
    Width = 5
    Height = 184
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 3
  end
  object Panel_Bottom: TPanelEx
    Left = 0
    Top = 211
    Width = 348
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
      Left = 330
      Top = 0
      Width = 18
      Height = 14
      Align = alRight
      AutoSize = True
    end
  end
end
