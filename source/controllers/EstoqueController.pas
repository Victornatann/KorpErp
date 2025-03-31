unit EstoqueController;

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  System.Net.HttpClient, System.Net.URLClient,
  System.Net.HttpClientComponent,
  Produto;

type
  TEstoqueController = class
  private
    FHTTP: TNetHTTPClient;
    const
      BASE_URL = 'http://localhost:8081';
  public
    constructor Create;
    destructor Destroy; override;
    function GetProduto(const ACodigo: string; out AProduto: TProduto; out AMsg: string): Boolean;
    function CreateProduct(const ADescription: string;
      const APrice: Double;
      const AStock: Integer;
      out AMsg: string
    ): Boolean;
    function AtualizarEstoque(const ACodigo: string; const AQuantidade: Double; out AMsg: string): Boolean;
  end;

implementation

constructor TEstoqueController.Create;
begin
  FHTTP := TNetHTTPClient.Create(nil);
  FHTTP.ContentType := 'application/json';
end;

destructor TEstoqueController.Destroy;
begin
  FHTTP.Free;
  inherited;
end;

function TEstoqueController.CreateProduct(
  const ADescription: string;
  const APrice: Double;
  const AStock: Integer;
  out AMsg: string
): Boolean;
var
  LResponse: IHTTPResponse;
  LJsonObj: TJSONObject;
  LBody: TJSONObject;
begin
  Result := False;
  try
    LBody := TJSONObject.Create;
    try
      LBody.AddPair('descricao', ADescription);
      LBody.AddPair('preco', TJSONNumber.Create(APrice));
      LBody.AddPair('saldo', TJSONNumber.Create(AStock));
      
      LResponse := FHTTP.Post(
        Format('%s/produtos', [BASE_URL]),
        TStringStream.Create(LBody.ToJSON)
      );
      
      if LResponse.StatusCode = 201 then
      begin
        LJsonObj := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
        try
          Result := True;
          AMsg := LJsonObj.GetValue<string>('message');
        finally
          LJsonObj.Free;
        end;
      end
      else
      begin
        AMsg := Format('Erro ao criar produto. Status: %d', [LResponse.StatusCode]);
      end;
    finally
      LBody.Free;
    end;
  except
    on E: Exception do
      AMsg := 'Erro ao criar produto: ' + E.Message;
  end;
end;

function TEstoqueController.GetProduto(const ACodigo: string; out AProduto: TProduto; out AMsg: string): Boolean;
var
  LResponse: IHTTPResponse;
  LJsonObj: TJSONObject;
  LUrl: string;
begin
  Result := False;
  AProduto := nil;
  
  try
    LUrl := Format('%s/produtos/%s', [BASE_URL, ACodigo]);
    LResponse := FHTTP.Get(LUrl);
    
    if LResponse.StatusCode = 200 then
    begin
      LJsonObj := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
      try
        AProduto := TProduto.Create;
        AProduto.ID := LJsonObj.GetValue<Integer>('id');
        AProduto.Nome := LJsonObj.GetValue<string>('descricao');
        AProduto.Preco := LJsonObj.GetValue<Double>('preco');
        AProduto.Saldo := Trunc(LJsonObj.GetValue<Double>('saldo'));
        Result := True;
      finally
        LJsonObj.Free;
      end;
    end
    else
    begin
      AMsg := Format('Erro ao consultar produto. Status: %d', [LResponse.StatusCode]);
    end;
  except
    on E: Exception do
    begin
      AMsg := 'Erro ao consultar produto: ' + E.Message;
      if Assigned(AProduto) then
        FreeAndNil(AProduto);
    end;
  end;
end;

function TEstoqueController.AtualizarEstoque(const ACodigo: string; const AQuantidade: Double; out AMsg: string): Boolean;
var
  LResponse: IHTTPResponse;
  LJsonObj, LBody: TJSONObject;
begin
  Result := False;
  try
    LBody := TJSONObject.Create;
    try
      LBody.AddPair('quantidade', TJSONNumber.Create(AQuantidade));
      
      LResponse := FHTTP.Put(
        Format('%s/produtos/%s/atualizar-estoque', [BASE_URL, ACodigo]),
        TStringStream.Create(LBody.ToJSON)
      );
      
      if LResponse.StatusCode = 200 then
      begin
        LJsonObj := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
        try
          Result := True;
          AMsg := LJsonObj.GetValue<string>('message');
        finally
          LJsonObj.Free;
        end;
      end
      else
      begin
        AMsg := Format('Erro ao atualizar estoque. Status: %d', [LResponse.StatusCode]);
      end;
    finally
      LBody.Free;
    end;
  except
    on E: Exception do
      AMsg := 'Erro ao atualizar estoque: ' + E.Message;
  end;
end;

end.
