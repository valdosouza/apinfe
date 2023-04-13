unit prm_brand;

interface

uses TypesCollection, System.SysUtils, prm_base ;

Type
  TPrmBrand = class(TPrmBase)
  private

  public
    constructor Create;Override;
    destructor Destroy;override;

  end;
implementation

{ TPrmBrand }

constructor TPrmBrand.Create;
begin
  inherited;

end;

destructor TPrmBrand.Destroy;
begin

  inherited;
end;

end.
