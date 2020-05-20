object frmClient: TfrmClient
  Left = 306
  Top = 153
  Width = 543
  Height = 259
  Caption = 'frmClient'
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 208
    Width = 42
    Height = 13
    Caption = 'Label1'
    Transparent = True
  end
  object Label2: TLabel
    Left = 248
    Top = 208
    Width = 42
    Height = 13
    Caption = 'Label2'
  end
  object Label3: TLabel
    Left = 376
    Top = 207
    Width = 42
    Height = 13
    Caption = 'Label2'
  end
  object Button2: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
    OnClick = Button2Click
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 40
    Width = 513
    Height = 16
    TabOrder = 1
  end
  object Memo1: TMemo
    Left = 8
    Top = 88
    Width = 513
    Height = 113
    Lines.Strings = (
      'Memo1')
    TabOrder = 2
  end
  object Button4: TButton
    Left = 368
    Top = 8
    Width = 75
    Height = 25
    Caption = 'SendFile'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Edit1: TEdit
    Left = 88
    Top = 8
    Width = 89
    Height = 21
    TabOrder = 4
    Text = '192.168.192.128'
  end
  object Edit2: TEdit
    Left = 184
    Top = 8
    Width = 41
    Height = 21
    TabOrder = 5
    Text = '4455'
  end
  object ProgressBar2: TProgressBar
    Left = 7
    Top = 64
    Width = 514
    Height = 16
    TabOrder = 6
  end
  object Button1: TButton
    Left = 312
    Top = 8
    Width = 49
    Height = 25
    Caption = 'Pull'
    TabOrder = 7
    OnClick = Button1Click
  end
  object Button3: TButton
    Left = 448
    Top = 8
    Width = 75
    Height = 25
    Caption = 'SendSimple'
    TabOrder = 8
    OnClick = Button3Click
  end
  object Button5: TButton
    Left = 232
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Disconnect'
    TabOrder = 9
    OnClick = Button5Click
  end
end
