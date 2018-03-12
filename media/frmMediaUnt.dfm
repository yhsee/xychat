object frmMedia: TfrmMedia
  Left = 252
  Top = 141
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'frmMedia'
  ClientHeight = 373
  ClientWidth = 332
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object AVideo_PopupMenu: TTntPopupMenu
    Left = 8
    Top = 8
    object ITEM_AllowVideo: TTntMenuItem
      Caption = #20572#27490#21457#36865#35270#39057
      GroupIndex = 1
      OnClick = ITEM_AllowVideoClick
    end
    object ITEM_Allowaudio: TTntMenuItem
      Caption = #20572#27490#21457#36865#22768#38899
      GroupIndex = 1
      OnClick = ITEM_AllowaudioClick
    end
    object ITEM_Break: TTntMenuItem
      Caption = '-'
      GroupIndex = 1
    end
    object ITEM_VideoConfig: TTntMenuItem
      Caption = #35774#22791#23646#24615
      GroupIndex = 1
      OnClick = ITEM_VideoConfigClick
    end
  end
end
