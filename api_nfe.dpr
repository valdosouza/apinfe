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
  EndpointInvoicingSale in 'src\endpoint\EndpointInvoicingSale.pas',
  prm_to_invoice in 'src\parameter\prm_to_invoice.pas',
  prm_to_invoice_sale in 'src\parameter\prm_to_invoice_sale.pas',
  ControllerInvoiceSale in 'src\controller\ControllerInvoiceSale.pas',
  Controllerinvoicemerchandise in 'src\controller\Controllerinvoicemerchandise.pas',
  ControllerOrderSale in 'src\controller\ControllerOrderSale.pas',
  ControllerOrder in 'src\controller\ControllerOrder.pas',
  Controllerinvoice in 'src\controller\Controllerinvoice.pas',
  ControllerOrderItem in 'src\controller\ControllerOrderItem.pas',
  ControllerOrderShipping in 'src\controller\ControllerOrderShipping.pas',
  ControllerOrderTotalizer in 'src\controller\ControllerOrderTotalizer.pas',
  ControllerTaxRuler in 'src\controller\ControllerTaxRuler.pas',
  ControllerMerchandise in 'src\controller\ControllerMerchandise.pas',
  ControllerInvoiceShipping in 'src\controller\ControllerInvoiceShipping.pas',
  ControllerInvoiceReturn55 in 'src\controller\ControllerInvoiceReturn55.pas',
  EndpointAuthorizationSale in 'src\endpoint\EndpointAuthorizationSale.pas',
  ControllerNfe in 'src\controller\ControllerNfe.pas',
  ControllerNfeConfig in 'src\controller\ControllerNfeConfig.pas',
  ControllerNfe55 in 'src\controller\ControllerNfe55.pas',
  ControllerNfe55Sale in 'src\controller\ControllerNfe55Sale.pas',
  ControllerStateMvaNcm in 'src\controller\ControllerStateMvaNcm.pas',
  tblStateFcpNcm in 'src\model\tblStateFcpNcm.pas',
  ControllerStateFcpNcm in 'src\controller\ControllerStateFcpNcm.pas',
  tblOrderItemIcmsFcp in 'src\model\tblOrderItemIcmsFcp.pas',
  ControllerOrderItemIcmsFcp in 'src\controller\ControllerOrderItemIcmsFcp.pas',
  tblOrderItemIpiBack in 'src\model\tblOrderItemIpiBack.pas',
  ControllerOrderItemIpiBack in 'src\controller\ControllerOrderItemIpiBack.pas',
  ControllerNfeSeries in 'src\controller\ControllerNfeSeries.pas',
  tblNfeSequences in 'src\model\tblNfeSequences.pas',
  ControllerNfeSequences in 'src\controller\ControllerNfeSequences.pas';

var
  DBConnection : TProviderConnection;
  function Init:boolean;
  Begin
    DBConnection := TProviderConnection.Create(nil);
  End;


begin
  Init;
  THorse.Use(HorseJWT(TArqIni.getSecret));
  THorse.Use(Jhonson());
  TEndpointInvoicingSale.Registrar;
  TEndpointAuthorizationSale.Registrar;

  THorse.Listen(9000);
end.
