program FaturamentoService;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Web.WebReq,
  Web.WebBroker,
  IdHTTPWebBrokerBridge,
  uFaturamentoController in 'uFaturamentoController.pas',
  uFaturamentoServiceResource in 'uFaturamentoServiceResource.pas';

{$R *.res}

procedure RunServer(APort: Integer);
var
  LServer: TIdHTTPWebBrokerBridge;
begin
  Writeln(Format('Servidor Faturamento rodando na porta %d', [APort]));
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
    RunServer(8082);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
