unit JSON.Writer;

interface

uses
  JSON;

type
  IJSONWriter = interface
    function writeObject(aObject: IJSONObject; aIndent: integer = 0): string;
    function writeArray(aArray: IJSONArray; aIndent: integer = 0): string;
  end;

function getJSONWriter: IJSONWriter;
function getReadableJSONWriter: IJSONWriter;

implementation

uses
  System.Rtti, System.TypInfo, System.SysUtils;

const
  CrLf = #13#10;

type
  TJSONWriterBase = class(TInterfacedObject, IJSONWriter)
  protected
    function escapeString(s: string): string;
    function writeValue(aValue: TValue): string;
    function writePair(aKey: string; aValue: TValue): string; virtual;
    function getEmptyString(aQuantity: integer): string;
  public
    function writeObject(aObject: IJSONObject; aIndent: integer = 0): string; virtual; abstract;
    function writeArray(aArray: IJSONArray; aIndent: integer = 0): string; virtual; abstract;
  end;

  TJSONWriter = class(TJSONWriterBase)
  public
    function writeObject(aObject: IJSONObject; aIndent: integer = 0): string; override;
    function writeArray(aArray: IJSONArray; aIndent: integer = 0): string; override;
  end;

  TReadableJSONWriter = class(TJSONWriterBase)
  private
    fLevel: integer;
    function shouldBeNested(aValue : TValue) : boolean;
  protected
    function writePair(aKey: string; aValue: TValue): string; override;
  public
    constructor Create;
    function writeObject(aObject: IJSONObject; aIndent: integer = 0): string; override;
    function writeArray(aArray: IJSONArray; aIndent: integer = 0): string; override;
  end;

function getJSONWriter: IJSONWriter;
begin
  result := TJSONWriter.Create;
end;

function getReadableJSONWriter: IJSONWriter;
begin
  result := TReadableJSONWriter.Create;
end;

{ TJSONWriter }

function TJSONWriter.writeArray(aArray: IJSONArray; aIndent: integer = 0): string;
var
  i: integer;
begin
  result := '[';
  for i := 0 to aArray.Count - 1 do
  begin
    if i > 0 then result := result + ',';
    result := result + writeValue(aArray.GetValue(i));
  end;
  result := result + ']';
end;

function TJSONWriter.writeObject(aObject: IJSONObject; aIndent: integer = 0): string;
var
  s: string;
begin
  result := '{';
  for s in aObject.GetKeys do
  begin
    result := result + writePair(s, aObject.GetValue(s)) + ',';
  end;
  if length(s) > 1 then delete(result, length(result), 1);
  result := result + '}';
end;

{ TJSONWriterBase }

function TJSONWriterBase.getEmptyString(aQuantity: integer): string;
var
  i: integer;
begin
  result := '';
  for i := 0 to aQuantity - 1 do
  begin
    result := result + ' ';
  end;
end;

function TJSONWriterBase.escapeString(s: string): string;
const
  NoConversion = ['A' .. 'Z', 'a' .. 'z', '*', '@', '.', '_', '-', '0' .. '9', '$', '!', '''', '(', ')', ' '];
var
  hex: string;
  ch : char;
  sb: TStringBuilder;
begin
  sb := TStringBuilder.Create;
  try
    for ch in s do
    begin
      case ch of
        '\': sb.Append('\\');
        '/': sb.Append('\/');
        '"': sb.Append('\"');
        #08: sb.Append('\b');
        #09: sb.Append('\t');
        #10: sb.Append('\n');
        #12: sb.Append('\f');
        #13: sb.Append('\r');
      else
        begin
          if CharInSet(ch, NoConversion) then
          begin
            sb.Append(ch);
          end
          else
          begin
            hex := IntToHex(Ord(ch), 4);
            sb.Append('\u' + hex);
          end;
        end;
      end;
    end;
    result := sb.ToString;
  finally
    sb.Free;
  end;
end;

function TJSONWriterBase.writePair(aKey: string; aValue: TValue): string;
begin
  result := '"' + escapeString(aKey) + '":' + writeValue(aValue);
end;

function TJSONWriterBase.writeValue(aValue: TValue): string;
var
  fs: TFormatSettings;
begin
  fs := TFormatSettings.Create('en-US');
  fs.DecimalSeparator := '.';
  case aValue.Kind of
    tkEnumeration: if aValue.AsBoolean then result := 'true'
      else result := 'false';
    tkChar, tkString, tkWChar, tkLString, tkWString, tkUString: result := '"' + escapeString(aValue.ToString) + '"';
    tkInteger, tkInt64: result := IntToStr(aValue.AsInteger);
    tkFloat: result := FloatToStr(aValue.AsExtended, fs);
    tkInterface:
      begin
        if aValue.TypeInfo.Name = 'IJSONObject' then result := writeObject(aValue.AsType<IJSONObject>)
        else if aValue.TypeInfo.Name = 'IJSONArray' then result := writeArray(aValue.AsType<IJSONArray>);
      end
  else
    begin
      result := 'null';
    end;
  end;
end;

{ TReadableJSONWriter }

constructor TReadableJSONWriter.Create;
begin
  fLevel := 0;
end;

function TReadableJSONWriter.shouldBeNested(aValue: TValue): boolean;
begin
  if aValue.IsType<IJSONObject> then
  begin
    result := aValue.AsType<IJSONObject>.Count > 0;
  end
  else
  if aValue.IsType<IJSONArray> then
  begin
    result := aValue.AsType<IJSONArray>.Count > 0;
  end
  else result := false;
end;

function TReadableJSONWriter.writeArray(aArray: IJSONArray; aIndent: integer): string;
var
  i: integer;
  sb: TStringBuilder;
  sIndent: string;
begin
  if aArray.Count = 0 then result := '[]'
  else
  begin
    sb := TStringBuilder.Create;
    sIndent := getEmptyString(fLevel * 2);
    sb.Append('[');
    sb.AppendLine;
    inc(fLevel);
    sIndent := getEmptyString(fLevel * 2);

    for i := 0 to aArray.Count - 1 do
    begin
      sb.Append(sIndent);
      sb.Append(writeValue(aArray.GetValue(i)));
      if i < aArray.Count-1 then sb.Append(',');
      sb.AppendLine;
    end;

    dec(fLevel);
    sIndent := getEmptyString(fLevel * 2);
    sb.Append(sIndent);
    sb.Append(']');

    result := sb.ToString;
    sb.Free;
  end;
end;

function TReadableJSONWriter.writeObject(aObject: IJSONObject; aIndent: integer): string;
var
  sb: TStringBuilder;
  s, sIndent: string;
  isFirstElement: boolean;
begin
  if aObject.Count = 0 then result := '{}'
  else
  begin
    sb := TStringBuilder.Create;

    sIndent := getEmptyString(fLevel * 2);

    sb.Append('{');
    sb.AppendLine;
    inc(fLevel);

    sIndent := getEmptyString(fLevel * 2);
    isFirstElement := true;

    for s in aObject.GetKeys do
    begin
      if isFirstElement then
      begin
        isFirstElement := false;
      end
      else
      begin
        sb.Append(',');
        sb.AppendLine;
      end;

      sb.Append(sIndent);
      sb.Append(writePair(s, aObject.GetValue(s)));
    end;

    sb.AppendLine;
    dec(fLevel);
    sb.Append(getEmptyString(fLevel * 2));
    sb.Append('}');

    result := sb.ToString;

    sb.Free;
  end;
end;

function TReadableJSONWriter.writePair(aKey: string; aValue: TValue): string;
var
  sb: TStringBuilder;
begin
  if shouldBeNested(aValue) then
  begin
    sb := TStringBuilder.Create;
    sb.Append('"' + escapeString(aKey) + '":');
    sb.AppendLine;
    sb.Append(getEmptyString(fLevel * 2));
    sb.Append(writeValue(aValue));
    result := sb.ToString;
    sb.Free;
  end
  else result := inherited;
end;

end.
