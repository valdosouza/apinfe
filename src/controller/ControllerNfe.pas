unit ControllerNfe;

interface

uses
  System.Classes, ACBrNFe,
    ControllerInstitution,BaseController,
    pcnConversao,
    ACBrNFeDANFEClass, pcnNFeW, pcnLeitor,  ACBrUtil,
    ACBrNFeNotasFiscais, pcnNFe, ACBrNFeWebServices, ACBrNFeDANFeRLClass,
    System.SysUtils,ControllerCtrlIcmsST,ControllerInvoice,ControllerStateMvaNcm,
    ControllerAccounting, ControllerNfesequences,FireDAC.Comp.Client;
type

  TControllerNfe = class(TBaseController)
    private

      procedure VerifyDuplicidadeDeChaveNFE;
      procedure setFEstabelecimento(const Value: Integer);
      procedure setFMostraLote(const Value: boolean);
      procedure IdentificaEntrega(dfent:TEntrega);
    procedure setFCarregaLogo(const Value: Boolean);
    protected
      FInvoice : TControllerInvoice;
      FNfe : TAcbrNfe;
      FCtrlInstitution : TControllerInstitution;
      FCtrlICMSST : TControllerCtrlIcmsST;
      FNfeSequences : TControllerNfeSequences;
      FFileXML : String;
      FCodigoNfeRetorno : Integer;
      FCodigoInternoRetorno : Integer;
      FNFeMensagemRetorno : String;
      FDataRetorno : TDateTime;
      FChaveDuplicada : String;
      FMostraLote: boolean;
      FCarregaLogo: Boolean;
      procedure UpdateInvoiceDateTime;Virtual;
      procedure handlReturn;Virtual;
      procedure UpdateRetornoNFe65;Virtual;
      procedure UpdateRetornoNFe55;Virtual;

      procedure GeraDanfeIde(dfide:TIde);Virtual;
      procedure GeraDanfeEmi(dfemi:TEmit);Virtual;
      procedure GeraDanfeDes(dfdes:TDest);Virtual;
      procedure GeraDanfeCasasDecimais;Virtual;
      procedure GeraDanfeItensProdServ(itens:Tprod; Item:Integer);Virtual;
      function  GeraDanfeProdInfoAdicLote(itens:Tprod; Item:Integer):String;Virtual;
      function  GeraDanfeProdInfoAdicFCP(itens:Tprod; Item:Integer):String;Virtual;
      function  GeraDanfeProdInfoAdicRTR(itens:Tprod; Item:Integer):String;Virtual;
      function  GeraDanfeProdInfoAdic(itens:Tprod; Item:Integer):String;Virtual;
      procedure GeraDanfeImportacao(itens:Tprod);Virtual;
      procedure GeraDanfeVeiculosNovos(itens:Tprod);Virtual;
      procedure GeraDanfeCombustivel(itens:Tprod);Virtual;
      procedure GeraDanfeImpostoAproximado(imposto:TImposto);Virtual;
      procedure GeraDanfeImpostoRegimeNormal(imposto:TImposto);Virtual;
      procedure GeraDanfeImpostoSimplesNacional(imposto:TImposto);Virtual;
      procedure GeraDanfeICMS(imposto:TImposto);Virtual;
      procedure GeraDanfePartilhaFCP(Emit:TEmit;Ide:TIde;Dest:TDest;Prod:TProd;imposto:TImposto);Virtual;
      procedure GetDanfeItens;Virtual;
      procedure GeraDanfeItens();Virtual;
      procedure GeraDanfeIPI(imposto:TImposto);Virtual;
      procedure GeraDanfeIPIDevolvido;Virtual;
      procedure GeraDanfeII(imposto:TImposto);Virtual;
      procedure GeraDanfePIS(imposto:TImposto);Virtual;
      procedure GeraDanfeCOFINS(imposto:TImposto);Virtual;
      procedure GeraDanfeISSQN(imposto:TImposto);Virtual;
      procedure GeraDanfeTotalizador;Virtual;
      procedure GeraDanfeTransportadora;Virtual;
      procedure GeraDanfeFormaPagto;Virtual;
      procedure GeraDanfeCobranca;Virtual;
      procedure GeraDanfeInfAdicContribuinte;Virtual;
      procedure GeraDanfeInfAdicFisco;Virtual;
      procedure GeraDanfeComercioExterior;
      procedure GeraResponsabelTécnico;
      procedure GeraCNPJAutorizados;
      Function  GeraDadosDanfe():Boolean;

    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure inicializa;virtual;
      function getAuthorization:boolean;Virtual;
      function chekAuthorization:boolean;
      property Estabelecimento : Integer write setFEstabelecimento;
      property MostraLote : boolean read FMostraLote write setFMostraLote;
      property CarregaLogo : Boolean read FCarregaLogo write setFCarregaLogo;
  end;
implementation

{ TControllerNfe }

function TControllerNfe.chekAuthorization: boolean;
begin
  inherited;

end;

constructor TControllerNfe.Create(AOwner: TComponent);
begin
  inherited;
  FNfe := TAcbrNfe.Create(self);
  FCtrlInstitution := TControllerInstitution.Create(self);
  FCtrlICMSST := TControllerCtrlIcmsST.create(Self);
  FNfeSequences := TControllerNfeSequences.create(Self);
  FMostraLote := False;
end;

destructor TControllerNfe.Destroy;
begin
  FNfeSequences.DisposeOf;
  FNfe.DisposeOf;
  FCtrlInstitution.DisposeOf;
  FCtrlICMSST.DisposeOf;
  inherited;
end;

procedure TControllerNfe.GeraCNPJAutorizados;
Var
  LcContador : TControllerAccounting;
  Lc_CNPj : String;
begin
  try
    LcContador := TControllerAccounting.create(nil);
    with FNfe.NotasFiscais[0].Nfe do
    Begin
      Lc_CNPj := LcContador.getCNPJ;
      if (Lc_CNPj <> Dest.CNPJCPF) then
      Begin
        if Lc_CNPj <> '' then
          autXML.New.CNPJCPF := Lc_CNPj;
      End;
    End;
  finally
    LcContador.disposeOf;
  end;
end;

function TControllerNfe.GeraDadosDanfe(): Boolean;
Var
  Lc_Aux: String;
  Lc_Ok: Boolean;
  Lc_Nr_Item: Integer;
  Lc_I: Integer;
  Lc_Aq_Icms_Partilha: Real;
Begin
  Try
    //Não aplicar o DisposeOf quando o create for Self
    REsult := True;
    // ========================== A - Dados da Nota Fiscal eletrônica =========================================
    // Componente está tratando
    FNfe.NotasFiscais.Clear;
    //Fr_Principal.Nfe.NotasFiscais[0].NFe.autXML
    with FNfe.NotasFiscais.Add.Nfe do
    begin
      //Controle Id da NFE que é diferente no numero da nota que deve ser sequencial e dirente um do outro
      FNfeSequences.Registro.Estabelecimento := FInvoice.Registro.Estabelecimento;
      FNfeSequences.Registro.Terminal        := FInvoice.Registro.Terminal;
      FNfeSequences.Registro.Serie           := FInvoice.Registro.Serie.ToInteger;
      FNfeSequences.Registro.Ordem           := FInvoice.Registro.Codigo;
      infNFe.ID := FNfeSequences.get;
      //Ativa os itens da nota e o primeiro reistro do ICMS para as primeiras verificações
      GetDanfeItens;
      // ========================== B - Identificação da Nota Fiscal eletrônica =================================
      GeraDanfeIde(Ide);
      // ========================== C - Identificação do Emitente da Nota Fiscal eletrônica =========================
      GeraDanfeEmi(Emit);
      // ========================== D - Identificação do Fisco Emitente da NF-e ===============================

      // ========================== E - Identificação do Destinatário da Nota Fiscal eletrônica =========================
      GeraDanfeDes(Dest);
      // ========================== F - Identificação do Local de Retirada ====================================

      // ========================== G - Identificação do Local de Entrega =====================================
  //    Pc_IdentificaEntrega( Qr_Nota.FieldByName('EMP_CODIGO').AsInteger,Entrega);
      // ========================== Definie quantas casas decimais ============================================
      GeraDanfeCasasDecimais;
      // ========================== H - Detalhamento de Produtos e Serviços da NF-e ===========================

      // ========================== I - Produtos e Serviços da NF-e ===========================================
      GeraDanfeItens();
      // ========================== V - Informações adicionais ============================================
      // tratado na tag I - Produtos e Serviços da NF-e
      // ========================== W - Valores Totais da NF-e ================================================
      GeraDanfeTotalizador;
      // ======================s==== X - Informações do Transporte da NF-e =====================================
      GeraDanfeTransportadora;
      // ========================== Y – Dados da Cobrança =====================================================
      GeraDanfeFormaPagto;
      GeraDanfeCobranca;
      // ========================== Z - Informações Adicionais da NF-e ========================================
      GeraDanfeInfAdicContribuinte;
      GeraDanfeInfAdicFisco;

      // ========================== ZA - Informações de Comércio Exterior =====================================
      GeraDanfeComercioExterior;
      // ========================== ZB - Informações de Compras ===============================================

      // ========================== ZC - Informações do Registro de Aquisição de Cana =========================

      // ========================== ZZ - Informações da Assinatura Digital ====================================
      GeraResponsabelTécnico;
      GeraCNPJAutorizados;
    // ======================================== Finalização ===================================================
      FNfe.NotasFiscais.Items[0].GerarXML;
      FFileXML := Copy(FNfe.NotasFiscais.Items[0].Nfe.infNFe.ID,(Length(FNfe.NotasFiscais.Items[0].Nfe.infNFe.ID) - 44) + 1, 44) + '-NFe.xml';
      FNfe.NotasFiscais.GerarNFe;

      FNfe.NotasFiscais.GravarXML(concat(FCtrlInstitution.PathPublico + '\xml\nfe\',FFileXML) );
      FNfe.NotasFiscais.Assinar;
      FNfe.NotasFiscais.Validar;
    end;
  except
    on E: Exception do
    Begin
      FMensagemRetorno.AddPair('Mensagem', E.Message);
    end;
  end;
end;

procedure TControllerNfe.GeraDanfeCasasDecimais;
begin

end;

procedure TControllerNfe.GeraDanfeCobranca;
begin

end;

procedure TControllerNfe.GeraDanfeCOFINS(imposto: TImposto);
begin

end;

procedure TControllerNfe.GeraDanfeCombustivel(itens: Tprod);
begin

end;

procedure TControllerNfe.GeraDanfeComercioExterior;
begin
  with FNfe.NotasFiscais[0].Nfe do
  Begin
    if (Copy(Det[0].Prod.CFOP, 1, 1) = '7') then // CFOP de Exportação (inicia por 7)
    Begin
      exporta.UFembarq    := FCtrlInstitution.Fiscal.Endereco.Estado.Registro.Abreviatura;
      exporta.xLocEmbarq  := FCtrlInstitution.Fiscal.Endereco.Cidade.Registro.Nome;
    end;
  End;
end;

procedure TControllerNfe.GeraDanfeDes(dfdes: TDest);
begin

end;

procedure TControllerNfe.GeraDanfeEmi(dfemi: TEmit);
begin

end;

procedure TControllerNfe.GeraDanfeFormaPagto;
begin

end;

procedure TControllerNfe.GeraDanfeICMS(imposto: TImposto);
begin

end;

procedure TControllerNfe.GeraDanfeIde(dfide: TIde);
Begin

end;

procedure TControllerNfe.GeraDanfeII(imposto: TImposto);
begin

end;

procedure TControllerNfe.GeraDanfeItens();
begin

end;

procedure TControllerNfe.GeraDanfeImportacao(itens: Tprod);
begin

end;

procedure TControllerNfe.GeraDanfeImpostoAproximado(imposto: TImposto);
begin

end;

procedure TControllerNfe.GeraDanfeImpostoRegimeNormal(imposto: TImposto);
begin

end;

procedure TControllerNfe.GeraDanfeImpostoSimplesNacional(imposto: TImposto);
begin

end;


procedure TControllerNfe.GeraDanfeInfAdicContribuinte;
begin

end;

procedure TControllerNfe.GeraDanfeInfAdicFisco;
begin

end;

procedure TControllerNfe.GeraDanfeIPI(imposto: TImposto);
begin

end;

procedure TControllerNfe.GeraDanfeIPIDevolvido;
begin

end;

procedure TControllerNfe.GeraDanfeISSQN(imposto: TImposto);
begin

end;

procedure TControllerNfe.GeraDanfeItensProdServ(itens: Tprod; Item: Integer);
begin

end;

procedure TControllerNfe.GeraDanfePartilhaFCP(Emit: TEmit; Ide: TIde;
  Dest: TDest; Prod: TProd; imposto: TImposto);
begin

end;

procedure TControllerNfe.GeraDanfePIS(imposto: TImposto);
begin

end;

function TControllerNfe.GeraDanfeProdInfoAdic(itens: Tprod;
  Item: Integer): String;
begin

end;

function TControllerNfe.GeraDanfeProdInfoAdicFCP(itens: Tprod;
  Item: Integer): String;
begin

end;

function TControllerNfe.GeraDanfeProdInfoAdicLote(itens: Tprod;
  Item: Integer): String;
begin

end;

function TControllerNfe.GeraDanfeProdInfoAdicRTR(itens: Tprod;
  Item: Integer): String;
begin

end;

procedure TControllerNfe.GeraDanfeTotalizador;
begin

end;

procedure TControllerNfe.GeraDanfeTransportadora;
begin

end;

procedure TControllerNfe.GeraDanfeVeiculosNovos(itens: Tprod);
begin

end;

procedure TControllerNfe.GeraResponsabelTécnico;
begin
  with FNfe.NotasFiscais[0].Nfe do
  Begin
    infRespTec.CNPJ := '07742094000113';
    infRespTec.xContato := 'Florisvaldo Domingues de Souza';
    infRespTec.email := 'valdo@setes.com.br';
    infRespTec.fone := '41999112072';
  End;
end;

function TControllerNfe.getAuthorization:boolean;
var
  Lc_Cd_Retorno: Integer;
  Lc_Cd_Vinculo: Integer;
begin
  try
    FNfe.WebServices.Consulta.Clear;
    FNfe.WebServices.Retorno.Clear;
    FNfe.WebServices.Enviar.Clear;

    FNfe.DANFE.MostraPreview := False;
    TRY
      FNfe.Enviar(0);
      REsult := True;
    except
      on E: Exception do
      Begin
        FMensagemRetorno.AddPair('Mensagem',E.Message);
        REsult := False;
      End;
    end;
  finally
    handlReturn;
  End;
end;

procedure TControllerNfe.GetDanfeItens;
begin

end;

procedure TControllerNfe.handlReturn;
begin
  Fnfe.NotasFiscais.Items[0].GravarXML(FFileXML,FCtrlInstitution.PathPublico);
  FDataRetorno := 0;
  if (FNfe.WebServices.Retorno.cStat > 0) then
  Begin
    FCodigoNfeRetorno := FNfe.WebServices.Retorno.cStat;
    FNFeMensagemRetorno := UpperCase(FNfe.WebServices.Retorno.XMotivo);
  End
  else
  Begin
    if (FNfe.WebServices.Enviar.cStat > 0) then
    Begin
      FDataRetorno := FNfe.WebServices.Enviar.dhRecbto;
      FCodigoNfeRetorno := FNfe.WebServices.Enviar.cStat;
      FNFeMensagemRetorno := UpperCase(FNfe.WebServices.Enviar.XMotivo);
    End
    else
    Begin
      FDataRetorno := FNfe.WebServices.Consulta.DhRecbto;
      FCodigoNfeRetorno := FNfe.WebServices.Consulta.cStat;
      FNFeMensagemRetorno := UpperCase(FNfe.WebServices.Consulta.XMotivo);
    End;
  End;

  UpdateInvoiceDateTime;
  VerifyDuplicidadeDeChaveNFE;

end;


procedure TControllerNfe.IdentificaEntrega(dfent: TEntrega);
var
  Lc_SqlTxt: String;
  Lc_Cd_Endereco, Lc_Cd_Entrega: Integer;
  Lc_qt_Endereco: Integer;
  Lc_Qry : TFDQuery;
begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      sql.Add(concat(
              'SELECT id, main ',
              'FROM tb_address ',
              'WHERE id =:id  and kind = ''COMERCIAL'' '
      ));
      ParamByName('id').AsInteger := FInvoice.Registro.Emitente;
      Active := True;
      FetchAll;
      First;
      Lc_qt_Endereco := recordcount;
      if Lc_qt_Endereco > 1 then
        Locate('id', 'S', []);
      Lc_Cd_Endereco := FieldByName('id').AsInteger;

      Active := False;
      sql.Clear;
      Lc_SqlTxt := '';
      sql.Add(concat(
              'Select adr.id, adr.street, adr.nmbr, adr.complement, ',
              'adr.neighborhood, adr.zip_code, cdd.name, cdd.ibge, ',
              ' ste.abbreviation, osp.tb_address_id ',
              ' from tb_address adr ',
              '  inner join tb_city cdd ',
              '  ON (cdd.id = adr.tb_city_id) ',
              '  inner join tb_state ste ',
              '  ON (ste.id = adr.tb_state_id) ',
              '  inner join tb_order_shipping osp ',
              '  ON (osp.tb_address_id = adr.id) ',
              'where osp.id =:id ',
              'and osp.tb_institution_id =:tb_institution_id '
      ));
      ParamByName('id').AsInteger := FInvoice.Registro.Codigo;
      ParamByName('tb_institution_id').AsInteger := FInvoice.Registro.Estabelecimento;
      Active := True;
      FetchAll;

      // Neste caso tem apenas um endereço e não precisa comparar
      if (Lc_qt_Endereco > 1) then
      Begin
        Lc_Cd_Entrega := FieldByName('tb_address_id').AsInteger;

        If Lc_Cd_Endereco <> Lc_Cd_Entrega then
        begin
          with dfent do
          begin
            //CNPJCPF := FieldByName('END_CNPJ').AsString; verificar se campo é obrigatorio
            xLgr    := FieldByName('street').AsString;
            nro     := FieldByName('nmbr').AsString;
            xCpl    := FieldByName('complement').AsString;
            xBairro := FieldByName('neighborhood').AsString;
            cMun    := FieldByName('ibge').AsInteger;
            xMun    := FieldByName('name').AsString;
            UF      := FieldByName('abbreviation').AsString;
          end;
        end;
      End;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

procedure TControllerNfe.inicializa;
begin

end;

procedure TControllerNfe.setFCarregaLogo(const Value: Boolean);
begin
  FCarregaLogo := Value;
end;

procedure TControllerNfe.setFEstabelecimento(const Value: Integer);
begin
  FCtrlInstitution.Registro.Codigo := Value;
  FCtrlInstitution.getAllByKey;
  FCtrlInstitution.getRepository(true,'');
end;

procedure TControllerNfe.setFMostraLote(const Value: boolean);
begin
  FMostraLote := Value;
end;

procedure TControllerNfe.UpdateInvoiceDateTime;
begin

end;

procedure TControllerNfe.UpdateRetornoNFe55;
begin

end;

procedure TControllerNfe.UpdateRetornoNFe65;
begin

end;

procedure TControllerNfe.VerifyDuplicidadeDeChaveNFE;
Var
  LcPosicao : Integer;
  LcTIpoNF : String;
begin
  FChaveDuplicada := '';
  if  (Pos(UpperCase('Duplicidade de NF-e'), UpperCase(FNFeMensagemRetorno)) > 0) then
  begin
    //123456789X123456789X123456789X123456789X123456789X12345678
    //Duplicidade de NF-e, com diferenca na Chave de Acesso. [41191017906757000141650020000215831000436399] [nRec:919001164446027]'

    LcPosicao := Pos(concat('[',FCtrlInstitution.Fiscal.Endereco.Registro.CodigoEstado.ToString), FNFeMensagemRetorno);


    FChaveDuplicada := Copy(FNFeMensagemRetorno,LcPosicao +1,44);

    LcTIpoNF := Copy(FChaveDuplicada,21,2);
    if LcTIpoNF = '65' then
    Begin
      UpdateRetornoNFe65;
    End;
    if LcTIpoNF = '55' then
    Begin
      UpdateRetornoNFe55;
    End;
  end;

end;

end.
