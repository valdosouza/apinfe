unit tblProductUfBenef;

interface

Uses CAtribEntity, Data.DB, GenericEntity;

Type

  [TableName('tb_product_uf_benef')]
  TProductUfBenef = Class(TGenericEntity)
  private
    FTB_PRODUTCT_ID: Integer;
    FCOD_BENEFITS: String;
    Fupdated_at: TDAteTime;
    Ftb_institution_id: Integer;
    FCST: String;
    FUF: String;
    Fcreated_at: TDAteTime;
    procedure setFCOD_BENEFITS(const Value: String);
    procedure setFcreated_at(const Value: TDAteTime);
    procedure setFCST(const Value: String);
    procedure setFtb_institution_id(const Value: Integer);
    procedure setFTB_PRODUTCT_ID(const Value: Integer);
    procedure setFUF(const Value: String);
    procedure setFupdated_at(const Value: TDAteTime);

  public
    [KeyField('tb_institution_id')]
    [FieldName('tb_institution_id')]
    property Estabelecimento: Integer read Ftb_institution_id write setFtb_institution_id;

    [KeyField('tb_product_id')]
    [FieldName('tb_product_id')]
    property Produto: Integer read FTB_PRODUTCT_ID write setFTB_PRODUTCT_ID;

    [KeyField('uf')]
    [FieldName('uf')]
    property Estado: String read FUF write setFUF;

    [KeyField('cst')]
    [FieldName('cst')]
    property CST: String read FCST write setFCST;

    [FieldName('cod_benefits')]
    property Beneficio: String read FCOD_BENEFITS write setFCOD_BENEFITS;

    [FieldName('created_at')]
    property RegistroCriado: TDAteTime read Fcreated_at write setFcreated_at;

    [FieldName('updated_at')]
    property RegistroAlterado: TDAteTime read Fupdated_at write setFupdated_at;

  End;


implementation

{ TProductUfBenef }

procedure TProductUfBenef.setFCOD_BENEFITS(const Value: String);
begin
  FCOD_BENEFITS := Value;
end;

procedure TProductUfBenef.setFcreated_at(const Value: TDAteTime);
begin
  Fcreated_at := Value;
end;

procedure TProductUfBenef.setFCST(const Value: String);
begin
  FCST := Value;
end;

procedure TProductUfBenef.setFtb_institution_id(const Value: Integer);
begin
  Ftb_institution_id := Value;
end;

procedure TProductUfBenef.setFTB_PRODUTCT_ID(const Value: Integer);
begin
  FTB_PRODUTCT_ID := Value;
end;

procedure TProductUfBenef.setFUF(const Value: String);
begin
  FUF := Value;
end;

procedure TProductUfBenef.setFupdated_at(const Value: TDAteTime);
begin
  Fupdated_at := Value;
end;

end.
