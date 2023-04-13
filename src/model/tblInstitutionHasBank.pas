unit tblInstitutionHasBank;

interface

Uses GenericEntity,GenericDao,CAtribEntity, System.Classes, System.SysUtils;
Type
  //nome da classe de entidade
  [TableName('tb_institution_has_bank')]
  TInstitutionHasBank = Class(TGenericEntity)
  private
    Ftb_institution_id: Integer;
    Fupdated_at: TDAteTime;
    Ftb_bank_id: Integer;
    Fcreated_at: TDAteTime;
    FActive: String;
    procedure setFactive(const Value: String);
    procedure setFcreated_at(const Value: TDAteTime);
    procedure setFtb_bank_id(const Value: Integer);
    procedure setFtb_institution_id(const Value: Integer);
    procedure setFupdated_at(const Value: TDAteTime);



  public
    [FieldName('tb_institution_id')]
    [KeyField('tb_institution_id')]
    property Estabelecimento: Integer read Ftb_institution_id write setFtb_institution_id;

    [FieldName('tb_bank_id')]
    [KeyField('tb_bank_id')]
    property Banco: Integer read Ftb_bank_id write setFtb_bank_id;

    [FieldName('active')]
    property Ativo: String read Factive write setFactive;

    [FieldName('created_at')]
    property RegistroCriado: TDAteTime read Fcreated_at write setFcreated_at;

    [FieldName('updated_at')]
    property RegistroAlterado: TDAteTime read Fupdated_at write setFupdated_at;

  End;
implementation

{ TInstitutionHasBank }

procedure TInstitutionHasBank.setFactive(const Value: String);
begin
  Factive := Value;
end;

procedure TInstitutionHasBank.setFcreated_at(const Value: TDAteTime);
begin
  Fcreated_at := Value;
end;

procedure TInstitutionHasBank.setFtb_bank_id(const Value: Integer);
begin
  Ftb_bank_id := Value;
end;

procedure TInstitutionHasBank.setFtb_institution_id(const Value: Integer);
begin
  Ftb_institution_id := Value;
end;

procedure TInstitutionHasBank.setFupdated_at(const Value: TDAteTime);
begin
  Fupdated_at := Value;
end;

end.
