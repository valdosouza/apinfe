unit tblPaymentTypes;

interface

Uses GenericEntity,CAtribEntity, Classes, SysUtils;
Type
  //nome da classe de entidade
  [TableName('tb_payment_types')]
  TPaymentTypes = Class(TGenericEntity)
  private
    Fdescription: String;
    FId: Integer;
    Fupdated_at: TDAteTime;
    Fcreated_at: TDAteTime;
    Fid_nfce: String;
    procedure setFcreated_at(const Value: TDAteTime);
    procedure setFdescription(const Value: String);
    procedure setFId(const Value: Integer);
    procedure setFupdated_at(const Value: TDAteTime);
    procedure setFid_nfce(const Value: String);

  public
    [FieldName('id')]
    [KeyField('id')]
    property Codigo: Integer read FId write setFId;

    [FieldName('description')]
    property Descricao: String read Fdescription write setFdescription;

    [FieldName('id_nfce')]
    property CodigoNFCE: String read Fid_nfce write setFid_nfce;

    [FieldName('created_at')]
    property RegistroCriado: TDAteTime read Fcreated_at write setFcreated_at;

    [FieldName('updated_at')]
    property RegistroAlterado: TDAteTime read Fupdated_at write setFupdated_at;

  End;
implementation
{ TPaymentTypes }

procedure TPaymentTypes.setFid_nfce(const Value: String);
begin
  Fid_nfce := Value;
end;

procedure TPaymentTypes.setFcreated_at(const Value: TDAteTime);
begin
  Fcreated_at := Value;
end;

procedure TPaymentTypes.setFdescription(const Value: String);
begin
  Fdescription := Value;
end;

procedure TPaymentTypes.setFId(const Value: Integer);
begin
  FId := Value;
end;

procedure TPaymentTypes.setFupdated_at(const Value: TDAteTime);
begin
  Fupdated_at := Value;
end;

end.
