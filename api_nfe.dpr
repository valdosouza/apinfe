program api_nfe;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  System.SysUtils,
  Horse.Jhonson,
  Horse.JWT,
  System.JSON,
  REST.Json,
  Provider.Connection in 'Providers\Provider.Connection.pas' {ProviderConnection: TDataModule},
  ControllerUser,
  tblUser,
  ArqIni,
  System.IOUtils,
  EndpointInvoicing in 'src\endpoint\EndpointInvoicing.pas';

var
  DBConnection : TProviderConnection;

  function getSecret:String;
  var
    LcEnv : String;
  begin
   LcEnv := Concat(TPath.GetDirectoryName(ParamStr(0)),
                   TPath.DirectorySeparatorChar,
                   'Config',
                   TPath.DirectorySeparatorChar,
                   '.env');
    Result := TArqIni.LeIni(LcEnv,'DEF','SECRET');
  end;

  function Init:boolean;
  Begin
    DBConnection := TProviderConnection.Create(nil);

  End;


begin
  Init;

  THorse.Use(HorseJWT(getSecret));

  THorse.Use(Jhonson());

  TEndpointInvoicing.Registrar;

  THorse.Listen(9000);
end.
