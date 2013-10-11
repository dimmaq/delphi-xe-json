unit JSON.Reader;

interface

uses
  JSON;

type
  IJSONReader = interface
    ['{19C800E9-95F4-40BC-A87C-FE0E4C0DF4BE}']
    function readObject(const aText: string): IJSONObject;
    function readArray(const aText: string): IJSONArray;
  end;

function getJSONReader: IJSONReader;

implementation

uses
  System.SysUtils, Generics.Collections, JSON.Classes;

type
  TJSONType = (jtString, jtInteger, jtDouble, jtBoolean, jtObject, jtArray, jtNull);

  TJSONReader = class(TInterfacedObject, IJSONReader)
  private
    fText: string;
    fPosition: Int64;
  protected
    procedure readUntil(ch: char);
    procedure readString;
    procedure readUntilControl;
    procedure readUntilMatchingSquareBrace;
    procedure readUntilMatchingCurlyBrace;

    function isObject(const aText: string): boolean;
    function isArray(const aText: string): boolean;
    function isString(const aText: string): boolean;
    function isBoolean(const aText: string): boolean;
    function isInteger(const aText: string): boolean;
    function isDouble(const aText: string): boolean;
    function isNull(const aText: string): boolean;

    function getType(const aText: string): TJSONType;
    function unescapeString(s: string): string;
    function StrToFloatF(const aText: string): double;
    function StripQuotes(const aText: string): string;
    procedure RemoveWhiteSpace;

    function TokenizeArray(const aText: string): TList<string>;
    function ArrayFromToken(aToken: TList<string>): IJSONArray;
    function TokenizeObject(const aText: string): TDictionary<string, string>;
    function ObjectFromToken(aToken: TDictionary<string, string>): IJSONObject;
  public
    function readObject(const aText: string): IJSONObject;
    function readArray(const aText: string): IJSONArray;
  end;

function getJSONReader: IJSONReader;
begin
  result := TJSONReader.Create;
end;

{ TJSONReader }

function TJSONReader.unescapeString(s: string): string;
var
  i: integer;
  hex: string;
  sb: TStringBuilder;
begin
  sb := TStringBuilder.Create;
  try
    s := StripQuotes(s);
    i := 1;
    while i <= length(s) do
    begin
      if s[i] = '\' then
      begin
        inc(i);
        case s[i] of
          '"':
            sb.Append('"');
          '\':
            sb.Append('\');
          '/':
            sb.Append('/');
          'b':
            sb.Append(#08);
          'f':
            sb.Append(#12);
          'n':
            sb.Append(#10);
          'r':
            sb.Append(#13);
          't':
            sb.Append(#09);
          'u':
            begin
              inc(i);
              hex := '$' + copy(s, i, 4);
              try
                sb.Append(WideChar(StrToInt(hex)));
              except
                on ex: EConvertError do
                begin
                  ex.RaiseOuterException(JSONException.Create('Invalid Unicode found: ' + s));
                end;
              end;
              inc(i, 3);
            end
        else
          raise JSONException.Create('Invalid escape character inside: ' + s);
        end;
      end
      else
        sb.Append(s[i]);
      inc(i);
    end;
    result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function TJSONReader.ArrayFromToken(aToken: TList<string>): IJSONArray;
var
  value: string;
  rdr: IJSONReader;
begin
  result := NewJSONArray;
  for value in aToken do
  begin
    case getType(value) of
      jtString:
        result.Put(unescapeString(value));
      jtInteger:
        result.Put(StrToInt(value));
      jtDouble:
        result.Put(StrToFloatF(value));
      jtBoolean:
        result.Put(StrToBool(value));
      jtObject:
        begin
          rdr := getJSONReader;
          result.Put(rdr.readObject(value));
        end;
      jtArray:
        begin
          rdr := getJSONReader;
          result.Put(rdr.readArray(value));
        end;
      jtNull:
        result.Put;
    end;
  end;
end;

function TJSONReader.getType(const aText: string): TJSONType;
begin
  if isObject(aText) then
    result := jtObject
  else if isArray(aText) then
    result := jtArray
  else if isString(aText) then
    result := jtString
  else if isBoolean(aText) then
    result := jtBoolean
  else if isInteger(aText) then
    result := jtInteger
  else if isDouble(aText) then
    result := jtDouble
  else if isNull(aText) then
    result := jtNull
  else
    raise JSONException.Create('Couldn''t identify valuetype of "' + aText + '"');
end;

function TJSONReader.isArray(const aText: string): boolean;
begin
  if length(aText) > 0 then
    result := (aText[1] = '[') and (aText[length(aText)] = ']')
  else
    result := false;
end;

function TJSONReader.isBoolean(const aText: string): boolean;
begin
  result := (aText = 'true') or (aText = 'false');
end;

function TJSONReader.isDouble(const aText: string): boolean;
var
  d: double;
  fs: TFormatSettings;
begin
  fs := TFormatSettings.Create('en-US');
  fs.DecimalSeparator := '.';
  result := TryStrToFloat(aText, d, fs);
end;

function TJSONReader.isInteger(const aText: string): boolean;
var
  i: integer;
begin
  result := TryStrToInt(aText, i);
end;

function TJSONReader.isNull(const aText: string): boolean;
begin
  result := aText = 'null';
end;

function TJSONReader.isObject(const aText: string): boolean;
begin
  if length(aText) > 0 then
    result := (aText[1] = '{') and (aText[length(aText)] = '}')
  else
    result := false;
end;

function TJSONReader.isString(const aText: string): boolean;
begin
  if length(aText) > 1 then
    result := (aText[1] = '"') and (aText[length(aText)] = '"')
  else
    result := false;
end;

function TJSONReader.ObjectFromToken(aToken: TDictionary<string, string>): IJSONObject;
var
  key, value: string;
begin
  result := NewJSONObject;
  for key in aToken.Keys do
  begin
    value := aToken[key];
    case getType(value) of
      jtString:
        result.Put(unescapeString(key), unescapeString(value));
      jtInteger:
        result.Put(unescapeString(key), StrToInt(value));
      jtDouble:
        result.Put(unescapeString(key), StrToFloatF(value));
      jtBoolean:
        result.Put(unescapeString(key), StrToBool(value));
      jtObject:
        result.Put(unescapeString(key), readObject(value));
      jtArray:
        result.Put(unescapeString(key), readArray(value));
      jtNull:
        result.Put(unescapeString(key));
    end;
  end;
end;

function TJSONReader.readArray(const aText: string): IJSONArray;
var
  liToken: TList<string>;
begin
  fText := Trim(aText);
  RemoveWhiteSpace;
  if (fText = '[]') or (fText = '') then
    result := NewJSONArray
  else if getType(fText) <> jtArray then
    raise JSONException.Create('Not an array: ' + aText)
  else
  begin
    fPosition := 2;
    liToken := TokenizeArray(fText);
    result := ArrayFromToken(liToken);
    liToken.Free;
  end;
end;

procedure TJSONReader.readUntilControl;
const
  control = ['{', '[', ','];
var
  inString: boolean;
begin
  inString := false;
  while (fPosition < length(fText)) and (inString or not CharInSet(fText[fPosition], control)) do
  begin
    if not inString then
      inString := (fText[fPosition] = '"') and (fText[fPosition - 1] <> '\')
    else if (fText[fPosition] = '"') and (fText[fPosition - 1] <> '\') then
      inString := false;
    inc(fPosition);
  end;
end;

procedure TJSONReader.readUntilMatchingCurlyBrace;
var
  level: integer;
begin
  level := 1;
  while level > 0 do
  begin
    inc(fPosition);
    case fText[fPosition] of
      '{':
        inc(level);
      '}':
        dec(level);
      '"':
        readUntil('"');
    end;
  end;
  inc(fPosition);
end;

procedure TJSONReader.readUntilMatchingSquareBrace;
var
  level: integer;
begin
  level := 1;
  while level > 0 do
  begin
    inc(fPosition);
    case fText[fPosition] of
      '[':
        inc(level);
      ']':
        dec(level);
      '"':
        readUntil('"');
    end;
  end;
  inc(fPosition);
end;

procedure TJSONReader.RemoveWhiteSpace;
const
  whitespace = [#0, #8, #9, #10, #12, #13, ' '];
var
  i: integer;
  insideString: boolean;
begin
  i := 1;
  insideString := false;
  while i < length(fText) do
  begin
    if fText[i] = '\' then
    begin
      inc(i, 2);
    end
    else if fText[i] = '"' then
    begin
      insideString := not insideString;
      inc(i);
    end
    else if not insideString and CharInSet(fText[i], whitespace) then
      delete(fText, i, 1)
    else
      inc(i);
  end;
end;

function TJSONReader.StripQuotes(const aText: string): string;
begin
  result := aText;
  if result[1] = '"' then
    delete(result, 1, 1);
  if result[length(result)] = '"' then
    delete(result, length(result), 1);
end;

function TJSONReader.StrToFloatF(const aText: string): double;
var
  f: TFormatSettings;
begin
  f := TFormatSettings.Create('en-US');
  f.DecimalSeparator := '.';
  result := StrToFloat(aText, f);
end;

function TJSONReader.TokenizeArray(const aText: string): TList<string>;
var
  start: integer;
  value: string;
begin
  result := TList<string>.Create;
  while fPosition < length(fText) do
  begin
    start := fPosition;
    readUntilControl;
    case fText[fPosition] of
      '{':
        begin
          readUntilMatchingCurlyBrace;
          value := copy(fText, start, fPosition - start);
        end;
      '[':
        begin
          readUntilMatchingSquareBrace;
          value := copy(fText, start, fPosition - start);
        end;
      ',', '}', ']':
        begin
          value := copy(fText, start, fPosition - start);
        end;
    end;
    inc(fPosition);
    result.Add(Trim(value));
  end;
end;

function TJSONReader.TokenizeObject(const aText: string): TDictionary<string, string>;
var
  start: integer;
  key, value: string;
begin
  result := TDictionary<string, string>.Create;
  while fPosition < length(fText) do
  begin
    start := fPosition;
    readUntil('"');
    inc(fPosition);
    readString;
    key := Trim(copy(fText, start + 1, fPosition - start - 2));
    key := StripQuotes(key);
    inc(fPosition);
    start := fPosition;
    readUntilControl;
    case fText[fPosition] of
      '{':
        begin
          readUntilMatchingCurlyBrace;
          value := copy(fText, start, fPosition - start);
        end;
      '[':
        begin
          readUntilMatchingSquareBrace;
          value := copy(fText, start, fPosition - start);
        end;
      ',', '}':
        value := copy(fText, start, fPosition - start);
    end;
    result.Add(key, Trim(value));
  end;
end;

function TJSONReader.readObject(const aText: string): IJSONObject;
var
  dictToken: TDictionary<string, string>;
begin
  fText := Trim(aText);
  RemoveWhiteSpace;

  if (fText = '{}') or (fText = '') then
    result := NewJSONObject
  else if getType(fText) <> jtObject then
    raise JSONException.Create('Not an object: ' + fText)
  else
  begin
    fPosition := 1;
    dictToken := TokenizeObject(fText);
    result := ObjectFromToken(dictToken);
    dictToken.Free;
  end;
end;

procedure TJSONReader.readString;
var
  done: boolean;
begin
  done := false;
  while not done and (fPosition < length(fText)) do
  begin
    if fText[fPosition] = '\' then
    begin
      inc(fPosition, 2);
    end
    else if fText[fPosition] = '"' then
    begin
      inc(fPosition);
      done := true;
    end
    else
      inc(fPosition);
  end;
end;

procedure TJSONReader.readUntil(ch: char);
begin
  while fText[fPosition] <> ch do
  begin
    inc(fPosition);
  end;
end;

end.
