unit tblStateFcpNcm;

interface

Uses GenericEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('tb_state_fcp_ncm')]
  TStateFcpNcm = Class(TGenericEntity)
  private
    Fupdated_at: TDAteTime;
    FNCM: String;
    Faliquota: Real;
    Ftb_state_id: Integer;
    Fcreated_at: TDAteTime;
    procedure setFaliquota(const Value: Real);
    procedure setFcreated_at(const Value: TDAteTime);
    procedure setFNCM(const Value: String);
    procedure setFtb_state_id(const Value: Integer);
    procedure setFupdated_at(const Value: TDAteTime);

  public

    [FieldName('tb_state_id')]
    [KeyField('tb_state_id')]
    property Estado: Integer read Ftb_state_id write setFtb_state_id;

    [FieldName('ncm')]
    property NCM: String read FNCM  write setFNCM;

    [FieldName('aliquota')]
    property Aliquota: Real read Faliquota write setFaliquota;

    [FieldName('created_at')]
    property RegistroCriado: TDAteTime read Fcreated_at write setFcreated_at;

    [FieldName('updated_at')]
    property RegistroAlterado: TDAteTime read Fupdated_at write setFupdated_at;
  End;

implementation

{ TStateFcpNcm }

procedure TStateFcpNcm.setFaliquota(const Value: Real);
begin
  Faliquota := Value;
end;

procedure TStateFcpNcm.setFcreated_at(const Value: TDAteTime);
begin
  Fcreated_at := Value;
end;

procedure TStateFcpNcm.setFNCM(const Value: String);
begin
  FNCM := Value;
end;

procedure TStateFcpNcm.setFtb_state_id(const Value: Integer);
begin
  Ftb_state_id := Value;
end;

procedure TStateFcpNcm.setFupdated_at(const Value: TDAteTime);
begin
  Fupdated_at := Value;
end;

end.
