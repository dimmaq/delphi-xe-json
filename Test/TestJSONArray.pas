unit TestJSONArray;
{

  Delphi DUnit-Testfall
  ----------------------
  Diese Unit enthält ein Skeleton einer Testfallklasse, das vom Experten für Testfälle erzeugt wurde.
  Ändern Sie den erzeugten Code so, dass er die Methoden korrekt einrichtet und aus der 
  getesteten Unit aufruft.

}

interface

uses
  TestFramework, SysUtils, Rtti,
  //
  DelphiXe.JSON;

type
  // Testmethoden für Klasse IJSONArray

  TestIJSONArray = class(TTestCase)
  strict private
    FIJSONArray: IJSONArray;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestClear;
    procedure TestPutNil;
    procedure TestIsObject;
    procedure TestIsArray;
    procedure TestIsInteger;
    procedure TestIsDouble;
    procedure TestIsString;
    procedure TestIsBoolean;
  end;

implementation

procedure TestIJSONArray.SetUp;
begin
  FIJSONArray := TJSON.NewArray;
end;

procedure TestIJSONArray.TearDown;
begin
  FIJSONArray := nil;
end;

procedure TestIJSONArray.TestClear;
begin
  FIJSONArray.Put('Value1');
  FIJSONArray.Put(2);
  FIJSONArray.Put(3.33);
  FIJSONArray.Clear;
  CheckEquals(0,FIJSONArray.Count);
  CheckEquals('[]',FIJSONArray.ToString);
end;

procedure TestIJSONArray.TestIsArray;
begin
  FIJSONArray.Put(TJSON.NewArray('[1,2,3]'));
  Check(FIJSONArray.isJSONArray(0));
end;

procedure TestIJSONArray.TestIsBoolean;
begin
  FIJSONArray.Put(true);
  Check(FIJSONArray.isBoolean(0));
end;

procedure TestIJSONArray.TestIsDouble;
begin
  FIJSONArray.Put(0.5);
  Check(FIJSONArray.isDouble(0));
end;

procedure TestIJSONArray.TestIsInteger;
begin
  FIJSONArray.Put(1);
  Check(FIJSONArray.isInteger(0));
end;

procedure TestIJSONArray.TestIsObject;
begin
  FIJSONArray.Put(TJSON.NewObject('{"key":"value"}'));
  Check(FIJSONArray.isJSONObject(0));
end;

procedure TestIJSONArray.TestIsString;
begin
  FIJSONArray.Put('abc');
  Check(FIJSONArray.isString(0));
end;

procedure TestIJSONArray.TestPutNil;
var
  obj : IJSONObject;
begin
  obj := nil;
  StartExpectingException(JSONException);
  FIJSONArray.Put(obj);
  StopExpectingException('Can''t add nil-object');
end;

initialization
  // Alle Testfälle beim Testprogramm registrieren
  RegisterTest(TestIJSONArray.Suite);
end.

