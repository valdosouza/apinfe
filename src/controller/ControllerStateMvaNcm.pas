unit ControllerStateMvaNcm;

interface
uses System.Classes, System.SysUtils,BaseController,
      tblStateMvaNcm,FireDAC.Comp.Client,Md5, FireDAC.Stan.Param,
      System.Generics.Collections;

Type
  TControllerStateMvaNcm = Class(TBaseController)
  procedure clear;
  private

  public
    Registro : TStateMvaNcm;
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

procedure TControllerStateMvaNcm.clear;
begin
  clearObj(Registro);
end;

constructor TControllerStateMvaNcm.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TStateMvaNcm.Create;
end;

function TControllerStateMvaNcm.delete: boolean;
begin
  Try
    deleteObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

destructor TControllerStateMvaNcm.Destroy;
begin
  Registro.DisposeOf ;
  inherited;
end;


function TControllerStateMvaNcm.insert: boolean;
begin
  try
    insertObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerStateMvaNcm.save: boolean;
begin
  try
    SaveObj(Registro);
    Result := true;
  except
    Result := False;
  end;

end;

function TControllerStateMvaNcm.update: boolean;
begin
  try
    updateObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerStateMvaNcm.getByKey: Boolean;
begin
  _getByKey(Registro);
end;


end.
