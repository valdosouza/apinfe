unit tblVehModel;

interface

Uses GenericEntity,GenericDao,CAtribEntity, System.Classes, System.SysUtils;
Type
  //nome da classe de entidade
  [TableName('tb_veh_model')]
  TVehModel = Class(TGenericEntity)
  private
    Fdescription: String;
    FId: Integer;
    Fupdated_at: TDAteTime;
    Ftb_veh_brand_id: Integer;
    Fcreated_at: TDAteTime;
    procedure setFcreated_at(const Value: TDAteTime);
    procedure setFdescription(const Value: String);
    procedure setFId(const Value: Integer);
    procedure setFtb_veh_brand_id(const Value: Integer);
    procedure setFupdated_at(const Value: TDAteTime);


  public
    [FieldName('id')]
    [KeyField('id')]
    property Codigo: Integer read FId write setFId;

    [FieldName('tb_veh_brand_id')]
    [KeyField('tb_veh_brand_id')]
    property Marca: Integer read Ftb_veh_brand_id write setFtb_veh_brand_id;

    [FieldName('description')]
    property Descricao: String read Fdescription write setFdescription;

    [FieldName('created_at')]
    property RegistroCriado: TDAteTime read Fcreated_at write setFcreated_at;

    [FieldName('updated_at')]
    property RegistroAlterado: TDAteTime read Fupdated_at write setFupdated_at;

  End;
implementation

{ TvehModel }



{ TVehModel }

procedure TVehModel.setFcreated_at(const Value: TDAteTime);
begin
  Fcreated_at := Value;
end;

procedure TVehModel.setFdescription(const Value: String);
begin
  Fdescription := Value;
end;

procedure TVehModel.setFId(const Value: Integer);
begin
  FId := Value;
end;

procedure TVehModel.setFtb_veh_brand_id(const Value: Integer);
begin
  Ftb_veh_brand_id := Value;
end;

procedure TVehModel.setFupdated_at(const Value: TDAteTime);
begin
  Fupdated_at := Value;
end;

end.
