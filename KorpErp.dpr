program KorpErp;

uses
  Vcl.Forms,
  NotaFiscalController in 'source\controllers\NotaFiscalController.pas',
  EstoqueController in 'source\controllers\EstoqueController.pas',
  Nota in 'source\model\Nota.pas',
  Produto in 'source\model\Produto.pas',
  CadProFrm in 'source\view\CadProFrm.pas' {FrmCadPro},
  GerenciarNotaFrm in 'source\view\GerenciarNotaFrm.pas' {FrmGerenciarNota},
  Main in 'source\view\Main.pas' {MainForm},
  NotaFrm in 'source\view\NotaFrm.pas' {FrmNota};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
