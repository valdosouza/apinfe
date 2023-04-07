unit EndpointInvoicing;

interface

uses
  Horse,
  System.SysUtils,
  Horse.Jhonson,
  Horse.JWT,
  System.JSON,
  REST.Json,
  System.IOUtils;

type
  TEndpointInvoicing = class
    class procedure Registrar;
    class procedure Get(Req: THorseRequest; Res : THorseResponse; Next: TProc);
    class procedure Invoicing(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;
implementation

{ TEndpointInvoicing }

class procedure TEndpointInvoicing.Get(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
begin

end;

class procedure TEndpointInvoicing.Invoicing(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
var
  LBody: TJSONObject;
begin
  try
    //do something
  finally
    Res.Send( 'Order Faturado com sucesso');
  end;
end;

class procedure TEndpointInvoicing.Registrar;
begin
  THorse.Post('/invoicing',Invoicing);
end;

end.
