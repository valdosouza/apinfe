unit ControllerNfe55;

interface

uses
  ControllerNfe, System.Classes,ControllerConfigNfe55,
  ACBrDFeReport, ACBrDFeDANFeReport, ACBrNFeDANFeRLClass, pcnConversaoNFe,
  pcnConversao, System.SysUtils,
  ControllerInvoiceReturn55;

type
  TControllerNfe55 = Class(TControllerNFe)
    Private
       procedure ConfiguraComponente;

    protected
      FConfig : TControllerConfigNfe55;
      FDfe_Fortes: TACBrNFeDANFeRL;
      FRetorno : TControllerInvoiceReturn55;
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
begin
  FDfe_Fortes.ExibeDadosISSQN := True;
  FNfe.Configuracoes.Geral.ModeloDF := moNFe;
  FDfe_Fortes.ACBrNFe := FNfe;
  //MArgem Direita
  //FDfe_Fortes.MargemEsquerda := StrToIntDef(Fc_Tb_Geral('L','NFE_MARGEM_ESQUERDA','5'),5);
  //FDfe_Fortes.MargemSuperior := StrToIntDef(Fc_Tb_Geral('L','NFE_MARGEM_SUPERIOR','5'),5);
  //FDfe_Fortes.MargemInferior := StrToIntDef(Fc_Tb_Geral('L','NFE_MARGEM_INFERIOR','10'),10);

  FNfe.DANFE := FDfe_Fortes;
  //Nfe.DANFE.Impressora := Printer.Printers[Printer.PrinterIndex];
  FDfe_Fortes.ACBrNFe := FNfe;

  FNfe.DANFE.TipoDANFE  := StrToTpImp(Lc_Ok,FConfig.Registro.Orientacao);
  if (FConfig.Registro.Recebimento = '0') then
    FDfe_Fortes.PosCanhoto := prCabecalho
  else
    FDfe_Fortes.PosCanhoto := prRodape;
  FCtrlInstitution.getRepository(true,'Nfe55');
  FNfe.Configuracoes.Arquivos.PathNFe    := FCtrlInstitution.PathPublico;
  FNfe.Configuracoes.Arquivos.PathInu    := FCtrlInstitution.PathPublico;
  FNfe.Configuracoes.Arquivos.PathEvento := FCtrlInstitution.PathPublico;

end;

constructor TControllerNfe55.Create(AOwner: TComponent);
begin
  inherited;
  FConfig := TControllerConfigNfe55.Create(Self);
  FDfe_Fortes := TACBrNFeDANFeRL.Create(self);
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
  inherited;
  //
  FConfig.Registro.Estabelecimento := FCtrlInstitution.Registro.Codigo;
  FConfig.getByKey;
  //

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
