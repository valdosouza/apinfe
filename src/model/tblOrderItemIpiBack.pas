unit tblOrderItemIpiBack;

interface

Uses GEnericEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('tb_order_item_ipi_back')]
  TOrderItemIpiBack = Class(TGenericEntity)
  private
    FPFCP: Real;
    Fupdated_at: TDAteTime;
    Ftb_order_item_id: Integer;
    Ftb_institution_id: Integer;
    Fterminal: Integer;
    Ftb_order_id: Integer;
    FVBCFCP: Real;
    Fcreated_at: TDAteTime;
    procedure setFcreated_at(const Value: TDAteTime);
    procedure setFPFCP(const Value: Real);
    procedure setFtb_institution_id(const Value: Integer);
    procedure setFtb_order_id(const Value: Integer);
    procedure setFtb_order_item_id(const Value: Integer);
    procedure setFterminal(const Value: Integer);
    procedure setFupdated_at(const Value: TDAteTime);
    procedure setFVBCFCP(const Value: Real);

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

    [FieldName('v_ipi')]
    property Percentual: Real read FVBCFCP write setFVBCFCP;

    [FieldName('v_ipi')]
    property Valor: Real read FPFCP write setFPFCP;

    [FieldName('created_at')]
    property RegistroCriado: TDAteTime read Fcreated_at write setFcreated_at;

    [FieldName('updated_at')]
    property RegistroAlterado: TDAteTime read Fupdated_at write setFupdated_at;

  End;

implementation


{ TOrderItemIpiBack }

procedure TOrderItemIpiBack.setFcreated_at(const Value: TDAteTime);
begin
  Fcreated_at := Value;
end;

procedure TOrderItemIpiBack.setFPFCP(const Value: Real);
begin
  FPFCP := Value;
end;

procedure TOrderItemIpiBack.setFtb_institution_id(const Value: Integer);
begin
  Ftb_institution_id := Value;
end;

procedure TOrderItemIpiBack.setFtb_order_id(const Value: Integer);
begin
  Ftb_order_id := Value;
end;

procedure TOrderItemIpiBack.setFtb_order_item_id(const Value: Integer);
begin
  Ftb_order_item_id := Value;
end;

procedure TOrderItemIpiBack.setFterminal(const Value: Integer);
begin
  Fterminal := Value;
end;

procedure TOrderItemIpiBack.setFupdated_at(const Value: TDAteTime);
begin
  Fupdated_at := Value;
end;

procedure TOrderItemIpiBack.setFVBCFCP(const Value: Real);
begin
  FVBCFCP := Value;
end;

end.
