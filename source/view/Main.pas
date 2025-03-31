unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  CadProFrm,
  GerenciarNotaFrm;

procedure TMainForm.Button1Click(Sender: TObject);
begin

  FrmCadPro := TFrmCadPro.Create(nil);
  try
    FrmCadPro.ShowModal;
  finally
    FrmCadPro.Free;
  end;

end;

procedure TMainForm.Button2Click(Sender: TObject);
begin

  FrmGerenciarNota := TFrmGerenciarNota.Create(nil);
  try
    FrmGerenciarNota.ShowModal;
  finally
    FrmGerenciarNota.Free;
  end;

end;

end.
