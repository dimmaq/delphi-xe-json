unit JSON.Formatter;

interface

type
  IJSONFormatter = interface
    ['{9985198D-CC54-41E5-A5FC-26CAAA3ECEBE}']
    function FormatJSON(const aInput: string): string;
  end;

implementation

uses
  Classes,
  SysUtils;

type
  TJSONFormatter = class(TInterfacedObject, IJSONFormatter)
  private
    fPosition: integer;
    fLevel: integer;
    fInput: string;
    fOutput: TStringList;
    function NextChar: Char;
    function PrevChar: Char;

    procedure RemoveWhiteSpace;
    procedure Indent(aStringBuilder: TStringBuilder); overload;

    procedure InsertLineBreaks;
    procedure Indent; overload;
  public
    constructor Create;
    destructor Destroy; override;
    function FormatJSON(const aInput: string): string;
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

  Indent;

  result := fInput;
end;

procedure TJSONFormatter.Indent(aStringBuilder: TStringBuilder);
var
  s: string;
  i: integer;
begin
  s := '';
  i := fLevel * 2;
  while i > 0 do
  begin
    s := s + ' ';
    dec(i);
  end;
  aStringBuilder.Append(s);
end;

procedure TJSONFormatter.Indent;
var
  l, level: integer;
begin
  level := 0;
  for l := 0 to fOutput.Count - 1 do
  begin
    case fOutput[l][1] of
      '{' : ;
    end;
  end;
end;

procedure TJSONFormatter.InsertLineBreaks;
var
  i: integer;
  insideString: boolean;
begin
  i := 1;
  insideString := false;
  while i < length(fInput) do
  begin
    case fInput[i] of
      '\':
        inc(i, 2);
      '"':
        begin
          insideString := not insideString;
          inc(i);
        end;
      '{', '}', '[', ']', ',':
        begin
          insert(sLineBreak, fInput, i + 1);
          inc(i);
        end;
    end;
  end;
end;

function TJSONFormatter.NextChar: Char;
begin
  if (fPosition >= 1) and (fPosition <= length(fInput)) then
    result := fInput[fPosition + 1];
end;

function TJSONFormatter.PrevChar: Char;
begin
  if (fPosition >= 1) and (fPosition <= length(fInput)) then
    result := fInput[fPosition - 1];
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
      delete(fInput, i, 1)
    else
      inc(i);
  end;
end;

end.
