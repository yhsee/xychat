object frmMain: TfrmMain
  Left = 202
  Top = 143
  Width = 463
  Height = 282
  Caption = 'frmMain'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 80
    Top = 8
    Width = 369
    Height = 233
  end
  object Button1: TButton
    Left = 8
    Top = 16
    Width = 65
    Height = 25
    Caption = 'TestVideo'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 8
    Top = 56
    Width = 65
    Height = 25
    Caption = 'TestAudio'
    TabOrder = 1
  end
end
