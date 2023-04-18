unit ControllerNfe55Sale;

interface

uses System.Classes, ControllerNfe55,ControllerInvoiceSale,ControllerInvoiceReturn55,
    pcnNFe;

type
  TControllerNfe55Sale = class(TControllerNfe55)
    private
      FInvoiceSale : TControllerInvoiceSale;
      FReturnNFe : TControllerInvoiceReturn55;
      function DefineNumeroNota:Boolean;
    protected
      procedure GeraDanfeIde(dfide:TIde;Oper_Consulta:Boolean);Override;
      procedure GeraDanfeEmi(dfemi:TEmit;Oper_Consulta:Boolean);Override;
      procedure GeraDanfeDes(dfdes:TDest;Oper_Consulta:Boolean);Override;
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
      procedure GeraDanfeIItens(itens:Tprod);Override;
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
      procedure GeraDanfeInfAdic;Override;
      procedure GeraDanfeComercioExterior;Override;
      procedure GeraResponsabelTécnico;Override;
      procedure GeraCNPJAutorizados;Override;

      procedure FinalizaCancelamento;Override;

    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure inicializa;override;
      function ValidateAuthorization:Boolean;Override;
      procedure doAuthorization;

  end;
implementation

{ TControllerNfe55Sale }

constructor TControllerNfe55Sale.Create(AOwner: TComponent);
begin
  inherited;
  FInvoiceSale := TControllerInvoiceSale.Create(self);

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

procedure TControllerNfe55Sale.GeraCNPJAutorizados;
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeCasasDecimais;
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeCobranca;
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeCOFINS(imposto: TImposto);
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeCombustivel(itens: Tprod);
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeComercioExterior;
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeDes(dfdes: TDest;
  Oper_Consulta: Boolean);
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeEmi(dfemi: TEmit;
  Oper_Consulta: Boolean);
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeFormaPagto;
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeICMS(imposto: TImposto);
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeIde(dfide: TIde;
  Oper_Consulta: Boolean);
Var
  Lc_Time_Str: String;
  Lc_Ok : Boolean;
Begin
  {
  with dfide do
  Begin
    natOp :=  Copy(FieldByName('NAT_DESCRICAO').AsString, 1, 60);
    nNF := It_Nr_Nota;
    if (ChBx_NF_PreExistente.Checked) then
    Begin
      ChaveDuplicada := '';
      if (FTipoOperacao = 'NFC-e') then
        Arquivo.DeleteByNotaViaVinculo(4,FieldByName('NFL_CODIGO').AsInteger)
      else
        Arquivo.DeleteByNotaViaVinculo(1,FieldByName('NFL_CODIGO').AsInteger);
      cNF := InformarChaveAcesso;
    end;

    if Trim(ChaveDuplicada) <> '' then
    Begin
      if (FTipoOperacao = 'NFC-e') then
        Arquivo.DeleteByNotaViaVinculo(4,FieldByName('NFL_CODIGO').AsInteger)
      else
        Arquivo.DeleteByNotaViaVinculo(1,FieldByName('NFL_CODIGO').AsInteger);
      cNF := StrToIntDef(Copy(ChaveDuplicada,36,8),0);

    End;

    //Caso o ccliente não informe chave pré existente
    if cNF = 0 then
      cNF := FieldByName('NFL_CODIGO').AsInteger;


    if (FTipoOperacao = 'NFC-e') then
      modelo := 65
    else
      modelo := 55;
    serie := StrToIntDef(FieldByName('NFL_SERIE').AsString,1);

    if (FTipoOperacao = 'NFC-e') then
    Begin
      if Oper_Consulta then
      Begin
        if (Length(FieldByName('NFL_HR_SAIDA').AsString) > 0) then
        Begin
          dEmi    := FieldByName('NFL_DT_EMISSAO').AsDateTime + FieldByName('NFL_HR_SAIDA').AsDateTime;
          dSaiEnt := FieldByName('NFL_DT_SAIDA').AsDateTime   + FieldByName('NFL_HR_SAIDA').AsDateTime;
          // Ide.hSaiEnt   := Qr_Nota.FieldByName('NFL_HR_SAIDA').AsDateTime;
        end
        else
        Begin
          Lc_Time_Str := TimeToStr(NOW);
          dEmi    := FieldByName('NFL_DT_EMISSAO').AsDateTime + StrToTime(Lc_Time_Str);
          dSaiEnt := FieldByName('NFL_DT_SAIDA').AsDateTime   + StrToTime(Lc_Time_Str);
          hSaiEnt := StrToTime(Lc_Time_Str);
        end;
      end
      else
      Begin
        dEmi := NOW;
        dSaiEnt := NOW;
        hSaiEnt := NOW;
      end;
    end
    else
    Begin
      dEmi := FieldByName('NFL_DT_EMISSAO').AsDateTime + FieldByName('NFL_HR_SAIDA').AsDateTime;
      if Trim( FieldByName('NFL_DT_SAIDA').AsString) <> '' then
      Begin
        dSaiEnt := FieldByName('NFL_DT_SAIDA').AsDateTime + FieldByName('NFL_HR_SAIDA').AsDateTime;
        hSaiEnt := FieldByName('NFL_HR_SAIDA').AsDateTime;
      end;
    end;

    verProc := '2.0.1.6';
    cMunFG  := DM.Qr_Estabelecimento.FieldByName('CDD_IBGE').AsInteger;
    cUF     := DM.Qr_Estabelecimento.FieldByName('UFE_CODIGO').AsInteger;
    if (FTipoOperacao = 'NFC-e') then
    Begin
      tpImp  := tiNFCe;
      if (StrToIntDef(Qr_RetornoNFCe.FieldByName('NFC_TP_EMISSAO').AsString,9) = 9) then
      Begin
        Fr_Principal.Nfe.Configuracoes.Geral.FormaEmissao := teOffLine;
        tpEmis := teOffLine;
        dhCont := FieldByName('NFL_DT_EMISSAO').AsDateTime + FieldByName('NFL_HR_SAIDA').AsDateTime;
        if ( Qr_RetornoNFCe.FieldByName('NFC_MOTIVO').AsString <> '') then
          xJust := Qr_RetornoNFCe.FieldByName('NFC_MOTIVO').AsString
        else
          xJust := 'Sem conectividade com a Receita';
      end
      else
      BEgin
        tpEmis := teNormal;
      End;
    end
    else
    Begin
      tpEmis := StrToTpEmis(Lc_Ok,  IntToStr(StrToIntdef(DM.Qr_Nf_Eletronica.FieldByName('NFE_EMISSAO').AsString, 0) + 1));
      if (tpEmis <> teNormal) then
      BEgin
        dhCont := NOW;
        xJust := 'Serviço paralisado - Longo Prazo';
      end;
    end;

    // Indica operação com Consumidor final E B01 N 1-1 1 0=Não; 1=Consumidor final;
    IF ( FieldByName('EMP_CONSUMIDOR').AsString = 'S') or
       (FTipoOperacao = 'NFC-e') then
      indFinal := cfConsumidorFinal
    else
      indFinal := cfNao;

    if (FTipoOperacao = 'NFC-e') then
    Begin
      if (Qr_RetornoNFCe.FieldByName('NFC_IND_PRES').AsString = '1') then
        indPres := pcPresencial
      else
        indPres := pcEntregaDomicilio;
    end
    else
    Begin
      case StrToIntDef( FieldByName('PED_INDPRES').AsString,1) of
        1:indPres := pcPresencial;
        2:indPres := pcInternet;
        3:indPres := pcTeleatendimento;
        4:indPres := pcEntregaDomicilio;
        5:indPres := pcPresencialForaEstabelecimento;
        6:indPres := pcOutros;
      else
        indPres := pcPresencial;
      end;

    end;

    indIntermed := iiOperacaoSemIntermediador;

    // 1=NF-e normal; 2=NF-e complementar; 3=NF-e de ajuste; 4=Devolução/Retorno.
    if not Oper_Consulta then
    Begin
      if (ChBx_NF_Referenciada.Checked) then
      Begin
        if not Pc_DocFiscalReferenciada(dfide) then
          abort;
      End
      else
      Begin
        case StrToIntdef( FieldByName('NFL_FINALIDADE').AsString, 1) of
          1:Begin
              finNFe := fnNormal;
              if ( FieldByName('NAT_CFOP').AsString = '5929' ) or
                 ( FieldByName('NAT_CFOP').AsString = '6929' ) then
              Begin
                if not Pc_DocFiscalReferenciada(dfide) then
                  abort;
              End;
            End;
          2:
            Begin
              finNFe := fnComplementar;
              dfide.NFref.Add;
              notaFiscal.REgistro.NotaVinculada := Qr_Nota.FieldByName('NFL_NFL_VINCULO').AsString;
              notaFiscal.REgistro.CodigoEstabelecimento := Gb_CodMha;
              dfide.NFref.Items[0].refNFe := notaFiscal.DocFiscalRefComplementar;
            end;
          3:Begin
              finNFe := fnAjuste;
              if not Pc_DocFiscalReferenciada(dfide) then
                abort;

            End;
          4:
            Begin
              finNFe := fnDevolucao;
              if not Pc_DocFiscalReferenciada(dfide) then
                abort;
            end;
        end;
      End;
    End;
    // 1=Operação interna; 2=Operação interestadual; 3=Operação com exterior.
    if ( FieldByName('END_PAIS').AsInteger = 1058) then
    Begin
      if ( FieldByName('UFE_SIGLA').AsString = DM.Qr_Estabelecimento.FieldByName('UFE_SIGLA').AsString) or
         (FTipoOperacao = 'NFC-e') then
            idDest := doInterna
      else
        idDest := doInterestadual;
    end
    else
    Begin
      idDest := doExterior;
    end;
  End;
  }
end;

procedure TControllerNfe55Sale.GeraDanfeII(imposto: TImposto);
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeIItens(itens: Tprod);
Var
  I : Integer;
BEgin
  with FNfe.NotasFiscais.Add.Nfe do
  begin
    FInvoiceSale.Itens.Registro.Estabelecimento := FInvoiceSale.Registro.Estabelecimento;
    FInvoiceSale.Itens.Registro.Ordem           := FInvoiceSale.Registro.Codigo;
    FInvoiceSale.Itens.Registro.Terminal        := FInvoiceSale.Registro.Terminal;
    FInvoiceSale.Itens.getList;
    for I := 0 to FInvoiceSale.Itens.Lista.Count -1 do
    begin
      FInvoiceSale.ClonarObj(FInvoiceSale.Itens.Lista[I],FInvoiceSale.Itens.registro);
      with Det.Add do
      Begin
        //Devolução do IPI
        GeraDanfeIPIDevolvido;
        //Produtos
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
          FInvoiceSale.Itens.Icms.Registro.ItemOrdem        := FInvoiceSale.Itens.Registro.Codigo;
          FInvoiceSale.Itens.Icms.Registro.Ordem            := FInvoiceSale.Itens.Registro.Ordem;
          FInvoiceSale.Itens.Icms.Registro.Estabelecimento  := FInvoiceSale.Itens.Registro.Estabelecimento;
          FInvoiceSale.Itens.Icms.Registro.Terminal         := FInvoiceSale.Itens.Registro.Terminal;
          FInvoiceSale.Itens.Icms.getbyKey;
          if FInvoiceSale.Itens.Icms.exist then
          Begin
            // ========================== N - ICMS Normal e ST ==================================================
            Ide.natOp := FInvoiceSale.Invoice.Registro.Cfop;
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
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeImpostoAproximado(imposto: TImposto);
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeImpostoRegimeNormal(imposto: TImposto);
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeImpostoSimplesNacional(
  imposto: TImposto);
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeInfAdic;
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeIPI(imposto: TImposto);
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeIPIDevolvido;
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeISSQN(imposto: TImposto);
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeItensProdServ(itens: Tprod;
  Item: Integer);
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfePartilhaFCP(Emit: TEmit; Ide: TIde;
  Dest: TDest; Prod: TProd; imposto: TImposto);
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfePIS(imposto: TImposto);
begin
  inherited;

end;

function TControllerNfe55Sale.GeraDanfeProdInfoAdic(itens: Tprod;
  Item: Integer): String;
begin

end;

function TControllerNfe55Sale.GeraDanfeProdInfoAdicFCP(itens: Tprod;
  Item: Integer): String;
begin

end;

function TControllerNfe55Sale.GeraDanfeProdInfoAdicLote(itens: Tprod;
  Item: Integer): String;
begin

end;

function TControllerNfe55Sale.GeraDanfeProdInfoAdicRTR(itens: Tprod;
  Item: Integer): String;
begin

end;

procedure TControllerNfe55Sale.GeraDanfeTotalizador;
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeTransportadora;
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraDanfeVeiculosNovos(itens: Tprod);
begin
  inherited;

end;

procedure TControllerNfe55Sale.GeraResponsabelTécnico;
begin
  inherited;

end;

procedure TControllerNfe55Sale.inicializa;
begin
  inherited;
  FInvoiceSale.Registro.Codigo := 1;
  FInvoiceSale.Registro.Estabelecimento := FCtrlInstitution.Registro.Codigo;
  FInvoiceSale.Registro.Terminal := 1;
  FInvoiceSale.getAllByKey;
  //repassa objeto para ascendente
  Finvoice := FInvoiceSale.Invoice;
  //Retorno
  FRetorno.Registro.Codigo := 1;
  FRetorno.Registro.Estabelecimento := FCtrlInstitution.Registro.Codigo;
  FRetorno.Registro.Terminal := 1;
  FRetorno.getByKey;
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
