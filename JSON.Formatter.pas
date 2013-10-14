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
    fPosition: integer;
    fLevel: integer;
    fInput: string;
    fOutput: TStringList;

    procedure RemoveWhiteSpace;
    procedure InsertLineBreaks;
    procedure RemoveEmptyLines;
    procedure Indent;

    function getSpaces(aCount: integer): string;
  public
    constructor Create;
    destructor Destroy; override;
    function FormatJSON(const aInput: string): string;
  end;

function getJSONFormatter: IJSONFormatter;
begin
  result := TJSONFormatter.Create;
end;

{ TJSONFormatter }

constructor TJSONFormatter.Create;
begin
  fOutput := TStringList.Create;
end;

destructor TJSONFormatter.Destroy;
begin
  fOutput.Free;
  inherited;
end;

function TJSONFormatter.FormatJSON(const aInput: string): string;
begin
  fInput := aInput;

  RemoveWhiteSpace;
  InsertLineBreaks;
  fOutput.Text := fInput;
  RemoveEmptyLines;

  Indent;

  result := fOutput.Text;
end;

function TJSONFormatter.getSpaces(aCount: integer): string;
var
  i: integer;
begin
  result := '';
  i := fLevel * 2;
  while i > 0 do
  begin
    result := result + ' ';
    dec(i);
  end;
end;

procedure TJSONFormatter.Indent;
var
  l, level: integer;
begin
  level := 0;
  for l := 0 to fOutput.Count - 1 do
  begin
    case fOutput[l][1] of
      '{', '[':
        begin
          fOutput[l] := getSpaces(fLevel * 2) + fOutput[l];
          inc(fLevel);
        end;
      '}', ']':
        begin
          dec(fLevel);
          fOutput[l] := getSpaces(fLevel * 2) + fOutput[l];
          fLevel := max(fLevel, 0);
        end
    else
      fOutput[l] := getSpaces(fLevel * 2) + fOutput[l];
    end;
  end;
end;

procedure TJSONFormatter.InsertLineBreaks;
var
  i: integer;
  insideString: boolean;
  s: string;
begin
  s := '';
  i := 1;
  insideString := false;
  while i <= length(fInput) do
  begin
    if insideString then
    begin
      s := s + fInput[i];
      if (fInput[i] = '"') and (fInput[i - 1] <> '\') then
        insideString := false;
      inc(i);
    end
    else
    begin
      case fInput[i] of
        '\':
          begin
            s := s + fInput[i] + fInput[i + 1];
            inc(i, 2);
          end;
        '"':
          begin
            s := s + fInput[i];
            insideString := not insideString;
            inc(i);
          end;
        '{', '[':
          begin
            s := s + sLineBreak + fInput[i] + sLineBreak;
            inc(i);
          end;
        '}', ']':
          begin
            if (length(fInput) > i) and (fInput[i + 1] = ',') then
            begin
              s := s + sLineBreak + fInput[i] + ',' + sLineBreak;
              inc(i,2);
            end
            else
            begin
              s := s + sLineBreak + fInput[i] + sLineBreak;
              inc(i);
            end;
          end;
        ',':
          begin
            s := s + fInput[i] + sLineBreak;
            inc(i);
          end
      else
        begin
          s := s + fInput[i];
          inc(i);
        end;
      end;
    end;
  end;
  fInput := s;
end;

procedure TJSONFormatter.RemoveEmptyLines;
var
  i: integer;
begin
  for i := fOutput.Count - 1 downto 0 do
  begin
    if fOutput[i] = '' then
      fOutput.Delete(i);
  end;
end;

procedure TJSONFormatter.RemoveWhiteSpace;
const
  whitespace = [#0, #8, #9, #10, #12, #13, ' '];
var
  i: integer;
  insideString: boolean;
begin
  i := 1;
  insideString := false;
  while i < length(fInput) do
  begin
    if fInput[i] = '\' then
    begin
      inc(i, 2);
    end
    else if fInput[i] = '"' then
    begin
      insideString := not insideString;
      inc(i);
    end
    else if not insideString and CharInSet(fInput[i], whitespace) then
      Delete(fInput, i, 1)
    else
      inc(i);
  end;
end;

end.
