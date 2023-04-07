program api_nfe;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  System.SysUtils,
  Horse.Jhonson,
  System.JSON,
  REST.Json,
  Provider.Connection in 'Providers\Provider.Connection.pas' {ProviderConnection: TDataModule},
  ControllerUser,tblUser;

var
  DBConnection : TProviderConnection;


  function Init:boolean;
  Begin
    DBConnection := TProviderConnection.Create(nil);

  End;


begin
  Init;
  // It's necessary to add the middleware in the Horse:
  THorse.Use(Jhonson());

  // You can specify the charset when adding middleware to the Horse:
  // THorse.Use(Jhonson('UTF-8'));

  THorse.Post('/invoicing',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LBody: TJSONObject;
      LcUser : TControllerUser;
    begin
      // Req.Body gives access to the content of the request in string format.
      // Using jhonson middleware, we can get the content of the request in JSON format.
      try
        //LBody := Req.Body;
        writeln( Req.Body );
        LcUser := TControllerUser.create(nil);
        LcUser.HasInstitution.Registro.Estabelecimento := 1;
        LcUser.Registro.Codigo := 1;
        LcUser.getbyKey;
      finally
        Res.Send( TJson.ObjectToJsonString(LcUser.Registro));
        LcUser.disposeOf;
      end;
    end);

    THorse.Listen(9000);
end.
