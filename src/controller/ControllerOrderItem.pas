unit ControllerOrderItem;

interface
  uses System.Classes, System.SysUtils,BaseController,
      tblOrderItem, tblEntity, Md5,TypesCollection,
      FireDAC.Stan.Param, System.Generics.Collections,
      Datasnap.DBClient,Data.DB,FireDAC.Comp.Client,
      tblOrderItemIcms,tblOrderItemCofins,tblOrderItemPis,tblOrderItemIpi,
      ControllerMerchandise, ControllerOrderItemDetail,
      ControllerStockStatement, ControllerOrderItemCofins, ControllerOrderItemPis,
      ControllerOrderItemIcms,ControllerOrderItemII,ControllerOrderItemIPI,
      ControllerOrderItemDetached, ControllerOrderItemIpiBack;
Type
  TControllerOrderItem = Class(TBaseController)
    procedure clear;
  private

  protected
    function getNext:Integer;
  public
    Registro : TOrderItem;
    Mercadoria : TControllerMerchandise;
    Detalhes : TControllerOrderItemDetail;
    MovimentoEstoque : TControllerStockStatement;
    Icms   : TControllerOrderItemIcms;
    Ipi    : TControllerOrderItemIPI;
    IpiBack : TControllerOrderItemIPIBAck;
    Cofins : TControllerOrderItemCofins;
    Pis    : TControllerOrderItemPis;
    II     : TControllerOrderItemII;
    Avulso : TControllerOrderItemDetached;
    Lista: TListOrdemItem;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure getList;
    function getByKey:Boolean;
    function save:boolean;
    function insert:boolean;
    function update:boolean;
    function delete:boolean;
    function deletebyOrder:boolean;
    function readByField:Boolean;
    function getListSpl:TFDQuery;
    function ThereStatement:Boolean;
  End;

implementation

{ ControllerOrderItem}

procedure TControllerOrderItem.clear;
begin
  clearObj(Registro);
  Lista.Clear;
end;

constructor TControllerOrderItem.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TOrderItem.Create;
  Detalhes := TControllerOrderItemDetail.Create(Self);
  Lista := TListOrdemItem.Create;
  Mercadoria := TControllerMerchandise.Create(Self);

  Icms    := TControllerOrderItemIcms.Create(Self);
  Ipi     := TControllerOrderItemIPI.Create(Self);
  IpiBack := TControllerOrderItemIPIBAck.Create(Self);
  Cofins  := TControllerOrderItemCofins.Create(Self);
  Pis     := TControllerOrderItemPis.Create(Self);
  II      := TControllerOrderItemII.Create(Self);
  Avulso  := TControllerOrderItemDetached.Create(Self);
end;

function TControllerOrderItem.delete: boolean;
begin
  try
    deleteObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerOrderItem.deletebyOrder: boolean;
var
  Lc_Qry : TFDQuery;
  LITem : TOrderItem;
begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      sql.add(concat('DELETE ',
                      'FROM tb_order_item ',
                      'WHERE tb_institution_id =:institution_id ',
                      ' AND tb_order_id =:order_id ',
                      ' AND terminal =:terminal '
                      ));

      ParamByName('institution_id').AsInteger := Registro.Estabelecimento;
      ParamByName('order_id').AsInteger := Registro.Ordem;
      ParamByName('terminal').AsInteger := Registro.Terminal;
      ExecSQL;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

destructor TControllerOrderItem.Destroy;
begin
  Mercadoria.DisposeOf;
  Lista.DisposeOf;
  Registro.DisposeOf;
  Detalhes.DisposeOf;

  Icms.DisposeOf;
  IpiBack.DisposeOf;
  Ipi.DisposeOf;
  Cofins.DisposeOf;
  Pis.DisposeOf;
  II.DisposeOf;
  inherited;
end;


function TControllerOrderItem.save: boolean;
begin
  try
    SaveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerOrderItem.ThereStatement: Boolean;
var
  Lc_Qry : TFDQuery;
  LITem : TOrderItem;
begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      sql.add(concat(
                'select id ',
                'from tb_order_item ',
                'where tb_institution_id =:tb_institution_id ',
                'and tb_product_id =:tb_product_id ',
                'limit 1 '
      ));
      ParamByName('tb_institution_id').AsInteger := Registro.Estabelecimento;
      ParamByName('tb_product_id').AsInteger := Registro.Produto;
      Active := True;
      FetchAll;
      Result := (RecordCount > 0);
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerOrderItem.update: boolean;
begin
  Result := updateObj(Registro);
end;


function TControllerOrderItem.getByKey: Boolean;
begin
  _getByKey(Registro);
end;

procedure TControllerOrderItem.getList;
var
  Lc_Qry : TFDQuery;
  LITem : TOrderItem;
begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                      'FROM tb_order_item oi ',
                      'WHERE tb_institution_id =:tb_institution_id ',
                      ' AND tb_order_id =:tb_order_id ',
                      ' AND terminal =:terminal ',
                      ' ORDER BY id '));

      ParamByName('tb_institution_id').AsInteger := Registro.Estabelecimento;
      ParamByName('tb_order_id').AsInteger := Registro.Ordem;
      ParamByName('terminal').AsInteger := Registro.Terminal;
      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LITem := TOrderItem.Create;
        get(Lc_Qry,LITem);
        Lista.add(LITem);
        next;
      end;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerOrderItem.getListSpl:TFDQuery;
Var
  Lc_Qry :TFDQuery;
  I:Integer;
  LcSqlStr : String;
Begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      sql.Clear;
      sql.Add(concat(
            'select ',
            'oi.id, ',
            'oi.tb_order_id, ',
            'oi.tb_product_id, ',
            'pd.description,',
            'oi.quantity, ',
            'oi.unit_value, ',
            'oi.discount_aliquot, ',
            'oi.discount_value, ',
            '( ( oi.quantity * oi.unit_value) - oi.discount_value ) subtotal ',
            'from tb_order_item oi ',
            ' inner join tb_product pd ',
            ' on (oi.tb_product_id = pd.id) ',
            'where (oi.tb_order_id =:order_id) '
          ));
      //sql.Add(concat('Limit ', InttoStr( (Page * 20 ) - 20 ),',', InttoStr( (Page * 20 ) ) ));
      //Passagem parametros
      ParamByName('order_id').AsInteger := Registro.Ordem;

      Active := True;
      Result := Lc_Qry;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;

end;

function TControllerOrderItem.getNext:Integer;
var
  Lc_qry: TFDQuery;
begin
  Try
    Lc_qry := createQuery;
    with Lc_qry do
    Begin
      sql.Clear;
      sql.Add(concat(
                  'SELECT MAX(id) id ',
                  'FROM tb_order_item ',
                  ' where ( tb_institution_id =:tb_institution_id ) ',
                  ' and (tb_order_id =:tb_order_id) '
                  ));
      ParamByName('tb_institution_id').AsInteger := Registro.Estabelecimento;
      ParamByName('tb_order_id').AsInteger := Registro.Ordem;
      Active := True;
      First;
      result := StrToIntDef(FieldByName('id').AsString,0) + 1;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;

end;

function TControllerOrderItem.insert: boolean;
begin
  Registro.Codigo := getNext;
  Try
    insertObj(Registro);
    Result := True;
  Except
    Result := False;
  End;

end;

function TControllerOrderItem.readByField: Boolean;
var
  Lc_Qry : TFDQuery;
  LITem : TOrderItem;
  LcSqlText : String;
begin
  Lc_Qry := createQuery;
  with Lc_Qry, Registro do
  Begin
    LcSqlText := concat('SELECT * ',
                         'FROM tb_order_item oi ',
                         'WHERE tb_institution_id =:tb_institution_id ');

    if ( Codigo > 0) then
      LcSqlText := concat(LcSqlText,
                          'and (id =:id) ');
    if ( Ordem > 0) then
      LcSqlText := concat(LcSqlText,
                          'and (tb_order_id =:order_id) ');

    if ( Produto > 0) then
      LcSqlText := concat(LcSqlText,
                          'and ( tb_product_id =:product_id ) ');

    if ( Estoque > 0) then
      LcSqlText := concat(LcSqlText,
                          'and ( tb_stock_list_id =:stock_list_id ) ');

    if ( Quantidade > 0) then
      LcSqlText := concat(LcSqlText,
                          'and ( quantity =:quantity ) ');

    if ( ValorUnitario > 0) then
      LcSqlText := concat(LcSqlText,
                          'and ( unit_value =:unit_value ) ');

    if ( AliquotaDesconto > 0) then
      LcSqlText := concat(LcSqlText,
                          'and ( discount_aliquot =:discount_aliquot ) ');

    if ( ValorDesconto > 0) then
      LcSqlText := concat(LcSqlText,
                          'and ( discount_value =:discount_value ) ');
    //----------------------------------------------------------------
    sql.Add(LcSqlText);

    ParamByName('tb_institution_id').AsInteger := Estabelecimento;

    if ( Codigo > 0) then
      ParamByName('id').AsInteger := Ordem;

    if ( Ordem > 0) then
      ParamByName('order_id').AsInteger := Ordem;

    if ( Produto > 0) then
      ParamByName('product_id').AsInteger := Produto;

    if ( Estoque > 0) then
      ParamByName('stock_list_id').AsInteger := Estoque;

    if ( Quantidade > 0) then
      ParamByName('quantity').AsFloat := Quantidade;

    if ( ValorUnitario > 0) then
      ParamByName('unit_value').AsFloat := ValorUnitario;

    if ( AliquotaDesconto > 0) then
      ParamByName('discount_aliquot').AsFloat := AliquotaDesconto;

    if ( ValorDesconto > 0) then
      ParamByName('discount_value').AsFloat := ValorDesconto;

    Active := True;
    FetchAll;
    result := ( RecordCount > 0 );

    Codigo              := FieldByName('id').AsInteger;
    Estabelecimento     := FieldByName('tb_institution_id').AsInteger;
    Ordem               := FieldByName('tb_order_id').AsInteger;
    Produto             := FieldByName('tb_product_id').AsInteger;
    Estoque             := FieldByName('tb_stock_list_id').AsInteger;
    Quantidade          := FieldByName('quantity').AsFloat;
    ValorUnitario       := FieldByName('unit_value').AsFloat;
    AliquotaDesconto    := FieldByName('discount_aliquot').AsFloat;
    ValorDesconto       := FieldByName('discount_value').AsFloat;
    RegistroCriado      := FieldByName('created_at').AsDateTime;
    RegistroAlterado    := FieldByName('updated_at').AsDateTime;
    Close;
  end;
    FinalizaQuery(Lc_Qry);
end;

end.
