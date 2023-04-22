unit tblNfeSequences;

interface

Uses GenericEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('tb_nfe_sequences')]
  TNfeSequences = Class(TGenericEntity)
  private
    FSerie: Integer;
    Fupdated_at: TDatetime;
    FId: Integer;
    Ftb_institution_id: Integer;
    Fterminal: Integer;
    Fcreated_at: TDatetime;
    Ftb_order_id: Integer;
    procedure setFcreated_at(const Value: TDatetime);
    procedure setFId(const Value: Integer);
    procedure setFSerie(const Value: Integer);
    procedure setFtb_institution_id(const Value: Integer);
    procedure setFterminal(const Value: Integer);
    procedure setFupdated_at(const Value: TDatetime);
    procedure setFtb_order_id(const Value: Integer);
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

    [KeyField('tb_order_id')]
    [FieldName('tb_order_id')]
    property Ordem: Integer read Ftb_order_id write setFtb_order_id;

    [FieldName('id')]
    property Id: Integer read FId write setFId;

	  [FieldName('created_at')]
    property RegistroCriado: TDatetime read Fcreated_at write setFcreated_at;

	  [FieldName('updated_at')]
    property RegistroAlterado: TDatetime read Fupdated_at write setFupdated_at;

  End;

implementation

{ TNfeSequences }

procedure TNfeSequences.setFcreated_at(const Value: TDatetime);
begin
  Fcreated_at := Value;
end;

procedure TNfeSequences.setFId(const Value: Integer);
begin
  FId := Value;
end;

procedure TNfeSequences.setFSerie(const Value: Integer);
begin
  FSerie := Value;
end;

procedure TNfeSequences.setFtb_institution_id(const Value: Integer);
begin
  Ftb_institution_id := Value;
end;

procedure TNfeSequences.setFtb_order_id(const Value: Integer);
begin
  Ftb_order_id := Value;
end;

procedure TNfeSequences.setFterminal(const Value: Integer);
begin
  Fterminal := Value;
end;

procedure TNfeSequences.setFupdated_at(const Value: TDatetime);
begin
  Fupdated_at := Value;
end;

end.
