program JSON_XETests;

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  TestJSONReader in 'TestJSONReader.pas',
  JSON.Reader in '..\JSON.Reader.pas',
  TestJSONWriter in 'TestJSONWriter.pas',
  JSON.Writer in '..\JSON.Writer.pas',
  TestJSONObject in 'TestJSONObject.pas',
  JSON in '..\JSON.pas',
  TestJSONArray in 'TestJSONArray.pas',
  TestJSONConvert in 'TestJSONConvert.pas',
  JSON.Convert in '..\JSON.Convert.pas',
  JSON.Classes in '..\JSON.Classes.pas',
  TestReadableWriter in 'TestReadableWriter.pas';

{$R *.RES}

begin
  Application.Initialize;
  if IsConsole then
    with TextTestRunner.RunRegisteredTests do
      Free
  else
    GUITestRunner.RunRegisteredTests;
end.

