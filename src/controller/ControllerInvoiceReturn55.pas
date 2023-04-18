unit ControllerInvoiceReturn55;

interface
uses System.Classes, System.SysUtils,BaseController,ObjInvoiceReturn55,
      tblInvoiceReturn55, tblEntity, FireDAC.Comp.Client,Md5, FireDAC.Stan.Param;

Type
  TControllerInvoiceReturn55= Class(TBaseController)
    procedure clear;
  private


  public
    Registro : TInvoiceReturn55;
    Obj: TObjInvoiceReturn55;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function getInternalIDReturn(NfeReturn : Integer):Integer;
    function save:boolean;
    function getByKey:boolean;
    function delete:Boolean;
  End;

implementation

{ ControllerInvoiceReturn55 }

procedure TControllerInvoiceReturn55.clear;
begin
  ClearObj(Registro);
end;

constructor TControllerInvoiceReturn55.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TInvoiceReturn55.Create;
  Obj := TObjInvoiceReturn55.Create;
end;

function TControllerInvoiceReturn55.delete: Boolean;
begin
  deleteObj(Registro);
end;

destructor TControllerInvoiceReturn55.Destroy;
begin
  Obj.Destroy;
  Registro.DisposeOf;
  inherited;
end;

function TControllerInvoiceReturn55.save: boolean;
begin
  try
    saveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerInvoiceReturn55.getByKey: boolean;
begin
  _getByKey(Registro);
end;

function TControllerInvoiceReturn55.getInternalIDReturn(NfeReturn : Integer): Integer;
Var
  Lc_Qry : TFDQuery;
Begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      Sql.Add(concat(
              'SELECT id, interno ' ,
              'FROM tb_msg_return_nfe ',
              'WHERE id =:id '
      ));
      ParamByName('id').AsInteger := NfeReturn;
      Active := True;
      FetchAll;
      First;
      Result := StrToIntDef(FieldByName('interno').AsString,0);
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;


end.
