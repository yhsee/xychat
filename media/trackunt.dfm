object trackfrm: Ttrackfrm
  Left = 284
  Top = 208
  BorderStyle = bsNone
  ClientHeight = 23
  ClientWidth = 121
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object TrackBar1: TTrackBar
    Left = 34
    Top = 2
    Width = 87
    Height = 22
    Cursor = crHandPoint
    LineSize = 0
    Max = 65535
    Orientation = trHorizontal
    PageSize = 8192
    Frequency = 1
    Position = 0
    SelEnd = 0
    SelStart = 0
    TabOrder = 0
    ThumbLength = 16
    TickMarks = tmBottomRight
    TickStyle = tsNone
    OnChange = TrackBar1Change
  end
  object CheckBox1: TCheckBox
    Left = 4
    Top = 3
    Width = 30
    Height = 17
    Caption = '��'
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = '����'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = CheckBox1Click
  end
end
