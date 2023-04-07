unit ArqIni;

interface

uses
  IniFiles, SysUtils, DateUtils, System.Types, System.StrUtils;



type
  TArqIni = class
  private
  public
    class procedure GravaIni(sArqIni, sSecao, sVariavel, sTexto: string);
    class function  LerAnoOperacional: string;
    Class function  LeIni(sArqIni, sSecao: string; sVariavel: String): Variant;
    Class function  LeIniInteger(sArqIni, sSecao: string; sVariavel: String): integer;
    Class function  LeIniBoolean(sArqIni, sSecao: string; sVariavel: String): boolean;
    class Function  LeIniDate(sArqIni: string; sSecao: string; sVariavel: string): TDateTime;


  end;

implementation

{ TArqIni }

class procedure TArqIni.GravaIni(sArqIni, sSecao, sVariavel, sTexto: string);
var
  ArqIni: TIniFile;
begin
  ArqIni := TIniFile.Create(ExtractFilePath(ParamStr(0))+sArqIni);
  try
    ArqIni.WriteString(sSecao, sVariavel, sTexto);
  finally
    ArqIni.Free;
  end;
end;




class function TArqIni.LeIniInteger(sArqIni, sSecao: string; sVariavel: String): integer;
var
  ArqIni: TIniFile;
  vntgr : integer;
begin
  vntgr := 0;
  ArqIni := TIniFile.Create(ExtractFilePath(ParamStr(0))+sArqIni);
  try
     Result := ArqIni.ReadInteger(sSecao, sVariavel, vntgr);
  finally
    ArqIni.Free;
  end;
end;

class function TArqIni.LerAnoOperacional: string;
begin
  Result := Format('%d%s%d', [YearOf(Date) - 1, FormatSettings.DateSeparator, YearOf(Date)]);
end;

class function TArqIni.LeIniBoolean(sArqIni, sSecao: string; sVariavel: String): boolean;
var
  ArqIni: TIniFile;
  vbln : boolean;
begin
  vbln := False;
  ArqIni := TIniFile.Create(sArqIni);
  try
     Result := ArqIni.ReadBool(sSecao , sVariavel, vbln);
  finally
    ArqIni.Free;
  end;
end;

class function TArqIni.LeIniDate(sArqIni, sSecao, sVariavel: string): TDateTime;
var
  ArqIni: tIniFile;
  sDate: TDateTime;
begin
  sDate := now();
   ArqIni := tIniFile.Create(sArqIni);
   Try
      Result := ArqIni.ReadDateTime(sSecao, sVariavel, sDate);
   Finally
      ArqIni.Free;
   end;
end;

class Function TArqIni.LeIni(sArqIni, sSecao: string; sVariavel: String): Variant;
var
  ArqIni: TIniFile;
  sString : string;
begin
  ArqIni := TIniFile.Create(sArqIni);
  try
     Result := ArqIni.ReadString(sSecao , sVariavel, sString);
  finally
    ArqIni.Free;
  end;
end;



end.
