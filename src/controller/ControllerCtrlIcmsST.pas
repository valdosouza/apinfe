unit ControllerCtrlIcmsST;

interface
uses IBX.IBDatabase,Classes, SysUtils,BaseController,
      tblCtrlIcmsST ,  Generics.Collections, FireDAC.Comp.Client;


Type
  TListCtrlIcmsST = TObjectList<TCtrlIcmsST>;
  TControllerCtrlIcmsST = Class(TBaseController)
  private

  public
    Registro : TCtrlIcmsST;
    Lista : TListCtrlIcmsST;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    function atualiza:Boolean;
    function insere:boolean;
    Function GetListByProduto:boolean;
    Function GetList:boolean;
    Function delete:boolean;
    Function deleteByOrigem:boolean;
    Function GetByDestino:boolean;
    function ChecarQtdeDisp:Integer;
    function AjustaLegado:Boolean;
  End;

implementation

{ TControllerCtrlIcmsST }

function TControllerCtrlIcmsST.ChecarQtdeDisp: Integer;
Var
  Lc_Qry : TFDQuery;
  LCItem : TCtrlIcmsST;
begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      sql.Add(concat(
          'SELECT *                                                 ',
          'FROM tb_ctrl_icms_st                                     ',
          'WHERE (tb_institution_id=:tb_institution_id )            ',
          'AND   tb_product_id=:tb_product_id                       ',
          'AND  ( (tb_order_item_dest IS NULL) OR (tb_order_item_dest =0) ) '
      ));
      ParamByName('tb_institution_id').AsInteger := Registro.Estabelecimento;
      ParamByName('tb_product_id').AsInteger := Registro.Produto;
      Active := True;
      FetchAll;
      First;
      exist := (RecordCount > 0);
      Result := RecordCount;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

procedure TControllerCtrlIcmsST.Clear;
begin
  clearObj(Registro);
end;

constructor TControllerCtrlIcmsST.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TCtrlIcmsST.Create;
  Lista :=TListCtrlIcmsST.Create;
end;

function TControllerCtrlIcmsST.delete: boolean;
begin
  deleteObj(Registro)
end;

function TControllerCtrlIcmsST.deleteByOrigem: boolean;
Var
  Lc_Qry : TFDQuery;
begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      sql.Add(concat(
          'DELETE                                        ',
          'FROM tb_ctrl_icms_st                          ',
          'WHERE (tb_institution_id=:tb_institution_id ) ',
          'AND   (tb_order_item_orig=:tb_order_item_orig)        '
      ));
      ParamByName('tb_institution_id').AsInteger := Registro.Estabelecimento;
      ParamByName('tb_order_item_orig').AsInteger := Registro.Origem;
      ExecSQL;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

destructor TControllerCtrlIcmsST.Destroy;
begin
  Registro.DisposeOf;
  Lista.DisposeOf;
  inherited;
end;

function TControllerCtrlIcmsST.GetByDestino: boolean;
Var
  Lc_Qry : TFDQuery;
  LCItem : TCtrlIcmsST;
begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      sql.Add(concat(
          'SELECT *                                                 ',
          'FROM tb_ctrl_icms_st                                     ',
          'WHERE (tb_institution_id=:tb_institution_id )            ',
          'AND   (tb_order_item_dest=:tb_order_item_dest)                   '
      ));
      ParamByName('tb_institution_id').AsInteger := Registro.Estabelecimento;
      ParamByName('tb_order_item_dest').AsInteger := Registro.Destino;
      Active := True;
      FetchAll;
      First;
      exist := (RecordCount > 0);
      if exist then
      Begin
        LCItem := TCtrlIcmsST.Create;
        LCItem.Estabelecimento := 0;
        LCItem.Codigo := 0;
        LCItem.AliqST := FieldByName('PST').AsFloat;
        while not eof do
        Begin
          LCItem.ValorBaseSTRetido    := LCItem.ValorBaseSTRetido   + FieldByName('vbc_st_ret').AsFloat;
          LCItem.ValorICMSSubstituto  := LCItem.ValorICMSSubstituto + FieldByName('vicms_substituto').AsFloat;
          LCItem.ValorICMSSTRetido    := LCItem.ValorICMSSTRetido   + FieldByName('vicms_st_ret').AsFloat;
          Next;
        End;
        Registro := LCItem;
      End;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;


end;

function TControllerCtrlIcmsST.GetList: boolean;
Var
  Lc_Qry : TFDQuery;
  LCItem : TCtrlIcmsST;
begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      sql.Add(concat(
          'SELECT *                                                 ',
          'FROM tb_ctrl_icms_st                                     ',
          'WHERE (tb_institution_id=:tb_institution_id )            '
      ));
     ParamByName('tb_institution_id').AsInteger := Registro.Estabelecimento;
     Active := True;
     First;
     lista.Clear;
     while not eof do
     Begin
        LCItem := TCtrlIcmsST.Create;
        get(Lc_Qry,LCItem);
        Lista.Add(LCItem);
      Next;
     End;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;

end;

function TControllerCtrlIcmsST.GetListByProduto: boolean;
Var
  Lc_Qry : TFDQuery;
  LCItem : TCtrlIcmsST;
begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      sql.Add(concat(
          'SELECT *                                                 ',
          'FROM tb_ctrl_icms_st                                     ',
          'WHERE (tb_institution_id=:tb_institution_id )            ',
          'AND   tb_product_id=:tb_product_id                       ',
          'AND  ((tb_order_item_dest IS NULL) OR (tb_order_item_dest =0) OR (tb_order_item_dest=:tb_order_item_dest) ) '
      ));
     ParamByName('tb_institution_id').AsInteger := Registro.Estabelecimento;
     ParamByName('tb_product_id').AsInteger := Registro.Produto;
     ParamByName('tb_order_item_dest').AsInteger := Registro.Destino;
     Active := True;
     First;
     lista.Clear;
     while not eof do
     Begin
        LCItem := TCtrlIcmsST.Create;
        get(Lc_Qry,LCItem);
        Lista.Add(LCItem);
      Next;
     End;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerCtrlIcmsST.insere: boolean;
begin
  Try
    REsult := True;
    if registro.codigo = 0 then
      registro.codigo := getNextByField(Registro,'id',Registro.Estabelecimento);
    InsertObj(Registro);
  Except
    REsult := False
  End;
end;

function TControllerCtrlIcmsST.AjustaLegado: Boolean;
Var
  Lc_Qry : TFDQuery;
  LCItem : TCtrlIcmsST;
  I,F : Integer;
begin
  Try
    Lc_Qry := createQuery;
    Lc_Qry.sql.Clear;
    Lc_Qry.sql.Add(concat(
                  'select ',
                  '0 ID,  ',
                  'tb_institution_id ,  ',
                  'i.itf_codigo tb_order_item_orig, ',
                  'i.itf_codpro tb_product_id,  ',
                  'ic.icm_vl_bc_st vbc_st_ret, ',
                  'ic.icm_aq_st PST,  ',
                  'ic.icm_vl_nr vicms_substituto, ',
                  'ic.icm_vl_st vicms_st_ret, ',
                  ' 0 tb_order_item_dest, ',
                  'i.quantity   ',
                  'from tb_order_item i  ',
                  '  inner join tb_order_purchase ord  ',
                  '  on (ord.id = i.tb_order_id) ',
                  '   and (ord.tb_institution_id = i.tb_institution_id) ',

                  '  inner join tb_invoice n      ',
                  '  on (n.id = i.tb_order_id) ',
                  '  and (n.tb_institution_id = i.tb_institution_id)',

                  '  inner join tb_order_item_icms ic      ',
                  '  on (ic.icm_coditf = i.itf_codigo) ',
                  '  and (ic.tb_institution_id = i.tb_institution_id) ',

                  '  LEFT OUTER JOIN tb_ctrl_icms_st st ',
                  '  on (st.tb_order_item_orig = i.id) ',
                  '   and (st.tb_institution_id = i.tb_institution_id) ',

                  'where icm_vl_bc_st > 0  ',
                  'and st.tb_order_item_orig is null '
      ));
    Lc_Qry.Active := True;
    Lc_Qry.First;
    lista.Clear;
    while not Lc_Qry.eof do
    Begin
      F := Trunc(Lc_Qry.FieldByName('quantity').AsFloat);
      for I := 1 to F do
      Begin
        LCItem := TCtrlIcmsST.Create;
        LCItem.Estabelecimento     := Lc_Qry.FieldByName('tb_institution_id').AsInteger;
        LCItem.codigo              := 0;
        LCItem.Origem              := Lc_Qry.FieldByName('tb_order_item_orig').AsInteger;
        LCItem.Produto             := Lc_Qry.FieldByName('tb_product_id').AsInteger;
        LCItem.ValorBaseSTRetido   := Lc_Qry.FieldByName('vbc_st_ret').AsFloat / F;
        LCItem.AliqST              := Lc_Qry.FieldByName('PST').AsFloat;
        LCItem.ValorICMSSubstituto := Lc_Qry.FieldByName('vicms_substituto').AsFloat / F;
        LCItem.ValorICMSSTRetido   := Lc_Qry.FieldByName('vicms_st_ret').AsFloat / F;
        LCItem.Destino             := 0;
        insertObj(LCItem);
      End;
      Lc_Qry.Next;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerCtrlIcmsST.atualiza:Boolean;
begin
  Try
    REsult := True;
    updateObj(Registro);
  Except
    REsult := False
  End;
end;

end.
