unit uEstoqueController;

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Def,
  FireDAC.Stan.Async, FireDAC.Phys.FB, FireDAC.DApt,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.FBDef,
  FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Stan.Intf,
  FireDAC.Comp.DataSet, FireDAC.Stan.Param;

type
  TEstoqueController = class
  private
    FConnection: TFDConnection;
  public
    constructor Create;
    destructor Destroy; override;
    function GetProduto(const AId: Integer): TJSONObject;
    function GetProdutos: TJSONArray;
    function CreateProduto(const AProduto: TJSONObject): TJSONObject;
    function UpdateProduto(const AProduto: TJSONObject): TJSONObject;
    function ValidarEstoque(const AId: Integer; const AQuantidade: Double): TJSONObject;
    function AtualizarEstoque(const AProdutoId: Integer; const AQuantidade: Double): TJSONObject;
  end;

implementation

constructor TEstoqueController.Create;
begin
  inherited Create;
  FConnection := TFDConnection.Create(nil);
  FConnection.Params.DriverID := 'FB';
  FConnection.Params.Database := 'localhost:C:\KorpTeste\database\KORP.FDB';
  FConnection.Params.UserName := 'SYSDBA';
  FConnection.Params.Password := 'masterkey';
  FConnection.Connected := True;
end;

destructor TEstoqueController.Destroy;
begin
  FConnection.Free;
  inherited;
end;

function TEstoqueController.GetProduto(const AId: Integer): TJSONObject;
var
  LQuery: TFDQuery;
begin
  Result := TJSONObject.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT * FROM PRODUTOS WHERE ID = :ID';
    LQuery.ParamByName('ID').AsInteger := AId;
    LQuery.Open;

    if not LQuery.IsEmpty then
    begin
      Result.AddPair('id', TJSONNumber.Create(LQuery.FieldByName('ID').AsInteger));
      Result.AddPair('descricao', LQuery.FieldByName('DESCRICAO').AsString);
      Result.AddPair('preco', TJSONNumber.Create(LQuery.FieldByName('PRECO').AsFloat));
      Result.AddPair('saldo', TJSONNumber.Create(LQuery.FieldByName('SALDO').AsFloat));
    end;
  finally
    LQuery.Free;
  end;
end;

function TEstoqueController.GetProdutos: TJSONArray;
var
  LQuery: TFDQuery;
  LItem: TJSONObject;
begin
  Result := TJSONArray.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT * FROM PRODUTOS';
    LQuery.Open;

    while not LQuery.Eof do
    begin
      LItem := TJSONObject.Create;
      LItem.AddPair('id', TJSONNumber.Create(LQuery.FieldByName('ID').AsInteger));
      LItem.AddPair('descricao', LQuery.FieldByName('DESCRICAO').AsString);
      LItem.AddPair('preco', TJSONNumber.Create(LQuery.FieldByName('PRECO').AsFloat));
      LItem.AddPair('saldo', TJSONNumber.Create(LQuery.FieldByName('SALDO').AsFloat));
      Result.AddElement(LItem);
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

function TEstoqueController.CreateProduto(const AProduto: TJSONObject): TJSONObject;
var
  LQuery: TFDQuery;
begin
  Result := TJSONObject.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'INSERT INTO PRODUTOS (DESCRICAO, PRECO, SALDO) ' +
      'VALUES (:DESCRICAO, :PRECO, :SALDO)';
    
    LQuery.ParamByName('DESCRICAO').AsString := AProduto.GetValue<string>('descricao');
    LQuery.ParamByName('PRECO').AsFloat := AProduto.GetValue<Double>('preco');
    LQuery.ParamByName('SALDO').AsInteger := AProduto.GetValue<Integer>('saldo');
    
    LQuery.ExecSQL;
    
    Result.AddPair('message', 'Produto criado com sucesso');
    Result.AddPair('id', TJSONNumber.Create(FConnection.GetLastAutoGenValue('GEN_PRODUTOS_ID')));
  finally
    LQuery.Free;
  end;
end;

function TEstoqueController.UpdateProduto(const AProduto: TJSONObject): TJSONObject;
var
  LQuery: TFDQuery;
begin
  Result := TJSONObject.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'UPDATE PRODUTOS SET ' +
      'DESCRICAO = :DESCRICAO, ' +
      'PRECO = :PRECO, ' +
      'SALDO = :SALDO ' +
      'WHERE ID = :ID';
    
    LQuery.ParamByName('ID').AsInteger := AProduto.GetValue<Integer>('id');
    LQuery.ParamByName('DESCRICAO').AsString := AProduto.GetValue<string>('descricao');
    LQuery.ParamByName('PRECO').AsFloat := AProduto.GetValue<Double>('preco');
    LQuery.ParamByName('SALDO').AsFloat := AProduto.GetValue<Double>('saldo');
    
    LQuery.ExecSQL;
    
    if LQuery.RowsAffected > 0 then
      Result.AddPair('message', 'Produto atualizado com sucesso')
    else
      Result.AddPair('message', 'Produto não encontrado');
  finally
    LQuery.Free;
  end;
end;

function TEstoqueController.ValidarEstoque(const AId: Integer; const AQuantidade: Double): TJSONObject;
var
  LQuery: TFDQuery;
  LSaldo: Double;
begin
  Result := TJSONObject.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT SALDO FROM PRODUTOS WHERE ID = :ID';
    LQuery.ParamByName('ID').AsInteger := AId;
    LQuery.Open;

    if LQuery.IsEmpty then
    begin
      Result.AddPair('error', 'Produto não encontrado');
      Result.AddPair('success', TJSONBool.Create(False));
    end
    else
    begin
      LSaldo := LQuery.FieldByName('SALDO').AsFloat;
      Result.AddPair('success', TJSONBool.Create(LSaldo >= AQuantidade));
      Result.AddPair('saldo', TJSONNumber.Create(LSaldo));
      Result.AddPair('quantidade', TJSONNumber.Create(AQuantidade));
    end;
  finally
    LQuery.Free;
  end;
end;

function TEstoqueController.AtualizarEstoque(const AProdutoId: Integer; const AQuantidade: Double): TJSONObject;
var
  LQuery: TFDQuery;
begin
  Result := TJSONObject.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'UPDATE PRODUTOS ' +
      'SET SALDO = SALDO - :QUANTIDADE ' +
      'WHERE ID = :ID AND SALDO >= :QUANTIDADE';
    
    LQuery.ParamByName('ID').AsInteger := AProdutoId;
    LQuery.ParamByName('QUANTIDADE').AsFloat := AQuantidade;
    
    LQuery.ExecSQL;
    
    if LQuery.RowsAffected > 0 then
      Result.AddPair('message', 'Estoque atualizado com sucesso')
    else
      Result.AddPair('message', 'Não foi possível atualizar o estoque');
  finally
    LQuery.Free;
  end;
end;

end.
