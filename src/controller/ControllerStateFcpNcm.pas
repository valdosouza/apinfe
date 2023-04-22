unit ControllerStateFcpNcm;

interface
uses System.Classes, System.SysUtils,BaseController,
      tblStateFcpNcm,FireDAC.Comp.Client,Md5, FireDAC.Stan.Param,
      json, System.Generics.Collections;

Type
  TControllerStateFcpNcm = Class(TBaseController)
  procedure clear;
  private

  public
    Registro : TStateFcpNcm;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function save:boolean;
    function getByKey:Boolean;
    function insert:boolean;
    function update:boolean;
    Function delete:boolean;
  End;

implementation

{ ControllerStateMvaNcm }

procedure TControllerStateFcpNcm.clear;
begin
  clearObj(Registro);
end;

constructor TControllerStateFcpNcm.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TStateFcpNcm.Create;
end;

function TControllerStateFcpNcm.delete: boolean;
begin
  Try
    deleteObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

destructor TControllerStateFcpNcm.Destroy;
begin
  Registro.DisposeOf ;
  inherited;
end;


function TControllerStateFcpNcm.insert: boolean;
begin
  try
    insertObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerStateFcpNcm.save: boolean;
begin
  try
    SaveObj(Registro);
    Result := true;
  except
    Result := False;
  end;

end;

function TControllerStateFcpNcm.update: boolean;
begin
  try
    updateObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerStateFcpNcm.getByKey: Boolean;
begin
  _getByKey(Registro);
end;


end.
