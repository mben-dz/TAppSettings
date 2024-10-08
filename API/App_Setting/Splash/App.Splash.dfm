object App_Splash: TApp_Splash
  Left = 0
  Top = 0
  AlphaBlend = True
  AlphaBlendValue = 250
  BorderStyle = bsNone
  ClientHeight = 141
  ClientWidth = 465
  Color = clHighlight
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -29
  Font.Name = 'Tahoma'
  Font.Style = []
  Font.Quality = fqClearTypeNatural
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 35
  object Lbl_Log: TLabel
    Left = 8
    Top = 29
    Width = 449
    Height = 68
    AutoSize = False
    Caption = 'Loading configurations...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlightText
    Font.Height = -20
    Font.Name = 'Bahnschrift SemiLight SemiConde'
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    ParentFont = False
    WordWrap = True
  end
  object Lbl_Progress: TLabel
    Left = 8
    Top = 93
    Width = 5
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindow
    Font.Height = -17
    Font.Name = 'Tahoma'
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    ParentFont = False
  end
  object Pnl_Top: TPanel
    Left = 0
    Top = 0
    Width = 465
    Height = 2
    Align = alTop
    BevelOuter = bvNone
    Color = clCream
    ParentBackground = False
    TabOrder = 0
  end
  object Pnl_Bottom: TPanel
    Left = 0
    Top = 139
    Width = 465
    Height = 2
    Align = alBottom
    BevelOuter = bvNone
    Color = clCream
    ParentBackground = False
    TabOrder = 1
  end
  object Pnl_Right: TPanel
    Left = 463
    Top = 2
    Width = 2
    Height = 137
    Align = alRight
    BevelOuter = bvNone
    Color = clCream
    ParentBackground = False
    TabOrder = 2
  end
  object Pnl_Left: TPanel
    Left = 0
    Top = 2
    Width = 2
    Height = 137
    Align = alLeft
    BevelOuter = bvNone
    Color = clCream
    ParentBackground = False
    TabOrder = 3
  end
  object ProgressBar_Extract: TProgressBar
    Left = 8
    Top = 120
    Width = 200
    Height = 5
    TabOrder = 4
    Visible = False
  end
  object Timer_Ready: TTimer
    Interval = 1500
    OnTimer = Timer_ReadyTimer
    Left = 376
    Top = 16
  end
end
