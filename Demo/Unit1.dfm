object Form1: TForm1
  Left = 357
  Top = 239
  Caption = 'Form1'
  ClientHeight = 518
  ClientWidth = 647
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    647
    518)
  PixelsPerInch = 96
  TextHeight = 13
  object TreeView1: TTreeView
    Left = 0
    Top = 41
    Width = 321
    Height = 388
    Align = alLeft
    Indent = 19
    TabOrder = 0
    OnClick = TreeView1Click
    ExplicitLeft = 8
    ExplicitTop = 40
    ExplicitHeight = 537
  end
  object ValueListEditor1: TValueListEditor
    Left = 327
    Top = 40
    Width = 320
    Height = 117
    Align = alCustom
    Anchors = [akLeft, akTop, akRight]
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goEditing, goThumbTracking]
    TabOrder = 1
    ExplicitWidth = 336
    ColWidths = (
      150
      164)
    RowHeights = (
      18
      18)
  end
  object WebBrowser1: TWebBrowser
    Left = 327
    Top = 159
    Width = 320
    Height = 270
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    OnBeforeNavigate2 = WebBrowser1BeforeNavigate2
    ExplicitWidth = 325
    ExplicitHeight = 340
    ControlData = {
      4C00000013210000E81B00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Memo1: TMemo
    Left = 0
    Top = 429
    Width = 647
    Height = 89
    Align = alBottom
    TabOrder = 3
    ExplicitLeft = 336
    ExplicitTop = 584
    ExplicitWidth = 185
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 647
    Height = 41
    Align = alTop
    TabOrder = 4
    ExplicitLeft = 224
    ExplicitTop = 8
    ExplicitWidth = 185
    object Button1: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = #1057#1086#1079#1076#1072#1090#1100
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 568
      Top = 8
      Width = 75
      Height = 25
      Caption = #1087#1077#1088#1077#1081#1090#1080
      TabOrder = 1
      OnClick = Button2Click
    end
    object WebCheckBox: TCheckBox
      Left = 89
      Top = 17
      Width = 144
      Height = 17
      Caption = #1055#1086#1082#1072#1079#1072#1090#1100' '#1074' '#1073#1088#1072#1091#1079#1077#1088#1077
      TabOrder = 2
    end
    object Edit1: TEdit
      Left = 256
      Top = 8
      Width = 305
      Height = 21
      TabOrder = 3
      Text = 'Shkaf/Sections/Section1/Polka1'
    end
  end
end
