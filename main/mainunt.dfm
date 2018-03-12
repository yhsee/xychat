object MainForm: TMainForm
  Left = 600
  Top = 105
  BorderIcons = []
  BorderStyle = bsNone
  Caption = #22869#20449' 2012'
  ClientHeight = 542
  ClientWidth = 265
  Color = clActiveBorder
  Font.Charset = GB2312_CHARSET
  Font.Color = clBlack
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Scaled = False
  OnCanResize = FormCanResize
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = TntFormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object UserListPopup: TTntPopupMenu
    OnPopup = UserListPopupPopup
    Left = 72
    Top = 39
    object ITEM_OnDownHint: TTntMenuItem
      Caption = #26174#31034#19978#19979#32447#25552#31034
      OnClick = ITEM_OnDownHintClick
    end
    object ITEM_OnlyOnline: TTntMenuItem
      Caption = #20165#26174#31034#22312#32447#22909#21451
      Visible = False
      OnClick = ITEM_OnlyOnlineClick
    end
    object ITEM_Break05: TTntMenuItem
      Caption = '-'
    end
    object ITEM_AddGroup: TTntMenuItem
      Caption = #28155#21152#20998#32452'(&A)'
      ShortCut = 16449
      OnClick = ITEM_AddGroupClick
    end
    object ITEM_DelGroup: TTntMenuItem
      Caption = #21024#38500#20998#32452'(&G)'
      ShortCut = 8238
      OnClick = ITEM_DelGroupClick
    end
    object ITEM_ReNameGroup: TTntMenuItem
      Caption = #37325#21629#21517#20998#32452'(&R)'
      OnClick = ITEM_ReNameGroupClick
    end
    object ITEM_FindUser: TTntMenuItem
      Caption = #28155#21152#32852#31995#20154'(&U)'
      ShortCut = 114
      OnClick = ITEM_SearchUserClick
    end
    object ITEM_Break06: TTntMenuItem
      Caption = '-'
    end
    object ITEM_SendMsg: TTntMenuItem
      Caption = #21457#36865#21363#26102#28040#24687'(&S)'
      OnClick = ITEM_SendMsgClick
    end
    object ITEM_AVideo: TTntMenuItem
      Caption = #35821#38899#35270#39057'(&V)'
      OnClick = ITEM_AVideoClick
    end
    object ITEM_Break07: TTntMenuItem
      Caption = '-'
    end
    object ITEM_SendMutilfile: TTntMenuItem
      Caption = #21457#36865#25991#20214'(&F)'
      ShortCut = 116
      OnClick = ITEM_SendMutilfileClick
    end
    object ITEM_Break08: TTntMenuItem
      Caption = '-'
    end
    object ITEM_RequestRemote: TTntMenuItem
      Caption = #35831#27714#36828#31243#21327#21161'(&T)'
      ShortCut = 117
      OnClick = ITEM_RequestRemoteClick
    end
    object ITEM_Break09: TTntMenuItem
      Caption = '-'
    end
    object ITEM_MoveUser: TTntMenuItem
      Caption = #31227#21160#32852#31995#20154#33267
    end
    object ITEM_MoveBlackList: TTntMenuItem
      Caption = #31227#33267#40657#21517#21333
      OnClick = ITEM_MoveBlackListClick
    end
    object ITEM_DelUser: TTntMenuItem
      Caption = #21024#38500#35813#32852#31995#20154'(&D)'
      ShortCut = 46
      OnClick = ITEM_DelUserClick
    end
    object ITEM_MoveNewly: TTntMenuItem
      Caption = #20174#26368#36817#32852#31995#20154#21015#34920#20013#31227#38500'(&D)'
      OnClick = ITEM_MoveNewlyClick
    end
    object ITEM_Break10: TTntMenuItem
      Caption = '-'
    end
    object ITEM_ShowHide: TTntMenuItem
      Caption = #38544#36523#26102#23545#20854#21487#35265
      OnClick = ITEM_ShowHideClick
    end
    object ITEM_ReNameUser: TTntMenuItem
      Caption = #20462#25913#26174#31034#21517#31216
      OnClick = ITEM_ReNameUserClick
    end
    object ITEM_HistoryMsg: TTntMenuItem
      Caption = #20132#35848#21382#21490#35760#24405#26597#30475'(&M)...'
      OnClick = ITEM_HistoryMsgClick
    end
    object ITEM_UserInfo: TTntMenuItem
      Caption = #26597#30475#36164#26009'(&C)'
      OnClick = ITEM_UserInfoClick
    end
  end
  object FlashStatusTime: TTimer
    Interval = 500
    OnTimer = FlashStatusTimeTimer
    Left = 40
    Top = 39
  end
  object StatusPopup: TTntPopupMenu
    Alignment = paRight
    Images = udpcore.main_small_list
    TrackButton = tbLeftButton
    OnPopup = StatusPopupPopup
    Left = 72
    Top = 8
    object ITEM_Online: TTntMenuItem
      Caption = #19978#32447
      Checked = True
      SubMenuImages = udpcore.main_small_list
      GroupIndex = 1
      ImageIndex = 0
      OnClick = ITEM_OnlineClick
    end
    object ITEM_Outline: TTntMenuItem
      Caption = #31163#24320
      SubMenuImages = udpcore.main_small_list
      GroupIndex = 1
      ImageIndex = 1
    end
    object ITEM_Hideline: TTntMenuItem
      Caption = #38544#36523
      SubMenuImages = udpcore.main_small_list
      GroupIndex = 1
      ImageIndex = 2
      OnClick = ITEM_OnlineClick
    end
    object ITEM_Break04: TTntMenuItem
      Caption = '-'
      GroupIndex = 1
    end
    object ITEM_Downline: TTntMenuItem
      Caption = #19979#32447
      SubMenuImages = udpcore.main_small_list
      GroupIndex = 1
      ImageIndex = 3
      OnClick = ITEM_OnlineClick
    end
    object ITEM_Break11: TTntMenuItem
      Caption = '-'
      GroupIndex = 1
    end
    object ITEM_ShortCustom: TTntMenuItem
      Caption = #33258#23450#20041#31163#32447#22238#22797#20449#24687'...'
      GroupIndex = 1
      OnClick = ITEM_ShortCustomClick
    end
  end
  object MainTrayIcon: TCoolTrayIcon
    mini = False
    IconList = udpcore.systray
    CycleInterval = 500
    Icon.Data = {
      0000010001001010040000000000280100001600000028000000100000002000
      0000010004000000000080000000000000000000000000000000000000000000
      000000008000008000000080800080000000800080008080000080808000C0C0
      C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
      000000000000000000F888000000000008FFFFF880000088888FFFFF80000888
      8888FFFF88000086666788FF8880086F66FF666788F008FFFFFF66666800086F
      87F877F7FF60007777FF7777FF70007FFFFFF77777700007F7FF88FFF7800008
      77778F8F700000007FFFFF78000000000F77780000000000000000000000FFFF
      0000FC3F0000F8070000C007000080030000C001000080010000800300008001
      0000C0010000C0010000E0010000E0070000F00F0000F83F0000FFFF0000}
    IconIndex = 0
    MinimizeToTray = True
    OnClick = MainTrayIconClick
    OnDblClick = MainTrayIconDblClick
    Left = 6
    Top = 8
  end
  object MainPopup: TTntPopupMenu
    Left = 40
    Top = 8
    object ITEM_MySpace: TTntMenuItem
      Caption = #25105#30340#23433#20840#23384#20648#31354#38388'(&F)'
      ShortCut = 113
    end
    object ITEM_Break01: TTntMenuItem
      Caption = '-'
    end
    object ITEM_Firend: TTntMenuItem
      Caption = #32852#31995#20154
      object ITEM_SearchUser: TTntMenuItem
        Caption = #21047#26032#32852#31995#20154'(&F)'
        ShortCut = 16454
        OnClick = ITEM_SearchUserClick
      end
      object ITEM_MsgManage: TTntMenuItem
        Caption = #28040#24687#31649#29702'(&M)'
        ShortCut = 16461
        OnClick = ITEM_MsgManageClick
      end
    end
    object ITEM_Config: TTntMenuItem
      Caption = #31995#32479#35774#23450'(&S)...'
      ShortCut = 16467
      OnClick = ITEM_ConfigClick
    end
    object ITEM_Break02: TTntMenuItem
      Caption = '-'
    end
    object ITEM_About: TTntMenuItem
      Caption = #20851#20110'(&A)'
      OnClick = ITEM_AboutClick
    end
    object ITEM_Help: TTntMenuItem
      Caption = #24110#21161'(&H)'
      ShortCut = 112
      OnClick = ITEM_HelpClick
    end
    object ITEM_Break03: TTntMenuItem
      Caption = '-'
    end
    object ITEM_Exit: TTntMenuItem
      Caption = #36864#20986'(&X)'
      OnClick = ITEM_ExitClick
    end
  end
end
