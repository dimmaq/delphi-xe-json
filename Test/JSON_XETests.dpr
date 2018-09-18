program JSON_XETests;

//{$IFDEF CONSOLE_TESTRUNNER}
//{$APPTYPE CONSOLE}
//{$ENDIF}

uses
  madExcept,
  madLinkDisAsm,
  madListModules,
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  TestJSONReader in 'TestJSONReader.pas',
  TestJSONWriter in 'TestJSONWriter.pas',
  TestJSONObject in 'TestJSONObject.pas',
  TestJSONArray in 'TestJSONArray.pas',
  TestJSONConvert in 'TestJSONConvert.pas',
  TestReadableWriter in 'TestReadableWriter.pas',

  DelphiXe.JSON in '..\DelphiXe.JSON.pas',
  DelphiXe.JSON.Reader in '..\DelphiXe.JSON.Reader.pas',
  DelphiXe.JSON.Writer in '..\DelphiXe.JSON.Writer.pas',
  DelphiXe.JSON.Convert in '..\DelphiXe.JSON.Convert.pas',
  DelphiXe.JSON.Classes in '..\DelphiXe.JSON.Classes.pas',
  DelphiXe.JSON.Formatter in '..\DelphiXe.JSON.Formatter.pas';

{$R *.RES}

begin
  Application.Initialize;
  if IsConsole then
    with TextTestRunner.RunRegisteredTests do
      Free
  else
    GUITestRunner.RunRegisteredTests;
end.

