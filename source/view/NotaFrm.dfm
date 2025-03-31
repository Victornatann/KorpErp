object FrmNota: TFrmNota
  Left = 0
  Top = 0
  Caption = 'Nota Fiscal'
  ClientHeight = 393
  ClientWidth = 514
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grpCabecalho: TGroupBox
    Left = 10
    Top = 8
    Width = 480
    Height = 57
    Caption = 'Cabe'#231'alho da Nota Fiscal'
    Enabled = False
    TabOrder = 0
    object lblNumero: TLabel
      Left = 20
      Top = 20
      Width = 41
      Height = 13
      Caption = 'N'#250'mero:'
    end
    object lblData: TLabel
      Left = 200
      Top = 20
      Width = 27
      Height = 13
      Caption = 'Data:'
    end
    object edtNumero: TEdit
      Left = 80
      Top = 16
      Width = 100
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
    object dtpData: TDateTimePicker
      Left = 240
      Top = 16
      Width = 120
      Height = 21
      Date = 45745.372407453700000000
      Time = 45745.372407453700000000
      TabOrder = 1
    end
  end
  object grpItens: TGroupBox
    Left = 8
    Top = 85
    Width = 480
    Height = 260
    Caption = 'Itens da Nota Fiscal'
    TabOrder = 1
    object lblProduto: TLabel
      Left = 20
      Top = 25
      Width = 42
      Height = 13
      Caption = 'Produto:'
    end
    object lblQuantidade: TLabel
      Left = 130
      Top = 25
      Width = 22
      Height = 13
      Caption = 'Qtd:'
    end
    object edtQuantidade: TEdit
      Left = 160
      Top = 22
      Width = 50
      Height = 21
      NumbersOnly = True
      TabOrder = 1
    end
    object btnAdicionarItem: TButton
      Left = 216
      Top = 20
      Width = 80
      Height = 25
      Caption = 'Adicionar'
      TabOrder = 2
      OnClick = btnAdicionarItemClick
    end
    object gridItens: TStringGrid
      Left = 20
      Top = 51
      Width = 440
      Height = 189
      ColCount = 2
      DefaultColWidth = 100
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goRowSelect]
      TabOrder = 3
      ColWidths = (
        100
        100)
      RowHeights = (
        24)
    end
    object EdtCodPro: TEdit
      Left = 68
      Top = 22
      Width = 50
      Height = 21
      NumbersOnly = True
      TabOrder = 0
    end
  end
  object btnConcluir: TButton
    Left = 410
    Top = 351
    Width = 80
    Height = 25
    Caption = 'Concluir'
    TabOrder = 2
    OnClick = btnConcluirClick
  end
end
