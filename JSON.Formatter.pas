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
  SysUtils;

type
  TJSONFormatter = class(TInterfacedObject, IJSONFormatter)
  private
    function RemoveWhiteSpace(const aInput: string): string;
    function InsertLineBreaks(const aInput: string): string;
    function RemoveEmptyLines(const aInput: string): string;
    function Indent(const aInput: string): string;
    function getSpaces(aCount: integer): string;
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
  result := RemoveWhiteSpace(aInput);
  // Split up logical units of JSON
  result := InsertLineBreaks(result);
  // It's easier to clean up empty lines then preventing them
  result := RemoveEmptyLines(result);
  // Indent each line with the correct space
  result := Indent(result);
end;

function TJSONFormatter.getSpaces(aCount: integer): string;
begin
  result := '';
  while aCount > 0 do
  begin
    result := result + ' ';
    dec(aCount);
  end;
end;

function TJSONFormatter.Indent(const aInput: string): string;
var
  sl: TStringList;
  i: integer;
  lvl : integer;
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
            if sl[i][2] = '}' then
              sl[i] := getSpaces(lvl * 2) + sl[i]
            else
            begin
              sl[i] := getSpaces(lvl * 2) + sl[i];
              inc(lvl);
            end;
          end;
        '[':
          begin
            if sl[i][2] = ']' then
              sl[i] := getSpaces(lvl * 2) + sl[i]
            else
            begin
              sl[i] := getSpaces(lvl * 2) + sl[i];
              inc(lvl);
            end;
          end;
        '}', ']':
          begin
            dec(lvl);
            lvl := max(lvl, 0);
            sl[i] := getSpaces(lvl * 2) + sl[i];
          end
      else
        sl[i] := getSpaces(lvl * 2) + sl[i];
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
      if (aInput[i] = '"') and (aInput[i - 1] <> '\') then
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

function TJSONFormatter.RemoveWhiteSpace(const aInput: string): string;
const
  whitespace = [#0, #8, #9, #10, #12, #13, ' '];
var
  i: integer;
  insideString: boolean;
begin
  i := 1;
  insideString := false;
  while i <= length(aInput) do
  begin
    if aInput[i] = '\' then
    begin
      result := result + aInput[i] + aInput[i + 1];
      inc(i, 2);
    end
    else if aInput[i] = '"' then
    begin
      result := result + aInput[i];
      insideString := not insideString;
      inc(i);
    end
    else if not insideString and CharInSet(aInput[i], whitespace) then
      inc(i)
    else
    begin
      result := result + aInput[i];
      inc(i);
    end;
  end;
end;

end.
