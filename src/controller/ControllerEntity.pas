unit ControllerEntity;

interface

uses
  System.Classes, System.SysUtils, System.Variants, FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  BaseController,
  tblEntity,
  tblInstitutionHasEntity,
  ControllerPhone,
  ControllerAddress,
  ControllerMailing,
  ControllerEntityHasMailing,
  ControllerSocialMedia,
  ControllerLineBusiness,
  ControllerInstitutionHasEntity,
  ControllerCompany,
  ControllerPerson, System.Generics.Collections;

Type
  TListEntity = TObjectList<TEntity>;

  TControllerEntity = Class(TBaseController)
    procedure clear;
  private
    function getNext:Integer;
  public
    Registro : TEntity;
    Endereco : TControllerAddress;
    Email : TControllerMailing;
    EntityHasMailing : TControllerEntityHasMailing;
    Telefone : TControllerPhone;
    MidiaSocial : TControllerSocialMedia;
    RamoAtividade : TControllerLineBusiness;
    HadInstitution : TControllerInstitutionHasEntity;
    Lista : TListEntity;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function save:boolean;
    function update:boolean;
    function getByKey:Boolean;Virtual;
    function getAllByKey:boolean;Virtual;
    function delete: boolean;
    function insert:boolean;
    function getlist:boolean;
    function getStateAdrress:Integer;

  End;

implementation

{ ControllerAddress }

procedure TControllerEntity.clear;
begin
  clearObj(Registro);
end;

constructor TControllerEntity.Create(AOwner: TComponent);
begin
  inherited;
  Registro          := TEntity.Create;
  HadInstitution    := TControllerInstitutionHasEntity.Create(self);
  Endereco           := TControllerAddress.Create(Self);
  Telefone             := TControllerPhone.Create(Self);
  email           := TControllerMailing.Create(Self);
  MidiaSocial       := TControllerSocialMedia.Create(Self);
  Ramoatividade      := TControllerLineBusiness.Create(Self);
  EntityHasMailing  := TControllerEntityHasMailing.Create(Self);
  Lista := TListEntity.Create;
end;

function TControllerEntity.delete: boolean;
begin
  Try
    deleteObj(Registro);
    Result := True;
  Except
    Result := False;
  End;

end;

destructor TControllerEntity.Destroy;
begin
  Lista.DisposeOf;
  Registro.DisposeOf;
  HadInstitution.DisposeOf;
  Endereco.DisposeOf;
  Telefone.DisposeOf;
  email.DisposeOf;
  Midiasocial.DisposeOf;
  RamoAtividade.DisposeOf;
  EntityHasMailing.DisposeOf;
  inherited;
end;



function TControllerEntity.save: boolean;
begin
  if Registro.Codigo = 0 then
    Registro.Codigo := getNext;
  try
    SaveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerEntity.update: boolean;
begin
  try
    updateObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;


function TControllerEntity.getAllByKey: boolean;
begin
  Result := True;
  getByKey;

  Endereco.Registro.Codigo := Self.Registro.Codigo;
  Endereco.Registro.Tipo := 'COMERCIAL';
  Endereco.getAllByKey;

  RamoAtividade.Registro.Codigo := Self.Registro.RamoAtividade;
  RamoAtividade.getByKey;

  //O grupo de email a ser utilizado deve ser deinfido no setVariable
  Email.getbyKind(Registro.Codigo,Email.Grupo.Registro.descricao);

  //O fone por ter tres será chamado individualmente
  //Phone : TControllerPhone;

  MidiaSocial.Registro.Codigo := Self.Registro.Codigo;
  MidiaSocial.Registro.Tipo := 'www';
  MidiaSocial.getByKey;
end;

function TControllerEntity.getByKey: Boolean;
begin
  _getByKey(Registro);
end;

function TControllerEntity.getlist: boolean;
Var
  Lc_Qry : TFDQuery;
  item : TEntity;
begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      Active := False;
      sql.Clear;
      sql.Add(concat(
                  'select * ',
                  'from tb_entity  ',
                  'order by id '
              ));
      Active := True;
      First;
      Lista.Clear;
      while not eof do
      Begin
        item := TEntity.Create;
        get(Lc_Qry,item);
        lista.Add(item);
        Next;
      End;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerEntity.getNext: Integer;
begin
end;

function TControllerEntity.getStateAdrress: Integer;
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
                  'select a.tb_state_id ',
                  'from tb_address a ',
                  'where (a.id =:id)',
                  ' and (main = ''S'') '
              ));
      ParamByName('id').AsInteger := Registro.Codigo;
      Active := True;
      Result := FieldByname('tb_state_id').AsInteger;
    End;
  Finally
    finalizaQuery(Lc_Qry);
  End;
end;

function TControllerEntity.insert: boolean;
begin
  try
    if Registro.Codigo = 0 then
      Registro.Codigo := getNext;
    insertObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

end.

