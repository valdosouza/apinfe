unit tblNfeSeries;

interface

Uses GenericEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('tb_nfl_series')]
  TNfeSeries = Class(TGenericEntity)
  private
    FSerie: Integer;
    Fupdated_at: TDatetime;
    Ftb_institution_id: Integer;
    Fterminal: Integer;
    Fcreated_at: TDatetime;
    procedure setFcreated_at(const Value: TDatetime);
    procedure setFSerie(const Value: Integer);
    procedure setFtb_institution_id(const Value: Integer);
    procedure setFterminal(const Value: Integer);
    procedure setFupdated_at(const Value: TDatetime);


  public

    [KeyField('tb_institution_id')]
    [FieldName('tb_institution_id')]
    property Estabelecimento: Integer read Ftb_institution_id write setFtb_institution_id;

    [FieldName('terminal')]
    [KeyField('terminal')]
    property Terminal: Integer read Fterminal write setFterminal;

    [KeyField('serie')]
    [FieldName('serie')]
    property Serie: Integer read FSerie write setFSerie;

	  [FieldName('created_at')]
    property RegistroCriado: TDatetime read Fcreated_at write setFcreated_at;

	  [FieldName('updated_at')]
    property RegistroAlterado: TDatetime read Fupdated_at write setFupdated_at;

  End;

implementation


{ TNfeSeries }

procedure TNfeSeries.setFcreated_at(const Value: TDatetime);
begin
  Fcreated_at := Value;
end;

procedure TNfeSeries.setFSerie(const Value: Integer);
begin
  FSerie := Value;
end;

procedure TNfeSeries.setFtb_institution_id(const Value: Integer);
begin
  Ftb_institution_id := Value;
end;

procedure TNfeSeries.setFterminal(const Value: Integer);
begin
  Fterminal := Value;
end;

procedure TNfeSeries.setFupdated_at(const Value: TDatetime);
begin
  Fupdated_at := Value;
end;

end.
