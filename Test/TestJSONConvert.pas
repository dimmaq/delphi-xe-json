unit TestJSONConvert;
{

  Delphi DUnit-Testfall
  ----------------------
  Diese Unit enthält ein Skeleton einer Testfallklasse, das vom Experten für Testfälle erzeugt wurde.
  Ändern Sie den erzeugten Code so, dass er die Methoden korrekt einrichtet und aus der 
  getesteten Unit aufruft.

}

interface

uses
  TestFramework, JSON.Convert, Windows, JSON;

type
  // Testmethoden für Klasse TJSONConvert

  TestTJSONConvert = class(TTestCase)
  strict private
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRectToJSON;
    procedure TestToRect;
    procedure TestPointToJSON;
    procedure TestToPoint;
  end;

implementation

procedure TestTJSONConvert.SetUp;
begin
end;

procedure TestTJSONConvert.TearDown;
begin
end;

procedure TestTJSONConvert.TestRectToJSON;
var
  ReturnValue: IJSONObject;
  aRect: TRect;
begin
  aRect.Left := 10;
  aRect.Top := 20;
  aRect.Height := 30;
  aRect.Width := 40;
  ReturnValue := TJSONConvert.ToJSON(aRect);

  CheckEquals(10,ReturnValue.GetInteger('Left'));
  CheckEquals(20,ReturnValue.GetInteger('Top'));
  CheckEquals(30,ReturnValue.GetInteger('Height'));
  CheckEquals(40,ReturnValue.GetInteger('Width'));
end;

procedure TestTJSONConvert.TestToRect;
var
  ReturnValue: TRect;
  aObject: IJSONObject;
begin
  aObject := TJSON.NewObject('{"Left":10,"Top":20,"Height":30,"Width":40}');
  ReturnValue := TJSONConvert.ToRect(aObject);

  CheckEquals(10,ReturnValue.Left);
  CheckEquals(20,ReturnValue.Top);
  CheckEquals(30,ReturnValue.Height);
  CheckEquals(40,ReturnValue.Width);
end;

procedure TestTJSONConvert.TestPointToJSON;
var
  ReturnValue: IJSONObject;
  aPoint: TPoint;
begin
  aPoint.X := 10;
  aPoint.Y := 20;
  ReturnValue := TJSONConvert.ToJSON(aPoint);
  CheckEquals(10,ReturnValue.GetInteger('X'));
  CheckEquals(20,ReturnValue.GetInteger('Y'));
end;

procedure TestTJSONConvert.TestToPoint;
var
  ReturnValue: TPoint;
  aObject: IJSONObject;
begin
  aObject := TJSON.NewObject('{"X":10,"Y":20}');
  ReturnValue := TJSONConvert.ToPoint(aObject);
  CheckEquals(10,ReturnValue.X);
  CheckEquals(20,ReturnValue.Y);
end;

initialization
  // Alle Testfälle beim Testprogramm registrieren
  RegisterTest(TestTJSONConvert.Suite);
end.

