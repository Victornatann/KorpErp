unit Nota;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Generics.Collections,
  Produto;

type
  TNota = class
  private
    FID: Integer;
    FEmissao: TDateTime;
    FStatus: string;
    FItens: TObjectList<TProduto>;
  public
    constructor Create; overload;
    constructor Create(Id: Integer; Emissao: TDateTime; Status: String); overload;
    destructor Destroy; override;
    function ToJson: TJSONObject;
    class function JsonArrayToNotaList(JsonArray: TJSONArray): TObjectList<TNota>;
    class function FromJson(Json: TJSONObject): TNota;
    property ID: Integer read FID write FID;
    property Emissao: TDateTime read FEmissao write FEmissao;
    property Status: string read FStatus write FStatus;
    property Itens: TObjectList<TProduto> read FItens write FItens;
  end;

implementation

{ TNota }

constructor TNota.Create;
begin
  FID := 0;
  FEmissao := Now;
  FStatus := '';
  FItens := TObjectList<TProduto>.Create(True);
end;

constructor TNota.Create(Id: Integer; Emissao: TDateTime; Status: String);
begin
  Create;
  FID := Id;
  FEmissao := Emissao;
  FStatus := Status;
end;

destructor TNota.Destroy;
begin
  FItens.Free;
  inherited;
end;

class function TNota.FromJson(Json: TJSONObject): TNota;
var
  ItensArray: TJSONArray;
  ItemJson: TJSONObject;
  Item: TProduto;
  i: Integer;
begin
  Result := TNota.Create;
  Result.FID := Json.GetValue<Integer>('ID');
  Result.FEmissao := StrToDateTime(Json.GetValue<string>('Emissao'));
  Result.FStatus := Json.GetValue<string>('Status');
  
  if Json.TryGetValue<TJSONArray>('Itens', ItensArray) then
  begin
    for i := 0 to ItensArray.Count - 1 do
    begin
      ItemJson := ItensArray.Items[i] as TJSONObject;
      Item := TProduto.Create;
      Item.Id := ItemJson.GetValue<Integer>('codigo');
      Item.Nome := ItemJson.GetValue<string>('descricao');
      Item.Saldo := ItemJson.GetValue<Integer>('quantidade');
      Item.Preco := ItemJson.GetValue<Double>('valor');
      Result.FItens.Add(Item);
    end;
  end;
end;

class function TNota.JsonArrayToNotaList(
  JsonArray: TJSONArray
): TObjectList<TNota>;
var
  i: Integer;
  NotaJson: TJSONObject;
  Nota: TNota;
begin
  Result := TObjectList<TNota>.Create;
  try
    for i := 0 to JsonArray.Count - 1 do
    begin
      NotaJson := JsonArray.Items[i] as TJSONObject;
      Nota := TNota.FromJson(NotaJson);
      Result.Add(Nota);
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TNota.ToJson: TJSONObject;
var
  ItensArray: TJSONArray;
  i: Integer;
begin
  Result := TJSONObject.Create;
  Result.AddPair('ID', TJSONNumber.Create(FID));
  Result.AddPair('Emissao', TJSONString.Create(DateTimeToStr(FEmissao)));
  Result.AddPair('Status', FStatus);
  
  ItensArray := TJSONArray.Create;
  for i := 0 to FItens.Count - 1 do
  begin
    ItensArray.Add(
      TJSONObject.Create
        .AddPair('codigo', TJSONNumber.Create(FItens[i].Id))
        .AddPair('descricao', FItens[i].Nome)
        .AddPair('quantidade', TJSONNumber.Create(FItens[i].Saldo))
        .AddPair('valor', TJSONNumber.Create(FItens[i].Preco))
    );
  end;
  Result.AddPair('Itens', ItensArray);
end;

end.
