unit BaseController;

interface

uses System.Classes,System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Param,
    System.Generics.Collections,GenericDao, FireDAC.DApt , //uAuthCM,
    FireDAC.UI.Intf,  FireDAC.Comp.UI, JOSE.Types.JSON;

Type

  TBaseController = Class(TComponent)
  private
    FVendedor: Integer;


    procedure setFVendedor(const Value: Integer);
    procedure setFMensagemRetorno(const Value: TJSOnObject);


  protected
    FEstabelecimento: Integer;
    FTerminal: Integer;
    FOrdem: Integer;
    procedure setFEstabelecimento(const Value: Integer);
    procedure setFOrdem(const Value: Integer);
    procedure setFTerminal(const Value: Integer);


    function clearObj<T: class>(Obj: T):Boolean;
    function insertObj<T: class>(Obj: T):Boolean;
    function updateObj<T: class>(Obj: T):Boolean;
    function deleteObj<T: class>(Obj: T):Boolean;
    procedure replaceObj<T: class>(Obj: T);
    procedure SaveObj<T: class>(Obj: T);
    function getLastInsert<T: class>(Obj: T):Integer;
    function getNextByField<T: class>(Obj: T; Field: String;Intitution: Integer): Integer;
    function Generator(pc_Gen: string): Integer;
    function getByField(strTable:String;field:String; Content:String):TFDQuery;
    procedure _assign<T: class>(ObjOri: T;ObjClone: T);
    procedure _getByKey<T: class>(Obj: T);

    function existObj<T: class>(Obj: T):Boolean;

    procedure get<T: class>(Qry: TFdQuery;Obj: T);
    function createQuery(): TFDQuery;Virtual;
    function dataMysql(data:String) : String;
    procedure FinalizaQuery(Qry:TFDQuery);Virtual;
    function execcmd(sql:STring):Boolean;
    Procedure geralog(origem,msg : string);Virtual;
  public
    FMensagemRetorno: TJSOnObject;
    exist : Boolean;
    orderby : String;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GeneratePrimaryKey:string;
    function setOrderBy:String;
    Function ConverteDataMysql(Data:TDateTime) : String;
    procedure ClonarObj<T: class>(ObjOri: T;ObjClone: T);

    property Estabelecimento : Integer read FEstabelecimento write setFEstabelecimento;
    property Ordem : Integer read FOrdem write setFOrdem;
    property Terminal : Integer read FTerminal write setFTerminal;
    property MensagemRetorno : TJSOnObject read FMensagemRetorno write setFMensagemRetorno;
  End;

implementation

uses
  unFunctions;


{ TBaseController }

function TBaseController.clearObj<T>(Obj: T): Boolean;
begin
  Try
    TGenericDAO._Clear(Obj);
    Result := True;
  except
    Result := False;
  End;
end;


procedure TBaseController.ClonarObj<T>(ObjOri, ObjClone: T);
begin
  TGenericDAO._assign(ObjOri,ObjClone);
end;

function TBaseController.ConverteDataMysql(Data: TDateTime): String;
Var
  Lc_Dia,Lc_Mes, Lc_Ano, Lc_Hora : String;
  Lc_data :String;

begin
  Result := '1900-01-01 01:00:00';
  Lc_data := DateTimeToStr(Data);
  if trim(Lc_data) <> '' then
  Begin
    if (Pos('-',Lc_data) > 0) then
    Begin
       Result := Lc_data ;
    End
    else
    if (Pos('/',Lc_data) > 0) then
    Begin
      //01/01/2016 00:00:01
      Lc_Dia  := Copy(Lc_data,1,2);
      Lc_Mes  := Copy(Lc_data,4,2);
      Lc_Ano  := Copy(Lc_data,7,4);
      Lc_Hora := Copy(Lc_data,12,8);
      Result := concat(Lc_Ano,'-',Lc_Mes,'-',Lc_Dia,' ', Lc_Hora);
    End
  End;
end;

constructor TBaseController.Create(AOwner: TComponent);
begin
  inherited;
  orderby := '';
  FMensagemRetorno := TJSOnObject.Create;
end;

destructor TBaseController.Destroy;
begin
  FMensagemRetorno.DisposeOf;
  inherited; //- quando ativa aparece invalida operator
end;



function TBaseController.execcmd(sql: STring): Boolean;
Var
  Lc_Qry : TFDQuery;
begin
  try
    Result := True;
    Lc_Qry := createQuery;
    Lc_Qry.SQL.Add( sql );
    Lc_Qry.Prepare;
    Lc_Qry.ExecSQL;
    FinalizaQuery(Lc_Qry);
  finally

  end;
end;

function TBaseController.existObj<T>(Obj: T): Boolean;
Var
  Lc_Qry : TFDQuery;
begin
  try
    try
      Lc_Qry := createQuery;
      Lc_Qry.SQL.Clear;
      Lc_Qry.SQL.Add (TGenericDAO._Select(Obj,''));
      Lc_Qry.Prepare;
      Lc_Qry.Active := True;
      Lc_Qry.FetchAll;
      result := ( Lc_Qry.RecordCount > 0 );
    Except
      on E: Exception do
        geralog('Base - existObj - ',concat(E.Message,' - SQL: ',Lc_Qry.SQL.text) );
    end;
  finally
    Lc_Qry.Unprepare;
    FinalizaQuery(Lc_Qry);
  end;
end;

procedure TBaseController.FinalizaQuery(Qry: TFDQuery);
begin
  Qry.Close;
  Qry.DisposeOf;
end;

function TBaseController.GeneratePrimaryKey: string;
begin
  Result := TGUID.Empty.NewGuid.ToString;
  Result := RemoveCaracterInformado(Result,['}','{','-']);
end;

function TBaseController.Generator(pc_Gen: string): Integer;
var
  Lc_SqlTxt: string;
  Lc_Qry : TFDQuery;
begin
  TRy
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      CachedUpdates := True;
      sql.Add('SELECT GEN_ID(' + pc_Gen + ',1) FROM RDB$DATABASE');
      Active := True;
      Result := fieldbyname('GEN_ID').AsInteger;
      ApplyUpdates;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TBaseController.createQuery: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.ConnectionName := 'gestao_setes';
end;

procedure TBaseController.geralog(origem,msg : string);
//Var
//  LcCrash : TControllerCrashlytics;
begin
// Try
//    LcCrash := TControllerCrashlytics.Create(nil);
////    LcCrash.Registro.Estabelecimento := UMM.GInstitution.Registro.Codigo;
////    LcCrash.Registro.Usuario         := UMM.GInstitution.User.Registro.Codigo;
//    LcCrash.Registro.Origem          := origem;
//    LcCrash.Registro.Mensagem        := msg;
//    LcCrash.Registro.RegistroCriado  := Now;
//    LcCrash.Registro.RegistroAlterado  := Now;
//    LcCrash.insert;
//  Finally
//    LcCrash.DisposeOf;
//  End;
end;

procedure TBaseController.get<T>(Qry: TFdQuery; Obj: T);
begin
  clearObj(Obj);
  TGenericDAO._get(Qry,Obj);
end;

function TBaseController.getByField(strTable:String;field, Content: String): TFDQuery;
var
  vSelect: string;
begin
  Result := createQuery;
  with Result do
  begin
    Active := False;
    SQL.Clear;
    vSelect := Format('Select * from %s where ( %s = :%s ) ',[strTable, Field, Field]);
    SQL.Add(vSelect);
    ParamByName(Field).Value := Content;
    Prepare;
    active := True;
    FetchAll;
    exist := (RecordCount > 0);
  end;
end;

procedure TBaseController.SaveObj<T>(Obj: T);
begin
  if existObj(Obj)  then
    updateObj(Obj)
  else
    InsertObj(Obj);
end;
{
procedure TBaseController.setFAuthCM(const Value: TAuthCM);
begin
  FAuthCM := Value;
end;

procedure TBaseController.setFDataCM(const Value: TDataCM);
begin
  FDataCM := Value;
end;
}
procedure TBaseController.setFEstabelecimento(const Value: Integer);
begin
  FEstabelecimento := Value;
end;

procedure TBaseController.setFMensagemRetorno(const Value: TJSOnObject);
begin
  FMensagemRetorno := Value;
end;

procedure TBaseController.setFOrdem(const Value: Integer);
begin
  FOrdem := Value;
end;

procedure TBaseController.setFTerminal(const Value: Integer);
begin
  FTerminal := Value;
end;

procedure TBaseController.setFVendedor(const Value: Integer);
begin
  FVendedor := Value;
end;


function TBaseController.setOrderBy: String;
begin
  if Trim(orderby)<>'' then
    Result := concat(' ORDER BY ', orderby,' asc  ')
end;

procedure TBaseController._assign<T>(ObjOri, ObjClone: T);
begin
  TGenericDAO._assign(ObjOri,ObjClone);
end;

procedure TBaseController._getByKey<T>(Obj: T);
VAr
  Lc_Qry : TFdQuery;
begin
  Try
    try
      Lc_Qry := createQuery;
      Lc_Qry.SQL.Clear;
      Lc_Qry.SQL.Add (TGenericDAO._Select(Obj,''));
      Lc_Qry.Prepare;
      Lc_Qry.Active := True;
      Lc_Qry.FetchAll;
      exist  := ( Lc_Qry.RecordCount > 0 );
      if exist then TGenericDAO._get(Lc_Qry,Obj) ;
    Except
      on E: Exception do
      geralog('Base - _getByKey',concat(E.Message,' - SQL: ',Lc_Qry.SQL.text) );
    end;
  Finally
    Lc_Qry.Unprepare;
    FinalizaQuery(Lc_Qry);
  End;
end;

function TBaseController.getLastInsert<T>(Obj: T): Integer;
Var
  Lc_Qry : TFDQuery;
begin
  try
    try
      Lc_Qry := createQuery;
      Lc_Qry.SQL.Clear;
      Lc_Qry.SQL.Add ( TGenericDAO._getLastInsert( Obj ) );
      Lc_Qry.Prepare;
      Lc_Qry.Active := True;
      Result := StrToIntDef(Lc_Qry.FieldByName('id').AsString,0);
    Except on E: Exception do
        geralog('Base - getLastInsert - ',concat(E.Message,'SQL: ',Lc_Qry.SQL.text) );
    end;
  finally
    Lc_Qry.Unprepare;
    FinalizaQuery(Lc_Qry);
  end;
end;


function TBaseController.getNextByField<T>(Obj: T; Field: String;
  Intitution: Integer): Integer;
Var
  Lc_Qry : TFDQuery;
begin
  try
    try
      Lc_Qry := createQuery;
      Lc_Qry.SQL.Clear;
      Lc_Qry.SQL.Add ( TGenericDAO._getNextByField( Obj,Field, Intitution  ) );
      Lc_Qry.Prepare;
      Lc_Qry.Active := True;
      Result := StrToIntDef( Lc_Qry.FieldByName(Field).AsString,0) + 1;
    Except
      on E: Exception do
        geralog('Base - getNextByField - ',concat(E.Message,'SQL: ',Lc_Qry.SQL.text) );
    end;
  finally
    Lc_Qry.Unprepare;
    FinalizaQuery(Lc_Qry);
  end;

end;

function TBaseController.insertObj<T>(Obj: T):Boolean;
Var
  LcSql : String;
  Lc_Qry :TFDQuery;
begin
  Try
    LcSql := TGenericDAO._Insert(Obj);
    Lc_Qry := createQuery;
    try
      Lc_Qry.SQL.Add(LcSql);
      Lc_Qry.ExecSQL;
    Except
      on E: Exception do
        geralog('Base - insertObj - ',concat(E.Message,'SQL: ',LcSql) );
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
End;


procedure TBaseController.replaceObj<T>(Obj: T);
Var
  LcSql : String;
  Lc_Qry :TFDQuery;
begin
  Try
    Try
      LcSql := TGenericDAO._Delete(Obj) ;
      Lc_Qry := createQuery;
      with Lc_Qry do
      Begin
        SQL.Clear;
        SQL.Add ( TGenericDAO._Replace(Obj) );
        ExecSQL;
      End;
    Except on E: Exception do
      geralog('Base - ',E.Message);
    end;
  finally
    FinalizaQuery(Lc_Qry);
  end;


end;

function TBaseController.updateObj<T>(Obj: T):Boolean;
Var
  LcSql : String;
  Lc_Qry :TFDQuery;
begin
  Try
    Lc_Qry := createQuery;
    try
      LcSql := TGenericDAO._Update(Obj);
      Lc_Qry.SQL.Add( LcSql);
      Lc_Qry.ExecSQL;
    Except
      on E: Exception do
      geralog('Base - updateObj - ',concat(E.Message,'SQL: ',LcSql) );
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
End;

function TBaseController.dataMysql(Data: String): String;
Var
  Lc_Dia,Lc_Mes, Lc_Ano, Lc_Hora : String;
begin
  Result := '1900-01-01 01:00:00';
  if trim(data) <> '' then
  Begin
    if (Pos('-',data) > 0) then
    Begin
       Result := Data ;
    End
    else
    if (Pos('/',data) > 0) then
    Begin
      //01/01/2016 00:00:01
      Lc_Dia  := Copy(data,1,2);
      Lc_Mes  := Copy(data,4,2);
      Lc_Ano  := Copy(data,7,4);
      Lc_Hora := Copy(data,12,8);
      Result := concat(Lc_Ano,'-',Lc_Mes,'-',Lc_Dia,' ', Lc_Hora);
    End
  End;

end;

function TBaseController.deleteObj<T>(Obj: T):Boolean;
Var
  LcSql : String;
  Lc_Qry :TFDQuery;
begin
  Try
    LcSql := TGenericDAO._Delete(Obj) ;
    Lc_Qry := createQuery;
    try
      Lc_Qry.SQL.Add(LcSql);
      Lc_Qry.ExecSQL;
    Except
      on E: Exception do
        geralog('Base - deleteObj - ',concat(E.Message,'SQL: ',LcSql) );
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;



end.

