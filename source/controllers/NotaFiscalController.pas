unit NotaFiscalController;

interface

uses
  System.SysUtils,
  System.JSON,
  System.Classes,
  System.Generics.Collections,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.DateUtils,
  Nota,
  Produto;

type
  TNotaFiscalController = class
  private
    FHTTP: TNetHTTPClient;
    const
      BASE_URL = 'http://localhost:8082';
      ESTOQUE_URL = 'http://localhost:8081';
  public
    constructor Create;
    destructor Destroy; override;
    function ConsultarNota(const ANotaID: Integer; out AMsg: string): Boolean;
    function ConcluirNota(const ANotaID: Integer; out AMsg: string): Boolean;
    function ListarNotas: TObjectList<TNota>;
    procedure LoadNotaItems(ANota: TNota);
    function CriarNota(const AItens: TObjectList<TProduto>; out AMsg: string): Boolean;
    function ValidarProduto(const AProdutoId: string; var AQuantidadeDisponivel: Double; var AMsg: string): Boolean;

  end;

implementation

constructor TNotaFiscalController.Create;
begin
  inherited;
  FHTTP := TNetHTTPClient.Create(nil);
  FHTTP.ContentType := 'application/json';
end;

destructor TNotaFiscalController.Destroy;
begin
  FHTTP.Free;
  inherited;
end;

function TNotaFiscalController.ConsultarNota(const ANotaID: Integer; out AMsg: string): Boolean;
var
  LResponse: IHTTPResponse;
  LJsonObj: TJSONObject;
  LUrl: String;
begin
  Result := False;
  try
    LUrl := Format('%s/notas/%d', [BASE_URL, ANotaID]);
    LResponse := FHTTP.Get(LUrl);
    Result := LResponse.StatusCode = 200;
    if not Result then
      AMsg := 'Erro ao consultar nota fiscal'
    else
    begin
      LJsonObj := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
      if LJsonObj <> nil then
      try
        // Verifica se a nota existe e está com status válido
        if LJsonObj.GetValue<string>('status') = 'F' then
        begin
          AMsg := 'Nota fiscal já está finalizada';
          Result := False;
        end
        else
          Result := True;
      finally
        LJsonObj.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      AMsg := 'Erro ao consultar nota fiscal: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TNotaFiscalController.ConcluirNota(const ANotaID: Integer; out AMsg: string): Boolean;
var
  LResponse: IHTTPResponse;
  LJSON: TJSONObject;
  LRequestStream: TStringStream;
  LRota: String;
begin
  Result := False;
  LJSON := TJSONObject.Create;
  LRequestStream := TStringStream.Create('', TEncoding.UTF8);
  try
    LJSON.AddPair('id', TJSONNumber.Create(ANotaID));
    LJSON.AddPair('status', 'F');
    LRequestStream.WriteString(LJSON.ToJSON);
    LRequestStream.Position := 0;
    LRota := Format('%s/notas/status', [BASE_URL]);
    try
      LResponse := FHTTP.Put(LRota, LRequestStream);
      Result := LResponse.StatusCode = 200;
      if not Result then
        AMsg := 'Erro ao concluir nota fiscal';
    except
      on E: Exception do
      begin
        AMsg := 'Erro ao concluir nota fiscal: ' + E.Message;
        Result := False;
      end;
    end;
  finally
    LJSON.Free;
    LRequestStream.Free;
  end;
end;

function TNotaFiscalController.ListarNotas: TObjectList<TNota>;
var
  LResponse: IHTTPResponse;
  LJsonArray: TJSONArray;
  LJsonObj: TJSONObject;
  LNota: TNota;
  I: Integer;
begin
  Result := TObjectList<TNota>.Create(True);
  try
    LResponse := FHTTP.Get(BASE_URL + '/notas');
    if LResponse.StatusCode = 200 then
    begin
      LJsonArray := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONArray;
      if LJsonArray <> nil then
      try
        for I := 0 to LJsonArray.Count - 1 do
        begin
          LJsonObj := LJsonArray.Items[I] as TJSONObject;
          LNota := TNota.Create;
          LNota.Id := LJsonObj.GetValue<Integer>('id');
          LNota.Emissao := StrToDate(LJsonObj.GetValue<string>('data'));
          LNota.Status := LJsonObj.GetValue<string>('status');
          
          Result.Add(LNota);
        end;
      finally
        LJsonArray.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      Result := nil;
    end;
  end;
end;

procedure TNotaFiscalController.LoadNotaItems(ANota: TNota);
var
  LResponse: IHTTPResponse;
  LJsonArray: TJSONArray;
  LJsonObj: TJSONObject;
  LProduto: TProduto;
  I: Integer;
begin
  try
    LResponse := FHTTP.Get(Format('%s/notas/%d/itens', [BASE_URL, ANota.ID]));
    if LResponse.StatusCode = 200 then
    begin
      LJsonArray := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONArray;
      if LJsonArray <> nil then
      try
        for I := 0 to LJsonArray.Count - 1 do
        begin
          LJsonObj := LJsonArray.Items[I] as TJSONObject;
          if LJsonObj <> nil then
          begin
            LProduto := TProduto.Create;
            try
              LProduto.Id := LJsonObj.GetValue<Integer>('codigo');
              LProduto.Nome := LJsonObj.GetValue<string>('descricao');
              LProduto.Saldo := LJsonObj.GetValue<Integer>('quantidade');
              LProduto.Preco := LJsonObj.GetValue<Double>('valor');
              ANota.Itens.Add(LProduto);
            except
              LProduto.Free;
              raise;
            end;
          end;
        end;
      finally
        LJsonArray.Free;
      end;
    end;
  except
    on E: Exception do
      raise Exception.Create('Erro ao carregar itens da nota: ' + E.Message);
  end;
end;

function TNotaFiscalController.CriarNota(const AItens: TObjectList<TProduto>; out AMsg: string): Boolean;
var
  LResponse: IHTTPResponse;
  LJSON: TJSONObject;
  LItensArray: TJSONArray;
  LRequestStream: TStringStream;
  I: Integer;
begin
  Result := False;
  LJSON := TJSONObject.Create;
  LItensArray := TJSONArray.Create;
  LRequestStream := TStringStream.Create('', TEncoding.UTF8);
  try
    for I := 0 to AItens.Count - 1 do
    begin
      LItensArray.Add(
        TJSONObject.Create
          .AddPair('codigo', TJSONNumber.Create(AItens[I].Id))
          .AddPair('descricao', AItens[I].Nome)
          .AddPair('quantidade', TJSONNumber.Create(AItens[I].Saldo))
          .AddPair('valor', TJSONNumber.Create(AItens[I].Preco))
      );
    end;
    
    LJSON.AddPair('itens', LItensArray);
    LRequestStream.WriteString(LJSON.ToJSON);
    LRequestStream.Position := 0;
    
    try
      LResponse := FHTTP.Post(BASE_URL + '/notas', LRequestStream);
      Result := LResponse.StatusCode = 201;
      if not Result then
        AMsg := 'Erro ao criar nota fiscal';
    except
      on E: Exception do
      begin
        AMsg := 'Erro ao criar nota fiscal: ' + E.Message;
        Result := False;
      end;
    end;
  finally
    LJSON.Free;
    LRequestStream.Free;
  end;
end;

function TNotaFiscalController.ValidarProduto(const AProdutoId: string; var AQuantidadeDisponivel: Double; var AMsg: string): Boolean;
var
  LResponse: IHTTPResponse;
  LJsonObj: TJSONObject;
  LUrl: string;
begin
  Result := False;
  try
    LUrl := Format('%s/produtos/%s/validar-estoque?quantidade=%f', [ESTOQUE_URL, AProdutoId, AQuantidadeDisponivel]);
    LResponse := FHTTP.Get(LUrl);
    
    if LResponse.StatusCode = 200 then
    begin
      LJsonObj := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
      try
        Result := LJsonObj.GetValue<Boolean>('success');
        AQuantidadeDisponivel := LJsonObj.GetValue<Double>('saldo');
        
        if not Result then
          AMsg := Format('Saldo insuficiente. Disponível: %.2f', [AQuantidadeDisponivel]);
      finally
        LJsonObj.Free;
      end;
    end
    else
    begin
      AMsg := Format('Erro ao validar produto. Status: %d', [LResponse.StatusCode]);
    end;
  except
    on E: Exception do
    begin
      AMsg := 'Erro ao validar produto: ' + E.Message;
    end;
  end;
end;

end.
