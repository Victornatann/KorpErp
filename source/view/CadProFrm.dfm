object FrmCadPro: TFrmCadPro
  Left = 0
  Top = 0
  Caption = 'Cadastro de Produto'
  ClientHeight = 170
  ClientWidth = 318
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
  object lblNome: TLabel
    Left = 20
    Top = 20
    Width = 31
    Height = 13
    Caption = 'Nome:'
  end
  object lblPreco: TLabel
    Left = 20
    Top = 52
    Width = 31
    Height = 13
    Caption = 'Pre'#231'o:'
  end
  object lblSaldo: TLabel
    Left = 20
    Top = 84
    Width = 30
    Height = 13
    Caption = 'Saldo:'
  end
  object edtNome: TEdit
    Left = 100
    Top = 18
    Width = 200
    Height = 21
    TabOrder = 0
  end
  object edtPreco: TEdit
    Left = 100
    Top = 50
    Width = 100
    Height = 21
    NumbersOnly = True
    TabOrder = 1
  end
  object edtSaldo: TEdit
    Left = 100
    Top = 82
    Width = 100
    Height = 21
    NumbersOnly = True
    TabOrder = 2
  end
  object btnSalvar: TButton
    Left = 20
    Top = 134
    Width = 100
    Height = 25
    Caption = 'Salvar'
    TabOrder = 3
    OnClick = btnSalvarClick
  end
end
