unit uFaturamentoServiceResource;

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  Web.HTTPApp,
  uFaturamentoController;

type
  TFaturamentoServiceResource = class(TWebModule)
  private
    FController: TFaturamentoController;
    procedure HandleRequest(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure ConfigurarRotas;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  WebModuleClass: TComponentClass = TFaturamentoServiceResource;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

constructor TFaturamentoServiceResource.Create(AOwner: TComponent);
begin
  inherited;
  FController := TFaturamentoController.Create;
  ConfigurarRotas;
end;

procedure TFaturamentoServiceResource.ConfigurarRotas;
begin
  Actions.Clear;

  // ConsultarNota - Usado pelo KorpErp para consultar uma nota específica
  with Actions.Add do
  begin
    Name := 'GetNotaAction';
    PathInfo := '/notas/*';
    MethodType := mtGet;
    OnAction := HandleRequest;
    Default := False;
  end;

  // LoadNotaItems - Usado pelo KorpErp para carregar os itens de uma nota
  with Actions.Add do
  begin
    Name := 'GetNotaItensAction';
    PathInfo := '/notas/*/itens';
    MethodType := mtGet;
    OnAction := HandleRequest;
    Default := False;
  end;

  // CriarNota - Usado pelo KorpErp para criar uma nova nota
  with Actions.Add do
  begin
    Name := 'CreateNotaAction';
    PathInfo := '/notas';
    MethodType := mtPost;
    OnAction := HandleRequest;
    Default := False;
  end;

  // ListarNotas - Usado pelo KorpErp para listar notas
  with Actions.Add do
  begin
    Name := 'GetNotasAction';
    PathInfo := '/notas';
    MethodType := mtGet;
    OnAction := HandleRequest;
    Default := False;
  end;

  // ConcluirNota - Usado pelo KorpErp para finalizar uma nota
  with Actions.Add do
  begin
    Name := 'ConcluirNotaAction';
    PathInfo := '/notas/status';
    MethodType := mtPut;
    OnAction := HandleRequest;
    Default := False;
  end;
end;

destructor TFaturamentoServiceResource.Destroy;
begin
  FController.Free;
  inherited;
end;

procedure TFaturamentoServiceResource.HandleRequest(Sender: TObject; Request: TWebRequest;
  Response: TWebResponse; var Handled: Boolean);
var
  LPathParts: TArray<string>;
  LId: Integer;
  LResult: TJSONValue;
  LRequestBody: string;
  LJsonValue: TJSONValue;
  LJsonObj: TJSONObject;
begin
  LId := 0;
  Response.ContentType := 'application/json';
  
  try
    // Extrair ID da URL quando necessário
    LPathParts := Request.PathInfo.Split(['/']);
    if Length(LPathParts) >= 3 then
      LId := StrToIntDef(LPathParts[2], 0);

    // Processar a requisição com base no path e método
    if (Request.PathInfo.Contains('/itens')) and (Request.MethodType = mtGet) then
    begin
      LResult := FController.GetNotaItens(LId);
      Response.Content := LResult.ToJSON;
      Response.StatusCode := 200;
    end
    else if (Request.PathInfo = '/notas') and (Request.MethodType = mtGet) then
    begin
      LResult := FController.GetNotas;
      Response.Content := LResult.ToJSON;
      Response.StatusCode := 200;
    end
    else if (Request.PathInfo.StartsWith('/notas/')) and (Request.MethodType = mtGet) and
            (not Request.PathInfo.Contains('/itens')) then
    begin
      LResult := FController.GetNota(LId);
      Response.Content := LResult.ToJSON;
      Response.StatusCode := 200;
    end
    else if (Request.PathInfo = '/notas') and (Request.MethodType = mtPost) then
    begin
      LJsonValue := TJSONObject.ParseJSONValue(Request.Content);
      try
        if LJsonValue is TJSONObject then
        begin
          LJsonObj := LJsonValue as TJSONObject;
          if LJsonObj.GetValue('itens') is TJSONArray then
          begin
            LResult := FController.CreateNota(LJsonObj.GetValue('itens') as TJSONArray);
            Response.Content := LResult.ToJSON;
            Response.StatusCode := 201;
          end
          else
          begin
            Response.Content := '{"error": "Campo itens ausente ou inválido na requisição"}';
            Response.StatusCode := 400;
          end;
        end
        else if LJsonValue is TJSONArray then
        begin
          LResult := FController.CreateNota(LJsonValue as TJSONArray);
          Response.Content := LResult.ToJSON;
          Response.StatusCode := 201;
        end
        else
        begin
          Response.Content := '{"error": "Invalid JSON format. Expected object with itens array or direct array"}';
          Response.StatusCode := 400;
        end;
      finally
        if Assigned(LJsonValue) and (LJsonValue <> LResult) then
          LJsonValue.Free;
      end;
    end
    else if (Request.PathInfo.Contains('/status')) and (Request.MethodType = mtPut) then
    begin
      LJsonValue := TJSONObject.ParseJSONValue(Request.Content);
      LJsonObj := LJsonValue as TJSONObject;
      LResult := FController.UpdateStatus(
        LJsonObj.GetValue<Integer>('id') ,
        LJsonObj.GetValue<string>('status')
      );
      Response.Content := LResult.ToJSON;
      Response.StatusCode := 200;
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
