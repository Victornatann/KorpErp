object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Main Form'
  ClientHeight = 64
  ClientWidth = 374
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 368
    Height = 25
    Align = alTop
    Caption = 'Cadastrar Produto'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    AlignWithMargins = True
    Left = 3
    Top = 34
    Width = 368
    Height = 25
    Align = alTop
    Caption = 'Gerenciar Nota'
    TabOrder = 1
    OnClick = Button2Click
  end
end
