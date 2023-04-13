unit prm_to_invoice_sale;

interface
  Uses prm_invoice_merchandise, prm_base, prm_invoice_shipping, prm_call_invoice;

Type
  TPrmToInvoiceSale = Class(TPrmBase)
  private
    FObservacao: String;
    FModeloNFe: String;
    FVendedor: Integer;
    FOrdem: Integer;
    procedure setFModeloNFe(const Value: String);
    procedure setFObservacao(const Value: String);
    procedure setFOrdem(const Value: Integer);
    procedure setFVendedor(const Value: Integer);


  public
    //Padrão
    property Ordem: Integer read FOrdem write setFOrdem;
    property Observacao : String read FObservacao write setFObservacao;
    property ModeloNFe : String read FModeloNFe write setFModeloNFe;
    property Vendedor : Integer read FVendedor write setFVendedor;

  End;


implementation


{ TPrmToInvoiceSale }

procedure TPrmToInvoiceSale.setFModeloNFe(const Value: String);
begin
  FModeloNFe := Value;
end;

procedure TPrmToInvoiceSale.setFObservacao(const Value: String);
begin
  FObservacao := Value;
end;

procedure TPrmToInvoiceSale.setFOrdem(const Value: Integer);
begin
  FOrdem := Value;
end;

procedure TPrmToInvoiceSale.setFVendedor(const Value: Integer);
begin
  FVendedor := Value;
end;

end.
