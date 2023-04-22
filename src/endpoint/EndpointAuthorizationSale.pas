unit EndpointAuthorizationSale;

interface

uses
  Horse,
  System.SysUtils,
  Horse.Jhonson,
  Horse.JWT,
  System.JSON,
  REST.Json,
  System.IOUtils,
  ACBrNFe,
  prm_to_invoice_sale,
  ControllerNfe55Sale, System.Classes;

type
  TEndpointAuthorizationSale = class
    private

    public
      class procedure Registrar;
      class procedure Get(Req: THorseRequest; Res : THorseResponse; Next: TProc);
      class procedure Authorization(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;
implementation

{ TEndpointInvoicingSale }

class procedure TEndpointAuthorizationSale.Get(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
begin

end;

class procedure TEndpointAuthorizationSale.Authorization(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
var
  Lc_Ctrl : TControllerNfe55Sale;
begin
  try
    Lc_Ctrl := TControllerNfe55Sale.Create(nil);
    Lc_Ctrl.Parametros := TJson.JsonToObject<TPrmToInvoiceSale>(Req.Body);
    Lc_Ctrl.inicializa;
    if Lc_Ctrl.ValidateAuthorization then
    Begin
      Lc_Ctrl.getAuthorization;
      Res.Send('Nota Autorizada com Sucesso').Status(200);
    End
    else
    Begin
      Res.Send(  Lc_Ctrl.MensagemRetorno.ToString);
    End;
  finally
    Lc_Ctrl.disposeOf;
  end;
end;

class procedure TEndpointAuthorizationSale.Registrar;
begin
  THorse.Post('/authorization',Authorization);
end;

end.
