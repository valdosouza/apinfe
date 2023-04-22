unit ControllerOrderItemIcmsFcp;

interface
uses System.Classes, System.SysUtils,BaseController,
      tblOrderItemIcmsFcp, tblEntity, FireDAC.Comp.Client,
      FireDAC.Stan.Param, System.Generics.Collections;

Type
  TControllerOrderItemIcmsFcp = Class(TBaseController)
    procedure clear;
  private

  public
    Registro : TOrderItemIcmsFcp;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function save:boolean;
    function delete:boolean;
    function deleteByOrdem:boolean;
    function getbyKey:Boolean;
  End;

implementation

{ ControllerOrderItemIcms}


procedure TControllerOrderItemIcmsFcp.clear;
begin
  ClearObj(Registro);
end;

constructor TControllerOrderItemIcmsFcp.Create(AOwner: TComponent);
begin
inherited;
  Registro := TOrderItemIcmsFcp.Create;
end;

function TControllerOrderItemIcmsFcp.delete: boolean;
begin
  deleteObj(Registro)
end;

function TControllerOrderItemIcmsFcp.deleteByOrdem: boolean;
Var
  Lc_Qry : TFDQuery;
begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      Active := False;
      sql.Clear;
      sql.Add(concat(
                'delete from tb_order_item_icms ',
                'where ( tb_order_id =:order_id ) ',
                ' and (tb_institution_id =:institution_id) '
      ));
      ParamByName('order_id').AsInteger := Registro.Ordem;
      ParamByName('institution_id').AsInteger := Registro.Estabelecimento;
      ExecSQL;
    End;
  Finally
    Lc_Qry.close;
    FReeandNil(Lc_Qry)
  End;
end;

destructor TControllerOrderItemIcmsFcp.Destroy;
begin
  Registro.DisposeOf;
  inherited;
end;

function TControllerOrderItemIcmsFcp.getbyKey: Boolean;
begin
  _getByKey(Registro);
end;

function TControllerOrderItemIcmsFcp.save: boolean;
begin
  try
    saveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;


end.
