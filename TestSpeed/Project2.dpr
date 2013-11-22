program Project2;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  madExcept,
  madLinkDisAsm,
  System.SysUtils,
  System.Diagnostics,
  windows,
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
    i, j: Integer;
    sw: TStopwatch;
  begin
    for i := 1 to 7 do
    begin
      sw := TStopwatch.StartNew;
      for j := 1 to 333 do
        proc;
      sw.Stop;
      Write(sw.ElapsedMilliseconds, ', ');
    end;
    Writeln;
  end;

begin
//  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  try
//    Write('old: '); test(test1);
    Write('new: '); test(test2);

    WriteLn('Finish. "Enter" for exit...');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
//  SetPriorityClass(GetCurrentProcess, NORMAL_PRIORITY_CLASS);
  readln;
end.
