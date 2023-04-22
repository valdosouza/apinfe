unit ControllerOrderItemIpiBack;

interface
uses System.Classes, System.SysUtils,BaseController,
      tblOrderItemIpiBack, tblEntity, FireDAC.Comp.Client,
      FireDAC.Stan.Param, System.Generics.Collections;

Type
  TControllerOrderItemIpiBack = Class(TBaseController)
    procedure clear;
  private

  public
    Registro : TOrderItemIpiBack;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function save:boolean;
    function delete:boolean;
    function deleteByOrdem:boolean;
    function getbyKey:Boolean;
  End;

implementation

{ ControllerOrderItemIcms}


procedure TControllerOrderItemIpiBack.clear;
begin
  ClearObj(Registro);
end;

constructor TControllerOrderItemIpiBack.Create(AOwner: TComponent);
begin
inherited;
  Registro := TOrderItemIpiBack.Create;
end;

function TControllerOrderItemIpiBack.delete: boolean;
begin
  deleteObj(Registro)
end;

function TControllerOrderItemIpiBack.deleteByOrdem: boolean;
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
                'delete from tb_order_item_ipi_back ',
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

destructor TControllerOrderItemIpiBack.Destroy;
begin
  Registro.DisposeOf;
  inherited;
end;

function TControllerOrderItemIpiBack.getbyKey: Boolean;
begin
  _getByKey(Registro);
end;

function TControllerOrderItemIpiBack.save: boolean;
begin
  try
    saveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;


end.
