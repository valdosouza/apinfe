unit EndpointInvoicingSale;

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
  ControllerInvoiceSale, System.Classes;

type
  TEndpointInvoicingSale = class
    private

    public
      class procedure Registrar;
      class procedure Get(Req: THorseRequest; Res : THorseResponse; Next: TProc);
      class procedure Invoicing(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;
implementation

{ TEndpointInvoicingSale }

class procedure TEndpointInvoicingSale.Get(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
begin

end;

class procedure TEndpointInvoicingSale.Invoicing(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
var
  Lc_sale : TControllerInvoiceSale;
  LcParams : TPrmToInvoiceSale;
begin
  try
    LcParams := TJson.JsonToObject<TPrmToInvoiceSale>(Req.Body);
    Lc_sale := TControllerInvoiceSale.Create(nil);
    Lc_sale.Estabelecimento := LcParams.Estabelecimento;
    Lc_sale.Terminal := LcParams.Terminal;
    Lc_sale.Ordem := LcParams.Ordem;
    Lc_sale.Direcao := 'S';
    Lc_sale.DistribuirITemsIcms := false;
    Lc_sale.DistribuirITemsIcmsST := False;
    Lc_sale.DistribuirITemsIPI := False;
    Lc_sale.ModeloNota := LcParams.ModeloNFe;
    Lc_sale.Observacao := LcParams.Observacao;
    Lc_sale.Vendedor := LcParams.Vendedor;
    if Lc_sale.ValidateInvoicing then
    Begin
      Lc_sale.invoicing;
      Res.Send('Ordem Faturada com Sucesso').Status(200);
    End
    else
    Begin
      Res.Send(  Lc_sale.MensagemRetorno.ToString);
    End;
  finally
    Lc_sale.disposeOf;
  end;
end;

class procedure TEndpointInvoicingSale.Registrar;
begin
  THorse.Post('/invoicing',Invoicing);
end;

end.
