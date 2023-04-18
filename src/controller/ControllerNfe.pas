unit ControllerNfe;

interface

uses
  System.Classes, ACBrNFe,
    ControllerInstitution,BaseController,
    pcnConversao,
    ACBrNFeDANFEClass, pcnNFeW, pcnLeitor,  ACBrUtil,
    ACBrNFeNotasFiscais, pcnNFe, ACBrNFeWebServices, ACBrNFeDANFeRLClass,
    System.SysUtils,ControllerCtrlIcmsST,ControllerInvoice;
type

  TControllerNfe = class(TBaseController)
    private

      procedure VerifyDuplicidadeDeChaveNFE;


    procedure setFEstabelecimento(const Value: Integer);

    protected
      FInvoice : TControllerInvoice;
      FNfe : TAcbrNfe;
      FCtrlInstitution : TControllerInstitution;
      FCtrlICMSST : TControllerCtrlIcmsST;
      FFileXML : String;
      FCodigoNfeRetorno : Integer;
      FCodigoInternoRetorno : Integer;
      FNFeMensagemRetorno : String;
      FDataRetorno : TDateTime;
      FChaveDuplicada : String;
      procedure UpdateInvoiceDateTime;Virtual;
      procedure handlReturn;Virtual;
      procedure UpdateRetornoNFe65;Virtual;
      procedure UpdateRetornoNFe55;Virtual;

      procedure GeraDanfeIde(dfide:TIde;Oper_Consulta:Boolean);Virtual;
      procedure GeraDanfeEmi(dfemi:TEmit;Oper_Consulta:Boolean);Virtual;
      procedure GeraDanfeDes(dfdes:TDest;Oper_Consulta:Boolean);Virtual;
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
      procedure GeraDanfeIItens(itens:Tprod);Virtual;
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
      procedure GeraDanfeInfAdic;Virtual;
      procedure GeraDanfeComercioExterior;Virtual;
      procedure GeraResponsabelTécnico;Virtual;
      procedure GeraCNPJAutorizados;Virtual;
      Function  GeraDadosDanfe():Boolean;

    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure inicializa;virtual;
      function getAuthorization:boolean;
      function chekAuthorization:boolean;
      property Estabelecimento : Integer write setFEstabelecimento;
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
end;

destructor TControllerNfe.Destroy;
begin
  inherited;
end;

procedure TControllerNfe.GeraCNPJAutorizados;
begin

end;

function TControllerNfe.GeraDadosDanfe(): Boolean;
Var
  Lc_Aux: String;
  Lc_Ok: Boolean;
  Lc_Obs: TStringList;
  Lc_Nr_Item: Integer;

  Lc_I: Integer;
  Lc_Aq_Icms_Partilha: Real;
Begin
  //Não aplicar o DisposeOf quando o create for Self
  {
  REsult := True;
  Lc_Obs := TStringList.Create;
  // ========================== A - Dados da Nota Fiscal eletrônica =========================================
  // Componente está tratando
  // ========================== B - Identificação da Nota Fiscal eletrônica =================================
  FNfe.NotasFiscais.Clear;
  //Fr_Principal.Nfe.NotasFiscais[0].NFe.autXML
  with FNfe.NotasFiscais.Add.Nfe do
  begin
    infNFe.ID := '0';

    GeraDanfeIde(Ide,Pc_Oper_Consulta);
    // ========================== C - Identificação do Emitente da Nota Fiscal eletrônica =========================
    GeraDanfeEmi(Emit,Pc_Oper_Consulta);
    // ========================== D - Identificação do Fisco Emitente da NF-e ===============================

    // ========================== E - Identificação do Destinatário da Nota Fiscal eletrônica =========================
    GeraDanfeDes(Dest,Pc_Oper_Consulta);
    // ========================== F - Identificação do Local de Retirada ====================================

    // ========================== G - Identificação do Local de Entrega =====================================
    Pc_IdentificaEntrega( Qr_Nota.FieldByName('EMP_CODIGO').AsInteger,Entrega);
    // ========================== Definie quantas casas decimais ============================================
    Pc_SelecionaItensNota(Qr_Nota.FieldByName('NFL_CODIGO').AsInteger);
    // Define Quantas Casas Decimais para o Valor
    GeraDanfeCasasDecimais;
    // ========================== H - Detalhamento de Produtos e Serviços da NF-e ===========================

    // ========================== I - Produtos e Serviços da NF-e ===========================================
    GeraDanfeIItens;
    // ========================== V - Informações adicionais ============================================
    // tratado na tag I - Produtos e Serviços da NF-e
    // ========================== W - Valores Totais da NF-e ================================================
    GeraDanfeTotalizador;
    // ======================s==== X - Informações do Transporte da NF-e =====================================
    GeraDanfeTransportadora;
    // ========================== Y – Dados da Cobrança =====================================================
    GeraDanfeFormaPagto;
    if not (TipoOperacao = 'NFC-e') then
      GeraDanfeCobranca;

    // ========================== Z - Informações Adicionais da NF-e ========================================
    GeraDanfeInfAdic;
    // ========================== ZA - Informações de Comércio Exterior =====================================
    GeraDanfeComercioExterior;
    // ========================== ZB - Informações de Compras ===============================================

    // ========================== ZC - Informações do Registro de Aquisição de Cana =========================

    // ========================== ZZ - Informações da Assinatura Digital ====================================
    GeraResponsabelTécnico;
    GeraCNPJAutorizados;
  end;


    FNfe.DANFE.Protocolo := '';
    if not Pc_GeraDadosDanfe(Pc_Oper_Consulta) then
    Begin
      Exit;
    end;
    Add('SALVANDO O XML REFERENTE A NOTA...');
    Proc.Update;
    // Faz a gravação do XML no Banco de dados
    Fr_Principal.Nfe.NotasFiscais.Items[0].GerarXML;
    Lc_FileXML := Copy(Fr_Principal.Nfe.NotasFiscais.Items[0].Nfe.infNFe.ID,(Length(Fr_Principal.Nfe.NotasFiscais.Items[0].Nfe.infNFe.ID) - 44) + 1, 44) + '-NFe.xml';

    // Fr_Principal.Nfe.NotasFiscais.Items[0].GravarXML();
    Add('VALIDANDO O XML REFERENTE A NOTA...');
    Proc.Update;
    Try
      Fr_Principal.Nfe.NotasFiscais.GerarNFe;
      //Fr_Principal.Nfe.NotasFiscais.GravarXML(concat('c:\temp\',Lc_FileXML) );
      Fr_Principal.Nfe.NotasFiscais.Assinar;
      Fr_Principal.Nfe.NotasFiscais.Validar;
     Result := Lc_FileXML
    except
      on E: Exception do
      Begin
        Add(E.ClassName + ' Erro : ' + E.Message);
        Result := '';
        Add('Problemas ao gerar e/ou validar o arquivo XML...');
      end;
    end;
  end;
  }
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

end;

procedure TControllerNfe.GeraDanfeDes(dfdes: TDest; Oper_Consulta: Boolean);
begin

end;

procedure TControllerNfe.GeraDanfeEmi(dfemi: TEmit; Oper_Consulta: Boolean);
begin

end;

procedure TControllerNfe.GeraDanfeFormaPagto;
begin

end;

procedure TControllerNfe.GeraDanfeICMS(imposto: TImposto);
begin

end;

procedure TControllerNfe.GeraDanfeIde(dfide: TIde; Oper_Consulta: Boolean);
Begin
end;

procedure TControllerNfe.GeraDanfeII(imposto: TImposto);
begin

end;

procedure TControllerNfe.GeraDanfeIItens(itens: Tprod);
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

procedure TControllerNfe.GeraDanfeInfAdic;
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


procedure TControllerNfe.inicializa;
begin

end;

procedure TControllerNfe.setFEstabelecimento(const Value: Integer);
begin
  FCtrlInstitution.Registro.Codigo := Value;
  FCtrlInstitution.getAllByKey;
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
