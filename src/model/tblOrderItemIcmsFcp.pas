unit tblOrderItemIcmsFcp;

interface

Uses GEnericEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('tb_order_item_icms_fcp')]
  TOrderItemIcmsFcp = Class(TGenericEntity)
  private
    FPFCP: Real;
    FVFCP: Real;
    FPST: Real;
    Ftb_order_item_id: Integer;
    FVBCFCPST: Real;
    FVBCFCPSTRET: Real;
    FPFCPST: Real;
    Ftb_institution_id: Integer;
    FPFCPSTRET: Real;
    FVFCPST: Real;
    FVFCPSTRET: Real;
    Fterminal: Integer;
    Ftb_order_id: Integer;
    FVBCFCP: Real;
    Fupdated_at: TDAteTime;
    Fcreated_at: TDAteTime;
    procedure setFPFCP(const Value: Real);
    procedure setFPFCPST(const Value: Real);
    procedure setFPFCPSTRET(const Value: Real);
    procedure setFPST(const Value: Real);
    procedure setFtb_institution_id(const Value: Integer);
    procedure setFtb_order_id(const Value: Integer);
    procedure setFtb_order_item_id(const Value: Integer);
    procedure setFterminal(const Value: Integer);
    procedure setFVBCFCP(const Value: Real);
    procedure setFVBCFCPST(const Value: Real);
    procedure setFVBCFCPSTRET(const Value: Real);
    procedure setFVFCP(const Value: Real);
    procedure setFVFCPST(const Value: Real);
    procedure setFVFCPSTRET(const Value: Real);
    procedure setFcreated_at(const Value: TDAteTime);
    procedure setFupdated_at(const Value: TDAteTime);


  public
    [KeyField('tb_order_item_id')]
    [FieldName('tb_order_item_id')]
    property ItemOrdem: Integer read Ftb_order_item_id write setFtb_order_item_id;

    [KeyField('tb_order_id')]
    [FieldName('tb_order_id')]
    property Ordem: Integer read Ftb_order_id write setFtb_order_id;

    [KeyField('tb_institution_id')]
    [FieldName('tb_institution_id')]
    property Estabelecimento: Integer read Ftb_institution_id write setFtb_institution_id;

    [FieldName('terminal')]
    [KeyField('terminal')]
    property Terminal: Integer read Fterminal write setFterminal;

    [FieldName('vbcfcp')]
    property BaseCalculo: Real read FVBCFCP write setFVBCFCP;

    [FieldName('pfcp')]
    property Percentual: Real read FPFCP write setFPFCP;

    [FieldName('vfcp')]
    property Valor: Real read FVFCP write setFVFCP;

    [FieldName('vbcfcpst')]
    property BaseCalculoST: Real read FVBCFCPST write setFVBCFCPST;

    [FieldName('pfcpst')]
    property PercentualST: Real read FPFCPST write setFPFCPST;

    [FieldName('vfcpst')]
    property ValorST: Real read FVFCPST write setFVFCPST;

    [FieldName('pst')]
    property AliqSupConsumidor: Real read FPST write setFPST;

    [FieldName('vbcfcpstret')]
    property BaseCalculoSTRET: Real read FVBCFCPSTRET write setFVBCFCPSTRET;

    [FieldName('pfcpstret')]
    property PercentualSTRET: Real read FPFCPSTRET write setFPFCPSTRET;

    [FieldName('vfcpstret')]
    property ValorSTRET: Real read FVFCPSTRET write setFVFCPSTRET;

    [FieldName('created_at')]
    property RegistroCriado: TDAteTime read Fcreated_at write setFcreated_at;

    [FieldName('updated_at')]
    property RegistroAlterado: TDAteTime read Fupdated_at write setFupdated_at;

  End;

implementation

{ TOrderItemIcmsFcp }

procedure TOrderItemIcmsFcp.setFcreated_at(const Value: TDAteTime);
begin
  Fcreated_at := Value;
end;

procedure TOrderItemIcmsFcp.setFPFCP(const Value: Real);
begin
  FPFCP := Value;
end;

procedure TOrderItemIcmsFcp.setFPFCPST(const Value: Real);
begin
  FPFCPST := Value;
end;

procedure TOrderItemIcmsFcp.setFPFCPSTRET(const Value: Real);
begin
  FPFCPSTRET := Value;
end;

procedure TOrderItemIcmsFcp.setFPST(const Value: Real);
begin
  FPST := Value;
end;

procedure TOrderItemIcmsFcp.setFtb_institution_id(const Value: Integer);
begin
  Ftb_institution_id := Value;
end;

procedure TOrderItemIcmsFcp.setFtb_order_id(const Value: Integer);
begin
  Ftb_order_id := Value;
end;

procedure TOrderItemIcmsFcp.setFtb_order_item_id(const Value: Integer);
begin
  Ftb_order_item_id := Value;
end;

procedure TOrderItemIcmsFcp.setFterminal(const Value: Integer);
begin
  Fterminal := Value;
end;

procedure TOrderItemIcmsFcp.setFupdated_at(const Value: TDAteTime);
begin
  Fupdated_at := Value;
end;

procedure TOrderItemIcmsFcp.setFVBCFCP(const Value: Real);
begin
  FVBCFCP := Value;
end;

procedure TOrderItemIcmsFcp.setFVBCFCPST(const Value: Real);
begin
  FVBCFCPST := Value;
end;

procedure TOrderItemIcmsFcp.setFVBCFCPSTRET(const Value: Real);
begin
  FVBCFCPSTRET := Value;
end;

procedure TOrderItemIcmsFcp.setFVFCP(const Value: Real);
begin
  FVFCP := Value;
end;

procedure TOrderItemIcmsFcp.setFVFCPST(const Value: Real);
begin
  FVFCPST := Value;
end;

procedure TOrderItemIcmsFcp.setFVFCPSTRET(const Value: Real);
begin
  FVFCPSTRET := Value;
end;

end.
