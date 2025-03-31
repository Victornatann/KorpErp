unit NotaFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Grids, System.Generics.Collections, Vcl.ExtCtrls,
  Vcl.ComCtrls, Data.DB, Vcl.DBGrids,
  Produto, Nota;

type
  TFrmNota = class(TForm)
    gridItens: TStringGrid;
    lblQuantidade: TLabel;
    edtQuantidade: TEdit;
    btnAdicionarItem: TButton;
    btnConcluir: TButton;
    EdtCodPro: TEdit;
    grpCabecalho: TGroupBox;
    dtpData: TDateTimePicker;
    procedure FormCreate(Sender: TObject);
    procedure btnAdicionarItemClick(Sender: TObject);
    procedure btnConcluirClick(Sender: TObject);
  private
    { Private declarations }
    FItens: TObjectList<TProduto>;
    procedure Critica();
    procedure LimpaTela();
  public
    { Public declarations }
  end;

var
  FrmNota: TFrmNota;

implementation

{$R *.dfm}

uses
  NotaFiscalController,
  EstoqueController;

procedure TFrmNota.btnAdicionarItemClick(Sender: TObject);
var
  LController: TEstoqueController;
  LProduto: TProduto;
begin
  Critica();

  LController := TEstoqueController.Create;
  try
    LProduto := TProduto.Create;
    LProduto.Id := StrToIntDef(EdtCodPro.Text, 0);
    LProduto.Saldo := StrToIntDef(edtQuantidade.Text, 0);
    FItens.Add(LProduto);

    gridItens.RowCount := FItens.Count + 1;
    gridItens.Cells[0, FItens.Count] := LProduto.Id.ToString();
    gridItens.Cells[1, FItens.Count] := FloatToStr(LProduto.Saldo);

    LimpaTela;
  finally
    LController.Free;
  end;
end;

procedure TFrmNota.btnConcluirClick(Sender: TObject);
var
  LMsg: string;
  LController: TNotaFiscalController;
begin
  if FItens.Count = 0 then
  begin
    ShowMessage('Adicione ao menos um item!');
    Exit;
  end;

  LController := TNotaFiscalController.Create;
  try
    if not LController.CriarNota(FItens, LMsg) then
    begin
      ShowMessage(LMsg);
      Exit;
    end;

    ShowMessage('Nota fiscal criada com sucesso!');
    Close;
  finally
    LController.Free;
  end;
end;

procedure TFrmNota.Critica;
begin
  if EdtCodPro.Text = '' then
    raise Exception.Create('Informe o código do produto!');

  if edtQuantidade.Text = '' then
    raise Exception.Create('Informe a quantidade!');

  try
    StrToFloat(edtQuantidade.Text);
  except
    raise Exception.Create('Quantidade inválida!');
  end;
end;

procedure TFrmNota.FormCreate(Sender: TObject);
begin
  FItens := TObjectList<TProduto>.Create(True);
  gridItens.Cells[0, 0] := 'Código';
  gridItens.Cells[1, 0] := 'Quantidade';
end;

procedure TFrmNota.LimpaTela;
begin
  EdtCodPro.Clear;
  edtQuantidade.Clear;
end;

end.
