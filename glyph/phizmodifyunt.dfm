object frmphizmodify: Tfrmphizmodify
  Left = 350
  Top = 260
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #28155#21152#34920#24773
  ClientHeight = 203
  ClientWidth = 410
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 12
  object TntLabel3: TTntLabel
    Left = 128
    Top = 120
    Width = 90
    Height = 12
    Caption = #34920#24773#21517#31216':('#21487#36873')'
  end
  object TntLabel2: TTntLabel
    Left = 128
    Top = 72
    Width = 90
    Height = 12
    Caption = #24555#25463#26041#24335':('#21487#36873')'
  end
  object TntLabel1: TTntLabel
    Left = 128
    Top = 8
    Width = 54
    Height = 12
    Caption = #25351#23450#22270#29255':'
  end
  object imgPreview: TTntImage
    Left = 8
    Top = 32
    Width = 105
    Height = 105
    Center = True
  end
  object Bevel1: TBevel
    Left = 8
    Top = 32
    Width = 105
    Height = 105
  end
  object TntButton2: TTntButton
    Left = 136
    Top = 170
    Width = 75
    Height = 25
    Caption = #30830#23450
    TabOrder = 0
    OnClick = TntButton2Click
  end
  object TntButton3: TTntButton
    Left = 216
    Top = 170
    Width = 75
    Height = 25
    Caption = #21462#28040
    TabOrder = 1
    OnClick = TntButton3Click
  end
  object TntButton1: TTntButton
    Left = 328
    Top = 30
    Width = 73
    Height = 25
    Caption = #27983#35272
    TabOrder = 2
    OnClick = TntButton1Click
  end
  object ED_picfilename: TTntEdit
    Left = 128
    Top = 32
    Width = 193
    Height = 20
    ReadOnly = True
    TabOrder = 3
    Text = 'ED_picfilename'
  end
  object ED_FaceQuick: TTntEdit
    Left = 128
    Top = 88
    Width = 273
    Height = 20
    TabOrder = 4
    Text = 'ED_FaceQuick'
  end
  object ED_FaceName: TTntEdit
    Left = 128
    Top = 136
    Width = 273
    Height = 20
    TabOrder = 5
    Text = 'ED_FaceName'
  end
end
