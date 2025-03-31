unit GerenciarNotaFrm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
  System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.ExtCtrls;

type
  TFrmGerenciarNota = class(TForm)
    pnlHeader: TPanel;
    lblTitulo: TLabel;
    gridNotas: TStringGrid;
    btnConcluir: TButton;
    btnNova: TButton;
    procedure btnNovaClick(Sender: TObject);
    procedure btnConcluirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure CarregaNota();
  public
    { Public declarations }
  end;

var
  FrmGerenciarNota: TFrmGerenciarNota;

implementation

{$R *.dfm}

uses
  NotaFrm,
  NotaFiscalController,
  Nota, EstoqueController, Produto;

procedure TFrmGerenciarNota.btnConcluirClick(Sender: TObject);
var 
  SelectedRow: Integer;
  NotaID: Integer;
  LController: TNotaFiscalController;
  LEstoqueController: TEstoqueController;
  LNota: TNota;
  LMsg: string;
  i: Integer;
  LItem: TProduto;
  LProdutoEstoque: TProduto;
begin
  SelectedRow := gridNotas.Row;
  NotaID := StrToIntDef(gridNotas.Cells[0, SelectedRow], -1);
  if NotaID = -1 then
    Exit;

  LController := TNotaFiscalController.Create;
  LEstoqueController := TEstoqueController.Create;
  LNota := TNota.Create;
  try

    if not LController.ConsultarNota(NotaID, LMsg) then
    begin
      ShowMessage(LMsg);
      Exit;
    end;

    LNota.ID := NotaID;
    LController.LoadNotaItems(LNota);

    // Valida cada item da nota
    for i := 0 to LNota.Itens.Count - 1 do
    begin
      LItem := LNota.Itens[i];
      
      // Consulta o produto no estoque
      if not LEstoqueController.GetProduto(IntToStr(LItem.Id), LProdutoEstoque, LMsg) then
      begin
        ShowMessage(Format('Erro ao consultar produto %d - %s: %s', [LItem.Id, LItem.Nome, LMsg]));
        Exit;
      end;

      try
        // Verifica se há saldo suficiente
        if LItem.Saldo > LProdutoEstoque.Saldo then
        begin
          ShowMessage(Format('Produto %d - %s: Quantidade solicitada (%d) maior que disponível em estoque (%d)!',
            [LItem.Id, LItem.Nome, LItem.Saldo, LProdutoEstoque.Saldo]));
          Exit;
        end;
      finally
        LProdutoEstoque.Free;
      end;
    end;

    // Se todos os itens foram validados, conclui a nota
    if LController.ConcluirNota(NotaID, LMsg) then
    begin
      for i := 0 to LNota.Itens.Count - 1 do
      begin
        LItem := LNota.Itens[i];
        if not LEstoqueController.AtualizarEstoque(
          LItem.ID.ToString(),
          LItem.Saldo,
          LMsg
        ) then
          ShowMessage(Format('Erro ao atualizar estoque do produto %d: %s', [LItem.Id, LMsg]));
      end;

      ShowMessage('Nota fiscal concluída com sucesso!');
    end
    else
      ShowMessage(LMsg);

    CarregaNota();
  finally
    LNota.Free;
    LController.Free;
    LEstoqueController.Free;
  end;
end;

procedure TFrmGerenciarNota.btnNovaClick(Sender: TObject);
begin
  FrmNota := TFrmNota.Create(nil);
  try
    FrmNota.ShowModal;
  finally
    FrmNota.Free;
    CarregaNota();
  end;
end;

procedure TFrmGerenciarNota.CarregaNota;
var
  LController: TNotaFiscalController;
  NotaList: TObjectList<TNota>;
  i: Integer;
  Nota: TNota;
begin
  gridNotas.RowCount := 2;
  
  LController := TNotaFiscalController.Create;
  try
    NotaList := LController.ListarNotas;
    if NotaList <> nil then
    begin
      gridNotas.RowCount := NotaList.Count + 1;
      
      for i := 0 to NotaList.Count - 1 do
      begin
        Nota := NotaList[i];
        gridNotas.Cells[0, i + 1] := IntToStr(Nota.ID);  
        gridNotas.Cells[1, i + 1] := DateToStr(Nota.Emissao);
        gridNotas.Cells[2, i + 1] := Nota.Status;
      end;
    end;
  finally
    LController.Free;
  end;
end;

procedure TFrmGerenciarNota.FormCreate(Sender: TObject);
begin
  gridNotas.Cells[0, 0] := 'ID';
  gridNotas.Cells[1, 0] := 'Data';
  gridNotas.Cells[2, 0] := 'Status';
  CarregaNota();
end;

end.
