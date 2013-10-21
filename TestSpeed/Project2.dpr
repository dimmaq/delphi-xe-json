program Project2;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  madExcept,
  madLinkDisAsm,
  System.SysUtils,
  System.Diagnostics,
  ujson,
  json,
  ujson_test in 'ujson_test.pas';


  procedure test1;
  var json: ujson.TJSONObject;
  begin
    json := ujson.TJSONObject.create(TEST_JSON);
    try
      json.getInt('credits');
    finally
      json.Free;
    end;
  end;

  procedure test2;
  var json: IJSONObject;
  begin
    json := tjson.NewObject(TEST_JSON);
    json.GetInteger('credits');
  end;

  procedure test(proc: TProcedure);
  var
    j: Integer;
    sw: TStopwatch;
  begin
    sw := TStopwatch.StartNew;
    for j := 1 to 1000 do
      proc;
    sw.Stop;
    Writeln(sw.ElapsedMilliseconds);
  end;

begin
  try
    test(test1);
    test(test2);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  readln;
end.
