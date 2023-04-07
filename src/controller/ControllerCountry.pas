unit ControllerCountry;

interface

uses System.Classes, System.SysUtils,BaseController,
      tblCountry,FireDAC.Comp.Client,Md5, FireDAC.Stan.Param,
      rest.json, System.Generics.Collections;

Type

  TListCountry =  TObjectList<TCountry>;

  TControllerCountry = Class(TBaseController)
  procedure clear;
  private

  public
    Registro : TCountry;
    Lista: TListCountry;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure setParametro(par:String);
    function save:boolean;
    function getByKey:Boolean;
    function insert:boolean;
    function update:boolean;
    Function delete:boolean;
    procedure getList;
    procedure assign(ObjOri : TCountry);
  End;

implementation

{ ControllerCountry }

procedure TControllerCountry.assign(ObjOri: TCountry);
begin
  _assign(ObjOri,Registro);
end;

procedure TControllerCountry.clear;
begin
  clearObj(Registro);
end;

constructor TControllerCountry.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TCountry.Create;
  Lista := TListCountry.Create;
end;

function TControllerCountry.delete: boolean;
begin
  Try
    DeleteObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

destructor TControllerCountry.Destroy;
begin
  Lista.DisposeOf;
  Registro.DisposeOf;
  inherited;
end;


function TControllerCountry.insert: boolean;
begin
  try
    InsertObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;


function TControllerCountry.save: boolean;
begin
  try
    SaveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

procedure TControllerCountry.setParametro(par: String);
begin

end;

function TControllerCountry.update: boolean;
begin
  try
    updateObj(Registro);
    Result := true;
  except
    Result := False;
  end;

end;

function TControllerCountry.getByKey: Boolean;
begin
  _getByKey(Registro);
end;

procedure TControllerCountry.getList;
var
  Qry : TFDQuery;
  LITem : TCountry;
begin
  try
    Qry := createQuery;
    with Qry do
    Begin
      {
      sql.add(concat(
                'SELECT c.* ',
                'FROM tb_country c '

      ));

      //Incrementa SQL - Inner Join
      if Parametro.Vendedor > 0 then
      Begin
        sql.add(concat(
                 '  INNER JOIN tb_state s ',
                 '  on ( s.tb_country_id = c.id ) ',
                 '  INNER JOIN tb_salesman_has_state she ',
                 '  on (she.tb_state_id = s.id) '
        ));
      End;

      //Incrementa SQL - Where
      sql.add(' Where ( c.id is not null ) ');
      if Parametro.Vendedor > 0 then
        sql.add(' and ( she.tb_salesman_id=:tb_salesman_id ) ');

      if Trim(Parametro.UltimaAtualizacao) <> '' then
        sql.add(' AND ( c.updated_at >:updated_at ) ');


      //Incrementa SQL - Order By
      if Trim(Parametro.UltimaAtualizacao) <> '' then
      Begin
        sql.add(' order by c.updated_at asc ');
      End
      else
      Begin
        if Trim(orderby)='' then orderby := 'c.id';
        sql.add(concat(' ORDER BY ',orderby,'  asc '));
      End;

      //sql.add(' limit 0,1 ');

      //Passagem de parametros
      if Parametro.Vendedor > 0 then
        parambyname('tb_salesman_id').AsInteger := Parametro.Vendedor;

      if Trim(Parametro.UltimaAtualizacao) <> '' then
        parambyname('updated_at').AsString := Parametro.UltimaAtualizacao;
      }
      Active := True;
      FetchAll;
      First;
      if RecordCount > 0 then
      Begin
        Lista.Clear;
        while not eof do
        Begin
          LITem := TCountry.Create;
          get(qry,LITem);
          Lista.add(LITem);
          next;
        end;
      End
      else
      BEgin
        LITem := TCountry.Create;
        LITem.Codigo := 0;
        Lista.add(LITem);
      End;
    end;
  finally
    Qry.Close;
    FreeAndNil(Qry);
  end;
end;


end.

