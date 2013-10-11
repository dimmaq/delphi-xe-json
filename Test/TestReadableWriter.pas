unit TestReadableWriter;

interface

uses
  TestFramework, JSON.Writer;

type
  // Testmethoden für Klasse IJSONWriter

  TestIJSONReadableWriter = class(TTestCase)
  strict private
    FIJSONWriter: IJSONWriter;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSimpleObject;
    procedure TestSimpleArray;
    procedure TestEmptyArray;
    procedure TestNestedEmptyArray;
    procedure TestNestedArray;
  end;

implementation

uses
  JSON, JSON.Classes;

procedure TestIJSONReadableWriter.SetUp;
begin
  FIJSONWriter := getReadableJSONWriter;
end;

procedure TestIJSONReadableWriter.TearDown;
begin
  FIJSONWriter := nil;
end;

procedure TestIJSONReadableWriter.TestSimpleObject;
var
  ReturnValue: string;
  aObject: IJSONObject;
begin
  aObject := NewJSONObject;
  aObject.Put('string','abc');
  ReturnValue := FIJSONWriter.writeObject(aObject);
  Check(pos('"string":"abc"',ReturnValue) > 0);
end;

procedure TestIJSONReadableWriter.TestEmptyArray;
var
  ReturnValue: string;
  aArray: IJSONArray;
begin
  aArray := NewJSONArray;
  ReturnValue := FIJSONWriter.writeArray(aArray);
  Check(ReturnValue = '[]');
end;

procedure TestIJSONReadableWriter.TestNestedArray;
const
  expected = '{'#13#10'  "array":'#13#10'  ['#13#10'    1'#13#10'  ]'#13#10'}';
var
  ReturnValue: string;
  aObject: IJSONObject;
  aArray : IJSONArray;
begin
  aObject := NewJSONObject;
  aArray := TJSON.NewArray;
  aArray.Put(1);
  aObject.Put('array',aArray);
  ReturnValue := FIJSONWriter.writeObject(aObject);
  Check(ReturnValue = expected);
end;

procedure TestIJSONReadableWriter.TestNestedEmptyArray;
const
  expected = '{'#13#10'  "array":[]'#13#10'}';
var
  ReturnValue: string;
  aObject: IJSONObject;
  aArray : IJSONArray;
begin
  aObject := NewJSONObject;
  aArray := TJSON.NewArray;
  aObject.Put('array',aArray);
  ReturnValue := FIJSONWriter.writeObject(aObject);
  Check(ReturnValue = expected);
end;

procedure TestIJSONReadableWriter.TestSimpleArray;
var
  ReturnValue: string;
  aArray: IJSONArray;
  pOpen, pValue, pClose : integer;
begin
  aArray := NewJSONArray;
  aArray.Put('abc');
  ReturnValue := FIJSONWriter.writeArray(aArray);

  pOpen := pos('[',ReturnValue);
  pValue := pos('"abc"',ReturnValue);
  pClose := pos(']',ReturnValue);

  Check(pOpen > 0);
  Check(pValue > 0);
  Check(pClose > 0);
  Check(pOpen < pValue);
  Check(pValue < pClose);

//  Check(TRegEx.IsMatch(ReturnValue,'^\[.*"abc".*\]$',[roMultiLine]));
end;

initialization
  // Alle Testfälle beim Testprogramm registrieren
  RegisterTest(TestIJSONReadableWriter.Suite);
end.

