unit CadProFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  EstoqueController;

type
  TFrmCadPro = class(TForm)
    lblNome: TLabel;
    edtNome: TEdit;
    lblPreco: TLabel;
    edtPreco: TEdit;
    lblSaldo: TLabel;
    edtSaldo: TEdit;
    btnSalvar: TButton;
    procedure btnSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCadPro: TFrmCadPro;

implementation

{$R *.dfm}

procedure TFrmCadPro.btnSalvarClick(Sender: TObject);
var
  LController: TEstoqueController;
  LMsg: String;
begin
  LController := TEstoqueController.Create;
  try
    if LController.CreateProduct(
      edtNome.Text,
      StrToFloatDef(edtPreco.Text, 0.0),
      StrToIntDef(edtSaldo.Text, 0),
      LMsg
    ) then
      ShowMessage('Produto cadastrado com sucesso!')
    else
      ShowMessage('Erro ao cadastrar produto.');
  finally
    LController.Free;
  end;
  
  Close;
end;

end.
