unit TestJSONReader;

interface

uses
  TestFramework, Generics.Collections, SysUtils, DelphiXe.JSON.Reader;

type
  // Testmethoden für Klasse IJSONReader

  TestIJSONReader = class(TTestCase)
  strict private
    FIJSONReader: IJSONReader;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSimpleObject;
    procedure TestSimpleArray;
    procedure TestNestedObjects;
    procedure TestNestedArrays;
    procedure TestComplicatedObject;
    procedure TestComplicatedArray;
    procedure TestPaddedObject;
    procedure TestInvalidObject;
    procedure TestStringWithBraces;
    procedure TestStringWithCurlyBrace;
    procedure TestStringWithSlashes;
    procedure TestStringWithUnicode;
    procedure TestInvalidUnicode;
  end;

implementation

uses
  DelphiXe.JSON;

procedure TestIJSONReader.SetUp;
begin
  FIJSONReader := getJSONReader;
end;

procedure TestIJSONReader.TearDown;
begin
  FIJSONReader := nil;
end;

procedure TestIJSONReader.TestSimpleObject;
var
  ReturnValue: IJSONObject;
  aText: string;
begin
  aText := '{"IntValue":123}';
  ReturnValue := FIJSONReader.readObject(aText);

  CheckEquals(ReturnValue.GetInteger('IntValue'), 123);
end;

procedure TestIJSONReader.TestStringWithSlashes;
var
  jo : IJSONObject;
  s : string;
begin
  jo := FIJSONReader.readObject('{"special":"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAf\/\/\/7\/\/9\/\/\/AP\/+AA\/\/\/\/\/+AAAB\/\/\/"}');
  s := jo.GetString('special');
  Check(s = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAf///7//9///AP/+AA/////+AAAB///');

  jo := FIJSONReader.readObject('{"special":"\"\\\/\b\f\n\r\t\""}');
  s := jo.GetString('special');
  Check(s = '"\/'#08#12#10#13#9'"');
end;

procedure TestIJSONReader.TestStringWithUnicode;
var
  jo : IJSONObject;
  s : string;
begin
  jo := FIJSONReader.readObject('{"unicode":"\u0021"}');
  s := jo.GetString('unicode');
  Check(s = '!');
end;

procedure TestIJSONReader.TestStringWithBraces;
var
  ReturnValue: IJSONObject;
  aText: string;
begin
  aText := '{"String":"(empty)"}';
  ReturnValue := FIJSONReader.readObject(aText);

  CheckEquals(ReturnValue.GetString('String'), '(empty)');
end;

procedure TestIJSONReader.TestComplicatedArray;
var
  ReturnValue: IJSONArray;
  aText: string;
begin
  aText := '[{"IntValue":123},"abc",true,[1,2,3]]';
  ReturnValue := FIJSONReader.readArray(aText);

  CheckEquals(ReturnValue.Count, 4);
  CheckEquals(ReturnValue.GetJSONObject(0).GetInteger('IntValue'), 123);
  CheckEquals(ReturnValue.GetString(1), 'abc');
  CheckEquals(ReturnValue.GetBoolean(2), true);
  CheckEquals(ReturnValue.GetJSONArray(3).Count, 3);
end;

procedure TestIJSONReader.TestComplicatedObject;
var
  ReturnValue: IJSONObject;
  aText: string;
begin
  aText := '{"IntValue":123,"obj":{"boolValue":false},"array":[1.23,true]}';
  ReturnValue := FIJSONReader.readObject(aText);

  CheckEquals(ReturnValue.GetInteger('IntValue'), 123);
  CheckEquals(ReturnValue.GetJSONObject('obj').GetBoolean('boolValue'), false);
  CheckEquals(ReturnValue.GetJSONArray('array').Count, 2);
end;

procedure TestIJSONReader.TestStringWithCurlyBrace;
var
  aText : string;
  jo : IJSONObject;
begin
  aText := '{"key":"ab}cdef}"}';
  jo := FIJSONReader.readObject(aText);
  CheckEquals('ab}cdef}',jo.GetString('key'));
end;

procedure TestIJSONReader.TestInvalidObject;
var
  aText: string;
begin
  aText := '{"value":1'; // missing "}" at end

  StartExpectingException(JSONException);
  FIJSONReader.readObject(aText);
  StopExpectingException;
end;

procedure TestIJSONReader.TestInvalidUnicode;
var
  aText: string;
begin
  aText := '{"value":"\umoep"}'; // missing "}" at end

  StartExpectingException(JSONException);
  FIJSONReader.readObject(aText);
  StopExpectingException;
end;

procedure TestIJSONReader.TestNestedArrays;
var
  ReturnValue: IJSONArray;
  aText: string;
begin
  aText := '[[1,2],[3],[]]';
  ReturnValue := FIJSONReader.readArray(aText);
  CheckEquals(ReturnValue.Count, 3);
  CheckEquals(ReturnValue.GetJSONArray(0).GetInteger(0), 1);
  CheckEquals(ReturnValue.GetJSONArray(1).Count, 1);
  CheckEquals(ReturnValue.GetJSONArray(2).Count, 0);
end;

procedure TestIJSONReader.TestNestedObjects;
var
  ReturnValue: IJSONObject;
  aText: string;
  keys: TArray<string>;
begin
  aText := '{"obj1":{"int":0},"obj2":{"obj2.1":{"string":"def"}},"emptyObject":{}}';
  ReturnValue := FIJSONReader.readObject(aText);

  CheckEquals(ReturnValue.GetJSONObject('obj1').GetInteger('int'), 0);
  CheckEquals(ReturnValue.GetJSONObject('obj2').GetJSONObject('obj2.1').GetString('string'), 'def');

  keys := ReturnValue.GetJSONObject('emptyObject').GetKeys;
  CheckEquals(length(keys), 0);
end;

procedure TestIJSONReader.TestPaddedObject;
var
  ReturnValue: IJSONObject;
  aText: string;
begin
  aText := '  {' + #13#10 + '  "key" : "value" ' + #13#10 + '}  ';
  ReturnValue := FIJSONReader.readObject(aText);
  CheckEquals(ReturnValue.GetString('key'), 'value');
end;

procedure TestIJSONReader.TestSimpleArray;
var
  ReturnValue: IJSONArray;
  aText: string;
  expectedDouble: double;
begin
  aText := '["abc",1,5.67]';
  ReturnValue := FIJSONReader.readArray(aText);

  CheckEquals(ReturnValue.Count, 3);
  CheckEquals(ReturnValue.GetString(0), 'abc');
  CheckEquals(ReturnValue.GetInteger(1), 1);
  //
  expectedDouble := 5.67;
  CheckEquals(ReturnValue.GetDouble(2), expectedDouble);
end;

initialization

// Alle Testfälle beim Testprogramm registrieren
RegisterTest(TestIJSONReader.Suite);

end.
