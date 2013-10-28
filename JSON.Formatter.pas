unit JSON.Formatter;

interface

type
  IJSONFormatter = interface
    ['{9985198D-CC54-41E5-A5FC-26CAAA3ECEBE}']
    function FormatJSON(const aInput: string): string;
  end;

function getJSONFormatter: IJSONFormatter;

implementation

uses
  Classes,
  Math,
  SysUtils,
  JSON.IOHelper;

type
  TJSONFormatter = class(TInterfacedObject, IJSONFormatter)
  private
    function InsertLineBreaks(const aInput: string): string;
    function RemoveEmptyLines(const aInput: string): string;
    function Indent(const aInput: string): string;
  public
    function FormatJSON(const aInput: string): string;
  end;

function getJSONFormatter: IJSONFormatter;
begin
  result := TJSONFormatter.Create;
end;

{ TJSONFormatter }

function TJSONFormatter.FormatJSON(const aInput: string): string;
begin
  // Clean the input from previous formatting
  result := TJSONIOHelper.RemoveWhiteSpace(aInput);
  // Split up logical units of JSON
  result := InsertLineBreaks(result);
  // It's easier to clean up empty lines then preventing them
  result := RemoveEmptyLines(result);
  // Indent each line with the correct space
  result := Indent(result);
end;

function TJSONFormatter.Indent(const aInput: string): string;
var
  sl: TStringList;
  i: integer;
  lvl: integer;
begin
  lvl := 0;
  sl := TStringList.Create;
  try
    sl.Text := aInput;
    for i := 0 to sl.Count - 1 do
    begin
      case sl[i][1] of
        '{':
          begin
            sl[i] := TJSONIOHelper.getSpaces(lvl * 2) + sl[i];
            if sl[i][2] <> '}' then
              inc(lvl);
          end;
        '[':
          begin
            sl[i] := TJSONIOHelper.getSpaces(lvl * 2) + sl[i];
            if sl[i][2] <> ']' then
              inc(lvl);
          end;
        '}', ']':
          begin
            dec(lvl);
            lvl := max(lvl, 0);
            sl[i] := TJSONIOHelper.getSpaces(lvl * 2) + sl[i];
          end
      else
        sl[i] := TJSONIOHelper.getSpaces(lvl * 2) + sl[i];
      end;
    end;
    result := sl.Text;
  finally
    sl.Free;
  end;
end;

function TJSONFormatter.InsertLineBreaks(const aInput: string): string;
var
  i: integer;
  insideString: boolean;
  s: string;
begin
  s := '';
  i := 1;
  insideString := false;
  while i <= length(aInput) do
  begin
    if insideString then
    begin
      s := s + aInput[i];
      if aInput[i] = '\' then
      begin
        s := s + aInput[i + 1];
        inc(i, 2);
      end;
      if aInput[i] = '"' then
        insideString := false;
      inc(i);
    end
    else
    begin
      case aInput[i] of
        '\':
          begin
            s := s + aInput[i] + aInput[i + 1];
            inc(i, 2);
          end;
        '"':
          begin
            s := s + aInput[i];
            insideString := not insideString;
            inc(i);
          end;
        '{':
          begin
            if aInput[i + 1] = '}' then
            begin
              s := s + '{}';
              inc(i, 2);
            end
            else
            begin
              s := s + sLineBreak + aInput[i] + sLineBreak;
              inc(i);
            end;
          end;
        '[':
          begin
            if aInput[i + 1] = ']' then
            begin
              s := s + '[]';
              inc(i, 2);
            end
            else
            begin
              s := s + sLineBreak + aInput[i] + sLineBreak;
              inc(i);
            end;
          end;
        '}', ']':
          begin
            if (length(aInput) > i) and (aInput[i + 1] = ',') then
            begin
              s := s + sLineBreak + aInput[i] + ',' + sLineBreak;
              inc(i, 2);
            end
            else
            begin
              s := s + sLineBreak + aInput[i] + sLineBreak;
              inc(i);
            end;
          end;
        ',':
          begin
            s := s + aInput[i] + sLineBreak;
            inc(i);
          end;
      else
        begin
          s := s + aInput[i];
          inc(i);
        end;
      end;
    end;
  end;
  result := s;
end;

function TJSONFormatter.RemoveEmptyLines(const aInput: string): string;
var
  sl: TStringList;
  i: integer;
begin
  sl := TStringList.Create;
  try
    sl.Text := aInput;
    for i := sl.Count - 1 downto 0 do
    begin
      if sl[i] = '' then
        sl.Delete(i);
    end;
    result := sl.Text;
  finally
    sl.Free;
  end;
end;

end.
