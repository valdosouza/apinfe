unit ControllerNfe55;

interface

uses
  ControllerNfe, System.Classes,ControllerConfigNfe55,
  ACBrDFeReport, ACBrDFeDANFeReport, ACBrNFeDANFeRLClass, pcnConversaoNFe,
  pcnConversao, System.SysUtils,
  ControllerInvoiceReturn55,  Vcl.ExtCtrls, Vcl.Graphics, ACBrDFeSSL, blcksock;

type
  TControllerNfe55 = Class(TControllerNFe)
    Private
       procedure ConfiguraComponente;

    protected
      FConfig : TControllerConfigNfe55;
      FDfe_Fortes: TACBrNFeDANFeRL;
      FRetorno : TControllerInvoiceReturn55;
      FCodigoConsumidor : Integer;
      procedure handlReturn;Override;
      procedure FinalizaCancelamento;Virtual;
      procedure UpdateInvoiceDateTime;Override;
      procedure UpdateRetornoNFe55;Override;
    public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure inicializa;override;
    function ValidateAuthorization:Boolean;Virtual;
    procedure getAuthorization;Virtual;
  End;
implementation

{ TControllerNfe55 }

procedure TControllerNfe55.ConfiguraComponente;
Var
  Lc_Ok : boolean;
  Lc_Arq_Logo : String;
  LocalCerti : String;
begin
  with FNfe do
  Begin
    Configuracoes.Geral.ModeloDF := moNFe;
    FDfe_Fortes.ExibeDadosISSQN := True;
    DANFE := FDfe_Fortes;
    FDfe_Fortes.PosCanhoto := prCabecalho;
    //MArgem Direita
    DANFE.MargemEsquerda := 5;
    DANFE.MargemSuperior := 5;
    DANFE.MargemInferior := 10;

    if ( FConfig.Registro.Orientacao = '0' ) then
      DANFE.TipoDANFE := tiRetrato
    else
      DANFE.TipoDANFE := tiPaisagem;

    if ( FConfig.Registro.Recebimento = '0' ) then
      FDfe_Fortes.PosCanhoto := prCabecalho
    else
      FDfe_Fortes.PosCanhoto := prRodape;

    Configuracoes.Arquivos.PathNFe := Concat(FCtrlInstitution.PathPublico,'Nfe');
    Configuracoes.Arquivos.PathInu := Concat(FCtrlInstitution.PathPublico,'Inu');
    Configuracoes.Arquivos.PathEvento := Concat(FCtrlInstitution.PathPublico,'Eve');

    Configuracoes.Geral.FormaEmissao := StrToTpEmis(Lc_Ok,IntToStr(StrToIntDef(FConfig.ConfigNfe.Registro.TipoEmissao,0)+1));

    Configuracoes.Geral.Salvar := True;

    Configuracoes.WebServices.UF := FCtrlInstitution.Fiscal.Endereco.Estado.Registro.Abreviatura;
    FCtrlInstitution.Fiscal.Telefone.Registro.Codigo  := FCtrlInstitution.Registro.Codigo;
    FCtrlInstitution.Fiscal.Telefone.Registro.Tipo    := 'Comercial';
    FCtrlInstitution.Fiscal.Telefone.getByKey;
    DANFE.Email := FCtrlInstitution.Fiscal.Telefone.Registro.Numero;

    FCtrlInstitution.Fiscal.MidiaSocial.Registro.Codigo  := FCtrlInstitution.Registro.Codigo;
    FCtrlInstitution.Fiscal.MidiaSocial.Registro.Tipo    := 'www';
    FCtrlInstitution.Fiscal.MidiaSocial.getByKey;
    DANFE.Site := FCtrlInstitution.Fiscal.MidiaSocial.Registro.Link;


    if FConfig.ConfigNfe.Registro.Ambiente = '0' then
      Configuracoes.WebServices.Ambiente := taProducao
    else
      Configuracoes.WebServices.Ambiente := taHomologacao;

    Configuracoes.Geral.VersaoDF := ve400;

    Configuracoes.WebServices.UF            := FCtrlInstitution.Fiscal.Endereco.Estado.Registro.Abreviatura;
    Configuracoes.WebServices.Ambiente      := StrToTpAmb(Lc_Ok,IntToStr(StrToIntDef(FConfig.ConfigNfe.Registro.Ambiente,0)+1));
    Configuracoes.WebServices.Visualizar    := (FConfig.ConfigNfe.Registro.VisualizarMensagem = 'S');
    Configuracoes.Arquivos.SalvarEvento     := true;
    Configuracoes.Arquivos.SepararPorCNPJ   := False;
    Configuracoes.Arquivos.SepararPorIE     := False;
    Configuracoes.Arquivos.SepararPorModelo := False;
    Configuracoes.Arquivos.SepararPorAno    := False;
    Configuracoes.Arquivos.SepararPorMes    := False;
    Configuracoes.Arquivos.SepararPorDia    := False;
    Configuracoes.Geral.AtualizarXMLCancelado := True;
    Configuracoes.Geral.ValidarDigest := False;

    Configuracoes.WebServices.SSLType :=  TSSLType.LT_TLSv1_2;

    Configuracoes.Geral.SSLLib := TSSLLib.libOpenSSL;
    Configuracoes.Geral.SSLCryptLib := TSSLCryptLib.cryOpenSSL;
    Configuracoes.Geral.SSLHttpLib := TSSLHttpLib.httpOpenSSL;
    Configuracoes.Geral.SSLXmlSignLib := TSSLXmlSignLib.xsLibXml2;


    LocalCerti := concat(FCtrlInstitution.PathPrivado, 'cert_', FCtrlInstitution.Fiscal.Juridica.Registro.CNPJ,'.pfx');
    SSL.DescarregarCertificado;
    if FileExists(LocalCerti) then
    Begin
      Configuracoes.Certificados.URLPFX := '';
      {'"CarregarCertificadoDeNumeroSerie" "não suportado em: TDFeOpenSSL"
        Este erro acontece ao usar o open SSL e preencher o campo abaixo...ele deve estar branco
      }
      Configuracoes.Certificados.NumeroSerie  := ''; // SSL.CertNumeroSerie;
      Configuracoes.Certificados.ArquivoPFX   := LocalCerti;
      Configuracoes.Certificados.Senha        := FConfig.ConfigNfe.Registro.Senha;
    End;
    //SSL.CertDataVenc;

    DANFE.Logo := '';
    if FCarregaLogo then
    Begin
      //Verificar se há arquivo para a logomarca da Empresa
      Lc_Arq_Logo := concat('logo_' , FCtrlInstitution.Registro.Codigo.ToString, '.jpg');
      DANFE.Logo       := FCtrlInstitution.PathImage + Lc_Arq_Logo;
    end;
    Configuracoes.Arquivos.PathSchemas := FCtrlInstitution.PathPrivado +  'Schemas\';

    if Trim(FCtrlInstitution.PathPublico) <> '' then
    Begin
      if not DirectoryExists(FCtrlInstitution.PathPublico + '\xml\nfe\') then
        ForceDirectories(FCtrlInstitution.PathPublico + '\xml\nfe\');
    end;
  End;
end;

constructor TControllerNfe55.Create(AOwner: TComponent);
begin
  inherited;
  FConfig := TControllerConfigNfe55.Create(Self);
  FDfe_Fortes := TACBrNFeDANFeRL.Create(self);
  FNfe.DANFE := FDfe_Fortes;
  FRetorno := TControllerInvoiceReturn55.Create(self);
end;

destructor TControllerNfe55.Destroy;
begin
  FConfig.DisposeOf;
  FDfe_Fortes.DisposeOf;
  FRetorno.DisposeOf;
  inherited;
end;

procedure TControllerNfe55.FinalizaCancelamento;
Begin
  {
  MM_Acompanhamento.Lines.Add('APAGANDO MOVIMENTO FINANCEIRO...');
  Pc_ApagaMovimFinanceiro(It_Cd_Nota);
  Financeiro.Clear;
  Financeiro.Registro.CodigoNota := It_Cd_Nota;
  Financeiro.deleteByNota;
  MM_Acompanhamento.Lines.Add('APAGANDO COMISSÃO...');
  Pc_ApagaComissaoFaturamento( It_Cd_Pedido);

  MM_Acompanhamento.Lines.Add('ATUALIZANDO SITUAÇÃO DA NOTA...');
  NotaFiscal.Registro.Codigo := iT_CD_NOTA;
  NotaFiscal.Registro.Situacao := 'C';
  NotaFiscal.AlteraStatus;

  Pc_CancelaVendaComercioEletronico(It_Cd_Pedido);
  Pc_Apaga_conserto(It_Cd_Pedido);
  Pc_ApagaVendedor( It_Cd_Pedido);
  Pc_Retornodevolucao(Qr_Itens); // Devolução modelo Genio

  NotaFiscal.AtualizaSeries(Qr_Nota.FieldByName('NFL_TIPO').AsString,Qr_Itens);
  MM_Acompanhamento.Lines.Add('ATUALIZANDO OS ITENS DA NOTA...');
  Pc_AtualizarItensNota(Qr_Nota.FieldByName('NFL_TIPO').AsString,
                        'AUTORIZADA',
                        It_Cd_Nota,
                        It_Cd_Pedido,
                        Qr_Itens);
  NotaFiscal.Pedido.Itens.BaseTroca.Registro.Ordem := It_Cd_Pedido;
  NotaFiscal.Pedido.Itens.BaseTroca.deleteByOrdem;

  MM_Acompanhamento.Lines.Add('APAGANDO ESTOQUE...');
  Pc_AtualizacaoEstoqueNota('AUTORIZADA', Qr_Nota.FieldByName('PED_TIPO').AsInteger, Qr_Nota.FieldByName('PED_CODIGO').AsInteger);
  // Pc_AtualizarItensDevolucao(Qr_Nota.FieldByName('NFL_TIPO').AsString,Qr_Itens);//Devolução modelo Winkert - comentei pois na nfe não tem devolução assim


  MM_Acompanhamento.Lines.Add('ATUALIZANDO SITUAÇÃO DO PEDIDO...');
  NotaFiscal.Pedido.Registro.Codigo   := It_Cd_Pedido;
  NotaFiscal.Pedido.Registro.Faturado := 'C';
  NotaFiscal.Pedido.alteraStatus;
  }
end;

procedure TControllerNfe55.getAuthorization;
begin
  GeraDadosDanfe;
end;

procedure TControllerNfe55.handlReturn;
begin
  inherited;
  FCodigoInternoRetorno := FRetorno.getInternalIDReturn(FCodigoNfeRetorno);

  FRetorno.Registro.Codigo           := FInvoice.Registro.Codigo;
  FRetorno.Registro.Estabelecimento  := FInvoice.Registro.Estabelecimento;
  FRetorno.Registro.Terminal         := FInvoice.Registro.Terminal;
  FRetorno.Registro.Numero           := FInvoice.Registro.Numero;
  FRetorno.Registro.Serie            := FInvoice.Registro.Serie;
  FRetorno.Registro.Status           := FCodigoInternoRetorno;
  FRetorno.Registro.NomeArquivo      := FFileXML;
  FRetorno.Registro.Motivo           := FNFeMensagemRetorno;
  FRetorno.save;

  if (FRetorno.Registro.Status = 5) then
  Begin
    // processo de cancelamento para nota denegada
    FinalizaCancelamento;
  end;
end;

procedure TControllerNfe55.inicializa;
begin
  FConfig.Registro.Estabelecimento := FCtrlInstitution.Registro.Codigo;
  FConfig.getByKey;
  ConfiguraComponente
end;

procedure TControllerNfe55.UpdateInvoiceDateTime;
begin
  inherited;
  if ( FNfe.WebServices.Retorno.cStat = 100 )  then
  Begin
    with FInvoice do
    Begin
      Registro.Data_emissao := FDataRetorno;
      updateDataHora;
    End;
  End;

end;

procedure TControllerNfe55.UpdateRetornoNFe55;
begin
  inherited;

end;

function TControllerNfe55.ValidateAuthorization: Boolean;
begin
  Result := True;

end;

end.
