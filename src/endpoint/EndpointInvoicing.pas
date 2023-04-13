unit EndpointInvoicing;

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
  ControllerInvoiceMerchandise, System.Classes;

type
  TEndpointInvoicing = class
    private

    public
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
  Lc_nf : TControllerInvoiceMerchandise;
begin
  try
    Lc_nf := TControllerInvoiceMerchandise.Create(nil);
    Lc_nf.Estabelecimento := 0;
    Lc_nf.Terminal := 0;
    Lc_nf.Ordem := 0;
    if Lc_nf.ValidateInvoicing then
    Begin
      Lc_nf.invoicing;
    End
    else
    Begin

    End;
  finally
    Lc_nf.disposeOf;
  end;
end;

class procedure TEndpointInvoicing.Registrar;
begin
  THorse.Post('/invoicing',Invoicing);
end;

end.
