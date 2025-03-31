unit uEstoqueServiceResource;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  Web.HTTPApp,
  uEstoqueController;

type
  TEstoqueServiceResource = class(TWebModule)
  private
    FController: TEstoqueController;
    procedure HandleRequest(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure ConfigurarRotas;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  WebModuleClass: TComponentClass = TEstoqueServiceResource;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

constructor TEstoqueServiceResource.Create(AOwner: TComponent);
begin
  inherited;
  FController := TEstoqueController.Create;
  ConfigurarRotas;
end;

procedure TEstoqueServiceResource.ConfigurarRotas;
begin
  Actions.Clear;

  // GetProduto - Usado pelo KorpErp para consultar produtos
  with Actions.Add do
  begin
    Name := 'GetProdutoAction';
    PathInfo := '/produtos/*';
    MethodType := mtGet;
    OnAction := HandleRequest;
    Default := False;
  end;

  // CreateProduct - Usado pelo KorpErp para criar novos produtos
  with Actions.Add do
  begin
    Name := 'CreateProdutoAction';
    PathInfo := '/produtos';
    MethodType := mtPost;
    OnAction := HandleRequest;
    Default := False;
  end;

  // AtualizarEstoque - Usado pelo KorpErp para atualizar o estoque após concluir nota
  with Actions.Add do
  begin
    Name := 'AtualizarEstoqueAction';
    PathInfo := '/produtos/*/atualizar-estoque';
    MethodType := mtPut;
    OnAction := HandleRequest;
    Default := False;
  end;
end;

destructor TEstoqueServiceResource.Destroy;
begin
  FController.Free;
  inherited;
end;

procedure TEstoqueServiceResource.HandleRequest(Sender: TObject; Request: TWebRequest;
  Response: TWebResponse; var Handled: Boolean);
var
  LResult: TJSONObject;
  LBody: TJSONObject;
  LId: Integer;
  LPathParts: TArray<string>;
begin
  LId := 0;
  Response.ContentType := 'application/json';
  
  try
    // Extrair ID da URL quando necessário
    LPathParts := Request.PathInfo.Split(['/']);
    if Length(LPathParts) >= 3 then
      LId := StrToIntDef(LPathParts[2], 0);

    // Processar a requisição com base no path e método
    if (Request.PathInfo.StartsWith('/produtos/')) and (Request.MethodType = mtGet) and
       (not Request.PathInfo.Contains('/atualizar-estoque')) then
    begin
      LResult := FController.GetProduto(LId);
      Response.Content := LResult.ToJSON;
      Response.StatusCode := 200;
    end
    else if (Request.PathInfo = '/produtos') and (Request.MethodType = mtPost) then
    begin
      LBody := TJSONObject.ParseJSONValue(Request.Content) as TJSONObject;
      try
        LResult := FController.CreateProduto(LBody);
        Response.Content := LResult.ToJSON;
        Response.StatusCode := 201;
      finally
        LBody.Free;
      end;
    end
    else if (Request.PathInfo.Contains('/atualizar-estoque')) and (Request.MethodType = mtPut) then
    begin
      LBody := TJSONObject.ParseJSONValue(Request.Content) as TJSONObject;
      try
        LResult := FController.AtualizarEstoque(LId, LBody.GetValue<Double>('quantidade'));
        Response.Content := LResult.ToJSON;
        Response.StatusCode := 200;
      finally
        LBody.Free;
      end;
    end;

    Handled := True;
  except
    on E: Exception do
    begin
      Response.StatusCode := 500;
      Response.Content := Format('{"error": "%s"}', [E.Message]);
      Handled := True;
    end;
  end;
end;

end.
