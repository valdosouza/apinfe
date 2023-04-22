unit ControllerNfeSeries;

interface
uses System.Classes, System.SysUtils,BaseController,
      tblNfeSeries,  FireDAC.Comp.Client,
      FireDAC.Stan.Param, TypesCollection;

Type

  TControllerNfeSeries = Class(TBaseController)
    procedure clear;
  private

  public
    Registro : TNfeSeries;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function save:boolean;
    function getByKey: Boolean;
    function insert:boolean;
    Function delete:boolean;

  End;

implementation

{ ControllerBrand }

procedure TControllerNfeSeries.clear;
begin
  ClearObj(Registro);
end;

constructor TControllerNfeSeries.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TNfeSeries.Create;
end;

function TControllerNfeSeries.delete: boolean;
begin
  Try
    deleteObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

destructor TControllerNfeSeries.Destroy;
begin
  FreeAndNil(Registro);
  inherited;
end;


function TControllerNfeSeries.insert: boolean;
begin
  try
    insertObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;


function TControllerNfeSeries.save: boolean;
begin
  try
   saveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerNfeSeries.getByKey: Boolean;
begin
  _getByKey(Registro);
end;



end.
