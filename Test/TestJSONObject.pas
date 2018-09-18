unit TestJSONObject;
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
  // Testmethoden für Klasse IJSONObject

  TestIJSONObject = class(TTestCase)
  strict private
    FIJSONObject: IJSONObject;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestPutNil;
    procedure TestClear;
    procedure TestGetWithDefault;
    procedure TestIsString;
    procedure TestIsInteger;
    procedure TestIsDouble;
    procedure TestIsBoolean;
    procedure TestIsObject;
    procedure TestIsArray;
    procedure TestDeleteKey;
  end;

implementation

procedure TestIJSONObject.SetUp;
begin
  FIJSONObject := TJSON.NewObject;
end;

procedure TestIJSONObject.TearDown;
begin
  FIJSONObject := nil;
end;

procedure TestIJSONObject.TestDeleteKey;
begin
  FIJSONObject.Put('key','value');
  FIJSONObject.Put('answer',42);
  FIJSONObject.Put('pi',3.14);
  FIJSONObject.Put('true',true);
  FIJSONObject.DeleteKey('key');
  CheckFalse(FIJSONObject.HasKey('key'));
  CheckTrue(FIJSONObject.HasKey('answer'));
  CheckTrue(FIJSONObject.HasKey('pi'));
  CheckTrue(FIJSONObject.HasKey('true'));
end;

procedure TestIJSONObject.TestClear;
var
  keys : TArray<string>;
begin
  FIJSONObject.Put('Key1', 'Value 1');
  FIJSONObject.Put('Key2', 2);
  FIJSONObject.Put('Key3', 3.33);
  FIJSONObject.Clear;

  keys := FIJSONObject.GetKeys;

  CheckEquals(0,length(keys));
  CheckEquals('{}',FIJSONObject.ToString);
end;

procedure TestIJSONObject.TestGetWithDefault;
var
  s : string;
begin
  s := FIJSONObject.GetString('anykey','defaultstring');
  CheckEquals('defaultstring',s);
end;

procedure TestIJSONObject.TestIsArray;
begin
  FIJSONObject.Put('myArray',TJSON.NewArray('[1,2,3]'));
  FIJSONObject.Put('myObject',TJSON.NewObject('{"key":"value"}'));
  Check(FIJSONObject.isJSONArray('myArray'));
  CheckFalse(FIJSONObject.isJSONArray('myObject'));
end;

procedure TestIJSONObject.TestIsBoolean;
begin
  FIJSONObject.Put('b1',true);
  FIJSONObject.Put('b2',false);
  FIJSONObject.Put('d2',-0.5);
  FIJSONObject.Put('i1',12);
  Check(FIJSONObject.isBoolean('b1'));
  Check(FIJSONObject.isBoolean('b2'));
  CheckFalse(FIJSONObject.isBoolean('d2'));
  CheckFalse(FIJSONObject.isBoolean('i1'));
end;

procedure TestIJSONObject.TestIsDouble;
begin
  FIJSONObject.Put('d1',1.23);
  FIJSONObject.Put('d2',-0.5);
  FIJSONObject.Put('i2',-50);
  FIJSONObject.Put('b2',false);
  Check(FIJSONObject.isDouble('d1'));
  Check(FIJSONObject.isDouble('d2'));
  CheckFalse(FIJSONObject.isDouble('i2'));
  CheckFalse(FIJSONObject.isDouble('b2'));
end;

procedure TestIJSONObject.TestIsInteger;
const
  i64 = 9223372036854775807;
begin
  FIJSONObject.Put('i1',12);
  FIJSONObject.Put('i2',-50);
  FIJSONObject.Put('d2',-0.5);
  FIJSONObject.Put('i64',i64);
  Check(FIJSONObject.isInteger('i1'));
  Check(FIJSONObject.isInteger('i2'));
  CheckFalse(FIJSONObject.isInteger('d2'));
  Check(FIJSONObject.GetInteger('i64', 0) = i64);
end;

procedure TestIJSONObject.TestIsObject;
begin
  FIJSONObject.Put('myObject',TJSON.NewObject('{"key":"value"}'));
  FIJSONObject.Put('i2',-50);
  FIJSONObject.Put('d2',-0.5);
  Check(FIJSONObject.isJSONObject('myObject'));
  CheckFalse(FIJSONObject.isJSONObject('i2'));
  CheckFalse(FIJSONObject.isJSONObject('d2'));
end;

procedure TestIJSONObject.TestIsString;
begin
  FIJSONObject.Put('s1','string');
  FIJSONObject.Put('s2','abc');
  FIJSONObject.Put('myObject',TJSON.NewObject('{"key":"value"}'));
  FIJSONObject.Put('i2',-50);
  Check(FIJSONObject.isString('s1'));
  Check(FIJSONObject.isString('s2'));
  CheckFalse(FIJSONObject.isString('myObject'));
  CheckFalse(FIJSONObject.isString('i2'));
end;

procedure TestIJSONObject.TestPutNil;
var
  obj : IJSONObject;
begin
  obj := nil;
  StartExpectingException(JSONException);
  FIJSONObject.Put('null', obj);
  StopExpectingException('Can''t add nil-object');
end;

initialization
  // Alle Testfälle beim Testprogramm registrieren
  RegisterTest(TestIJSONObject.Suite);
end.

