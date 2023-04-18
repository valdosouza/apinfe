unit tblCtrlIcmsST;

interface

Uses GenericEntity,CAtribEntity, Classes, SysUtils;

Type
  //nome da classe de entidade
  [TableName('tb_ctrl_icms_st')]
  TCtrlIcmsST = Class(TGenericEntity)

  private
    FPST: Real;
    Ftb_product_id: integer;
    Fvbc_st_ret: Real;
    FID: integer;
    Fvicms_st_ret: real;
    Ftb_institution_id: integer;
    Ftb_order_item_dest: Integer;
    Fvicms_substituto: real;
    Ftb_order_item_orig: Integer;
    procedure setFID(const Value: integer);
    procedure setFPST(const Value: Real);
    procedure setFtb_institution_id(const Value: integer);
    procedure setFtb_order_item_dest(const Value: Integer);
    procedure setFtb_order_item_orig(const Value: Integer);
    procedure setFtb_product_id(const Value: integer);
    procedure setFvbc_st_ret(const Value: Real);
    procedure setFvicms_st_ret(const Value: real);
    procedure setFvicms_substituto(const Value: real);

  public
    [KeyField('tb_institution_id')]
    [FieldName('tb_institution_id')]
    property Estabelecimento: integer  read Ftb_institution_id write setFtb_institution_id;

    [KeyField('id')]
    [FieldName('id')]
    property Codigo: integer  read FID write setFID;

    [FieldName('tb_order_item_orig')]
    property Origem: Integer  read Ftb_order_item_orig write setFtb_order_item_orig;

    [FieldName('tb_product_id')]
    property Produto: integer read Ftb_product_id write setFtb_product_id;

    [FieldName('vbc_st_ret')]
    property ValorBaseSTRetido: Real  read Fvbc_st_ret write setFvbc_st_ret;

    [FieldName('pst')]
    property AliqST: Real read FPST write setFPST;

    [FieldName('vicms_substituto')]
    property ValorICMSSubstituto: real read Fvicms_substituto write setFvicms_substituto;

    [FieldName('vicms_st_ret')]
    property ValorICMSSTRetido: real read Fvicms_st_ret  write setFvicms_st_ret;

    [FieldName('tb_order_item_dest')]
    property Destino: Integer  read Ftb_order_item_dest write setFtb_order_item_dest;

  End;


implementation

{ TCtrlIcmsST }

procedure TCtrlIcmsST.setFID(const Value: integer);
begin
  FID := Value;
end;

procedure TCtrlIcmsST.setFPST(const Value: Real);
begin
  FPST := Value;
end;

procedure TCtrlIcmsST.setFtb_institution_id(const Value: integer);
begin
  Ftb_institution_id := Value;
end;

procedure TCtrlIcmsST.setFtb_order_item_dest(const Value: Integer);
begin
  Ftb_order_item_dest := Value;
end;

procedure TCtrlIcmsST.setFtb_order_item_orig(const Value: Integer);
begin
  Ftb_order_item_orig := Value;
end;

procedure TCtrlIcmsST.setFtb_product_id(const Value: integer);
begin
  Ftb_product_id := Value;
end;

procedure TCtrlIcmsST.setFvbc_st_ret(const Value: Real);
begin
  Fvbc_st_ret := Value;
end;

procedure TCtrlIcmsST.setFvicms_st_ret(const Value: real);
begin
  Fvicms_st_ret := Value;
end;

procedure TCtrlIcmsST.setFvicms_substituto(const Value: real);
begin
  Fvicms_substituto := Value;
end;

end.
