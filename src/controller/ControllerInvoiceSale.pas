unit ControllerInvoiceSale;

interface
uses System.Classes, System.SysUtils,
      tblEntity, FireDAC.Comp.Client, Md5, FireDAC.Stan.Param,
      ControllerOrderSale, ControllerCustomer,
      BaseController, ControllerMerchandise,ControllerInvoiceMerchandise;

Type
  TControllerInvoiceSale = Class(TControllerInvoiceMerchandise)
  private
    FModeloNota: String;
    FObservacao: String;
    FMensagemRetorno: String;
    FVendedor: Integer;
    procedure setVariable;
    procedure setFModeloNota(const Value: String);
    procedure setFObservacao(const Value: String);
    procedure setMensagemRetorno(const Value: String);
    procedure setFVendedor(const Value: Integer);

  protected
    function saveInvoice:boolean;Override;
    function getTaxationComplement:boolean;Override;
  public
    OrderSale : TControllerOrderSale;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function ValidateInvoicing:Boolean;Override;
    procedure invoicing;Override;


    property ModeloNota : String read FModeloNota write setFModeloNota;
    property Observacao : String Read FObservacao write setFObservacao;

    property Vendedor : Integer read FVendedor write setFVendedor;
  End;

implementation

{ TControllerInvoiceSale }


constructor TControllerInvoiceSale.Create(AOwner: TComponent);
begin
  inherited;
  OrderSale := TControllerOrderSale.create(self);
end;

destructor TControllerInvoiceSale.Destroy;
begin
  OrderSale.DisposeOf;
  inherited;
end;


function TControllerInvoiceSale.getTaxationComplement: boolean;
begin
  FTaxRuler.Registro.ParaConsumidor := OrderSale.Customer.Registro.ConsumidorFinal;
  if OrderSale.Customer.Fiscal.kindPerson = 'J' then
    FTaxRuler.Registro.CRT := OrderSale.Customer.Fiscal.Juridica.Registro.CRT
  else
    FTaxRuler.Registro.CRT := '3';
  FTaxRuler.Registro.Estado := OrderSale.Customer.Fiscal.Endereco.Registro.CodigoEstado;

end;

procedure TControllerInvoiceSale.invoicing;
begin
  //Emitente
  Invoice.Emitente.Registro.Codigo := OrderSale.Registro.Estabelecimento;
  Invoice.Emitente.getAllByKey;
  //Destinatario
  OrderSale.Customer.Registro.Estabelecimento := OrderSale.Registro.Estabelecimento;
  OrderSale.Customer.Registro.Codigo := OrderSale.Registro.Cliente;
  OrderSale.Customer.getAllByKey;
  OrderSale.Customer.Fiscal.Endereco.Registro.Codigo := OrderSale.Registro.Cliente;
  OrderSale.Customer.Fiscal.Endereco.Registro.Tipo := 'COMERCIAL';
  OrderSale.Customer.Fiscal.Endereco.getAllByKey;
  inherited;
end;

function TControllerInvoiceSale.saveInvoice: boolean;
begin
  Invoice.Registro.Codigo          := OrderSale.Registro.Codigo;
  Invoice.Registro.Estabelecimento := OrderSale.Registro.Estabelecimento;
  Invoice.Registro.Terminal        := OrderSale.Registro.Terminal;
  Invoice.Registro.Emitente        := OrderSale.Registro.Estabelecimento;
  Invoice.Registro.TipoEmissao     := '4';
  Invoice.Registro.Finalidade      := '1';
  Invoice.Registro.Numero          := '';
  Invoice.Registro.Serie           := '1';
  Invoice.Registro.Cfop            := '';
  Invoice.Registro.Destinatario    := OrderSale.Registro.Cliente;
  Invoice.Registro.Data_emissao    := Date;
  Invoice.Registro.Valor           := Registro.ValorIcmsSt +
                                      Registro.ValorTotal +
                                      Registro.ValorFrete +
                                      Registro.ValorSeguro +
                                      Registro.ValorDespesas +
                                      Registro.ValorIpi -
                                      Registro.ValorDesc;
  Invoice.Registro.Modelo          := FModeloNota;
  Invoice.Registro.Status          := 'F';
  Invoice.save;
  //coloca na lista para salvar a observação
  createObservation(FObservacao);
end;

procedure TControllerInvoiceSale.setFModeloNota(const Value: String);
begin
  FModeloNota := Value;
end;

procedure TControllerInvoiceSale.setFObservacao(const Value: String);
begin
  FObservacao := Value;
end;

procedure TControllerInvoiceSale.setFVendedor(const Value: Integer);
begin
  FVendedor := Value;
end;

procedure TControllerInvoiceSale.setMensagemRetorno(const Value: String);
begin
  FMensagemRetorno := Value;
end;

procedure TControllerInvoiceSale.setVariable;
begin

end;

function TControllerInvoiceSale.ValidateInvoicing: Boolean;
begin
  Result := True;
  OrderSale.Parametro.Estabelecimento := FEstabelecimento;
  OrderSale.Parametro.Ordem           := FOrdem;
  OrderSale.Parametro.Terminal        := FTerminal;
  OrderSale.Parametro.Vendedor        := FVendedor;
  OrderSale.getByKey;
  if not OrderSale.exist then
  Begin
    FMensagemRetorno := 'Ordem não encontrada';
    Result := False;
  End;
  //Emitente
  OrderSale.Customer.Registro.Estabelecimento := OrderSale.Registro.Estabelecimento;
  OrderSale.Customer.Registro.Codigo := OrderSale.Registro.Cliente;
  OrderSale.Customer.getAllByKey;
  OrderSale.Customer.Fiscal.Endereco.Registro.Codigo := OrderSale.Registro.Cliente;
  OrderSale.Customer.Fiscal.Endereco.Registro.Tipo := 'COMERCIAL';
  OrderSale.Customer.Fiscal.Endereco.getAllByKey;

  if not ValidateItems then
  Begin
    Result := False;
  End;

end;


end.
