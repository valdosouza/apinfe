unit Provider.Connection;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Phys, FireDAC.Comp.Client, System.IOUtils,FireDAC.DApt,
  FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL, FireDAC.Stan.Pool,FireDAC.Stan.Async,
  FireDAC.Comp.ScriptCommands, FireDAC.Stan.Util, FireDAC.Comp.Script;

type
  TProviderConnection = class(TDataModule)
    FDManager: TFDManager;
    FDPhysMySQL: TFDPhysMySQLDriverLink;
    FDScript1: TFDScript;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ProviderConnection: TProviderConnection;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TProviderConnection.DataModuleCreate(Sender: TObject);
var
  LcConfigDB, LcConfigDriver,LcVendedorLib, LcS : String;
  LcQry: TFDQuery;
begin
 LcVendedorLib := Concat(TPath.GetDirectoryName(ParamStr(0)),
                      TPath.DirectorySeparatorChar,
                      'Config',
                      TPath.DirectorySeparatorChar,
                      'libmysql.dll');

 LcConfigDB := Concat(TPath.GetDirectoryName(ParamStr(0)),
                      TPath.DirectorySeparatorChar,
                      'Config',
                      TPath.DirectorySeparatorChar,
                      'db.ini');

 LcConfigDriver := Concat(TPath.GetDirectoryName(ParamStr(0)),
                          TPath.DirectorySeparatorChar,
                          'Config',
                          TPath.DirectorySeparatorChar,
                          'driver.ini');

  Writeln(concat('Carregando arquivo VendorLib ',LcVendedorLib));
  if not FileExists(LcVendedorLib) then
  Begin
    Writeln('Arquivo VendorLib não foi encontrado');
    Writeln('Pressione ENTER para continuar...');
    readln(LcS);
    System.Halt(0);
  End;

  Writeln(concat('Carregando configuracoes do arquivos do BD ',LcConfigDB));
  if not FileExists(LcConfigDB) then
  Begin
    Writeln('Arquivo de configuracacao do BD não foi encontrado');
    Writeln('Pressione ENTER para continuar...');
    readln(LcS);
    System.Halt(0);
  End;

  Writeln(concat('Carregando configuracoes do arquivos de driver ',LcConfigDriver));
  if not FileExists(LcConfigDriver) then
  Begin
    Writeln('Arquivo de configuracacao do Driver não foi encontrado');
    Writeln('Pressione ENTER para continuar...');
    readln(LcS);
    System.Halt(0);
  End;
  //Carrega os aquivos de configuração
  FDPhysMySQL.VendorLib := LcVendedorLib;
  FDManager.DriverDefFileName := LcConfigDriver;
  FDManager.ConnectionDefFileName := LcConfigDB;
  FDManager.Open;
  Writeln('Configuracao do BD carregado com sucesso');
  try
    try
      LcQry := TFDQuery.Create(Self);
      LcQry.ConnectionName := 'gestao_setes';
      LcQry.Open('select now()');
      Writeln(concat('Conexao com o BD testada co sucesso em ',LcQry.Fields[0].AsString));
    Except
      On E: Exception do
      Begin
        Writeln(concat('Falha na Conexao do Banco de dados. Verifique!'));
        readln(LcS);
        System.Halt(0);
      End;
    end;
  finally
    LcQry.Close;
    LcQry.DisposeOf;
  end;

end;

end.
