unit ControllerNfeSequences;

interface
uses System.Classes, System.SysUtils,BaseController,
      tblNfeSequences,  FireDAC.Comp.Client,
      FireDAC.Stan.Param, TypesCollection;

Type

  TControllerNfeSequences = Class(TBaseController)
    procedure clear;
  private
    function getNext:Integer;
  public
    Registro : TNfeSequences;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function save:boolean;
    function getByKey: Boolean;
    function insert:boolean;
    Function delete:boolean;
    function get:String;
  End;

implementation

{ ControllerBrand }

procedure TControllerNfeSequences.clear;
begin
  ClearObj(Registro);
end;

constructor TControllerNfeSequences.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TNfeSequences.Create;
end;

function TControllerNfeSequences.delete: boolean;
begin
  Try
    deleteObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

destructor TControllerNfeSequences.Destroy;
begin
  FreeAndNil(Registro);
  inherited;
end;


function TControllerNfeSequences.insert: boolean;
begin
  try
    insertObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;


function TControllerNfeSequences.save: boolean;
begin
  try
   saveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerNfeSequences.get: String;
Var
  Lc_Qry : TFdQuery;
begin
  try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      sql.Add(concat(
              'select id ',
              'from tb_nfe_sequences ',
              'where ( tb_institution_id =:tb_institution_id) ',
              ' and (terminal =:terminal)',
              ' and (serie =:serie) ',
              ' and (tb_order_id =:tb_order_id) '
        ));
      ParamByName('tb_institution_id').AsInteger  := Registro.Estabelecimento;
      ParamByName('terminal').AsInteger           := Registro.Terminal;
      ParamByName('serie').AsInteger              := Registro.Serie;
      ParamByName('tb_order_id').AsInteger        := Registro.Ordem;
      Active := True;
      FetchAll;
      if RecordCount > 0 then
      Begin
        Result := FieldByName('id').AsString;
      End
      else
      Begin
        Registro.Id := getNext;
        insertObj(Registro);
        Result := Registro.Id.ToString;
      End;
    End;
  finally
    FinalizaQuery(Lc_Qry);
  end;
end;

function TControllerNfeSequences.getByKey: Boolean;
begin
  _getByKey(Registro);
end;


function TControllerNfeSequences.getNext: Integer;
Var
  Lc_Qry : TFdQuery;
begin
  try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      sql.Add(concat(
              'select max(id) max_id ',
              'from tb_nfe_sequences ',
              'where ( tb_institution_id =:tb_institution_id) ',
              ' and (terminal =:terminal)',
              ' and (serie =:serie) ',
              ' and (tb_order_id =:tb_order_id) '
        ));
      ParamByName('tb_institution_id').AsInteger  := Registro.Estabelecimento;
      ParamByName('terminal').AsInteger           := Registro.Terminal;
      ParamByName('serie').AsInteger              := Registro.Serie;
      ParamByName('tb_order_id').AsInteger        := Registro.Ordem;
      Active := True;
      Result := StrToIntDef(FieldByName('max_id').AsString,0) + 1;

    End;
  finally
    FinalizaQuery(Lc_Qry);
  end;
end;

end.
