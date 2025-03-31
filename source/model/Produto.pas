unit Produto;

interface

type
  TProduto = class
  private
    FID: Integer;
    FNome: string;
    FPreco: Double;
    FSaldo: Integer;
  public
    constructor Create;
    property ID: Integer read FID write FID;
    property Nome: string read FNome write FNome;
    property Preco: Double read FPreco write FPreco;
    property Saldo: Integer read FSaldo write FSaldo;

  end;

implementation

uses
  System.SysUtils;

{ TProduto }

constructor TProduto.Create();
begin
  ID := 0;
  Nome:= '';
  Preco:= 0.0;
  Saldo:= 0;
end;

end.

