object Found_Second: TFound_Second
  Left = 0
  Top = 0
  Width = 440
  Height = 277
  TabOrder = 0
  object Panel_Frame: TTntPanel
    Left = 0
    Top = 0
    Width = 440
    Height = 277
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
      Width = 440
      Height = 277
      Align = alClient
      Stretch = True
    end
    object Image_Return: TImage
      Left = 21
      Top = 238
      Width = 77
      Height = 24
      Cursor = crHandPoint
      Hint = #36820#22238#26597#25214#39029#38754
      AutoSize = True
      ParentShowHint = False
      ShowHint = True
    end
    object Label1: TLabel
      Left = 8
      Top = 16
      Width = 48
      Height = 12
      Caption = #26597#25214#32467#26524
    end
    object Image_AddFirend: TImage
      Left = 341
      Top = 238
      Width = 77
      Height = 24
      Cursor = crHandPoint
      Hint = #28155#21152#22909#21451
      AutoSize = True
      ParentShowHint = False
      ShowHint = True
    end
    object FoundListView: TListView
      Left = 8
      Top = 32
      Width = 425
      Height = 193
      Columns = <
        item
          Caption = #21602#31216
          Width = 100
        end
        item
          Caption = #24080#21495
          Width = 80
        end
        item
          Caption = #24615#21035
          Width = 40
        end
        item
          Caption = #24180#40836
          Width = 40
        end>
      Ctl3D = False
      FlatScrollBars = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
end
