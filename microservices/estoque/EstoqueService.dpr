program EstoqueService;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Web.WebReq,
  Web.WebBroker,
  IdHTTPWebBrokerBridge,
  uEstoqueController in 'uEstoqueController.pas',
  uEstoqueServiceResource in 'uEstoqueServiceResource.pas';

{$R *.res}

procedure RunServer(APort: Integer);
var
  LServer: TIdHTTPWebBrokerBridge;
begin
  Writeln(Format('Servidor Estoque rodando na porta %d', [APort]));
  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    LServer.DefaultPort := APort;
    LServer.Active := True;
    LServer.StartListening;
    ReadLn;
    LServer.Active := False;
  finally
    LServer.Free;
  end;
end;

begin
  try
    if WebRequestHandler <> nil then
      WebRequestHandler.WebModuleClass := WebModuleClass;
    RunServer(8081);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
