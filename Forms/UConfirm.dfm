object Confirm: TConfirm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Confirm'
  ClientHeight = 135
  ClientWidth = 490
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    490
    135)
  PixelsPerInch = 96
  TextHeight = 13
  object Message1: TLabel
    Left = 8
    Top = 8
    Width = 92
    Height = 19
    Caption = '<Message1>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Message2: TLabel
    Left = 325
    Top = 48
    Width = 110
    Height = 23
    Alignment = taRightJustify
    Anchors = [akRight, akBottom]
    BiDiMode = bdLeftToRight
    Caption = '<Message2>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBiDiMode = False
    ParentFont = False
  end
  object Yes: TButton
    Left = 278
    Top = 83
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '<Yes>'
    TabOrder = 0
    OnClick = YesClick
  end
  object No: TButton
    Left = 360
    Top = 83
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '<No>'
    TabOrder = 1
    OnClick = NoClick
  end
end
