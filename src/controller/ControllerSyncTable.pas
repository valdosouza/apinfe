unit ControllerSyncTable;

interface
uses Classes,  SysUtils,BaseController, tblSyncTable ,
      Generics.Collections, FireDAC.Comp.Client ;


Type

  TControllerSyncTable = Class(TBaseController)
  private

  public
    Registro : TSyncTable;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function save:boolean;
    function insert:boolean;
    function update:boolean;
    procedure getById;
    function getTime:TDateTime;
    Function delete:boolean;
    function setTimeToWEb:Boolean;
  End;

implementation

{ TControllerEmpresa }


constructor TControllerSynctable.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TSyncTable.Create;
end;

function TControllerSynctable.delete: boolean;
begin
  Try
    deleteObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

destructor TControllerSynctable.Destroy;
begin
  Registro.DisposeOf;
  inherited;
end;

function TControllerSynctable.save: boolean;
begin
  SaveObj(Registro);
end;

function TControllerSyncTable.setTimeToWEb: Boolean;
Var
  Lc_Qry : TFDQuery;
begin
  Try
    //13/12/2017 01:37:38
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      Active := False;
      sql.Clear;
      sql.Add(concat(
              'update TB_SYNC_TABLE SET  ',
              'DT_UPDATE =:DT_UPDATE,    ',
              'TM_UPDATE =:TM_UPDATE    '
      ));
      if Registro.Sentido <> 'A' then
        sql.Add(' WHERE (WAY=:WAY ) ');
      ParamByName('DT_UPDATE').AsDateTime := Registro.Data;
      ParamByName('TM_UPDATE').AsDateTime := Registro.Hora;
      if Registro.Sentido <> 'A' then
        ParamByName('WAY').AsString := Registro.Sentido;
      ExecSQL;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;


end;

function TControllerSynctable.update: boolean;
Var
  Lc_Qry : TFDQuery;
begin
  Try
    //13/12/2017 01:37:38
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      Active := False;
      sql.Clear;
      sql.Add(concat(
              'update TB_SYNC_TABLE SET  ',
              'DT_UPDATE =:DT_UPDATE,    ',
              'TM_UPDATE =:TM_UPDATE    ',
              'WHERE ( ID:ID )',
              ' AND ( WAY=:WAY ) ',
              ' AND ( DT_UPDATE >:DT_UPDATE ) ',
              ' AND ( TM_UPDATE >:TM_UPDATE ) '
      ));
      ParamByName('ID').AsString := Registro.Codigo;
      ParamByName('WAY').AsString := Registro.Sentido;
      ParamByName('DT_UPDATE').AsDateTime := Registro.Data;
      ParamByName('TM_UPDATE').AsDateTime := Registro.Hora;
      ExecSQL;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

procedure TControllerSynctable.getById;
begin
  _getByKey(Registro);
end;


function TControllerSyncTable.getTime: TDateTime;
Var
  Lc_Qry : TFDQuery;
begin
  Try
    //13/12/2017 01:37:38
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      Active := False;
      sql.Clear;
      sql.Add(concat(
              'SELECT DT_UPDATE, TM_UPDATE ',
              'FROM TB_SYNC_TABLE ',
              'WHERE ( ID=:ID ) ',
              'AND ( WAY=:WAY )'
      ));
      ParamByName('ID').AsString := Registro.Codigo;
      ParamByName('WAY').AsString := Registro.Sentido;
      Active := True;
      FetchAll;
      if RecordCount > 0 then
        REsult := FieldByName('DT_UPDATE').AsDateTime + ( FieldByName('TM_UPDATE').AsDateTime + StrTotime('00:00:01') )
      else
        REsult := StrToDateTime('01/01/2016 00:00:01');
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerSynctable.insert: boolean;
begin
  insertObj(Registro);
end;

end.
