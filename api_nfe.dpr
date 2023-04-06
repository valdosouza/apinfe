program api_nfe;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  System.SysUtils,
  Horse.Jhonson, // It's necessary to use the unit
  System.JSON;

begin
  // It's necessary to add the middleware in the Horse:
  THorse.Use(Jhonson());

  // You can specify the charset when adding middleware to the Horse:
  // THorse.Use(Jhonson('UTF-8'));

  THorse.Post('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LBody: TJSONObject;
    begin
      // Req.Body gives access to the content of the request in string format.
      // Using jhonson middleware, we can get the content of the request in JSON format.

      LBody := Req.Body<TJSONObject>;
      Res.Send<TJSONObject>(LBody);
    end);

  //THorse.Listen(9000);


    THorse.Listen(9000);
end.
