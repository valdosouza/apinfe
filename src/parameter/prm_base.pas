unit prm_base;

interface

uses System.SysUtils;

Type
  TPrmBase = class
  private
    FEstabelecimento: Integer;
    FUltimaAtualizacao: String;
    FResultado: Boolean;
    FLimite: String;
    FUsuario: Integer;
    FDataFinal: String;
    FDataInicial: String;
    FPagina: Integer;
    FTerminal: Integer;
    procedure setFDataFinal(const Value: String);
    procedure setFDataInicial(const Value: String);
    procedure setFEstabelecimento(const Value: Integer);
    procedure setFLimite(const Value: String);
    procedure setFPagina(const Value: Integer);
    procedure setFResultado(const Value: Boolean);
    procedure setFUltimaAtualizacao(const Value: String);
    procedure setFUsuario(const Value: Integer);
    procedure setFTerminal(const Value: Integer);

  public
    constructor Create;Virtual;
    destructor Destroy;override;

    property Estabelecimento : Integer read FEstabelecimento write setFEstabelecimento;
    property Terminal: Integer read FTerminal write setFTerminal;
    property Usuario: Integer read FUsuario write setFUsuario;
    property Pagina : Integer read FPagina write setFPagina;
    property DataInicial : String read FDataInicial write setFDataInicial;
    property DataFinal : String read FDataFinal write setFDataFinal;
    property Limite : String read FLimite write setFLimite;
    property UltimaAtualizacao:String read FUltimaAtualizacao write setFUltimaAtualizacao;
    property Resultado : Boolean read FResultado write setFResultado;
  end;
implementation

{ TPrmBase }

constructor TPrmBase.Create;
begin
  FDataFinal := DateToStr(Date);
  FDataInicial := DateToStr(Date);
end;

destructor TPrmBase.Destroy;
begin

end;

procedure TPrmBase.setFDataFinal(const Value: String);
begin
  FDataFinal := Value;
end;

procedure TPrmBase.setFDataInicial(const Value: String);
begin
  FDataInicial := Value;
end;

procedure TPrmBase.setFEstabelecimento(const Value: Integer);
begin
  FEstabelecimento := Value;
end;

procedure TPrmBase.setFLimite(const Value: String);
begin
  FLimite := Value;
end;

procedure TPrmBase.setFPagina(const Value: Integer);
begin
  FPagina := Value;
end;

procedure TPrmBase.setFResultado(const Value: Boolean);
begin
  FResultado := Value;
end;

procedure TPrmBase.setFTerminal(const Value: Integer);
begin
  FTerminal := Value;
end;

procedure TPrmBase.setFUltimaAtualizacao(const Value: String);
begin
  FUltimaAtualizacao := Value;
end;

procedure TPrmBase.setFUsuario(const Value: Integer);
begin
  FUsuario := Value;
end;

end.
