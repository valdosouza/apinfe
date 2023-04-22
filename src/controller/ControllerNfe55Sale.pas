unit ControllerNfe55Sale;

interface

uses System.Classes, ControllerNfe55,ControllerInvoiceSale,ControllerInvoiceReturn55,
    pcnNFe, System.SysUtils, pcnConversao, pcnConversaoNFe,ControllerFinancialBills,
    ControllerProductUfBenef, ControllerBrand, System.Math,
  prm_to_invoice_sale;

type
  TControllerNfe55Sale = class(TControllerNfe55)
    private
      FInvoiceSale : TControllerInvoiceSale;
      FReturnNFe : TControllerInvoiceReturn55;
      FBenefits : TControllerProductUfBenef;
      FBrand : TControllerBrand;
      FinancialBills : TControllerFinancialBills;
    FParametros: TPrmToInvoiceSale;
      function DefineNumeroNota:Boolean;
      function InfoSubTributariaItem: String;
    procedure setFParametros(const Value: TPrmToInvoiceSale);

    protected
      procedure GeraDanfeIde(dfide:TIde);Override;
      procedure GeraDanfeEmi(dfemi:TEmit);Override;
      procedure GeraDanfeDes(dfdes:TDest);Override;
      procedure GeraDanfeCasasDecimais;Override;
      procedure GeraDanfeItensProdServ(itens:Tprod; Item:Integer);Override;
      function  GeraDanfeProdInfoAdicLote(itens:Tprod; Item:Integer):String;Override;
      function  GeraDanfeProdInfoAdicFCP(itens:Tprod; Item:Integer):String;Override;
      function  GeraDanfeProdInfoAdicRTR(itens:Tprod; Item:Integer):String;Override;
      function  GeraDanfeProdInfoAdic(itens:Tprod; Item:Integer):String;Override;
      procedure GeraDanfeImportacao(itens:Tprod);Override;
      procedure GeraDanfeVeiculosNovos(itens:Tprod);Override;
      procedure GeraDanfeCombustivel(itens:Tprod);Override;
      procedure GeraDanfeImpostoAproximado(imposto:TImposto);Override;
      procedure GeraDanfeImpostoRegimeNormal(imposto:TImposto);Override;
      procedure GeraDanfeImpostoSimplesNacional(imposto:TImposto);Override;
      procedure GeraDanfeICMS(imposto:TImposto);Override;
      procedure GeraDanfePartilhaFCP(Emit:TEmit;Ide:TIde;Dest:TDest;Prod:TProd;imposto:TImposto);Override;
      procedure GetDanfeItens;override;
      procedure GeraDanfeItens();Override;
      procedure GeraDanfeIPI(imposto:TImposto);Override;
      procedure GeraDanfeIPIDevolvido;Override;
      procedure GeraDanfeII(imposto:TImposto);Override;
      procedure GeraDanfePIS(imposto:TImposto);Override;
      procedure GeraDanfeCOFINS(imposto:TImposto);Override;
      procedure GeraDanfeISSQN(imposto:TImposto);Override;
      procedure GeraDanfeTotalizador;Override;
      procedure GeraDanfeTransportadora;Override;
      procedure GeraDanfeFormaPagto;Override;
      procedure GeraDanfeCobranca;Override;
      procedure GeraDanfeInfAdicContribuinte;Override;
      procedure GeraDanfeInfAdicFisco;Override;
      //procedure GeraDanfeComercioExterior;Override;
      //procedure GeraResponsabelTécnico;Override;
      //procedure GeraCNPJAutorizados;Override;

      procedure FinalizaCancelamento;Override;

    public

      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      procedure inicializa;override;
      function ValidateAuthorization:Boolean;Override;
      procedure doAuthorization;
      property Parametros : TPrmToInvoiceSale read FParametros write setFParametros;
  end;
implementation

uses UnFunctions;
{ TControllerNfe55Sale }

constructor TControllerNfe55Sale.Create(AOwner: TComponent);
begin
  inherited;
  FInvoiceSale  := TControllerInvoiceSale.Create(self);
  FReturnNfe    := TControllerInvoiceReturn55.Create(self);
  FBenefits     := TControllerProductUfBenef.Create(self);
  FBrand        := TControllerBrand.Create(self);
  FinancialBills := TControllerFinancialBills.Create(self);
end;

function TControllerNfe55Sale.DefineNumeroNota:Boolean;
begin
  if FInvoiceSale.Invoice.Registro.Numero = '' then
  Begin
    FInvoiceSale.Invoice.Registro.Codigo          := FInvoiceSale.Registro.Codigo;
    FInvoiceSale.Invoice.Registro.Estabelecimento := FInvoiceSale.Registro.Estabelecimento;
    FInvoiceSale.Invoice.Registro.Terminal        := FInvoiceSale.Registro.Terminal;
    FInvoiceSale.Invoice.Registro.Numero          := FInvoiceSale.Invoice.getNextNfeNumber;
    FInvoiceSale.Invoice.setNfeNumber;

    if not FRetorno.exist then
    Begin

      FRetorno.Registro.Codigo            := FInvoiceSale.Registro.Codigo;
      FRetorno.Registro.Estabelecimento   := FInvoiceSale.Registro.Estabelecimento;
      FRetorno.Registro.Terminal          := FInvoiceSale.Registro.Terminal;
      FRetorno.Registro.Serie             := FConfig.ConfigNfe.Registro.Serie;
      FRetorno.Registro.Status            := 0;
      FRetorno.Registro.NomeArquivo       := '';
      FRetorno.Registro.Numero            := FInvoiceSale.Invoice.Registro.Numero;
      FRetorno.save;
    End;
  End;
end;

destructor TControllerNfe55Sale.Destroy;
begin
  FinancialBills.DisposeOf;
  FBenefits.DisposeOf;
  FBrand.DisposeOf;
  FReturnNfe.DisposeOf;
  FInvoiceSale.DisposeOf;
  inherited;
end;

procedure TControllerNfe55Sale.doAuthorization;
begin
  if chekAuthorization then
  Begin
    getAuthorization;
  End;
end;

procedure TControllerNfe55Sale.FinalizaCancelamento;
begin
  inherited;

end;


procedure TControllerNfe55Sale.GeraDanfeCasasDecimais;
Var
  Lc_Nr_CasaDecimal: Integer;
  Lc_Tam_CodPro: Integer;
  Lc_AuxInt: Integer;
  LcValor : Real;
  I :Integer;
BEgin
  Lc_Nr_CasaDecimal := 0;
  FNfe.DANFE.CasasDecimais.vUnCom := 2;
  for I := 0 to FInvoiceSale.Itens.Lista.Count-1 do
  Begin
    FInvoiceSale.ClonarObj(FInvoiceSale.Itens.Lista[I],FInvoiceSale.Itens.Registro);
    LcValor := (FInvoiceSale.Itens.Registro.ValorUnitario * FInvoiceSale.Itens.Registro.Quantidade);
    Lc_Nr_CasaDecimal := getDecimalPoint(FloatToStrF(LcValor,ffFixed, 10, 6));
    if Lc_Nr_CasaDecimal > FNfe.DANFE.CasasDecimais.vUnCom then
      FNfe.DANFE.CasasDecimais.vUnCom := Lc_Nr_CasaDecimal;
  end;

  // Define Quantas Casas Decimais para a Quantidade
  Lc_Nr_CasaDecimal := 0;
  FNfe.DANFE.CasasDecimais.qCom := 2;
  for I := 0 to FInvoiceSale.Itens.Lista.Count-1 do
  Begin
    Lc_Nr_CasaDecimal := getDecimalPoint(FloatToStrF( FInvoiceSale.Itens.Registro.Quantidade, ffFixed, 10, 4));
    if Lc_Nr_CasaDecimal > FNfe.DANFE.CasasDecimais.qCom then
      FNfe.DANFE.CasasDecimais.qCom := Lc_Nr_CasaDecimal;
  end;
 // Determina tamanho do campo codigo do produto
  FDfe_Fortes.LarguraCodProd := Length(FInvoiceSale.Itens.Mercadoria.Registro.CodigoInterno ) * 6;
  for I := 0 to FInvoiceSale.Itens.Lista.Count-1 do
  Begin
    FInvoiceSale.Itens.Mercadoria.Registro.Codigo          := FInvoiceSale.Itens.Registro.Produto;
    FInvoiceSale.Itens.Mercadoria.Registro.Estabelecimento := FInvoiceSale.Itens.Registro.Estabelecimento;
    FInvoiceSale.Itens.Mercadoria.getByKey;
    // Determina tamanho do campo codigo do produto
    Lc_Tam_CodPro := Length(FInvoiceSale.Itens.Mercadoria.Registro.CodigoInterno ) * 6;
    if (Lc_Tam_CodPro > FDfe_Fortes.LarguraCodProd) then
       FDfe_Fortes.LarguraCodProd := Lc_Tam_CodPro

  end;
end;

procedure TControllerNfe55Sale.GeraDanfeCobranca;
Var
  Lc_Ok : Boolean;
  I : Integer;
BEgin
  // Verifica se é uma NF de Saida
  with FNfe.NotasFiscais[0].Nfe do
  Begin
    Ide.tpNF := tnSaida;
    Cobr.Fat.nFat   := FInvoiceSale.Invoice.Registro.Numero;
    // Carregar as duplicatas -


    If (FConfig.Registro.Duplicata = 'S') then
    Begin

      if FinancialBills.Lista.Count > 1 then
      Begin
        for I := 0 to FinancialBills.Lista.Count -1 do
        Begin
          FinancialBills.Financial.Registro.Ordem     := FinancialBills.Registro.Ordem;
          FinancialBills.Financial.Estabelecimento    := FinancialBills.Registro.Estabelecimento;
          FinancialBills.Financial.Terminal           := FinancialBills.Registro.Terminal;
          FinancialBills.Financial.getByKey;

          with Cobr.Dup.Add do
          Begin
            nDup  := StrZero( FinancialBills.Lista[I].Parcela,3,0);
            dVenc := FinancialBills.Financial.Registro.DataVencimento;
            vDup  := FinancialBills.Financial.Registro.Valor;

            Cobr.Fat.vOrig  := Cobr.Fat.vOrig + FinancialBills.Financial.Registro.Valor;;
            Cobr.Fat.vLiq   := Cobr.Fat.vLiq  + FinancialBills.Financial.Registro.Valor;;
            Cobr.Fat.vDesc  := 0;
          end;
        end;
      end
      else
      Begin
        //Com apenas uma parcela verificamos se se ela é a vista e se deseja ocultar
        if FConfig.Registro.OcultarPrimeiraParcela = 'S' then
        BEgin
          if(FinancialBills.Financial.Registro.DataVencimento > FInvoiceSale.Invoice.Registro.Data_emissao ) then
          BEgin
            with Cobr.Dup.Add do
            Begin
              nDup  := StrZero(FinancialBills.Financial.Registro.Parcela,3,0);
              dVenc := FinancialBills.Financial.Registro.DataVencimento;
              vDup  := FinancialBills.Financial.Registro.Valor;
            end;
          End;
        End
        else
        BEgin
          with Cobr.Dup.Add do
          Begin
            nDup  := StrZero(FinancialBills.Financial.Registro.Parcela,3,0);
            dVenc := FinancialBills.Financial.Registro.DataVencimento;
            vDup  := FinancialBills.Financial.Registro.Valor;
          end;
        End;
        Cobr.Fat.vOrig  := Cobr.Fat.vOrig + FinancialBills.Financial.Registro.Valor;;
        Cobr.Fat.vLiq   := Cobr.Fat.vLiq  + FinancialBills.Financial.Registro.Valor;;
        Cobr.Fat.vDesc  := 0;
      End;
    end;
  End;
end;

procedure TControllerNfe55Sale.GeraDanfeCOFINS(imposto: TImposto);
Var
  Lc_Ok : Boolean;
Begin
  WITH imposto  DO
  Begin
    // Define a Situação tributária do COFINS COM ISENTA PARA NA SEQUENCIA FOR SETADA AS VARIAVEIS SE HOUVER
    COFINS.CST := cof07;
    COFINS.vBC := 0;
    COFINS.pcofins := 0;
    COFINS.vCOFINS := 0;

    // valores do Cofins
    FInvoiceSale.Itens.Cofins.Registro.ItemOrdem       := FInvoiceSale.Itens.Registro.Codigo;
    FInvoiceSale.Itens.Cofins.Registro.Ordem           := FInvoiceSale.Itens.Registro.Ordem;
    FInvoiceSale.Itens.Cofins.Registro.Estabelecimento := FInvoiceSale.Itens.Registro.Estabelecimento;
    FInvoiceSale.Itens.Cofins.Registro.Terminal        := FInvoiceSale.Itens.Registro.Terminal;
    FInvoiceSale.Itens.Cofins.getByKey;
    if FInvoiceSale.Itens.Cofins.exist then
    begin
      // Define a Situação tributária do COFINS
      COFINS.CST := StrToCSTCOFINS(Lc_Ok, FInvoiceSale.Itens.Cofins.Registro.Cst);
      if (COFINS.CST = cof01) OR (COFINS.CST = cof02) then
      Begin
        COFINS.vBC := FInvoiceSale.Itens.Cofins.Registro.Base;
        COFINS.pcofins := FInvoiceSale.Itens.Cofins.Registro.Aliquota;
        COFINS.vCOFINS := FInvoiceSale.Itens.Cofins.Registro.Valor;
      end;
      if (COFINS.CST = cof03) then
      Begin
        COFINS.qBCProd := FInvoiceSale.Itens.Cofins.Registro.QuantVendas;
        COFINS.vAliqProd := FInvoiceSale.Itens.Cofins.Registro.QuantValorAliquota;
        COFINS.vCOFINS := FInvoiceSale.Itens.Cofins.Registro.Valor;
      end;
      if (COFINS.CST = cof99) then
      Begin
        if (FInvoiceSale.Itens.Cofins.Registro.Base > 0) then
        Begin
          COFINS.vBC := FInvoiceSale.Itens.Cofins.Registro.Base;
          COFINS.pcofins := FInvoiceSale.Itens.Cofins.Registro.Aliquota;
        end
        else
        Begin
          COFINS.qBCProd := FInvoiceSale.Itens.Cofins.Registro.QuantVendas;
          COFINS.vAliqProd := FInvoiceSale.Itens.Cofins.Registro.QuantValorAliquota;
        end;
        COFINS.vCOFINS := FInvoiceSale.Itens.Cofins.Registro.Valor;
      end
      else
      Begin
        COFINS.vBC := FInvoiceSale.Itens.Cofins.Registro.Base;
        COFINS.pcofins := FInvoiceSale.Itens.Cofins.Registro.Aliquota;
        COFINS.vCOFINS := FInvoiceSale.Itens.Cofins.Registro.Valor;
      End;
    end;
  End;
end;

procedure TControllerNfe55Sale.GeraDanfeCombustivel(itens: Tprod);
//Var
//  Lc_Ok : Boolean;
Begin
  {
  with itens,Qr_Combustivel do
  Begin
    Active := False;
    ParamByName('tb_order_items_id').AsInteger := Qr_Itens.FieldByName('ITF_CODIGO').AsInteger;
    Active := True;
    FetchAll;
    First;
    if recordcount > 0 then
    Begin
      //FieldByName('TB_ORDER_ITEMS_ID').AsInteger
      comb.cProdANP := FieldByName('CODIF').AsInteger;
      //comb.pMixGN
      comb.descANP := FieldByName('DESCRIPTION').AsString;

      comb.pGLP
      comb.pGNn
      comb.pGNi
      comb.vPart
      comb.CODIF

      comb.qTemp  := FieldByName('QTEMP').AsFloat;
      comb.UFcons := FieldByName('UFCONS').AsString;

      comb.CIDE.qBCProd
      comb.CIDE.vAliqProd
      comb.CIDE.vCIDE
      comb.ICMS.vBCICMS
      comb.ICMS.vICMS
      comb.ICMS.vBCICMSST
      comb.ICMS.vICMSST
      comb.ICMSInter.vBCICMSSTDest
      comb.ICMSInter.vICMSSTDest
      comb.ICMSCons.vBCICMSSTCons
      comb.ICMSCons.vICMSSTCons
      comb.ICMSCons.UFcons
      comb.encerrante.nBico
      comb.encerrante.nBomba
      comb.encerrante.nTanque
      comb.encerrante.vEncIni
      comb.encerrante.vEncFin

    end;
  End;
  }
end;


procedure TControllerNfe55Sale.GeraDanfeDes(dfdes: TDest);
Begin
  with dfdes do
  Begin
    if ( FInvoiceSale.Invoice.Registro.Destinatario  <> FCodigoConsumidor) then
    Begin
      if FInvoiceSale.Invoice.Destinatario.kindPerson = 'F' then
        CNPJCPF :=    FInvoiceSale.Invoice.Destinatario.Fisica.Registro.CPF
      else
        CNPJCPF :=    FInvoiceSale.Invoice.Destinatario.Juridica.Registro.CNPJ;

      xNome := Copy( FInvoiceSale.Invoice.Destinatario.Registro.NomeRazao , 1, 60);

      EnderDest.xLgr    := FInvoice.Destinatario.Endereco.Registro.Logradouro;
      EnderDest.nro     := FInvoice.Destinatario.Endereco.Registro.NumeroPredial;
      EnderDest.xCpl    := FInvoice.Destinatario.Endereco.Registro.Complemento;
      EnderDest.xBairro := FInvoice.Destinatario.Endereco.Registro.Bairro;
      EnderDest.CEP     := FInvoice.Destinatario.Endereco.Registro.Cep.ToInteger();
      EnderDest.cPais   := FInvoice.Destinatario.Endereco.Registro.CodigoPais;
      EnderDest.xPais   := FInvoice.Destinatario.Endereco.Pais.Registro.Nome;
      EnderDest.UF      := FInvoice.Destinatario.Endereco.Estado.Registro.Abreviatura;
      EnderDest.cMun    := FInvoice.Destinatario.Endereco.Cidade.Registro.IBGE.ToInteger();
      EnderDest.xMun    := FInvoice.Destinatario.Endereco.Cidade.Registro.Nome;

      EnderDest.fone    := MaskFone( FInvoice.Destinatario.Telefone.Registro.Numero );

      if ( FInvoice.Destinatario.Endereco.Registro.CodigoPais <> 1058) then
      Begin
        idEstrangeiro := FInvoice.Destinatario.Juridica.Registro.InscricaoEstadual;
      end;
    end;
    // Inscrição Estualdo Destinatario é apagada para verificação mais a frentes
    IE := '';

    case StrToIntdef(FInvoice.Destinatario.Juridica.Registro.IndicacaoIEDestinatario, 0) of
      0:Begin
          indIEDest := inContribuinte;
          IE := FInvoice.Destinatario.Juridica.Registro.InscricaoEstadual;
        end;
      1:Begin
          indIEDest := inIsento;
        End;
      2:Begin
          indIEDest := inNaoContribuinte;
        End
    else
      indIEDest := inIsento;
    end;
  End;
end;

procedure TControllerNfe55Sale.GeraDanfeEmi(dfemi: TEmit);
Var
  Lc_Aux : String;
  Lc_Ok : Boolean;
Begin
  with dfemi do
  Begin
    if FCtrlInstitution.Fiscal.kindPerson = 'F' then
      CNPJCPF           :=  FCtrlInstitution.Fiscal.Fisica.Registro.CPF
    else
      CNPJCPF           :=  FCtrlInstitution.Fiscal.Juridica.Registro.CNPJ;

    xNome             := Copy(  FCtrlInstitution.Fiscal.Registro.NomeRazao , 1, 60);
    xFant             := Copy(  FCtrlInstitution.Fiscal.Registro.ApelidoFantasia , 1, 60);
    EnderEmit.xLgr    := Copy(  FCtrlInstitution.Fiscal.Endereco.Registro.Logradouro , 1, 60);
    EnderEmit.nro     := FCtrlInstitution.Fiscal.Endereco.Registro.NumeroPredial;
    EnderEmit.xCpl    := FCtrlInstitution.Fiscal.Endereco.Registro.Complemento;
    EnderEmit.xBairro := FCtrlInstitution.Fiscal.Endereco.Registro.Bairro;
    EnderEmit.cMun    := FCtrlInstitution.Fiscal.Endereco.Cidade.Registro.IBGE.ToInteger;
    EnderEmit.xMun    := FCtrlInstitution.Fiscal.Endereco.Cidade.Registro.Nome;
    EnderEmit.UF      := FCtrlInstitution.Fiscal.Endereco.Estado.Registro.Abreviatura;
    EnderEmit.CEP     := FCtrlInstitution.Fiscal.Endereco.Registro.Cep.ToInteger;
    EnderEmit.cPais   := FCtrlInstitution.Fiscal.Endereco.Registro.CodigoPais;
    EnderEmit.xPais   := FCtrlInstitution.Fiscal.Endereco.Pais.Registro.Nome;
    EnderEmit.fone    := MaskFone( FCtrlInstitution.Fiscal.Telefone.Registro.Numero );
    // Inscrição estadual
    Lc_Aux            := FCtrlInstitution.Fiscal.Juridica.Registro.InscricaoEstadual ;
    Lc_Aux            := RemoveCaracterInformado(Lc_Aux, ['.', ',', '/', '-', ' ']);
    IE           := Lc_Aux;
    // Verifica se há valor de icms de substituição e se há registro de Inscrição de susbtituição exceto NFC-e
    // Verifica se é nota Conjugada

    CRT := StrToCRT(Lc_Ok, FCtrlInstitution.Fiscal.Juridica.Registro.CRT);
  End;

end;

procedure TControllerNfe55Sale.GeraDanfeFormaPagto;
Var
  Lc_Ok : Boolean;
  lcSaldoTroco : REal;
  I : Integer;
BEgin
  // Verifica se é uma NF de Saida
  with FNfe.NotasFiscais[0].Nfe do
  Begin
    //Definição padrão
    Ide.tpNF := tnEntrada;
    with pag.Add do
    begin
      indPag  := ipNenhum;
      tPag    := fpSemPagamento;
      vPag    := 0;
    end;
    Ide.tpNF := tnSaida;
    pag.Clear;

    FinancialBills.Registro.Ordem           := FInvoiceSale.Registro.Codigo;
    FinancialBills.Registro.Estabelecimento := FInvoiceSale.Registro.Estabelecimento;
    FinancialBills.Registro.Terminal        := FInvoiceSale.Registro.Terminal;
    FinancialBills.getlist;
    if FinancialBills.exist then
    Begin
      //lcSaldoTroco := ValorTroco;
      for I := 0 to FinancialBills.Lista.Count-1 do
      Begin
        FinancialBills.Financial.Registro.Ordem     := FinancialBills.Registro.Ordem;
        FinancialBills.Financial.Estabelecimento    := FinancialBills.Registro.Estabelecimento;
        FinancialBills.Financial.Terminal           := FinancialBills.Registro.Terminal;
        FinancialBills.Financial.getByKey;

        with pag.Add do // PAGAMENTOS apenas para NFC-e
        begin
          if (FinancialBills.Financial.Registro.DataVencimento =  FInvoiceSale.Invoice.Registro.Data_emissao) then
            indPag := ipVista
          else
            indPag := ipPrazo;
          FinancialBills.PaymentType.Registro.Codigo := FinancialBills.Financial.Registro.TipoPagamento;
          FinancialBills.PaymentType.getbyKey;
          tPag := StrToFormaPagamento(Lc_Ok, FinancialBills.PaymentType.Registro.CodigoNFCE);
          vPag := FinancialBills.Financial.Registro.Valor;
          tpIntegra := tiPagNaoIntegrado;
        end;
      end;
    End
    else
    Begin
      with pag.Add do
      begin
        indPag  := ipNenhum;
        tPag    := fpSemPagamento;
        vPag    := 0;
      end;
    End;
  End;
end;

procedure TControllerNfe55Sale.GeraDanfeICMS(imposto: TImposto);
Var
  Lc_Ok : Boolean;
Begin
  with imposto do
  BEgin
    // Origem da Mercadoria
    ICMS.orig := StrToOrig(Lc_Ok, FInvoiceSale.Itens.Icms.Registro.Origem);
    // Codigo de Regime Tributario 1/2 - Simples nacional e 3 Regime normal
    ICMS.CST := cstVazio;
    if (FCtrlInstitution.Fiscal.Juridica.Registro.CRT = '2') or (FCtrlInstitution.Fiscal.Juridica.Registro.CRT = '3') then
      GeraDanfeImpostoRegimeNormal(Imposto)
    else
      GeraDanfeImpostoSimplesNacional(Imposto);
  End;

end;

procedure TControllerNfe55Sale.GeraDanfeIde(dfide: TIde);
Var
  Lc_Time_Str: String;
  Lc_Ok : Boolean;
Begin
  with dfide do
  Begin

    natOp :=  FInvoiceSale.Itens.Icms.Registro.Cfop;

    nNF := FInvoiceSale.Invoice.Registro.Numero.ToInteger;

    cNF := FInvoiceSale.Invoice.Registro.Codigo;

    modelo := 55;

    serie := FInvoiceSale.Invoice.Registro.Serie.ToInteger;

    dEmi :=  FInvoiceSale.Invoice.Registro.Data_emissao;

    if FInvoiceSale.Registro.DataSaida > 0 then
    Begin
      dSaiEnt := FInvoiceSale.Registro.DataSaida;
      hSaiEnt := FInvoiceSale.Registro.DataSaida;
    end;

    verProc := '2.0.1.6';
    cMunFG  := FCtrlInstitution.Fiscal.Endereco.Cidade.Registro.IBGE.ToInteger;
    cUF     := FCtrlInstitution.Fiscal.Endereco.Registro.CodigoEstado;

    tpEmis := StrToTpEmis(Lc_Ok,  IntToStr(StrToIntdef(FConfig.ConfigNfe.Registro.TipoEmissao, 0) + 1));
    if (tpEmis <> teNormal) then
    BEgin
      dhCont := NOW;
      xJust := 'Serviço paralisado - Longo Prazo';
    end;


    // Indica operação com Consumidor final E B01 N 1-1 1 0=Não; 1=Consumidor final;

    IF (  FInvoiceSale.OrderSale.Customer.Registro.ConsumidorFinal = 'S')then
      indFinal := cfConsumidorFinal
    else
      indFinal := cfNao;

    case FInvoiceSale.Registro.IndicacaoPresenca of
      1:indPres := pcPresencial;
      2:indPres := pcInternet;
      3:indPres := pcTeleatendimento;
      4:indPres := pcEntregaDomicilio;
      5:indPres := pcPresencialForaEstabelecimento;
      6:indPres := pcOutros;
    else
      indPres := pcPresencial;
    end;

    indIntermed := iiOperacaoSemIntermediador;
    // 1=NF-e normal; 2=NF-e complementar; 3=NF-e de ajuste; 4=Devolução/Retorno.
    finNFe := fnNormal;

    // 1=Operação interna; 2=Operação interestadual; 3=Operação com exterior.
    if (  FInvoiceSale.Invoice.Destinatario.Endereco.Registro.CodigoPais = 1058) then
    Begin
      if ( FInvoiceSale.Invoice.Destinatario.Endereco.Registro.CodigoEstado = FCtrlInstitution.Fiscal.Endereco.Registro.CodigoEstado ) then
        idDest := doInterna
      else
        idDest := doInterestadual;
    end
    else
    Begin
      idDest := doExterior;
    end;
  End;
end;

procedure TControllerNfe55Sale.GeraDanfeII(imposto: TImposto);
Begin
  with imposto do
  BEgin
    FInvoiceSale.Itens.II.Registro.ItemOrdem       := FInvoiceSale.Itens.Registro.Codigo;
    FInvoiceSale.Itens.II.Registro.Ordem           := FInvoiceSale.Itens.Registro.Ordem;
    FInvoiceSale.Itens.II.Registro.Estabelecimento := FInvoiceSale.Itens.Registro.Estabelecimento;
    FInvoiceSale.Itens.II.Registro.Terminal        := FInvoiceSale.Itens.Registro.Terminal;
    FInvoiceSale.Itens.II.getByKey;
    if FInvoiceSale.Itens.II.exist then
    begin
      II.vBC      := FInvoiceSale.Itens.II.Registro.ValorBase;
      II.vDespAdu := FInvoiceSale.Itens.II.Registro.Despesas;
      II.vII      := FInvoiceSale.Itens.II.Registro.Valor;
      II.vIOF     := FInvoiceSale.Itens.II.Registro.ValorIOF;
    end;
  End;
end;

procedure TControllerNfe55Sale.GeraDanfeItens();
Var
  I : Integer;
BEgin
  for I := 0 to FInvoiceSale.Itens.Lista.Count -1 do
  begin
    FInvoiceSale.ClonarObj(FInvoiceSale.Itens.Lista[I],FInvoiceSale.Itens.registro);
    with FNfe.NotasFiscais[0].NFe do
    begin
      with Det.Add do
      Begin
        //Devolução do IPI
        GeraDanfeIPIDevolvido;
        //pega dos dados da mercadoria.
        FInvoiceSale.Itens.Mercadoria.Registro.Codigo          := FInvoiceSale.Itens.Registro.Produto;
        FInvoiceSale.Itens.Mercadoria.Registro.Estabelecimento := FInvoiceSale.Itens.Registro.Estabelecimento;
        FInvoiceSale.Itens.Mercadoria.getAllByKey;
        //Pega os dados do icms que é a base para todos os outros impostos
        FInvoiceSale.Itens.Icms.Registro.ItemOrdem        := FInvoiceSale.Itens.Registro.Codigo;
        FInvoiceSale.Itens.Icms.Registro.Ordem            := FInvoiceSale.Itens.Registro.Ordem;
        FInvoiceSale.Itens.Icms.Registro.Estabelecimento  := FInvoiceSale.Itens.Registro.Estabelecimento;
        FInvoiceSale.Itens.Icms.Registro.Terminal         := FInvoiceSale.Itens.Registro.Terminal;
        FInvoiceSale.Itens.Icms.getbyKey;

        GeraDanfeItensProdServ(Prod,I);
        //Informações Adicionais
        infAdProd := GeraDanfeProdInfoAdic(Prod,I);
        // ==========================  Tag da Declaração de Importação ==========================
        GeraDanfeImportacao(Prod);
        // ==========================  J - Detalhamento Específico de Veículos novos ==========================
        GeraDanfeVeiculosNovos(Prod);
        // ==========================  K - Detalhamento Específico de Medicamento e de matérias-primas farmacêuticas =========================

        // ==========================  L - Detalhamento Específico de Armamentos ==============================

        // ==========================  L1 - Detalhamento Específico de Combustíveis ===========================
        GeraDanfeCombustivel(Prod);

        // ==========================  M - Tributos incidentes no Produto ou Serviço ==========================
        //Imposto Aproximado
        GeraDanfeImpostoAproximado(Imposto);
        with Imposto do
        Begin
          if FInvoiceSale.Itens.Icms.exist then
          Begin
            // ========================== N - ICMS Normal e ST ==================================================

            GeraDanfeICMS(imposto);
            //Grupo de Partilha do ICMS
            GeraDanfePartilhaFCP(Emit,Ide,Dest,Prod,imposto);

            // ========================== O - Imposto sobre Produtos Industrializados ===========================
            GeraDanfeIPI(Imposto);
            // ========================== P - Imposto de Importação =============================================
            GeraDanfeII(Imposto);
            // ========================== Q – PIS ===============================================================
            GeraDanfePIS(Imposto);
            // ========================== R – PIS ST ============================================================

            // ========================== S – COFINS ============================================================
            GeraDanfeCOFINS(Imposto);
            // ========================== T - COFINS ST =========================================================

            // ========================== U - ISSQN =============================================================
            GeraDanfeISSQN(Imposto);
          end;
        end;
      end;
    end;
  end;

end;

procedure TControllerNfe55Sale.GeraDanfeImportacao(itens: Tprod);
//Var
//  Lc_Qry : TIBQuery;
//  Lc_Qry_Aux : TIBQuery;
//  LcBase : TControllerBase;
Begin
  {
  with itens do
  Begin
    Try
      LcBase := TcontrollerBase.create(nil);
      Lc_Qry_Aux := LcBase.GeraQuery;
      Lc_Qry := LcBase.GeraQuery;
      Lc_Qry.sql.Add(concat(
                      'Select  DIM_CODIGO,DIM_NUMERO, DIM_DIV, DIM_DATA,           ',
                      'DIM_LOCAL_DESEMB, UFE_SIGLA, DIM_DT_DESEMB, DIM_CODEXP      ',
                      'from TB_DEC_IMP                                             ',
                      '  inner join TB_UF                                          ',
                      '  ON (UFE_CODIGO = DIM_CODUFE)                              ',
                      'where DIM_CODITF = :DIM_CODITF                              '
                      ));
      Lc_Qry.ParamByName('DIM_CODITF').AsInteger :=  Qr_Itens.FieldByName('ITF_CODIGO').AsInteger;
      Lc_Qry.Active := True;
      Lc_Qry.FetchAll;
      Lc_Qry.First;
      if Lc_Qry.recordcount > 0 then
      Begin
        while not Lc_Qry.Eof do
        Begin
          with DI.Add do
          Begin
            nDi         := concat( Lc_Qry.FieldByName('DIM_NUMERO').AsString, '-',
                           Lc_Qry.FieldByName('DIM_DIV').AsString
                        );
            dDi         := Lc_Qry.FieldByName('DIM_DATA').AsDateTime;
            xLocDesemb  := Lc_Qry.FieldByName('DIM_LOCAL_DESEMB').AsString;
            dDesemb     := Lc_Qry.FieldByName('DIM_DT_DESEMB').AsDateTime;
            UFDesemb    := Lc_Qry.FieldByName('UFE_SIGLA').AsString;
            cExportador := Lc_Qry.FieldByName('DIM_CODEXP').AsString;
            // Incluir as adições para cada DI
            Lc_Qry_Aux.sql.Add(concat(
                              'Select ADC_NUMERO, ADC_SEQUENCIA, ADC_CODFAB,      ',
                              'ADC_VL_DESC, ADC_PEDCPA, ADC_ITMCPA                ',
                              'from TB_ADIC_IMP                                   ',
                              'where ADC_CODDIM = :ADC_CODDIM                     '
                            ));
            Lc_Qry_Aux.ParamByName('ADC_CODDIM').AsInteger := Lc_Qry.FieldByName('DIM_CODIGO').AsInteger;
            Lc_Qry_Aux.Active := True;
            Lc_Qry_Aux.FetchAll;
            Lc_Qry_Aux.First;
            while not Lc_Qry_Aux.Eof do
            Begin
              with adi.Add do
              Begin
                nAdicao     := Lc_Qry_Aux.FieldByName('ADC_NUMERO').AsInteger;
                nSeqAdi     := Lc_Qry_Aux.FieldByName('ADC_SEQUENCIA').AsInteger;
                cFabricante := Lc_Qry_Aux.FieldByName('ADC_CODFAB').AsString;
                vDescDI     := Lc_Qry_Aux.FieldByName('ADC_VL_DESC').asfloat;
              end;
              Lc_Qry_Aux.Next;
            end;
          end;
          Lc_Qry.Next;
        end;
      end;
    Finally
      LcBase.FinalizaQuery(Lc_Qry);
      LcBase.FinalizaQuery(Lc_Qry_Aux);
      LcBase.disposeOf;
    End;
  End;
  }
end;

procedure TControllerNfe55Sale.GeraDanfeImpostoAproximado(imposto: TImposto);
Var
  Lc_InformaTRibAprox: Boolean;
  Lc_Vl_BaseImpostoAprox: Real;
Begin
  with imposto do
  Begin
    Lc_InformaTRibAprox := true; //(Fc_Tb_Geral('L', 'GRL_G_IMPOSTO_APROX', 'S') = 'S');
    if Lc_InformaTRibAprox then
    Begin
      Lc_Vl_BaseImpostoAprox := ((
                                  FInvoiceSale.Itens.Registro.ValorUnitario *
                                  FInvoiceSale.Itens.Registro.Quantidade) -
                                  FInvoiceSale.Itens.Registro.ValorDesconto);
      Lc_Vl_BaseImpostoAprox := roundTo(Lc_Vl_BaseImpostoAprox,-2);
      vTotTrib := (Lc_Vl_BaseImpostoAprox * FInvoiceSale.Itens.Icms.Registro.ImpostoAproximado) / 100;
      vTotTrib := roundTo(vTotTrib, -2);
    End;
  End;
end;

procedure TControllerNfe55Sale.GeraDanfeImpostoRegimeNormal(imposto: TImposto);
Var
  Lc_Ok : boolean;
begin
  with imposto do
  Begin
    // Define o Cdigo de situação tributaria

    ICMS.CST      := StrToCSTICMS(Lc_Ok, FInvoiceSale.Itens.Icms.Registro.cst);
    //Retenção do ICMS ST
    ICMS.vBCSTRet         := FInvoiceSale.Itens.Icms.Registro.ValorBaseRetido;
    ICMS.pST              := FInvoiceSale.Itens.Icms.Registro.AliquotaST;
    ICMS.vICMSSubstituto  := FInvoiceSale.Itens.Icms.Registro.ValorST;
    ICMS.vICMSSTRet       := FInvoiceSale.Itens.Icms.Registro.ValorRetido;

    // Tributação do ICMS – 00 – Tributada integralmente
    if ICMS.CST = cst00 then
    Begin
      ICMS.modBC  := StrTomodBC(Lc_Ok,FInvoiceSale.Itens.Icms.Registro.DeterminacaoBase);
      ICMS.vBC    := FInvoiceSale.Itens.Icms.Registro.ValorBase;
      ICMS.pICMS  := FInvoiceSale.Itens.Icms.Registro.Aliquota;
      ICMS.pRedBC := FInvoiceSale.Itens.Icms.Registro.AliqReducaoBase;
      ICMS.vICMS  := FInvoiceSale.Itens.Icms.Registro.Valor;
    end;
    // Tributação do ICMS - 10 - Tributada e com cobrança do ICMS por substituição tributária
    if ICMS.CST = cst10 then
    Begin
      // ICMS Normal
      ICMS.modBC  := StrTomodBC(Lc_Ok,FInvoiceSale.Itens.Icms.Registro.DeterminacaoBase);
      ICMS.vBC    := FInvoiceSale.Itens.Icms.Registro.ValorBase;
      ICMS.pICMS  := FInvoiceSale.Itens.Icms.Registro.Aliquota;
      ICMS.pRedBC := FInvoiceSale.Itens.Icms.Registro.AliqReducaoBase;
      ICMS.vICMS  := FInvoiceSale.Itens.Icms.Registro.Valor;
      // ICMS Normal S.T
      ICMS.modBCST  := StrTomodBCST(Lc_Ok, FInvoiceSale.Itens.Icms.Registro.DeterminacaoBaseST);
      ICMS.pMVAST   := ( FInvoiceSale.Itens.Icms.Registro.MVA -1 ) *100;
      ICMS.pRedBCST := FInvoiceSale.Itens.Icms.Registro.AliqReducaoBaseST;
      ICMS.vBCST    := FInvoiceSale.Itens.Icms.Registro.ValorBaseST;
      ICMS.pICMSST  := FInvoiceSale.Itens.Icms.Registro.AliquotaST;
      ICMS.vICMSST  := FInvoiceSale.Itens.Icms.Registro.ValorST;
    end;
    // Tributação do ICMS – 20 - Com redução de base de cálculo
    if ICMS.CST = cst20 then
    Begin
      ICMS.modBC  := StrTomodBC(Lc_Ok,FInvoiceSale.Itens.Icms.Registro.DeterminacaoBase);
      ICMS.vBC    := FInvoiceSale.Itens.Icms.Registro.ValorBase;
      ICMS.pICMS  := FInvoiceSale.Itens.Icms.Registro.Aliquota;
      ICMS.pRedBC := FInvoiceSale.Itens.Icms.Registro.AliqReducaoBase;
      ICMS.vICMS  := FInvoiceSale.Itens.Icms.Registro.Valor;
    end;
    // Tributação do ICMS – 30 - Isenta ou não tributada e com cobrança do ICMS por substituição tributária
    if ICMS.CST = cst30 then
    Begin
      // ICMS Normal S.T
      ICMS.modBCST  := StrTomodBCST(Lc_Ok, FInvoiceSale.Itens.Icms.Registro.DeterminacaoBaseST);
      ICMS.pMVAST   := ( FInvoiceSale.Itens.Icms.Registro.MVA -1 ) *100;
      ICMS.pRedBCST := FInvoiceSale.Itens.Icms.Registro.AliqReducaoBaseST;
      ICMS.vBCST    := FInvoiceSale.Itens.Icms.Registro.ValorBaseST;
      ICMS.pICMSST  := FInvoiceSale.Itens.Icms.Registro.AliquotaST;
      ICMS.vICMSST  := FInvoiceSale.Itens.Icms.Registro.ValorST;
    end;
    // Tributação do ICMS – 40 - Isenta 41 - Não tributada 50 - Suspensão
    if (ICMS.CST = cst40) or (ICMS.CST = cst41) or (ICMS.CST = cst50)
    then
    Begin
      if FInvoiceSale.Itens.Icms.Registro.Desoneracao > 0 then
      Begin
        ICMS.vICMS      := FInvoiceSale.Itens.Icms.Registro.Valor;
        ICMS.motDesICMS := StrTomotDesICMS(Lc_Ok, FInvoiceSale.Itens.Icms.Registro.Desoneracao.ToString);
      end;
    end;
    // Tributação do ICMS – 51 - Diferimento  A exigência do preenchimento das informações do ICMS diferido fica a critério de cada UF.
    if ICMS.CST = cst51 then
    Begin
      // ICMS Normal
      ICMS.modBC    := StrTomodBC(Lc_Ok,FInvoiceSale.Itens.Icms.Registro.DeterminacaoBase);
      ICMS.vBC      := FInvoiceSale.Itens.Icms.Registro.ValorBase;
      ICMS.pICMS    := FInvoiceSale.Itens.Icms.Registro.Aliquota;
      ICMS.vICMSOp  := ICMS.vBC * ( ICMS.pICMS  / 100);
      ICMS.vICMSOp  := RoundTo( ICMS.vICMSOp ,-2);
      ICMS.pDif     := FInvoiceSale.Itens.Icms.Registro.AliqReducaoBase;
      icms.vICMSDif := ICMS.vICMSOp * (ICMS.pDif / 100);
      icms.vICMSDif := RoundTo( icms.vICMSDif ,-2);
      ICMS.vICMS    := ICMS.vBC * ( ICMS.pICMS  / 100);
      ICMS.vICMS    := RoundTo( ICMS.vICMS,-2);
      ICMS.vICMS    := ICMS.vICMS - icms.vICMSDif;
      ICMS.vICMS    := RoundTo( ICMS.vICMS ,-2);
      icms.vICMSSTRet := 0;
     end;
    // Tributação do ICMS – 60 - ICMS cobrado anteriormente por substituição tributária
    if ICMS.CST = cst60 then
    Begin
      ICMS.vBCSTRet := 0;
      ICMS.vICMSSTRet := 0;
          //desenvolvido em 07/05 e em 08/05 a receita revogou a liberação
          //ver implementação na tributação bloco onde verifica se existe tributação
          //ICMS.orig já preenchido em outro local
          FCtrlICMSST.Registro.Estabelecimento := FInvoiceSale.Itens.Icms.Registro.Estabelecimento;
          FCtrlICMSST.Registro.Destino :=  FInvoiceSale.Itens.Icms.Registro.ItemOrdem;
          FCtrlICMSST.GetByDestino;
          if FCtrlICMSST.exist then
          Begin
            ICMS.vBCSTRet         := FCtrlICMSST.Registro.ValorBaseSTRetido;
            ICMS.pST              := FCtrlICMSST.Registro.AliqST;
            ICMS.vICMSSubstituto  := FCtrlICMSST.Registro.ValorICMSSubstituto;
            ICMS.vICMSSTRet       := FCtrlICMSST.Registro.ValorICMSSTRetido;
          End;

    end;
    // Tributação do ICMS - 70 - Com redução de base de cálculo e  cobrança do ICMS por substituição tributária
    if ICMS.CST = cst70 then
    Begin
      // ICMS Normal
      ICMS.modBC    := StrTomodBC(Lc_Ok, FInvoiceSale.Itens.Icms.Registro.DeterminacaoBase);
      ICMS.pRedBC   := FInvoiceSale.Itens.Icms.Registro.AliqReducaoBase;
      ICMS.vBC      := FInvoiceSale.Itens.Icms.Registro.ValorBase;
      ICMS.pICMS    := FInvoiceSale.Itens.Icms.Registro.Aliquota;
      ICMS.pRedBC   := FInvoiceSale.Itens.Icms.Registro.AliqReducaoBase;
      ICMS.vICMS    := FInvoiceSale.Itens.Icms.Registro.Valor;
      // ICMS Normal S.T
      ICMS.modBCST  := StrTomodBCST(Lc_Ok, FInvoiceSale.Itens.Icms.Registro.DeterminacaoBaseST);
      ICMS.pMVAST   := ( FInvoiceSale.Itens.Icms.Registro.MVA -1 ) *100;
      ICMS.pRedBCST := FInvoiceSale.Itens.Icms.Registro.AliqReducaoBaseST;
      ICMS.vBCST    := FInvoiceSale.Itens.Icms.Registro.ValorBaseST;
      ICMS.pICMSST  := FInvoiceSale.Itens.Icms.Registro.AliquotaST;
      ICMS.vICMSST  := FInvoiceSale.Itens.Icms.Registro.ValorST;
    end;
    // Tributação do ICMS - 90 – Outros
    if ICMS.CST = cst90 then
    Begin
      // ICMS Normal
      ICMS.modBC    := StrTomodBC(Lc_Ok, FInvoiceSale.Itens.Icms.Registro.DeterminacaoBase);
      ICMS.pRedBC   := FInvoiceSale.Itens.Icms.Registro.AliqReducaoBase;
      ICMS.vBC      := FInvoiceSale.Itens.Icms.Registro.ValorBase;
      ICMS.pICMS    := FInvoiceSale.Itens.Icms.Registro.Aliquota;
      ICMS.pRedBC   := FInvoiceSale.Itens.Icms.Registro.AliqReducaoBase;
      ICMS.vICMS    := FInvoiceSale.Itens.Icms.Registro.Valor;
      // ICMS Normal S.T
      ICMS.modBCST  := StrTomodBCST(Lc_Ok, FInvoiceSale.Itens.Icms.Registro.DeterminacaoBaseST);
      ICMS.pMVAST   := ( FInvoiceSale.Itens.Icms.Registro.MVA -1 ) *100;
      ICMS.pRedBCST := FInvoiceSale.Itens.Icms.Registro.AliqReducaoBaseST;
      ICMS.vBCST    := FInvoiceSale.Itens.Icms.Registro.ValorBaseST;
      ICMS.pICMSST  := FInvoiceSale.Itens.Icms.Registro.AliquotaST;
      ICMS.vICMSST  := FInvoiceSale.Itens.Icms.Registro.ValorST;
    end;
  End;

end;

procedure TControllerNfe55Sale.GeraDanfeImpostoSimplesNacional(
  imposto: TImposto);
Var
  Lc_Ok : Boolean;
  procedure ZeraValoresICMS;
  Begin
    with  Imposto do
    Begin
      ICMS.vBC      := 0;
      ICMS.pICMS    := 0;
      ICMS.pRedBC   := 0;
      ICMS.vICMS    := 0;
    End;
  End;
  procedure ZeraValoresST;
  Begin
    with  Imposto do
    Begin
      ICMS.pMVAST   := 0;
      ICMS.pRedBCST := 0;
      ICMS.vBCST    := 0;
      ICMS.pICMSST  := 0;
      ICMS.vICMSST  := 0;
      ICMS.vBCSTRet := 0;
      ICMS.vICMSSTRet := 0;
    End;
  End;
Begin
  with imposto do
  Begin
    // ICMS Normal
    ICMS.modBC  := StrTomodBC(Lc_Ok,FInvoiceSale.Itens.Icms.Registro.DeterminacaoBase);
    ICMS.vBC    := FInvoiceSale.Itens.Icms.Registro.ValorBase;
    ICMS.pICMS  := FInvoiceSale.Itens.Icms.Registro.Aliquota;
    ICMS.pRedBC := FInvoiceSale.Itens.Icms.Registro.AliqReducaoBase;
    ICMS.vICMS  := FInvoiceSale.Itens.Icms.Registro.Valor;
    // ICMS Normal S.T
    ICMS.modBCST  := StrTomodBCST(Lc_Ok, FInvoiceSale.Itens.Icms.Registro.DeterminacaoBaseST);
    ICMS.pMVAST   := ( FInvoiceSale.Itens.Icms.Registro.MVA -1 ) *100;
    ICMS.pRedBCST := FInvoiceSale.Itens.Icms.Registro.AliqReducaoBaseST;
    ICMS.vBCST    := FInvoiceSale.Itens.Icms.Registro.ValorBaseST;
    ICMS.pICMSST  := FInvoiceSale.Itens.Icms.Registro.AliquotaST;
    ICMS.vICMSST  := FInvoiceSale.Itens.Icms.Registro.ValorST;
    ICMS.pCredSN := roundTo( FInvoiceSale.Itens.Icms.Registro.Aliquota_CalcCred, -2);
    //Retenção do ICMS ST
    ICMS.vBCSTRet         := 0;
    ICMS.pST              := 0;
    ICMS.vICMSSubstituto  := 0;
    ICMS.vICMSSTRet       := 0;

    // Alíquota aplicável de cálculo do crédito (Simples Nacional).
    //ICMS.vCredICMSSN :=roundTo( FInvoiceSale.Itens.Icms.Registro.Valor_CredExpl, -2); VEriricar
    // Valor crédito do ICMS que pode ser aproveitado nos termos do art. 23 da LC 123 (Simples Nacional)

    // Verifica se há tributação pelo Simples Nacional
    ICMS.CSOSN := StrToCSOSNIcms(Lc_Ok,FInvoiceSale.Itens.Icms.Registro.cst);
    // Tributação do ICMS pelo SIMPLES NACIONAL e CSOSN=101 (v.2.0)
    if (ICMS.CSOSN = csosn101) then
    Begin
      ZeraValoresST;
      exit;
    end;
    // Tributação do ICMS pelo SIMPLES NACIONAL e CSOSN=102, 103, 300
    if (ICMS.CSOSN = csosn102) or (ICMS.CSOSN = csosn103) or
      (ICMS.CSOSN = csosn300)  then
    Begin
      ZeraValoresST;
      //credito ICMS
      ICMS.pCredSN     := 0;
      ICMS.vCredICMSSN := 0;
      exit;
    end;
    // Tributação do ICMS pelo SIMPLES NACIONAL e 400
    if (ICMS.CSOSN = csosn400) then
    Begin
      ZeraValoresST;
      //credito ICMS
      ICMS.pCredSN     := 0;
      ICMS.vCredICMSSN := 0;
      exit;
    end;


    // 201- Tributada pelo Simples Nacional com permissão de crédito e com cobrança do ICMS por Substituição Tributária v.2.0)
    if (ICMS.CSOSN = csosn201) then
    Begin
      //ICMS Normal S.T já calculada no inicio do processo
      //ICMS Normal - Zera os valores depois de feito o calculo
      ZeraValoresICMS;
      exit;
    end;
    // 202- Tributada pelo Simples Nacional sem permissão de  crédito e com cobrança do ICMS por Substituição Tributária
    // 203- Isenção do ICMS nos Simples Nacional para faixa de receita bruta e com cobrança do ICMS por Substituição Tributária  (v.2.0)
    if (ICMS.CSOSN = csosn202) OR (ICMS.CSOSN = csosn203) then
    Begin
      //ICMS Normal S.T já calculada no inicio do processo
      //ICMS Normal - Zera os valores depois de feito o calculo
      ZeraValoresICMS;
      //credito ICMS
      ICMS.pCredSN     := 0;
      ICMS.vCredICMSSN := 0;
      exit;
    end;
    // 500 – ICMS cobrado anteriormente por substituição tributária (substituído) ou por antecipação (v.2.0)
    if (ICMS.CSOSN = csosn500) then
    Begin
      ZeraValoresST;
              //desenvolvido em 07/05 e em 08/05 a receita revogou a liberação
              //ver implementação na tributação bloco onde verifica se existe tributação
              //ICMS.orig já preenchido em outro local
              FCtrlICMSST.Registro.Estabelecimento := FInvoiceSale.Itens.Icms.Registro.Estabelecimento;
              FCtrlICMSST.Registro.Destino :=  FInvoiceSale.Itens.Icms.Registro.ItemOrdem;
              FCtrlICMSST.GetByDestino;
              if FCtrlICMSST.exist then
              Begin
                ICMS.vBCSTRet         := FCtrlICMSST.Registro.ValorBaseSTRetido;
                ICMS.pST              := FCtrlICMSST.Registro.AliqST;
                ICMS.vICMSSubstituto  := FCtrlICMSST.Registro.ValorICMSSubstituto;
                ICMS.vICMSSTRet       := FCtrlICMSST.Registro.ValorICMSSTRetido;
              end;
      exit;
    end;
    // Tributação do ICMS pelo SIMPLES NACIONAL e CSOSN=900 (v2.0)
    if (ICMS.CSOSN = csosn900) then
    Begin
      exit;
    end;
  End;

end;

procedure TControllerNfe55Sale.GeraDanfeInfAdicContribuinte;
Var
  Lc_Obs: TStrings;
  I,J : Integer;
Begin
  //Não aplicar o disposeof quando o create for SElf
  Lc_Obs :=  TStrings.Create;
  with FNfe.NotasFiscais[0].Nfe do
  Begin
    // Informaçoes de Interesse do Financeiro
    FInvoiceSale.Invoice.Observacao.Registro.Estabelecimento  := FInvoiceSale.Registro.Estabelecimento;
    FInvoiceSale.Invoice.Observacao.Registro.NotaFiscal       := FInvoiceSale.Registro.Codigo;
    FInvoiceSale.Invoice.Observacao.Registro.Terminal         := FInvoiceSale.Registro.Terminal;
    FInvoiceSale.Invoice.Observacao.Registro.Tipo             := 'A';
    FInvoiceSale.Invoice.Observacao.getlist;
    InfAdic.infCpl := '';

    for I := 0 to FInvoiceSale.Invoice.Observacao.Lista.Count -1 do
    Begin
      Lc_Obs.Clear;
      Lc_Obs.text := FInvoiceSale.Invoice.Observacao.Lista[I].Observacao;
      for J := 0 to Lc_Obs.Count - 1 do
      Begin
        if (J = 0) then
          InfAdic.infCpl := Lc_Obs[J]
        else
          InfAdic.infCpl := concat(InfAdic.infCpl,' | ',Lc_Obs[J]);
      End;
      //Retira os ; do texto
      InfAdic.infCpl := RemoveCaracterInformado(InfAdic.infCpl, [';']);
    end;

    // Informaçoes de Interesse do Contribuinte
    FInvoiceSale.Invoice.Observacao.Registro.Estabelecimento  := FInvoiceSale.Registro.Estabelecimento;
    FInvoiceSale.Invoice.Observacao.Registro.NotaFiscal       := FInvoiceSale.Registro.Codigo;
    FInvoiceSale.Invoice.Observacao.Registro.Terminal         := FInvoiceSale.Registro.Terminal;
    FInvoiceSale.Invoice.Observacao.Registro.Tipo             := 'M';
    FInvoiceSale.Invoice.Observacao.getlist;
    for I := 0 to FInvoiceSale.Invoice.Observacao.Lista.Count -1 do
    Begin
      Lc_Obs.Clear;
      Lc_Obs.text := FInvoiceSale.Invoice.Observacao.Lista[I].Observacao;
      for J := 0 to Lc_Obs.Count - 1 do
      Begin
        if InfAdic.infCpl = '' then
          InfAdic.infCpl := Lc_Obs[J]
        else
          InfAdic.infCpl := concat(InfAdic.infCpl, ' | ', Lc_Obs[J])
      End;
      //Retira os ; do texto
      InfAdic.infCpl := RemoveCaracterInformado(InfAdic.infCpl, [';']);
    End;

    // Informaçoes de Intersse do Fisco
    FInvoiceSale.Invoice.Observacao.Registro.Estabelecimento  := FInvoiceSale.Registro.Estabelecimento;
    FInvoiceSale.Invoice.Observacao.Registro.NotaFiscal       := FInvoiceSale.Registro.Codigo;
    FInvoiceSale.Invoice.Observacao.Registro.Terminal         := FInvoiceSale.Registro.Terminal;
    FInvoiceSale.Invoice.Observacao.Registro.Tipo             := 'F';
    FInvoiceSale.Invoice.Observacao.getlist;
    InfAdic.infAdFisco := '';
    for I := 0 to FInvoiceSale.Invoice.Observacao.Lista.Count -1 do
    Begin
      InfAdic.infAdFisco := concat(
                                InfAdic.infAdFisco ,
                                FInvoiceSale.Invoice.Observacao.Lista[I].Observacao
                            );
    end;
    //Totais do fundo de combate a pobreza
    if Total.ICMSTot.vFCP > 0 then
    BEgin
      InfAdic.infAdFisco := concat(
                                InfAdic.infAdFisco ,
                                'Total de FCP : ', FloatToStrF(Total.ICMSTot.vFCP,ffFixed,10,2)
                            );
    End;
    InfAdic.infAdFisco := RemoveCaracterInformado(InfAdic.infAdFisco, [';']);
  End;
end;

procedure TControllerNfe55Sale.GeraDanfeInfAdicFisco;
Var
  I,J : Integer;
Begin
  with FNfe.NotasFiscais[0].Nfe do
  Begin
    // Informaçoes de Intersse do Fisco
    FInvoiceSale.Invoice.Observacao.Registro.Estabelecimento  := FInvoiceSale.Registro.Estabelecimento;
    FInvoiceSale.Invoice.Observacao.Registro.NotaFiscal       := FInvoiceSale.Registro.Codigo;
    FInvoiceSale.Invoice.Observacao.Registro.Terminal         := FInvoiceSale.Registro.Terminal;
    FInvoiceSale.Invoice.Observacao.Registro.Tipo             := 'F';
    FInvoiceSale.Invoice.Observacao.getlist;
    InfAdic.infAdFisco := '';
    for I := 0 to FInvoiceSale.Invoice.Observacao.Lista.Count -1 do
    Begin
      InfAdic.infAdFisco := concat(
                                InfAdic.infAdFisco ,
                                FInvoiceSale.Invoice.Observacao.Lista[I].Observacao
                            );
    end;
    //Totais do fundo de combate a pobreza
    if Total.ICMSTot.vFCP > 0 then
    BEgin
      InfAdic.infAdFisco := concat(
                                InfAdic.infAdFisco ,
                                'Total de FCP : ', FloatToStrF(Total.ICMSTot.vFCP,ffFixed,10,2)
                            );
    End;
    InfAdic.infAdFisco := RemoveCaracterInformado(InfAdic.infAdFisco, [';']);
  End;
end;

procedure TControllerNfe55Sale.GeraDanfeIPI(imposto: TImposto);
Var
  Lc_Ok : Boolean;
Begin
  with imposto do
  Begin
    // Define a Situação tributária do IPI COM ISENTA PARA NA SEQUENCIA FOR SETADA AS VARIAVEIS SE HOUVER
    FInvoiceSale.Itens.Ipi.Registro.ItemOrdem       := FInvoiceSale.Itens.Registro.Codigo;
    FInvoiceSale.Itens.Ipi.Registro.Ordem           := FInvoiceSale.Itens.Registro.Ordem;
    FInvoiceSale.Itens.Ipi.Registro.Estabelecimento := FInvoiceSale.Itens.Registro.Estabelecimento;
    FInvoiceSale.Itens.Ipi.Registro.Terminal        := FInvoiceSale.Itens.Registro.Terminal;
    FInvoiceSale.Itens.Ipi.getByKey;
    if FInvoiceSale.Itens.Ipi.exist then
    begin
      // Define a Situação Tributaria do IPI
      IPI.CST := StrToCSTIPI(Lc_Ok, FInvoiceSale.Itens.Ipi.Registro.CST);
      IPI.cEnq := '109';

      // Tabela a ser criada pela RFB, informar 999 enquanto a tabela não for criada
      if (IPI.CST = ipi00) or (IPI.CST = ipi49) or (IPI.CST = ipi50) or(IPI.CST = ipi99) then
      Begin
        if (FInvoiceSale.Itens.Ipi.Registro.Aliquota > 0) then
        Begin
          IPI.vBC   := FInvoiceSale.Itens.Ipi.Registro.Base;
          IPI.pIPI  := FInvoiceSale.Itens.Ipi.Registro.Aliquota;
          IPI.vIPI  := FInvoiceSale.Itens.Ipi.Registro.Valor;
          /// IPI.vBC * (IPI.pIPI/100);
        end
        else
        Begin
          IPI.qUnid := FInvoiceSale.Itens.Ipi.Registro.QuantUnidade;
          IPI.vUnid := FInvoiceSale.Itens.Ipi.Registro.Valor;
        end;
      END;
    end;
  End;

end;

procedure TControllerNfe55Sale.GeraDanfeIPIDevolvido;
VAr
  LcItem : Integer;
Begin
  FInvoiceSale.Itens.IpiBack.Registro.ItemOrdem       := FInvoiceSale.Itens.Registro.Codigo;
  FInvoiceSale.Itens.IpiBack.Registro.Ordem           := FInvoiceSale.Itens.Registro.Ordem;
  FInvoiceSale.Itens.IpiBack.Registro.Estabelecimento := FInvoiceSale.Itens.Registro.Estabelecimento;
  FInvoiceSale.Itens.IpiBack.Registro.Terminal        := FInvoiceSale.Itens.Registro.Terminal;
  FInvoiceSale.Itens.IpiBack.getByKey;
  if FInvoiceSale.Itens.IpiBack.exist then
  begin
    LcItem := FNfe.NotasFiscais[0].NFe.Det.Count - 1;
    with FNfe.NotasFiscais[0].NFe.Det.Items[LcItem] do
    BEgin
      pDevol    := FInvoiceSale.Itens.IpiBack.Registro.Percentual;
      vIPIDevol := FInvoiceSale.Itens.IpiBack.Registro.Valor;
    End;
  End;

end;

procedure TControllerNfe55Sale.GeraDanfeISSQN(imposto: TImposto);
Var
  Lc_Ok : Boolean;
Begin
  {
  WITH imposto,Qr_Pis  DO
  Begin
    if It_Nf_Conjugada then
    Begin
      // valores do ISSQN
      Qr_Issqn.Close;
      Qr_Issqn.ParamByName('ITF_CODIGO').AsInteger := Qr_Itens.FieldByName('ITF_CODIGO').AsInteger;
      Qr_Issqn.Active := True;
      Qr_Issqn.FetchAll;
      Qr_Issqn.First;
      Imposto.ISSQN.cSitTrib := ISSQNcSitTribVazio;
      if not Qr_Issqn.IsEmpty then
      begin
        Imposto.ISSQN.vBC := Qr_Issqn.FieldByName('ISS_VL_BC').asfloat;
        Imposto.ISSQN.vDeducao := Qr_Itens.FieldByName('ITF_VL_DESC').asfloat;
        Imposto.ISSQN.vAliq := Qr_Issqn.FieldByName('ISS_AQ_NR').asfloat;
        Imposto.ISSQN.vISSQN := Qr_Issqn.FieldByName('ISS_VL_NR').asfloat;
        Imposto.ISSQN.cMunFG := Qr_Issqn.FieldByName('ISS_MUN_IBGE').AsInteger;
        Imposto.ISSQN.cListServ := Qr_Issqn.FieldByName('ISS_LST_SRV').AsString;
        Imposto.ISSQN.vISSRet := Qr_Issqn.FieldByName('ISS_VL_RET').asfloat;
        if Imposto.ISSQN.vISSRet > 0 then
          ISSQN.indISSRet := StrToindISSRet(Lc_Ok, '1')
        else
          ISSQN.indISSRet := StrToindISSRet(Lc_Ok, '2');
        ISSQN.indISS := StrToindISS(Lc_Ok,IntToStr(StrToIntdef(Qr_Nota.FieldByName('CLI_ISS_EXIGIB').AsString, 0) + 1));
        ISSQN.cServico := Qr_Itens.FieldByName('ITF_CODPRO').AsString;
        ISSQN.cMunFG := Qr_Nota.FieldByName('CDD_IBGE').AsInteger;

        ISSQN.cPais := Qr_Nota.FieldByName('END_PAIS').AsInteger;

        ISSQN.nProcesso := Qr_Nota.FieldByName('CLI_ISS_NR_PROCESSO').AsString;

        if (Qr_Nota.FieldByName('CLI_ISS_IND_INC_FISCAL').AsString = 'S') then
          ISSQN.indIncentivo := StrToindIncentivo(Lc_Ok, '1')
        else
          ISSQN.indIncentivo := StrToindIncentivo(Lc_Ok, '2');
      end;
    end;

  End;
  }
end;


procedure TControllerNfe55Sale.GeraDanfeItensProdServ(itens: Tprod;
  Item: Integer);
VAr
  Lc_Aux : String;
  Lc_Ok : Boolean;
  Lc_Valor : Real;
Begin
  with itens  do
  Begin
    nItem := Item + 1; // Número do item (1-990)

    CFOP :=  FInvoiceSale.Itens.Icms.Registro.Cfop;
    cProd := FInvoiceSale.Itens.Mercadoria.Registro.Codigo.ToString;

    FInvoiceSale.Itens.Avulso.Registro.Codigo           := FInvoiceSale.Itens.Registro.Codigo;
    FInvoiceSale.Itens.Avulso.Registro.Estabelecimento  := FInvoiceSale.Itens.Registro.Estabelecimento;
    FInvoiceSale.Itens.Avulso.Registro.Ordem            := FInvoiceSale.Itens.Registro.Ordem;
    FInvoiceSale.Itens.Avulso.Registro.Terminal         := FInvoiceSale.Itens.Registro.Terminal;
    FInvoiceSale.Itens.Avulso.getByKey;

    if Length(Trim( FInvoiceSale.Itens.Avulso.Registro.Descricao )) > 0 then
      xProd := FInvoiceSale.Itens.Avulso.Registro.Descricao
    else
      xProd := FInvoiceSale.Itens.Mercadoria.Produto.Registro.Descricao;

    Lc_Aux := FInvoiceSale.Itens.Mercadoria.Registro.NCM;
    Lc_Aux := RemoveCaracterInformado(Lc_Aux, ['.', ',', '/', '-']);
    NCM := Lc_Aux;
    if (Length(Trim( FInvoiceSale.Itens.Mercadoria.Estoque.Registro.CodigoBarra))  < 6) then
    Begin
        cEAN     := 'SEM GTIN';
        cEANTrib := 'SEM GTIN';
    end;

    // Campo CEST - Código Especificador da Substituição Tributária
    if (Trim( FInvoiceSale.Itens.Mercadoria.Registro.CEST) <> '') then
      CEST := FInvoiceSale.Itens.Mercadoria.Registro.CEST;

    // Unidade Comercial
    uCom := FInvoiceSale.Itens.Mercadoria.Estoque.Medida.Registro.Abreviatura;

    // Quantidade Comercial
    qCom := FInvoiceSale.Itens.Registro.Quantidade;
    // Valor Unitário de comercialização
    vUnCom := FInvoiceSale.Itens.Registro.ValorUnitario;
    // Valor Total Bruto dos Produtos ou
    Lc_Valor := FInvoiceSale.Itens.Registro.ValorUnitario * FInvoiceSale.Itens.Registro.Quantidade;
    Lc_Valor := RoundTo( Lc_Valor ,-2);

    vProd :=  StrToFloatDef(FloatToStrF( Lc_Valor, ffFixed, 10, 2),0);

    if ( false )  then
    Begin
      {
      // Unidade Tributável
      uTrib := getUnidadeTributavel(StrToIntDef( FieldByName('PRO_CODMED_TRIB').AsString,1));
      // Quantidade Tributável
      qTrib := FieldByName('ITF_QTDE').asfloat * FieldByName('PRO_QTDE_TRIB').asfloat;
      // Valor Unitário de tributação
      vUnTrib := FieldByName('ITF_VL_UNIT').asfloat / FieldByName('PRO_QTDE_TRIB').asfloat;
      }
    End
    else
    Begin
      // Unidade Tributável
      uTrib := FInvoiceSale.Itens.Mercadoria.Estoque.Medida.Registro.Abreviatura;
      // Quantidade Tributável
      qTrib := FInvoiceSale.Itens.Registro.Quantidade;
      // Valor Unitário de tributação
      vUnTrib := FInvoiceSale.Itens.Registro.ValorUnitario;
    End;
    vDesc := FInvoiceSale.Itens.Registro.ValorDesconto;
    // Valor do Desconto
    vFrete := FInvoiceSale.Itens.icms.Registro.ValorFrete;
    vSeg := FInvoiceSale.Itens.icms.Registro.ValorSeguro;
    vOutro := FInvoiceSale.Itens.icms.Registro.ValorDespesas;
    //a tipagem no desktop foi trocado pela herança quando for tratar serviço deve revisar aqui
    IF 'P' = 'S' then
      IndTot := StrToindTot(Lc_Ok, '0')
    else
      IndTot := StrToindTot(Lc_Ok, '1');

    indEscala := StrToIndEscala(lc_ok, FInvoiceSale.Itens.Mercadoria.Registro.ProduzidoEscalaRelevante);
    //Escala Relevante de produção
    if indEscala = ieNaoRelevante then
    Begin
      //CNPJFab := FBrand.GetCNPJFactory(FInvoiceSale.Itens.Mercadoria.Registro.Marca);
    End;
    //Codigo de Beneficio
    FBenefits.clear;
    FBenefits.Registro.Estabelecimento  := FInvoiceSale.Itens.Mercadoria.Registro.Estabelecimento;
    FBenefits.Registro.Produto          := FInvoiceSale.Itens.Mercadoria.Registro.Codigo;;
    FBenefits.Registro.estado           := FCtrlInstitution.Fiscal.Endereco.Estado.Registro.Abreviatura;
    FBenefits.Registro.CST              := FInvoiceSale.Itens.Icms.Registro.cst;
    FBenefits.getbyId;
    if FBenefits.exist then
      cBenef  := FBenefits.Registro.Beneficio
    else
      cBenef  := 'SEM CBENEF';
  End;
end;

procedure TControllerNfe55Sale.GeraDanfePartilhaFCP(Emit: TEmit; Ide: TIde;
  Dest: TDest; Prod: TProd; imposto: TImposto);
Var
  Lc_Aq_Icms_Partilha : Real;
Begin
  with imposto do
  BEgin
    // NA. Item / ICMS para a UF de Destino
    if ( Ide.modelo     =   55)                 and
       ( Ide.tpNF       =   tnSaida)            and
       ( Ide.idDest     =   doInterestadual)    and
       ( Ide.indFinal   =   cfConsumidorFinal)  and
       ( Dest.indIEDest =   inNaoContribuinte)  and
       ( Ide.finNFe     <>  fnDevolucao)       then
    Begin
      // Valor da BC do ICMS na UF de destino
      ICMSUFDest.vBCUFDest := ICMS.vBC;
      //Aliquota Interestadual origem para destino que vem da Regra...
      ICMSUFDest.pICMSInter := ICMS.pICMS;
      // Alíquota interna da UF de destino
      FInvoiceSale.Invoice.Destinatario.Endereco.Estado.MVA.Registro.Estado := FCtrlInstitution.Fiscal.Endereco.Estado.Registro.Codigo;
      FInvoiceSale.Invoice.Destinatario.Endereco.Estado.MVA.Registro.NCM := FInvoiceSale.Itens.Mercadoria.Registro.NCM;
      FInvoiceSale.Invoice.Destinatario.Endereco.Estado.MVA.getByKey;

      ICMSUFDest.pICMSUFDest :=  FInvoiceSale.Invoice.Destinatario.Endereco.Estado.Registro.Aliquota;
      //Caso seja do simples e não tenha na regra precisamos pegar do estado
      if ICMSUFDest.pICMSInter = 0 then
        ICMSUFDest.pICMSInter := FInvoiceSale.Invoice.Destinatario.Endereco.Estado.Registro.Aliquota;
      // Calcula a Diferença  entre a alíquota interna do Estado destinatário e a alíquota interestadual;
      Lc_Aq_Icms_Partilha := ICMSUFDest.pICMSUFDest - ICMSUFDest.pICMSInter;
      // Percentual do ICMS relativo ao Fundo de Combate à Pobreza (FCP) na UF de destino
      FInvoiceSale.Invoice.Destinatario.Endereco.Estado.FCP.Registro.Estado := FCtrlInstitution.Fiscal.Endereco.Estado.Registro.Codigo;
      FInvoiceSale.Invoice.Destinatario.Endereco.Estado.FCP.Registro.NCM := FInvoiceSale.Itens.Mercadoria.Registro.NCM;
      FInvoiceSale.Invoice.Destinatario.Endereco.Estado.FCP.getByKey;
      ICMSUFDest.pFCPUFDest := FInvoiceSale.Invoice.Destinatario.Endereco.Estado.FCP.Registro.Aliquota;

      // Percentual de ICMS Interestadual para a UF de destino: - 40% em 2016; - 60% em 2017; - 80% em 2018; - 100% a partir de 2019.
      ICMSUFDest.pICMSInterPart := 100.00;
      // Valor do ICMS Interestadual para a UF de destino
      ICMSUFDest.vICMSUFDest :=   ( (ICMSUFDest.vBCUFDest * Lc_Aq_Icms_Partilha) / 100) * 1;
      ICMSUFDest.vICMSUFDest := roundTo(ICMSUFDest.vICMSUFDest, -2);
      // Valor do ICMS Interestadual para a UF do remetente
      ICMSUFDest.vICMSUFRemet :=  ((ICMSUFDest.vBCUFDest * Lc_Aq_Icms_Partilha) / 100) * 0.0;
      ICMSUFDest.vICMSUFRemet := roundTo(  ICMSUFDest.vICMSUFRemet, -2 );
      // Valor do ICMS relativo ao Fundo de Combate à Pobreza (FCP) da UF de destino
      ICMSUFDest.vFCPUFDest := (ICMSUFDest.vBCUFDest * ICMSUFDest.pFCPUFDest)  / 100;
      ICMSUFDest.vFCPUFDest := roundTo(ICMSUFDest.vFCPUFDest , -2);
    end
    else
    Begin
      // Abre a Tabela de ICMS - FCP
      FInvoiceSale.Itens.Icms.FCP.Registro.ItemOrdem       := FInvoiceSale.Itens.Registro.Codigo;
      FInvoiceSale.Itens.Icms.FCP.Registro.Ordem           := FInvoiceSale.Itens.Registro.Ordem;
      FInvoiceSale.Itens.Icms.FCP.Registro.Estabelecimento := FInvoiceSale.Itens.Registro.Estabelecimento;
      FInvoiceSale.Itens.Icms.FCP.Registro.Terminal        := FInvoiceSale.Itens.Registro.Terminal;
      FInvoiceSale.Itens.Icms.FCP.getbyKey;
      if FInvoiceSale.Itens.Icms.FCP.exist then
      Begin
        //ICMS Normal
        ICMS.vBCFCP := FInvoiceSale.Itens.Icms.FCP.Registro.BaseCalculo;
        ICMS.pFCP   := FInvoiceSale.Itens.Icms.FCP.Registro.Percentual;
        ICMS.vFCP   := FInvoiceSale.Itens.Icms.FCP.Registro.Valor;
        //ICMS ST
        ICMS.vBCFCPST := FInvoiceSale.Itens.Icms.FCP.Registro.BaseCalculoST;
        ICMS.pFCPST   := FInvoiceSale.Itens.Icms.FCP.Registro.PercentualST;
        ICMS.vFCPST   := FInvoiceSale.Itens.Icms.FCP.Registro.ValorST
      End;
    End;
  End;

end;

procedure TControllerNfe55Sale.GeraDanfePIS(imposto: TImposto);
Var
  Lc_Ok : Boolean;
Begin
  WITH imposto  DO
  Begin
    // Define a Situação tributária do PISPIS COM ISENTA PARA NA SEQUENCIA FOR SETADA AS VARIAVEIS SE HOUVER
    PIS.CST := pis07;
    PIS.vBC := 0;
    PIS.pPIS := 0;
    PIS.vPIS := 0;

    // valores do PIS
    FInvoiceSale.Itens.Pis.Registro.ItemOrdem       := FInvoiceSale.Itens.Registro.Codigo;
    FInvoiceSale.Itens.Pis.Registro.Ordem           := FInvoiceSale.Itens.Registro.Ordem;
    FInvoiceSale.Itens.Pis.Registro.Estabelecimento := FInvoiceSale.Itens.Registro.Estabelecimento;
    FInvoiceSale.Itens.Pis.Registro.Terminal        := FInvoiceSale.Itens.Registro.Terminal;
    FInvoiceSale.Itens.Pis.getByKey;
    if FInvoiceSale.Itens.Pis.exist then
    begin
      // Define a Situação tributária do PISPIS
      PIS.CST := StrToCSTPIS(Lc_Ok, FInvoiceSale.Itens.Pis.Registro.CST);
      if (PIS.CST = pis01) OR (PIS.CST = pis02) then
      Begin
        PIS.vBC   := FInvoiceSale.Itens.Pis.Registro.Base;
        PIS.pPIS  := FInvoiceSale.Itens.Pis.Registro.Aliquota;
        PIS.vPIS  := FInvoiceSale.Itens.Pis.Registro.Valor;
      end;
      if (PIS.CST = pis03) then
      Begin
        PIS.qBCProd   := FInvoiceSale.Itens.Pis.Registro.QuantVendas;
        PIS.vAliqProd := FInvoiceSale.Itens.Pis.Registro.QuantValorAliquota;
        PIS.vPIS      := FInvoiceSale.Itens.Pis.Registro.Valor;
      end;
      if (PIS.CST = pis99) then
      Begin
        if (FInvoiceSale.Itens.Pis.Registro.Base > 0) then
        Begin
          PIS.vBC   := FInvoiceSale.Itens.Pis.Registro.Base;
          PIS.pPIS  := FInvoiceSale.Itens.Pis.Registro.Aliquota;
        end
        else
        Begin
          PIS.qBCProd   := FInvoiceSale.Itens.Pis.Registro.QuantVendas;
          PIS.vAliqProd := FInvoiceSale.Itens.Pis.Registro.QuantValorAliquota;
        end;
      end
      else
      Begin
        PIS.vBC   := FInvoiceSale.Itens.Pis.Registro.Base;
        PIS.pPIS  := FInvoiceSale.Itens.Pis.Registro.Aliquota;
        PIS.vPIS  := FInvoiceSale.Itens.Pis.Registro.Valor;
      End;
    End;
  end;

end;

function TControllerNfe55Sale.GeraDanfeProdInfoAdic(itens: Tprod;
  Item: Integer): String;
Var
  LcRes : Boolean;
Begin
  Result := '';
  // Observação do produto na Descrição da
  //LcRes := (Fc_Tb_Geral('L', 'PRO_G_OBS_DESCRIC_NFE', 'S') = 'S');
  LcRes := False;
  if LcRes then
    Result := concat(
                  Result,
                  FInvoiceSale.Itens.Mercadoria.produto.Registro.Observaocao
                  );
  //Lote - preenchimento simples desvinculado com a tag de lote
  Result := concat(
                  Result,
                  GeraDanfeProdInfoAdicLote(itens,Item)
                  );
  //Fundo de Combate a Pobreza
  Result := concat(
                  Result,
                  GeraDanfeProdInfoAdicFCP(itens,Item)
                  );
  //Itens do Restaurante para detalhar o pedido
  Result := concat(
                  Result,
                  GeraDanfeProdInfoAdicRTR(itens,Item)
                  );

  {
  //IPI Devolvido
  LcItem := FNfe.NotasFiscais[0].NFe.Det.Count - 1;
  with FNfe.NotasFiscais[0].NFe.Det.Items[LcItem] do
  BEgin
    if (vIPIDevol > 0) then
    BEgin
      Result := concat(
                      Result,
                      ' | Aliq. IPI Devol. : ',FloatToStrF(pDevol,fffixed,10,2),
                      ' | Valor IPI Devol  : ',FloatToStrF(vIPIDevol,fffixed,10,2)
                );
    End;
  End;

  // Informação de Série do Produto
  Pc_Sql_Serie_Produto;
  Qr_Serie_Produto.Active := False;
  IF Qr_Nota.FieldByName('NFL_TIPO').AsString = 'SI' THEN
    Qr_Serie_Produto.ParamByName('SRP_CODSAI').AsInteger :=  Qr_Itens.FieldByName('ITF_CODIGO').AsInteger;
  IF Qr_Nota.FieldByName('NFL_TIPO').AsString = 'EI' THEN
    Qr_Serie_Produto.ParamByName('SRP_CODENT').AsInteger :=  Qr_Itens.FieldByName('ITF_CODIGO').AsInteger;
  Qr_Serie_Produto.Active := True;
  Qr_Serie_Produto.FetchAll;
  Qr_Serie_Produto.First;
  if Qr_Serie_Produto.recordcount > 0 then
  begin
    Result := concat(
                  Result,
                  Qr_Serie_Produto.FieldByName('SRP_DESCRICAO').AsString
              );
  end;
  }
  //Detalhamento da ST.
  {
  if (Fc_Tb_Geral('L', 'PRO_G_DET_ST_NFE', 'N') = 'S') then
  Begin
    Result := concat(
                  Result,
                  InfoSubTributariaItem()
              );
  end;
  }
end;

function TControllerNfe55Sale.GeraDanfeProdInfoAdicFCP(itens: Tprod;
  Item: Integer): String;
begin
  Result := '';
  {
  // Abre a Tabela de ICMS - FCP
  Qr_FCP.Active := False;
  Qr_FCP.ParamByName('ITENS_NFL_ID').AsInteger := Qr_Itens.FieldByName('ITF_CODIGO').AsInteger;
  Qr_FCP.Active := True;
  Qr_FCP.FetchAll;
  Qr_FCP.First;
  if Qr_fcp.recordCount > 0 then
  Begin
    REsult := Concat(
                'B.C.F.C.P : ',FloatToStrF(Qr_fcp.FieldByName('VBCFCP').asfloat,fffixed,10,2),' | ',
                '% F.C.P : ',FloatToStrF(Qr_fcp.FieldByName('PFCP').asfloat,fffixed,10,2),' | ',
                'V.F.C.P : ',FloatToStrF(Qr_fcp.FieldByName('VFCP').asfloat,fffixed,10,2)
                );
    if ( Qr_fcp.FieldByName('PFCPST').asfloat > 0 ) then
    Begin
     REsult := Concat(
                'B.C.F.C.P ST : ',FloatToStrF(Qr_fcp.FieldByName('VBCFCPST').asfloat,fffixed,10,2),' | ',
                '% F.C.P ST : ',FloatToStrF(Qr_fcp.FieldByName('PFCPST').asfloat,fffixed,10,2),' | ',
                'V.F.C.P ST : ',FloatToStrF(Qr_fcp.FieldByName('VFCPST').asfloat,fffixed,10,2)
                );
    End;
  End;
  }
end;

function TControllerNfe55Sale.GeraDanfeProdInfoAdicLote(itens: Tprod;
  Item: Integer): String;
Begin
  Result := '';
  if FMostraLote then
  Begin
    {
    // Informação de Lote
    FInvoiceSale.Itens.Lote.Registro.Codigo := FInvoiceSale.Itens.
    FInvoiceSale.Itens.Lote.Registro.Estabelecimento
    Qr_lote.Active := False;
    Qr_lote.ParamByName('ITF_CODIGO').AsInteger :=  Qr_Itens.FieldByName('ITF_CODIGO').AsInteger;
    Qr_lote.Active := True;
    Qr_lote.FetchAll;
    Qr_lote.First;
    while not Qr_lote.Eof do
    Begin
      if PreencheLoteValid then
      Begin
        if MostraRastreioCompleto then
        Begin
          with itens.rastro.Add do
          Begin
            if MostraRastreioCompleto then
            Begin
              nLote :=  Qr_lote.FieldByName('CLT_NUMERO').AsString;
              dVal  :=  Qr_lote.FieldByName('clt_dt_vencimento').AsDateTime;
              Qr_LoteProduzido.Active := False;
              Qr_LoteProduzido.ParamByName('CLT_CODIGO').AsInteger := Qr_lote.FieldByName('CLT_CODIGO').AsInteger;
              Qr_LoteProduzido.Active := True;
              Qr_LoteProduzido.FetchAll;
              if ( Qr_LoteProduzido.RecordCount > 0 ) then
                dFab  :=  Qr_LoteProduzido.FieldByName('MLT_DATA').AsDateTime
              else
                dFab  :=  Qr_Lote.FieldByName('MLT_DATA').AsDateTime;
                qLote :=  Qr_lote.FieldByName('MLT_QTDE').AsFloat;
              cAgreg := '';
            End;
          end;
        end
        else
        Begin
          if (Qr_lote.Bof ) then
          Begin
            Result := concat(
                          Result,
                          'Lote/Validade(s): ',
                                Qr_lote.FieldByName('CLT_NUMERO').AsString,' | ',
                                Qr_lote.FieldByName('clt_dt_vencimento').AsString
                          );
          End
          else
          Begin
            Result := concat(
                          Result,
                          ' | ', Qr_lote.FieldByName('CLT_NUMERO').AsString,' | ',
                                Qr_lote.FieldByName('clt_dt_vencimento').AsString
                          );
          End;
        End;
      End
      else
      Begin
        if (Qr_lote.Bof ) then
        Begin
          Result := concat(
                        Result,
                        'Lote(s): ', Qr_lote.FieldByName('CLT_NUMERO').AsString
                        );
        End
        else
        Begin
          Result := concat(
                        Result,
                        ' | ', Qr_lote.FieldByName('CLT_NUMERO').AsString
                        );
        End;
      End;
      Qr_lote.Next;
    end;
    }
  End;
end;

function TControllerNfe55Sale.GeraDanfeProdInfoAdicRTR(itens: Tprod;
  Item: Integer): String;
begin
  Result := '';
  {
  Qr_Itens_RTR.Active := False;
  Qr_Itens_RTR.ParamByName('ITR_CODITF').AsInteger := Qr_Itens.FieldByName('ITF_CODIGO').AsInteger;
  Qr_Itens_RTR.Active := True;
  Qr_Itens_RTR.FetchAll;
  Qr_Itens_RTR.First;
  while not Qr_Itens_RTR.eof do
  Begin
    if ((Qr_Itens.FieldByName('IAV_DESCRICAO').AsString <> Qr_Itens_RTR.FieldByname('ITR_DESCRICAO').asString)) then
      Result := concat(Result,Qr_Itens_RTR.FieldByname('ITR_DESCRICAO').asString,sLineBreak);
    Qr_Itens_RTR.Next;
  End;
  }
end;

procedure TControllerNfe55Sale.GeraDanfeTotalizador;
Var
  Lc_I : Integer;
  Lc_Ok : Boolean;
Begin
  with FNfe.NotasFiscais[0].Nfe do
  Begin
    Total.ICMSTot.vBC := 0;
    For Lc_I := 0 to (Det.Count - 1) do
    Begin
      Total.ICMSTot.vTotTrib      := Total.ICMSTot.vTotTrib  + Det.Items[Lc_I].Imposto.vTotTrib;

      Total.ICMSTot.vIPIDevol     := Total.ICMSTot.vIPIDevol + Det.Items[Lc_I].vIPIDevol;

      IF Det.Items[Lc_I].Prod.IndTot = (StrToindTot(Lc_Ok, '1')) then
        Total.ICMSTot.vProd       := Total.ICMSTot.vProd + Det.Items[Lc_I].Prod.vProd;
      Total.ICMSTot.vBC           := Total.ICMSTot.vBC + Det.Items[Lc_I].Imposto.ICMS.vBC;
      Total.ICMSTot.vICMS         := Total.ICMSTot.vICMS + Det.Items[Lc_I].Imposto.ICMS.vICMS;


      Total.ICMSTot.vBCST         := Total.ICMSTot.vBCST + Det.Items[Lc_I].Imposto.ICMS.vBCST;
      Total.ICMSTot.vST           := Total.ICMSTot.vST + Det.Items[Lc_I].Imposto.ICMS.vICMSST;

      Total.ICMSTot.vFCP          := Total.ICMSTot.vFCP       + Det.Items[Lc_I].Imposto.ICMS.vFCP;
      Total.ICMSTot.vFCPST        := Total.ICMSTot.vFCPST     + Det.Items[Lc_I].Imposto.ICMS.vFCPST;
      Total.ICMSTot.vFCPSTRet     := Total.ICMSTot.vFCPSTRet  + Det.Items[Lc_I].Imposto.ICMS.vFCPSTRet;

      Total.ICMSTot.vFCPUFDest    := Total.ICMSTot.vFCPUFDest + Det.Items[Lc_I].Imposto.ICMSUFDest.vFCPUFDest;
      Total.ICMSTot.vICMSUFDest   := Total.ICMSTot.vICMSUFDest + Det.Items[Lc_I].Imposto.ICMSUFDest.vICMSUFDest;
      Total.ICMSTot.vICMSUFRemet  := Total.ICMSTot.vICMSUFRemet + Det.Items[Lc_I].Imposto.ICMSUFDest.vICMSUFRemet;


      Total.ICMSTot.vDesc         := Total.ICMSTot.vDesc + Det.Items[Lc_I].Prod.vDesc;
      Total.ICMSTot.vFrete        := Total.ICMSTot.vFrete + Det.Items[Lc_I].Prod.vFrete;
      Total.ICMSTot.vSeg          := Total.ICMSTot.vSeg + Det.Items[Lc_I].Prod.vSeg;
      Total.ICMSTot.vOutro        := Total.ICMSTot.vOutro + Det.Items[Lc_I].Prod.vOutro;
      Total.ICMSTot.vII           := Total.ICMSTot.vII + Det.Items[Lc_I].Imposto.II.vII;
      Total.ICMSTot.vIPI          := Total.ICMSTot.vIPI + Det.Items[Lc_I].Imposto.IPI.vIPI;
      Total.ICMSTot.vPIS          := Total.ICMSTot.vPIS + Det.Items[Lc_I].Imposto.PIS.vPIS;
      Total.ICMSTot.vCOFINS       := Total.ICMSTot.vCOFINS + Det.Items[Lc_I].Imposto.COFINS.vCOFINS;
    end;
    // Verifica se a Nota é Conjugada
    if false then
    Begin
      Total.ISSQNtot.vServ := 0;
      Total.ISSQNtot.vBC := 0;
      Total.ISSQNtot.vISS := 0;
      Total.ISSQNtot.vISSRet := 0;
      Total.ISSQNtot.vDeducao := 0;
      For Lc_I := 0 to (Det.Count - 1) do
      Begin
        IF (Det.Items[Lc_I].Prod.IndTot = StrToindTot(Lc_Ok, '2')) then
        Begin
          Total.ISSQNtot.vServ    := Total.ISSQNtot.vServ + Det.Items[Lc_I].Imposto.ISSQN.vBC + Det.Items[Lc_I].Imposto.ISSQN.vDeducao;
          Total.ISSQNtot.vBC      := Total.ISSQNtot.vBC + Det.Items[Lc_I].Imposto.ISSQN.vBC;
          Total.ISSQNtot.vISS     := Total.ISSQNtot.vISS + Det.Items[Lc_I].Imposto.ISSQN.vISSQN;
          Total.ISSQNtot.vISSRet  := Total.ISSQNtot.vISSRet + Det.Items[Lc_I].Imposto.ISSQN.vISSRet;
          Total.ISSQNtot.vDeducao := Total.ISSQNtot.vDeducao + Det.Items[Lc_I].Imposto.ISSQN.vDeducao;
          Total.ISSQNtot.dCompet  := FInvoiceSale.Invoice.Registro.Data_emissao;
        end;
      end;
    end;
   Total.ICMSTot.vNF := FInvoiceSale.Invoice.Registro.Valor;
  End;
end;

procedure TControllerNfe55Sale.GeraDanfeTransportadora;
Var
  Lc_Ok : Boolean;
  Lc_Aux : String;
Begin
  if FInvoiceSale.OrderShipping.Registro.Transportadora > 0 then
  Begin
    FInvoiceSale.OrderShipping.TRansportadora.Registro.Codigo := FInvoiceSale.OrderShipping.Registro.Transportadora;
    FInvoiceSale.OrderShipping.TRansportadora.getAllByKey;

    with FNfe.NotasFiscais[0].Nfe.Transp do
    Begin
      if (FInvoiceSale.OrderShipping.TRansportadora.Fiscal.kindPerson = 'F') then
      Begin
        Transporta.CNPJCPF := FInvoiceSale.OrderShipping.TRansportadora.Fiscal.Fisica.Registro.CPF;
      end
      else
      Begin
        Transporta.CNPJCPF  := FInvoiceSale.OrderShipping.TRansportadora.Fiscal.Juridica.Registro.CNPJ;
        Transporta.IE       := FInvoiceSale.OrderShipping.TRansportadora.Fiscal.Juridica.Registro.InscricaoEstadual;
      end;
      Transporta.xNome  := Copy(FInvoiceSale.OrderShipping.TRansportadora.Fiscal.Registro.NomeRazao, 1, 60);
      Transporta.xEnder := FInvoiceSale.OrderShipping.TRansportadora.Fiscal.Endereco.Registro.Logradouro + ', '+
                           FInvoiceSale.OrderShipping.TRansportadora.Fiscal.Endereco.Registro.NumeroPredial;
      Transporta.xMun   := FInvoiceSale.OrderShipping.TRansportadora.Fiscal.Endereco.Cidade.Registro.Nome;
      Transporta.UF     := FInvoiceSale.OrderShipping.TRansportadora.Fiscal.Endereco.Estado.Registro.Abreviatura;

      modFrete := StrTomodFrete(Lc_Ok, FInvoiceSale.OrderShipping.Registro.ModalidadeFrete);

      if Trim(FInvoiceSale.InvoiceShipping.Registro.PlacaVeiculo ) <> '' then
      begin
        Lc_Aux := FInvoiceSale.InvoiceShipping.Registro.PlacaVeiculo;
        Lc_Aux := RemoveCaracterInformado(Lc_Aux, ['.', ',', '/', '-', ' ']);
        veicTransp.placa  := Lc_Aux;
        veicTransp.UF     := UpperCase(FInvoiceSale.InvoiceShipping.Registro.PlacaVeiculo);
        veicTransp.RNTC   := UpperCase(FInvoiceSale.InvoiceShipping.Registro.PlacaRntc);
      end;

      if (FInvoiceSale.InvoiceShipping.Registro.Quantidade > 0) then
      Begin
        with Vol.Add do
        begin
          qVol := FInvoiceSale.InvoiceShipping.Registro.Quantidade;
          esp := FInvoiceSale.InvoiceShipping.Registro.Classificacao;
          marca := FInvoiceSale.InvoiceShipping.Registro.Marca;

          if (StrToIntDef(FInvoiceSale.InvoiceShipping.Registro.PesoLiquido,0) > 0) then
            pesoL := StrToIntDef(FInvoiceSale.InvoiceShipping.Registro.PesoLiquido,0);
          if (StrToIntDef(FInvoiceSale.InvoiceShipping.Registro.PesoBruto,0)> 0) then
            pesoB := StrToIntDef(FInvoiceSale.InvoiceShipping.Registro.PesoBruto,0);
          nVol := FInvoiceSale.InvoiceShipping.Registro.NumeroVolume;
          // Lacres.Add.nLacre := '';
        end;
      end;
    End;
  End;
end;

procedure TControllerNfe55Sale.GeraDanfeVeiculosNovos(itens: Tprod);
//Var
//  Lc_Ok : Boolean;
Begin
  {
  with itens,Qr_Serie_Veiculo do
  Begin
    Active := False;
    ParamByName('SRV_CODITF').AsInteger := Qr_Itens.FieldByName('ITF_CODIGO').AsInteger;
    Active := True;
    FetchAll;
    First;
    if recordcount > 0 then
    Begin
      veicProd.tpOP     := StrTotpOP(Lc_Ok, FieldByName('SRV_TIPO_OPER').AsString);
      veicProd.chassi   := FieldByName('SRV_CHASSI').AsString;
      veicProd.cCor     := FieldByName('SRV_NUMCOR').AsString;                  // Código de cor de cada montadora
      veicProd.xCor     := FieldByName('SRV_DESCCOR').AsString;                 // Descrição da Cor
      veicProd.pot      := FieldByName('SRV_POTMOTOR').AsString; // Potencia do motor em Cavalo Vapor
      veicProd.Cilin    := FieldByName('SRV_CILINDRADA').AsString; // Clindradas
      veicProd.pesoB    := FieldByName('SRV_PESOBRT').AsString; // em toneladas - 4 casas decimais
      veicProd.pesoL    := FieldByName('SRV_PESOLIQ').AsString; // em toneladas - 4 casas decimais
      veicProd.nSerie   := FieldByName('SRV_SERIE').AsString; // Serial (série)
      veicProd.tpComb   := FieldByName('SRV_TPCOMB').AsString;
      veicProd.nMotor   := FieldByName('SRV_NMOTOR').AsString; // Numero do Motor
      veicProd.CMT      := FieldByName('SRV_POTCM3').AsString;
      // CMT-Capacidade Máxima de Tração - em Toneladas 4 casas decimais (v2.0)
      veicProd.dist     := FieldByName('SRV_DISTEIXO').AsString;
      // Distancia entre Eixos - em metros - 4 casas decimais
      veicProd.anoMod   := FieldByName('SRV_ANOMOD').AsInteger; // Ano Modelo de Fabricação
      veicProd.anoFab   := FieldByName('SRV_ANOFAB').AsInteger; // Ano de Fabricação
      veicProd.tpPint   := FieldByName('SRV_TPPINTURA').AsString; // Tipo de Pintura
      veicProd.tpVeic   := FieldByName('SRV_CODTPV').AsInteger; // Tipo de Veículo - Utilizar Tabela RENAVAM
      veicProd.espVeic  := FieldByName('SRV_CODEPV').AsInteger; // Utilizar Tabela RENAVAM
      veicProd.VIN      := FieldByName('SRV_VIN').AsString;
      // Informa-se o veículo tem VIN (chassi) remarcado. R-Remarcado N-Normal
      veicProd.condVeic := StrTocondVeic(Lc_Ok,FieldByName('SRV_COND_VEIC').AsString);
      veicProd.cMod     := FieldByName('SRV_CODMRMD').AsString; // Utilizar Tabela RENAVAM
      veicProd.cCor     := FieldByName('SRV_CODCOR').AsString;
      veicProd.lota     := FieldByName('SRV_LOTA').AsInteger;
      veicProd.tpRest   := FieldByName('SRV_CODRTV').AsInteger;
    end;
  End;
  }
end;


procedure TControllerNfe55Sale.GetDanfeItens;
begin
  { Esta função é utilizada parar pegar os itens da nota
    é pelo menos o primeiro registro do icms para preencher alguns dados da nota
    antes de iniciar a geração completa dos itens que é feita mais adiante
  }
  inherited;
  FInvoiceSale.Itens.Registro.Estabelecimento := FInvoiceSale.Registro.Estabelecimento;
  FInvoiceSale.Itens.Registro.Ordem           := FInvoiceSale.Registro.Codigo;
  FInvoiceSale.Itens.Registro.Terminal        := FInvoiceSale.Registro.Terminal;
  FInvoiceSale.Itens.getList;
  if FInvoiceSale.Itens.Lista.Count > 0 then
  Begin
    FInvoiceSale.ClonarObj(FInvoiceSale.Itens.lista[0],FInvoiceSale.Itens.Registro);

    FInvoiceSale.Itens.Icms.Registro.ItemOrdem        := FInvoiceSale.Itens.Registro.Codigo;
    FInvoiceSale.Itens.Icms.Registro.Ordem            := FInvoiceSale.Itens.Registro.Ordem;
    FInvoiceSale.Itens.Icms.Registro.Estabelecimento  := FInvoiceSale.Itens.Registro.Estabelecimento;
    FInvoiceSale.Itens.Icms.Registro.Terminal         := FInvoiceSale.Itens.Registro.Terminal;
    FInvoiceSale.Itens.Icms.getbyKey;
  End;
end;

function TControllerNfe55Sale.InfoSubTributariaItem: String;
begin
  {
  with Qr_Itens_ICMS_ST do
  Begin
    Active := False;
    ParamByName('ITF_CODIGO').AsInteger := Fc_Cd_Item;
    Active := True;
    FetchAll;
    if (recordcount > 0) then
    Begin
      Result := 'MVA: ' + FloatToStrF
        (((FieldByName('ICM_MG_VA_ST').asfloat - 1) * 100), ffFixed,
        10, 2) + '%';
      Result := Result + ' | ' + 'BCST: R$ ' +
        FloatToStrF(FieldByName('ICM_VL_BC_ST').asfloat, ffFixed, 10, 2);
      Result := Result + ' | ' + 'ICMS ST: R$ ' +
        FloatToStrF(FieldByName('ICM_VL_ST').asfloat, ffFixed, 10, 2);
    end
    else
    Begin
      Result := '';
    end;
  end;
  }
end;

procedure TControllerNfe55Sale.inicializa;
begin
  //Institution
  Estabelecimento := FParametros.Estabelecimento;
  //Configuração
  inherited;
  //Abrir dados da nota
  FInvoiceSale.Registro.Codigo          := FParametros.Ordem;
  FInvoiceSale.Registro.Estabelecimento := FParametros.Estabelecimento;
  FInvoiceSale.Registro.Terminal        := FParametros.Terminal;
  FInvoiceSale.getAllByKey;
  //repassa objeto para ascendente
  Finvoice := FInvoiceSale.Invoice;
  //Dados da Ordem de venda
  FInvoiceSale.OrderSale.Parametro.Ordem          :=  FParametros.Ordem;
  FInvoiceSale.OrderSale.Parametro.Estabelecimento :=  FParametros.Estabelecimento;
  FInvoiceSale.OrderSale.Parametro.Terminal        :=  FParametros.Terminal;
  FInvoiceSale.OrderSale.getByKey;
  //Dados do DEstinatario
  FInvoiceSale.Invoice.Destinatario.Registro.Codigo := FInvoiceSale.OrderSale.Registro.Cliente;
  FInvoiceSale.Invoice.Destinatario.getAllByKey;
  //Dados do Cliente da ordem
  FInvoiceSale.OrderSale.Customer.Registro.Codigo           := FInvoiceSale.OrderSale.Registro.Cliente;
  FInvoiceSale.OrderSale.Customer.Registro.Estabelecimento  := FInvoiceSale.OrderSale.Registro.Estabelecimento;
  FInvoiceSale.OrderSale.Customer.getByKey;
  //Retorno
  FRetorno.Registro.Codigo := FParametros.Ordem;
  FRetorno.Registro.Estabelecimento := FParametros.Estabelecimento;
  FRetorno.Registro.Terminal := FParametros.Terminal;
  FRetorno.getByKey;
end;

procedure TControllerNfe55Sale.setFParametros(const Value: TPrmToInvoiceSale);
begin
  FParametros := Value;
end;

function TControllerNfe55Sale.ValidateAuthorization: Boolean;
begin
  result := True;
  inherited;
//  if not Fc_VerificaPermissao('Fr_GeraNFe', 'Autorizar a Nota Fiscal',
//    'AUTORIZAR', GB_Cd_Usuario, 'S') then
//  Begin
//    Result := False;
//    Exit;
//  end;

  if (not FInvoiceSale.exist) then
  Begin
    FMensagemRetorno.AddPair('Mensagem','Não foi possivel carregar a Nota.');
    Result := False;
    Exit;
  end;


  if (FRetorno.Registro.Status = 3) then
  Begin
    FMensagemRetorno.AddPair('Mensagem','Esta nota já esta cancelada.');
    Result := False;
    Exit;
  end;

  if (FRetorno.Registro.Status = 4) then
  Begin
    FMensagemRetorno.AddPair('Mensagem','Número de Nota Inutilizada.');
    Result := False;
    Exit;
  end;

  if (FRetorno.Registro.Status = 5) then
  Begin
    FMensagemRetorno.AddPair('Mensagem','Nota denegada em sua autorização.');
    Result := False;
    Exit;
  end;

  if not DefineNumeroNota then
  Begin
    Result := False;
    Exit;
  end;

end;

end.
