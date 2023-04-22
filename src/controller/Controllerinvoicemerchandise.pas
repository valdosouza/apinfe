unit Controllerinvoicemerchandise;

interface
uses  System.Classes, System.SysUtils,Md5, FireDAC.Stan.Param,System.Math,
      tblinvoicemerchandise,  tblEntity, FireDAC.Comp.Client,
      BaseController,ControllerInvoice,ControllerOrder, ControllerOrderItem,
      ControllerOrderShipping,ControllerOrdertotalizer,ControllerTaxRuler,
      tblOrderItemIcms,tblOrderItem,
      ControllerMerchandise,ControllerInvoiceShipping, ControllerInvoiceReturn55,
  tblInvoiceObs, REST.Json;

Type
  TControllerInvoiceMerchandise = Class(TBaseController)
  private
    FItemIndex: Integer;
    FDistribuirITemsIPI: Boolean;
    FDistribuirITemsIcmsST: Boolean;
    FDirecao: String;
    FDistribuirITemsIcms: Boolean;
    function getOrderComplete:Boolean;

    procedure CalculateTaxes;
    function CalculateIcmsRule:boolean;
    function InformaIcmsManual:boolean;
    function RegimeTributarioNormal:Boolean;
    function RegimeTributarioSimplesNacional:Boolean;

    procedure DistributeShippingToItem;
    procedure DistributeInsuranceItem;
    procedure DistributeExpensesItem;
    procedure DistributeICMSItem;
    procedure DistributeICMSItemST;
    procedure DistributeIPI;

    function calculateICMS:boolean;
    function calculateIImpostoAproximado:boolean;
    function calculateIPI:boolean;
    function calculatePIS:Boolean;
    function calculateCofins:Boolean;
    function calculateII:Boolean;
    function CreateObservationRule:Boolean;

    procedure Totalizer;

    function saveICMS:boolean;
    function saveIPI:boolean;
    function savePIS:Boolean;
    function saveCofins:Boolean;
    function saveII:Boolean;
    function saveInvoiceShipping:Boolean;
    function saveObsInvoice:boolean;
    function updateOrderStatus:boolean;


    function CalculateFundoCombatePobreza:Boolean;
    procedure setFDirecao(const Value: String);
    procedure setFDistribuirITemsIcms(const Value: Boolean);
    procedure setFDistribuirITemsIcmsST(const Value: Boolean);
    procedure setFDistribuirITemsIPI(const Value: Boolean);
  protected
    FTaxRuler : TControllerTaxRuler;
    //Validações
    function ValidateItems:Boolean;
    function getTaxation:boolean;
    function getTaxationComplement:boolean;Virtual;
    function saveInvoice:boolean;Virtual;
    procedure createObservation(obs:String);
  public
    Registro        : TInvoicemerchandise;
    Invoice         : TControllerInvoice;
    OrderShipping   : TControllerOrderShipping;
    OrderTotalizer  : TControllerOrdertotalizer;
    InvoiceShipping : TControllerInvoiceShipping;
    Itens           : TControllerOrderItem;
    Return55        : TControllerInvoiceReturn55;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure setVariable;
    function save:boolean;
    function delete:boolean;
    procedure clear;
    function getByKey:boolean;
    function getAllByKey:boolean;
    function ValidateInvoicing:Boolean;Virtual;
    procedure invoicing;Virtual;


    property Direcao: String read FDirecao write setFDirecao;
    property DistribuirITemsIcms: Boolean read FDistribuirITemsIcms write setFDistribuirITemsIcms;
    property DistribuirITemsIcmsST: Boolean read FDistribuirITemsIcmsST write setFDistribuirITemsIcmsST;
    property DistribuirITemsIPI: Boolean read FDistribuirITemsIPI write setFDistribuirITemsIPI;
  End;

implementation

{ Controllerinvoicemerchandise }

uses unFunctions, tblOrderItemIpi, tblOrderItemPis, tblOrderItemCofins;

function TControllerInvoiceMerchandise.calculateCofins: Boolean;
Var
  LcItem : TOrderItemCofins;
begin
  if (FTaxRuler.Registro.CstCofins> '0') then
  Begin
    LcItem := TOrderItemCofins.create;
    LcItem.CST       := FTaxRuler.Registro.CstCofins;
    LcItem.Base      := (Itens.Lista[FItemIndex].Quantidade * Itens.Lista[FItemIndex].ValorUnitario);
    LcItem.Aliquota  := FTaxRuler.Registro.AliquotaCofins;
    LcItem.Valor     := (Itens.Cofins.Lista[FItemIndex].Base * Itens.Cofins.Lista[FItemIndex].Aliquota) /100;
    LcItem.Valor     := RoundTo(Itens.Cofins.Lista[FItemIndex].Valor,-2);
    Itens.Cofins.Lista.Add(LcItem);
  End;
end;

function TControllerInvoiceMerchandise.CalculateFundoCombatePobreza: Boolean;
begin
  REsult := True;
end;


function TControllerInvoiceMerchandise.calculateICMS: boolean;
Var
  Lc_taxa : Real;
  Lc_Icms : TOrderItemIcms;
begin
  Lc_Icms := TOrderItemIcms.Create;
  Lc_Icms.Estabelecimento := Itens.Lista[FItemIndex].Estabelecimento;
  Lc_Icms.Terminal        := Itens.Lista[FItemIndex].Terminal;
  Lc_Icms.ItemOrdem       := Itens.Lista[FItemIndex].Codigo;
  Lc_Icms.Ordem           := Itens.Lista[FItemIndex].Ordem;
  Itens.icms.lista.add(Lc_Icms);

  DistributeShippingToItem;
  DistributeInsuranceItem;
  DistributeExpensesItem;

  calculateIImpostoAproximado;

  if FDistribuirITemsIcms or FDistribuirITemsIcmsST then
  Begin
    DistributeICMSItem;
    if FDistribuirITemsIcmsST then
      DistributeICMSItemST;
  end
  else
  Begin
    if Itens.icms.Lista[FItemIndex].Aliquota = 0 then
      CalculateIcmsRule
    else
      InformaIcmsManual;
  end;

end;

function TControllerInvoiceMerchandise.CalculateIcmsRule: boolean;
begin
  CalculateFundoCombatePobreza;
  if (invoice.Emitente.juridica.Registro.CRT = '3') or ( invoice.Emitente.juridica.Registro.CRT = '2') then
    RegimeTributarioNormal
  else
    RegimeTributarioSimplesNacional
end;

function TControllerInvoiceMerchandise.calculateII: Boolean;
begin
  REsult := True;
end;

function TControllerInvoiceMerchandise.calculateIImpostoAproximado: boolean;
Var
  Lc_Qry:TFDQuery;
  Lc_Campo : String;

begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      if (Itens.Icms.Registro.Origem = '0') then
        Lc_Campo := 'NCM_AQ_NAC'
      else
        Lc_Campo := 'NCM_AQ_IMP';

      SQL.Add('select ' + Lc_Campo + ' , NCM_AQ_ESTADUAL, NCM_AQ_MUNICIPAL FROM tb_ncm WHERE tb_ncm.ncm_n_ncm =:NCM_N_NCM');
      ParamByName('NCM_N_NCM').AsString := Itens.Mercadoria.Registro.NCM;
      Active := True;
      Itens.Icms.Lista[FItemIndex].ImpostoAproximado := FieldByName(Lc_Campo).AsFloat +
                                                        FieldByName('NCM_AQ_ESTADUAL').AsFloat +
                                                        FieldByName('NCM_AQ_MUNICIPAL').AsFloat;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerInvoiceMerchandise.calculateIPI: boolean;
Var
  LcItem : TOrderItemIpi;
begin
  if FDistribuirITemsIPI then
  Begin
    DistributeIPI;
  end
  else
  Begin
    if (FTaxRuler.Registro.CstIPI> '0') then
    Begin
      LcItem := TOrderItemIpi.Create;
      LcItem.CST       := FTaxRuler.Registro.CstIPI;
      LcItem.Base      := (Itens.Lista[FItemIndex].Quantidade * Itens.Lista[FItemIndex].ValorUnitario);
      LcItem.Aliquota  := FTaxRuler.Registro.AliquotaIPI;
      LcItem.Valor     := (Itens.Ipi.Lista[FItemIndex].Base * Itens.Ipi.Lista[FItemIndex].Aliquota) /100;
      LcItem.Valor     := RoundTo(Itens.Ipi.Lista[FItemIndex].Valor,-2);
      Itens.Ipi.Lista.Add(LcItem);
    End;
  end;
end;

function TControllerInvoiceMerchandise.calculatePIS: Boolean;
Var
  LcItem : TOrderItemPis;
begin
  if (FTaxRuler.Registro.CstPIS> '0') then
  Begin
    LcItem := TOrderItemPis.Create;
    LcItem.CST       := FTaxRuler.Registro.CstIPI;
    LcItem.Base      := (Itens.Lista[FItemIndex].Quantidade * Itens.Lista[FItemIndex].ValorUnitario);
    LcItem.Aliquota  := FTaxRuler.Registro.AliquotaPIS;
    LcItem.Valor     := (Itens.PIs.Lista[FItemIndex].Base * Itens.PIs.Lista[FItemIndex].Aliquota) /100;
    LcItem.Valor     := RoundTo(Itens.Pis.Lista[FItemIndex].Valor,-2);
    itens.Pis.Lista.Add(LcItem);
  End;
end;

procedure TControllerInvoiceMerchandise.CalculateTaxes;
Var
  I : Integer;
Begin
  FItemIndex := 0;
  for I := 0 to Itens.Lista.Count -1 do
  Begin
    FItemIndex := I;
    if getTaxation then
    Begin
      //Calculo o IPI por que fara parte da Base de ICMS
      CalculateIPI;
      //Faz o calculo do ICMS segundo o regime tributario
      calculateICMS;
      CalculatePIS;
      CalculateCofins;
      CalculateII;
      CreateObservationRule;

    End;
  End;
  Totalizer;
end;

procedure TControllerInvoiceMerchandise.clear;
begin
  ClearObj(Registro);
end;

constructor TControllerInvoiceMerchandise.Create(AOwner: TComponent);
begin
  inherited;
  Registro        := Tinvoicemerchandise.Create;
  Invoice         := TControllerInvoice.Create(Self);
  OrderShipping   := TControllerOrderShipping.Create(Self);
  InvoiceShipping := TControllerInvoiceShipping.Create(self);
  OrderTotalizer  := TControllerOrdertotalizer.Create(self);
  Itens           := TControllerOrderItem.Create(self);
  Return55        := TControllerInvoiceReturn55.Create(Self);
  FTaxRuler       := TControllerTaxRuler.Create(Self);

end;

procedure TControllerInvoiceMerchandise.createObservation(obs: String);
Var
  LcItem : TInvoiceObs;
  I : Integer;
  LcInsere : Boolean;
begin
  LcInsere := True;
  for I:= 0 to  Invoice.Observacao.Lista.Count -1 do
  Begin
    if Invoice.Observacao.Lista[I].Observacao = obs then
    Begin
      LcInsere :=False;
      Break
    End;
  End;
  if LcInsere then
  Begin
    LcItem := TInvoiceObs.Create;
    LcItem.Codigo := 0;
    LcItem.Estabelecimento  := Invoice.Registro.Estabelecimento;
    LcItem.NotaFiscal       := Invoice.Registro.Codigo;
    LcItem.Terminal         := Invoice.Registro.Terminal;
    LcItem.Observacao       := obs;
    Invoice.Observacao.Lista.Add(LcItem);
  End;

end;

function TControllerInvoiceMerchandise.CreateObservationRule: Boolean;
begin
  if FTaxRuler.Registro.Observacao >0 then
  Begin
    FTaxRuler.Observation.Registro.Codigo := FTaxRuler.Registro.Observacao;
    FTaxRuler.Observation.Registro.Estabelecimento := FEstabelecimento;
    FTaxRuler.Observation.getByKey;
    if FTaxRuler.Observation.exist then
    Begin
      createObservation(FTaxRuler.Observation.Registro.Observacao);
    End;
  End;
end;

function TControllerInvoiceMerchandise.delete: boolean;
begin
  deleteObj(Registro)

end;

destructor TControllerInvoiceMerchandise.Destroy;
begin
  FTaxRuler.DisposeOf;
  OrderTotalizer.DisposeOf;
  Invoice.DisposeOf;
  InvoiceShipping.DisposeOf;
  OrderShipping.DisposeOf;
  Itens.DisposeOf;
  Registro.DisposeOf;
  Return55.DisposeOf;
  inherited;
end;

procedure TControllerInvoiceMerchandise.DistributeExpensesItem;
Var
  Lc_taxa : Real;
  Lc_Total : Real;
  I : Integer;
begin
  if (OrderShipping.Registro.Valor > 0) then
  Begin
    if (FItemIndex < Itens.Lista.count) then
    Begin
      Lc_taxa := (Itens.Lista[FItemIndex].Quantidade * Itens.Lista[FItemIndex].ValorUnitario) /  OrderTotalizer.Registro.ValorTotal;
      Itens.Icms.Lista[FItemIndex].ValorDespesas := RoundToDow(OrderShipping.Registro.Valor * Lc_taxa, 2, False);
    end
    else
    Begin
      Lc_Total := 0;
      for I := 0 to itens.Lista.Count do
        Lc_Total := Lc_Total + Itens.Icms.Lista[I].ValorDespesas;
      Itens.Icms.Lista[FItemIndex].ValorDespesas := OrderShipping.Registro.Valor - Lc_Total;
    end;
  End;

end;

procedure TControllerInvoiceMerchandise.DistributeIPI;
Var
  Lc_taxa : Real;
  Lc_Total : Real;
  I : Integer;
begin
  if (Registro.ValorIpi > 0 ) then
  Begin
    Itens.Ipi.Lista[FItemIndex].CST       := FTaxRuler.Registro.CstIPI;
    if (FItemIndex < Itens.Lista.count) then
    Begin
      Lc_taxa := (Itens.Lista[FItemIndex].Quantidade * Itens.Lista[FItemIndex].ValorUnitario) /  OrderTotalizer.Registro.ValorTotal;
      // Valor da Base Ipi -
      Itens.Ipi.Lista[FItemIndex].Base := (Itens.Lista[FItemIndex].Quantidade * Itens.Lista[FItemIndex].ValorUnitario);
      // Valor do IPI
      Itens.Ipi.Lista[FItemIndex].Valor := RoundToDow(Registro.ValorIPI * Lc_taxa, 2, False);
    End
    else
    Begin
      // Valor da Base IPI
      Itens.Ipi.Lista[FItemIndex].Base := (Itens.Lista[FItemIndex].Quantidade * Itens.Lista[FItemIndex].ValorUnitario);

      Lc_Total := 0;
      for I := 0 to itens.Lista.Count do
        Lc_Total := Lc_Total + Itens.IPI.Lista[I].Valor;
      Itens.Ipi.Lista[FItemIndex].Valor := Registro.ValorIPI - Lc_Total;
    End;
    // Aliquota do IPI
    Itens.Ipi.Lista[FItemIndex].Aliquota := (Itens.Ipi.Lista[FItemIndex].Valor / Itens.Ipi.Lista[FItemIndex].Base);
    Itens.Ipi.Lista[FItemIndex].Aliquota := Itens.Ipi.Lista[FItemIndex].Aliquota * 100;
    Itens.Ipi.Lista[FItemIndex].Aliquota := RoundTo(Itens.Ipi.Lista[FItemIndex].Aliquota,-2);
  End;
end;

procedure TControllerInvoiceMerchandise.DistributeICMSItem;
Var
  Lc_taxa : Real;
  Lc_Total : Real;
  I : Integer;
begin
  if (Registro.ValorIcms > 0 ) then
  Begin
    if (FItemIndex < Itens.Lista.count) then
    Begin
      Lc_taxa := (Itens.Lista[FItemIndex].Quantidade * Itens.Lista[FItemIndex].ValorUnitario) /  OrderTotalizer.Registro.ValorTotal;
      // Valor da Base ICMS -
      Itens.Icms.Lista[FItemIndex].ValorBase := RoundToDow(Registro.ValorBaseICMS * Lc_taxa, 2, False);
      // Aliquota do ICMS = VL ICMS / BC
      Itens.Icms.Lista[FItemIndex].Valor := RoundToDow(Registro.ValorICMS * Lc_taxa, 2, False);

    End
    else
    Begin
      // Valor da Base ICMS
      Lc_Total := 0;
      for I := 0 to itens.Lista.Count do
        Lc_Total := Lc_Total + Itens.Icms.Lista[I].ValorBase;
      Itens.Icms.Lista[FItemIndex].ValorBase := Registro.ValorBaseICMS - Lc_Total;
      // Valor do ICMS
      Lc_Total := 0;
      for I := 0 to itens.Lista.Count do
        Lc_Total := Lc_Total + Itens.Icms.Lista[I].Valor;
      Itens.Icms.Lista[FItemIndex].Valor := Registro.ValorICMS - Lc_Total;
    End;
    //Aliquota de ICMS
    Itens.Icms.Lista[FItemIndex].Aliquota := (Itens.Icms.Lista[FItemIndex].Valor / Itens.Icms.Lista[FItemIndex].ValorBase);
    Itens.Icms.Lista[FItemIndex].Aliquota := Itens.Icms.Lista[FItemIndex].Aliquota * 100;
    Itens.Icms.Lista[FItemIndex].Aliquota := RoundTo(Itens.Icms.Lista[FItemIndex].Aliquota, -2);
  End;
end;

procedure TControllerInvoiceMerchandise.DistributeICMSItemST;
Var
  Lc_taxa : Real;
  Lc_Total : Real;
  I : Integer;
begin
  if (Registro.ValorIcmsST > 0 ) then
  Begin
    if (FItemIndex < Itens.Lista.count) then
    Begin
      Lc_taxa := (Itens.Lista[FItemIndex].Quantidade * Itens.Lista[FItemIndex].ValorUnitario) /  OrderTotalizer.Registro.ValorTotal;
      // Valor da Base ICMS -
      Itens.Icms.Lista[FItemIndex].ValorBaseST := RoundToDow(Registro.ValorBaseICMSST * Lc_taxa, 2, False);
      // Aliquota do ICMS = VL ICMS / BC
      Itens.Icms.Lista[FItemIndex].ValorST := RoundToDow(Registro.ValorICMSST * Lc_taxa, 2, False);
    end
    else
    Begin
      // Valor da Base ICMS
      Lc_Total := 0;
      for I := 0 to itens.Lista.Count do
        Lc_Total := Lc_Total + Itens.Icms.Lista[I].ValorBaseST;
      Itens.Icms.Lista[FItemIndex].ValorBaseST := Registro.ValorBaseICMSST - Lc_Total;
      // Valor do ICMS
      Lc_Total := 0;
      for I := 0 to itens.Lista.Count do
        Lc_Total := Lc_Total + Itens.Icms.Lista[I].ValorST;
      Itens.Icms.Lista[FItemIndex].ValorsT := Registro.ValorICMSST - Lc_Total;
    end;
    //Aliquota de ICMS
    Itens.Icms.Lista[FItemIndex].AliquotaST := (Itens.Icms.Lista[FItemIndex].ValorST / Itens.Icms.Lista[FItemIndex].ValorBaseST);
    Itens.Icms.Lista[FItemIndex].AliquotaST := Itens.Icms.Lista[FItemIndex].AliquotaST * 100;
    Itens.Icms.Lista[FItemIndex].AliquotaST := RoundTo(Itens.Icms.Lista[FItemIndex].AliquotaST, -2);
  End;
end;

procedure TControllerInvoiceMerchandise.DistributeInsuranceItem;
Var
  Lc_taxa : Real;
  Lc_Total : Real;
  I : Integer;
begin
  if (OrderShipping.Registro.Valor > 0) then
  Begin
    if (FItemIndex < Itens.Lista.count) then
    Begin
      Lc_taxa := (Itens.Lista[FItemIndex].Quantidade * Itens.Lista[FItemIndex].ValorUnitario) /  OrderTotalizer.Registro.ValorTotal;
      Itens.Icms.Lista[FItemIndex].ValorSeguro := RoundToDow(OrderShipping.Registro.Valor * Lc_taxa, 2, False);
    end
    else
    Begin
      Lc_Total := 0;
      for I := 0 to itens.Lista.Count do
        Lc_Total := Lc_Total + Itens.Icms.Lista[I].ValorSeguro;
      Itens.Icms.Lista[FItemIndex].ValorSeguro := OrderShipping.Registro.Valor - Lc_Total;
    end;
  End;
end;

procedure TControllerInvoiceMerchandise.DistributeShippingToItem;
Var
  Lc_taxa : Real;
  Lc_Total : Real;
  I : Integer;
begin
  if (OrderShipping.Registro.Valor > 0) then
  Begin
    if (FItemIndex < Itens.Lista.count) then
    Begin
      Lc_taxa := (Itens.Lista[FItemIndex].Quantidade * Itens.Lista[FItemIndex].ValorUnitario) /  OrderTotalizer.Registro.ValorTotal;
      Itens.Icms.Lista[FItemIndex].ValorFrete := RoundToDow(OrderShipping.Registro.Valor * Lc_taxa, 2, False);
    end
    else
    Begin
      Lc_Total := 0;
      for I := 0 to itens.Lista.Count do
        Lc_Total := Lc_Total + Itens.Icms.Lista[I].ValorFrete;
      Itens.Icms.Lista[FItemIndex].ValorFrete := OrderShipping.Registro.Valor - Lc_Total;
    end;
  End;
end;

function TControllerInvoiceMerchandise.getAllByKey: boolean;
begin
  _getByKey(Registro);

  //Nota Principal
  invoice.Registro.Estabelecimento  := Self.Registro.Estabelecimento;
  invoice.Registro.Codigo           := Self.Registro.Codigo;
  invoice.Registro.Terminal         := Self.Registro.Terminal;
  invoice.getByKey;
  //Cfop
  invoice.Cfop.Registro.Codigo := invoice.Registro.Cfop;
  invoice.Cfop.getByKey;
  //Retorno nota

  Return55.Registro.Estabelecimento := Self.Registro.Estabelecimento;
  Return55.Registro.Codigo          := Self.Registro.Codigo;
  Return55.Registro.Terminal        := Self.Registro.Terminal;
  invoice.getByKey;
end;

function TControllerInvoiceMerchandise.getByKey: boolean;
begin
  _getByKey(Registro);
end;

function TControllerInvoiceMerchandise.getOrderComplete: Boolean;
begin
  invoice.Pedido.Registro.Estabelecimento := FEstabelecimento;
  invoice.Pedido.Registro.Codigo := FOrdem;
  invoice.Pedido.Registro.Terminal := FTerminal;
  invoice.Pedido.getByKey;

  Itens.Registro.Estabelecimento := FEstabelecimento;
  Itens.Registro.Ordem := FOrdem;
  Itens.Registro.Terminal := FTerminal;
  Itens.getList;
end;

function TControllerInvoiceMerchandise.getTaxation:Boolean;
begin
  itens.Mercadoria.Registro.Codigo := itens.Lista[FItemIndex].Produto;
  itens.Mercadoria.Registro.Estabelecimento := FEstabelecimento;
  itens.Mercadoria.getByKey;
  itens.Mercadoria.Estoque.Registro.Mercadoria := itens.Lista[FItemIndex].Produto;
  itens.Mercadoria.Estoque.Registro.Estabelecimento := FEstabelecimento;
  itens.Mercadoria.Estoque.getByKey;

  FTaxRuler.clear;
  FTaxRuler.Registro.Estabelecimento := FEstabelecimento;
  //Dados do Produto
  FTaxRuler.Registro.Produto := itens.Lista[FItemIndex].Produto;
  FTaxRuler.Registro.NCM := itens.Mercadoria.Registro.NCM;
  FTaxRuler.Registro.Origem := itens.Mercadoria.Registro.Origem;
  FTaxRuler.Registro.ParaProdutosComIcmsSt := itens.Mercadoria.Estoque.Registro.TemST;
  FTaxRuler.Registro.TipoTransacao :=itens.Mercadoria.Registro.TipoTributacao;
  //Dados do DEstinatario - PEgar na classe descendente
  getTaxationComplement;

  FTaxRuler.Registro.Direcao := 'S';
  Result := FTaxRuler.getRuler;
end;

function TControllerInvoiceMerchandise.getTaxationComplement: boolean;
begin
  inherited;
end;

function TControllerInvoiceMerchandise.InformaIcmsManual: boolean;
begin

end;

procedure TControllerInvoiceMerchandise.invoicing;
begin
  getOrderComplete;
  CalculateTaxes;
  CalculateFundoCombatePobreza;
  saveInvoice;
  save;
  saveICMS;
  saveIPI;
  savePIS;
  saveCofins;
  saveII;
  saveObsInvoice;
  saveInvoiceShipping;
  updateOrderStatus;
end;

function TControllerInvoiceMerchandise.RegimeTributarioNormal: Boolean;
begin

end;

function TControllerInvoiceMerchandise.RegimeTributarioSimplesNacional: Boolean;
Var
  lcItem : TOrderItem;
  Lc_Ok:Boolean;
  LcVlIpiDevol : Real;
  procedure ZeraValoresICMS;
  Begin
    with itens.icms.lista[Fitemindex] do
    Begin
      ValorBase      := 0;
      Aliquota    := 0;
      AliqReducaoBase   := 0;
      valor    := 0;
    End;
  End;
  procedure ZeraValoresST;
  Begin
    with itens.icms.lista[Fitemindex] do
    Begin
      MVA   := 0;
      AliqReducaoBaseST := 0;
      valorbaseST    := 0;
      aliquotaST  := 0;
      valorST  := 0;
      ValorBaseRetido := 0;
      ValorRetido := 0;
    End;
  End;
Begin
  with itens.icms.lista[Fitemindex] do
  Begin
    lcItem := itens.lista[Fitemindex];
    //Verifica se há tributação pelo Simples Nacional

    cst                 := FTaxRuler.Registro.CSOSN;
    Origem              := FTaxRuler.Registro.Origem;
    DeterminacaoBase    := FTaxRuler.Registro.DeterminacaoBaseIcms;
    Desoneracao         := FTaxRuler.Registro.Desoneracao;
    AliqReducaoBase     := FTaxRuler.Registro.ReducaoBaseICMS;
    //Base do ICMS ST = (Valor do produto + Valor do IPI + Frete + Seguro + Outras Despesas Acessórias - Descontos) * (1+(%MVA / 100))
    ValorBase           := (lcItem.valorUnitario * lcItem.quantidade) - lcItem.valorDesconto;
    ValorBase           := ValorBase + itens.IPI.Registro.Valor + ValorFrete + ValorSeguro + valorDespesas;
    ValorBase           := ValorBase - ((ValorBase * AliqReducaoBase) /100);
    ValorBase           := RoundTo(ValorBase,-2);

    Aliquota            := FTaxRuler.Registro.AliquotaIcms;
    ReducaoAliquota     := FTaxRuler.Registro.ReducaoAliqICMS;

    Valor               :=  ValorBase * ((aliquota - ReducaoAliquota)/100);
    Valor               :=  RoundTo(Valor,-2);

    //ICMS Normal S.T
    DeterminacaoBaseST  := FTaxRuler.Registro.DeterminacaoBaseICMSST;
    MVA                 := 0;
    AliqReducaoBaseST   := 0;
    if FTaxRuler.Registro.PropagaReducaoBase = 'S' then
    Begin
      ValorBaseST           := ValorBase;
    end
    else
    Begin
      ValorBaseST           := (lcItem.valorUnitario * lcItem.quantidade) - lcItem.valorDesconto;
      ValorBaseST           := ValorBaseST + itens.IPI.Registro.Valor + ValorFrete + ValorSeguro + valorDespesas;
    end;
    ValorBaseST           := RoundTo(ValorBaseST,-2);

    AliquotaST          := 0; //Falta Pegar do Estado Aliquota do icms interna do estado de destino
    ReducaoAliquotaST   := 0;
    ValorST             := (ValorBaseST * (AliquotaST - ReducaoAliquotaST)/100);
    ValorST             := Roundto(ValorST,-2);
    ValorST             := ValorST - Valor;

    //Criar função para informar os valores anteriores
    if FTaxRuler.Registro.CSOSN = '500' then
    Begin
      ValorBaseRetido     := 0;
      ValorRetido         := 0;
      ValorBaseRetidoST   := 0;
      ValorRetidoST       := 0;
    end;
    if PArtilha = 'S' then
    Begin
      Repasse             := '';
    end;
    //credito ICMS
    Aliquota_CalcCred   := 0;
    Valor_CredExpl      := 0;
    Cfop                := FTaxRuler.Registro.CFOP;

    //TRIBUTADA PELO SIMPLES NACIONAL COM PERMISSÃO DE CRÉDITO
    if (FTaxRuler.Registro.CSOSN = '101') then
    Begin
      ZeraValoresICMS;
      ZeraValoresST;
      exit;
    end;
    //Tributação do ICMS pelo SIMPLES NACIONAL e CSOSN=102, 103, 300 ou 400 (v.2.0)
    if (FTaxRuler.Registro.CSOSN = '102') or
       (FTaxRuler.Registro.CSOSN = '103') or
       (FTaxRuler.Registro.CSOSN = '300') then
    Begin
      ZeraValoresICMS;
      ZeraValoresST;
      //credito ICMS
      Aliquota_CalcCred   := 0;
      Valor_CredExpl      := 0;
      exit;
    end;
    //Tributação do ICMS pelo SIMPLES NACIONAL e CSOSN=102, 103, 300 ou 400 (v.2.0)
    if ( FTaxRuler.Registro.CSOSN = '400') then
    Begin
      ZeraValoresST;
      //credito ICMS
      Aliquota_CalcCred   := 0;
      Valor_CredExpl      := 0;
      exit;
    end;


    //201- Tributada pelo Simples Nacional com permissão de crédito e com cobrança do ICMS por Substituição Tributária v.2.0)
    if (FTaxRuler.Registro.CSOSN = '201') then
    Begin
      //ICMS Normal S.T já calculada no inicio do processo
      //ICMS Normal - Zera os valores depois de feito o calculo
      ZeraValoresICMS;
      exit;
    end;
    //202- Tributada pelo Simples Nacional sem permissão de  crédito e com cobrança do ICMS por Substituição Tributária
    //203- Isenção do ICMS nos Simples Nacional para faixa de receita bruta e com cobrança do ICMS por Substituição Tributária  (v.2.0)
    if (FTaxRuler.Registro.CSOSN = '202') OR
       (FTaxRuler.Registro.CSOSN = '203')then
    Begin
      //ICMS Normal S.T já calculada no inicio do processo
      //ICMS Normal - Zera os valores depois de feito o calculo
      ZeraValoresICMS;
      //credito ICMS
      Aliquota_CalcCred   := 0;
      Valor_CredExpl      := 0;
      exit;
    end;
    //500 – ICMS cobrado anteriormente por substituição tributária (substituído) ou por antecipação (v.2.0)
    if (FTaxRuler.Registro.CSOSN = '500') then
    Begin
      ZeraValoresICMS;
      ZeraValoresST;
      exit;
    end;
    //Tributação do ICMS pelo SIMPLES NACIONAL e CSOSN=900 (v2.0)
    if (FTaxRuler.Registro.CSOSN = '900') then
    Begin
      if (FTaxRuler.Registro.ParaProdutosComIcmsSt <> 'S') then
        ZeraValoresST;
      exit;
    end;
  end;
end;

function TControllerInvoiceMerchandise.save: boolean;
begin
  try
    Registro.Codigo          := Invoice.Registro.Codigo;
    Registro.Estabelecimento := Invoice.Registro.estabelecimento;
    Registro.Terminal        := Invoice.Registro.terminal;
    Registro.DataSaida       := Date;
    Registro.HoraSaida       := Time;
    Registro.IndicacaoPresenca := 1;
    saveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerInvoiceMerchandise.saveCofins: Boolean;
Var
  I : Integer;
begin
  for I := 0 to Itens.Cofins.Lista.Count - 1 do
  Begin
    Itens.ClonarObj(Itens.Cofins.Lista[I],Itens.Cofins.Registro);
    Itens.Cofins.save;
  End;
end;

function TControllerInvoiceMerchandise.saveICMS: boolean;
Var
  I : Integer;
begin
  for I := 0 to Itens.Icms.Lista.Count - 1 do
  Begin
    Itens.ClonarObj(Itens.Icms.Lista[I],Itens.Icms.Registro);
    Itens.Icms.save;
  End;
end;

function TControllerInvoiceMerchandise.saveII: Boolean;
Var
  I : Integer;
begin
  for I := 0 to Itens.II.Lista.Count - 1 do
  Begin
    Itens.ClonarObj(Itens.II.Lista[I],Itens.II.Registro);
    Itens.II.save;
  End;
end;

function TControllerInvoiceMerchandise.saveInvoice: boolean;
begin
  inherited;
end;

function TControllerInvoiceMerchandise.saveInvoiceShipping: Boolean;
begin
  InvoiceShipping.Registro.Codigo          := Invoice.Registro.Codigo;
  InvoiceShipping.Registro.Estabelecimento := Invoice.Registro.Estabelecimento;
  InvoiceShipping.Registro.Terminal        := Invoice.Registro.Terminal;
  InvoiceShipping.Registro.Quantidade      := 0;
  InvoiceShipping.Registro.Classificacao   := '';
  InvoiceShipping.Registro.Marca           := '';
  InvoiceShipping.Registro.PesoBruto       := '';
  InvoiceShipping.Registro.PesoLiquido     := '';
  InvoiceShipping.Registro.NumeroVolume    := '';
  InvoiceShipping.Registro.PlacaVeiculo    := '';
  InvoiceShipping.Registro.PlacaEstado     := '';
  InvoiceShipping.Registro.PlacaRntc       := '';
  InvoiceShipping.save;
end;

function TControllerInvoiceMerchandise.saveIPI: boolean;
Var
  I : Integer;
begin
  for I := 0 to Itens.Ipi.Lista.Count - 1 do
  Begin
    Itens.ClonarObj(Itens.Ipi.Lista[I],Itens.Ipi.Registro);
    Itens.Ipi.save;
  End;
end;

function TControllerInvoiceMerchandise.saveObsInvoice: boolean;
Var
  I : Integer;
begin
  for I := 0 to Invoice.Observacao.Lista.Count - 1 do
  Begin
    Itens.ClonarObj(Invoice.Observacao.Lista[I],Invoice.Observacao.Registro);
    Invoice.Observacao.save;
  End;
end;

function TControllerInvoiceMerchandise.savePIS: Boolean;
Var
  I : Integer;
begin
  for I := 0 to Itens.Pis.Lista.Count - 1 do
  Begin
    Itens.ClonarObj(Itens.Pis.Lista[I],Itens.Pis.Registro);
    Itens.Pis.save;
  End;
end;

procedure TControllerInvoiceMerchandise.setFDirecao(const Value: String);
begin
  FDirecao := Value;
end;

procedure TControllerInvoiceMerchandise.setFDistribuirITemsIcms(
  const Value: Boolean);
begin
  FDistribuirITemsIcms := Value;
end;

procedure TControllerInvoiceMerchandise.setFDistribuirITemsIcmsST(
  const Value: Boolean);
begin
  FDistribuirITemsIcmsST := Value;
end;

procedure TControllerInvoiceMerchandise.setFDistribuirITemsIPI(
  const Value: Boolean);
begin
  FDistribuirITemsIPI := Value;
end;

procedure TControllerInvoiceMerchandise.setVariable;
begin

end;

procedure TControllerInvoiceMerchandise.Totalizer;
Var
  I : Integer;
Begin
  if not FDistribuirITemsIcms then
  Begin
    Registro.ValorBaseICMS   := 0;
    Registro.ValorIcms       := 0;
    for I := 0 to Itens.icms.Lista.Count -1 do
    Begin
      Registro.ValorBaseICMS   := Registro.ValorBaseICMS + Itens.ICMS.lista[I].valorBase;
      Registro.ValorIcms       := Registro.ValorIcms + Itens.ICMS.lista[I].Valor;
    End;
  end;

  if not FDistribuirITemsIcmsST then
  Begin
    Registro.ValorBaseIcmsSt := 0;
    Registro.ValorIcmsSt     := 0;
    for I := 0 to Itens.icms.Lista.Count -1 do
    Begin
      Registro.ValorBaseIcmsSt := Registro.ValorBaseIcmsSt + Itens.ICMS.lista[I].valorBaseST;
      Registro.ValorIcmsSt     := Registro.ValorIcmsSt + Itens.ICMS.lista[I].valorST;
    end;
  end;
  //Valor total dos produtos
  Registro.ValorTotal      := 0;
  for I := 0 to Itens.Lista.Count -1 do
  Begin
    Registro.ValorTotal := Registro.ValorTotal + ((Itens.lista[I].ValorUnitario * Itens.lista[I].Quantidade)-Itens.lista[I].ValorDesconto);
  End;

  Registro.ValorFrete      := 0;
  Registro.ValorSeguro     := 0;
  Registro.ValorDespesas   := 0;
  for I := 0 to Itens.icms.Lista.Count -1 do
  Begin
    Registro.ValorFrete     := Registro.ValorFrete + Itens.ICMS.lista[I].valorFrete;
    Registro.ValorSeguro    := Registro.ValorSeguro + Itens.ICMS.lista[I].valorSeguro;
    Registro.ValorDespesas  := Registro.ValorDespesas + Itens.ICMS.lista[I].valorDespesas;
  End;

  if not FDistribuirITemsIPI then
  Begin
    Registro.ValorIpi := 0;
    for I := 0 to Itens.IPI.Lista.Count -1 do
    Begin
      Registro.ValorIpi :=  Registro.ValorIpi + Itens.IPI.lista[I].valor
    end;
  end;
end;

function TControllerInvoiceMerchandise.updateOrderStatus: boolean;
begin
  Invoice.Pedido.Registro.Codigo          := Registro.Codigo;
  Invoice.Pedido.Registro.Estabelecimento := Registro.Estabelecimento;
  Invoice.Pedido.Registro.Terminal        := Registro.Terminal;
  Invoice.Pedido.Registro.Status          := 'F';
  Invoice.Pedido.setStatus;
end;

function TControllerInvoiceMerchandise.ValidateInvoicing: Boolean;
begin
  Result := True;
end;

function TControllerInvoiceMerchandise.ValidateItems: Boolean;
Var
  I : Integer;
begin
  Result := True;
  Itens.Registro.Estabelecimento := FEstabelecimento;
  Itens.Registro.Ordem := FOrdem;
  Itens.Registro.Terminal := FTerminal;
  Itens.getList;
  for I := 0 to Itens.Lista.Count -1 do
  Begin
    FItemIndex := I;
    if not getTaxation then
    Begin
      FMensagemRetorno.AddPair('Mensagem','Regra não encontrada.');
      FMensagemRetorno.AddPair('produto',itens.Mercadoria.Produto.Registro.Descricao);
      Result := False;
      break;
    End;
  End;

end;

end.
