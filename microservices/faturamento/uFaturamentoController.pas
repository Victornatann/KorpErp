unit uFaturamentoController;

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Def,
  FireDAC.Stan.Async, FireDAC.Phys.FB, FireDAC.DApt,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.FBDef,
  FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Stan.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Stan.Param;

type
  TFaturamentoController = class
  private
    FConnection: TFDConnection;
  public
    constructor Create;
    destructor Destroy; override;
    function GetNota(const AId: Integer): TJSONObject;
    function GetNotas: TJSONArray;
    function GetNotaItens(const AId: Integer): TJSONArray;
    function CreateNota(const AItens: TJSONArray): TJSONObject;
    function UpdateStatus(const AId: Integer; const AStatus: string): TJSONObject;
  end;

implementation

constructor TFaturamentoController.Create;
begin
  inherited Create;
  FConnection := TFDConnection.Create(nil);
  FConnection.Params.DriverID := 'FB';
  FConnection.Params.Database := 'localhost:C:\KorpTeste\database\KORP.FDB';
  FConnection.Params.UserName := 'SYSDBA';
  FConnection.Params.Password := 'masterkey';
  FConnection.Connected := True;
end;

destructor TFaturamentoController.Destroy;
begin
  FConnection.Free;
  inherited;
end;

function TFaturamentoController.GetNota(const AId: Integer): TJSONObject;
var
  LQuery: TFDQuery;
  LItensQuery: TFDQuery;
  LItensArray: TJSONArray;
  LItem: TJSONObject;
begin
  Result := TJSONObject.Create;
  LQuery := TFDQuery.Create(nil);
  LItensQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT * FROM NOTAS WHERE ID = :ID';
    LQuery.ParamByName('ID').AsInteger := AId;
    LQuery.Open;

    if not LQuery.IsEmpty then
    begin
      Result.AddPair('id', TJSONNumber.Create(LQuery.FieldByName('ID').AsInteger));
      Result.AddPair('data', LQuery.FieldByName('DATA').AsString);
      Result.AddPair('status', LQuery.FieldByName('STATUS').AsString);
      Result.AddPair('valorTotal', TJSONNumber.Create(LQuery.FieldByName('VALOR_TOTAL').AsFloat));

      LItensQuery.Connection := FConnection;
      LItensQuery.SQL.Text :=
        'SELECT ' +
        '  NI.PRODUTO_ID, ' +
        '  P.DESCRICAO, ' +
        '  NI.QUANTIDADE, ' +
        '  NI.VALOR_UNITARIO, ' +
        '  NI.VALOR_TOTAL '+
        'FROM NOTA_ITENS NI ' +
        'INNER JOIN PRODUTOS P ON P.ID = NI.PRODUTO_ID ' +
        'WHERE NI.NOTA_ID = :ID';
      LItensQuery.ParamByName('ID').AsInteger := AId;
      LItensQuery.Open;

      LItensArray := TJSONArray.Create;
      while not LItensQuery.Eof do
      begin
        LItem := TJSONObject.Create;
        LItem.AddPair('id', TJSONNumber.Create(AId));
        LItem.AddPair('produtoId', TJSONNumber.Create(LItensQuery.FieldByName('PRODUTO_ID').AsInteger));
        LItem.AddPair('descricao', LItensQuery.FieldByName('DESCRICAO').AsString);
        LItem.AddPair('quantidade', TJSONNumber.Create(LItensQuery.FieldByName('QUANTIDADE').AsFloat));
        LItem.AddPair('valorUnitario', TJSONNumber.Create(LItensQuery.FieldByName('VALOR_UNITARIO').AsFloat));
        LItem.AddPair('valorTotal', TJSONNumber.Create(LItensQuery.FieldByName('VALOR_TOTAL').AsFloat));
        LItensArray.AddElement(LItem);
        LItensQuery.Next;
      end;
      Result.AddPair('itens', LItensArray);
    end;
  finally
    LQuery.Free;
    LItensQuery.Free;
  end;
end;

function TFaturamentoController.GetNotas: TJSONArray;
var
  LQuery: TFDQuery;
  LItem: TJSONObject;
begin
  Result := TJSONArray.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT * FROM NOTAS ORDER BY ID DESC';
    LQuery.Open;

    while not LQuery.Eof do
    begin
      LItem := TJSONObject.Create;
      LItem.AddPair('id', TJSONNumber.Create(LQuery.FieldByName('ID').AsInteger));
      LItem.AddPair('data', LQuery.FieldByName('DATA').AsString);
      LItem.AddPair('status', LQuery.FieldByName('STATUS').AsString);
      LItem.AddPair('valorTotal', TJSONNumber.Create(LQuery.FieldByName('VALOR_TOTAL').AsFloat));
      Result.AddElement(LItem);
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

function TFaturamentoController.GetNotaItens(const AId: Integer): TJSONArray;
var
  LQuery: TFDQuery;
  LItem: TJSONObject;
begin
  Result := TJSONArray.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 
      'SELECT ' +
      '  NI.PRODUTO_ID as codigo, ' +
      '  P.DESCRICAO as descricao, ' +
      '  NI.QUANTIDADE as quantidade, ' +
      '  NI.VALOR_UNITARIO as valor ' +
      'FROM NOTA_ITENS NI ' +
      'INNER JOIN PRODUTOS P ON P.ID = NI.PRODUTO_ID ' +
      'WHERE NI.NOTA_ID = :ID';
    
    LQuery.ParamByName('ID').AsInteger := AId;
    LQuery.Open;

    while not LQuery.Eof do
    begin
      LItem := TJSONObject.Create;
      LItem.AddPair('codigo', TJSONNumber.Create(LQuery.FieldByName('codigo').AsInteger));
      LItem.AddPair('descricao', LQuery.FieldByName('descricao').AsString);
      LItem.AddPair('quantidade', TJSONNumber.Create(LQuery.FieldByName('quantidade').AsInteger));
      LItem.AddPair('valor', TJSONNumber.Create(LQuery.FieldByName('valor').AsFloat));
      Result.AddElement(LItem);
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

function TFaturamentoController.CreateNota(const AItens: TJSONArray): TJSONObject;
var
  LQuery: TFDQuery;
  LNotaId: Integer;
  I: Integer;
  LItem: TJSONObject;
  LValorTotal: Double;
  LTransaction: TFDTransaction;
begin
  Result := TJSONObject.Create;
  LQuery := TFDQuery.Create(nil);
  LTransaction := TFDTransaction.Create(nil);
  try
    // Configurar transação
    LTransaction.Connection := FConnection;
    LQuery.Connection := FConnection;
    LQuery.Transaction := LTransaction;
    
    // Iniciar transação
    LTransaction.StartTransaction;
    try
      // Calcula o valor total
      LValorTotal := 0;
      for I := 0 to AItens.Count - 1 do
      begin
        LItem := AItens.Items[I] as TJSONObject;
        LValorTotal := LValorTotal + (
          LItem.GetValue<Double>('quantidade') *
          LItem.GetValue<Double>('valor')
        );
      end;

      // Insere a nota fiscal
      LQuery.SQL.Text :=
        'INSERT INTO NOTAS (DATA, STATUS, VALOR_TOTAL) ' +
        'VALUES (:DATA, :STATUS, :VALOR_TOTAL)';
      
      LQuery.ParamByName('DATA').AsDateTime := Now;
      LQuery.ParamByName('STATUS').AsString := 'P';
      LQuery.ParamByName('VALOR_TOTAL').AsFloat := LValorTotal;
      LQuery.ExecSQL;
      
      LNotaId := FConnection.GetLastAutoGenValue('GEN_NOTAS_ID');

      // Insere os itens
      for I := 0 to AItens.Count - 1 do
      begin
        LItem := AItens.Items[I] as TJSONObject;

        LQuery.SQL.Text :=
          'INSERT INTO NOTA_ITENS ' +
          '(NOTA_ID, PRODUTO_ID, QUANTIDADE, VALOR_UNITARIO, VALOR_TOTAL) ' +
          'VALUES ' +
          '(:NOTA_ID, :PRODUTO_ID, :QUANTIDADE, :VALOR_UNITARIO, :VALOR_TOTAL)';

        LQuery.ParamByName('NOTA_ID').AsInteger := LNotaId;
        LQuery.ParamByName('PRODUTO_ID').AsInteger := LItem.GetValue<Integer>('codigo');
        LQuery.ParamByName('QUANTIDADE').AsFloat := LItem.GetValue<Double>('quantidade');
        LQuery.ParamByName('VALOR_UNITARIO').AsFloat := LItem.GetValue<Double>('valor');
        LQuery.ParamByName('VALOR_TOTAL').AsFloat :=
          LItem.GetValue<Double>('quantidade') * LItem.GetValue<Double>('valor');
        
        LQuery.ExecSQL;
      end;

      LTransaction.Commit;

      Result.AddPair('message', 'Nota fiscal criada com sucesso');
      Result.AddPair('id', TJSONNumber.Create(LNotaId));
    except
      on E: Exception do
      begin
        LTransaction.Rollback;
        raise Exception.Create('Erro ao criar nota fiscal: ' + E.Message);
      end;
    end;
  finally
    LQuery.Free;
    LTransaction.Free;
  end;
end;

function TFaturamentoController.UpdateStatus(const AId: Integer; const AStatus: string): TJSONObject;
var
  LQuery: TFDQuery;
begin
  Result := TJSONObject.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text :=
      'UPDATE NOTAS SET STATUS = :STATUS WHERE ID = :ID';
    
    LQuery.ParamByName('ID').AsInteger := AId;
    LQuery.ParamByName('STATUS').AsString := AStatus;
    
    LQuery.ExecSQL;
    
    if LQuery.RowsAffected > 0 then
      Result.AddPair('message', 'Status da nota fiscal atualizado com sucesso')
    else
      Result.AddPair('message', 'Nota fiscal não encontrada');
  finally
    LQuery.Free;
  end;
end;

end.
