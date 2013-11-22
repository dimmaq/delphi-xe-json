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
  System.SysUtils, System.Rtti, Generics.Collections,
  JSON.Classes, JSON.IOHelper;

type
  TJSONType = (jtString, jtInteger, jtDouble, jtBoolean, jtObject, jtArray, jtNull);

  TJSONReader = class(TInterfacedObject, IJSONReader)
  private
    FText: PChar;
    FLast: PChar;
    //---
    procedure InitText(const AText: string);
    //---
    function GetObject: IJSONObject;
    function GetArray: IJSONArray;
    function GetString: string;
    function GetType: TJSONType;
    function GetValue: string;
    //---
    procedure NextChar(const ACount: Integer); overload; inline;
    procedure NextChar; overload; inline;
    function SkipSpacesNotRaise: Boolean;
    procedure SkipSpaces; inline;
    function IsBoolean(out ABol: Boolean): Boolean;
    function IsInteger(const AValue: string; out AInt: Int64): Boolean;
    function IsDouble(const AValue: string; out ADouble: Double): Boolean;
    function IsNull: Boolean;
  protected
  public
    function readObject(const aText: string): IJSONObject;
    function readArray(const aText: string): IJSONArray;
  end;

const
  SNULL_LENGTH = 4;
  SBOOL_LENGTH: array[Boolean] of Integer = (5, 4);

var
  STRUE: string = 'true';
  SFALSE: string = 'false';
  SNULL: string = 'null';

function geTJSONReader: IJSONReader;
begin
  result := TJSONReader.Create;
end;

procedure RaiseEndOfData;
begin
  raise JSONException.Create('Unexpected end of data');
end;

procedure RaiseUnknowValueType(const A: string);
begin
  raise JSONException.CreateFmt('Couldn''t identify valuetype of "%s"', [A]);
end;

{ TJSONReader }

procedure TJSONReader.InitText(const AText: string);
begin
  FText := PChar(AText);
  FLast := FText;
  Inc(FLast, AText.Length);
end;

procedure TJSONReader.NextChar(const ACount: Integer);
begin
  Inc(FText, ACount);
  if FText > FLast then
  begin
    RaiseEndOfData();
  end;
end;

procedure TJSONReader.NextChar;
begin
  Inc(FText);
  if FText > FLast then
  begin
    RaiseEndOfData();
  end;
end;

procedure TJSONReader.SkipSpaces;
begin
  while (FText <= FLast) and (FText^ <= ' ') do
  begin
    Inc(FText);
  end;
  if FText > FLast then
  begin
    RaiseEndOfData();
  end;
end;

function TJSONReader.SkipSpacesNotRaise: Boolean;
begin
  while (FText^ <= ' ') and (FText <= FLast) do
  begin
    Inc(FText);
  end;
  Result := FText <= FLast
end;

function unescapeJsonString(const A: string): string;
var
  j,l,k,b: Integer;
  hex: string;
  ch: Char;

  procedure addChar; overload;
  begin
    Inc(k);
    Result[k] := ch;
  end;
  procedure addChar(C: Char); overload;
  begin
    Inc(k);
    Result[k] := C;
  end;

begin
  j := 1;
  l := Length(A);
  k := 0;
  SetLength(Result, l);
  while j <= l do
  begin
    ch := A[j];
    if ch = '\' then
    begin
      Inc(j);
      ch := A[j];
      case ch of
        '"': addChar();
        '\': addChar();
        '/': addChar();
        'b': addChar(#08); // backspace
        'f': addChar(#12); // formfeed
        'n': addChar(#10); // newline
        'r': addChar(#13); //carriage return
        't': addChar(#09); // tab
        'u':
          begin
            Inc(j);
            hex := '$' + Copy(A, j, 4);
            if TryStrToInt(hex, b) then
            begin
              Inc(j, 3);
              addChar(Char(b));
            end
            else
            begin
              raise JSONException.Create('Invalid Unicode found: ' + hex)
            end
          end
      else
        raise JSONException.Create('Invalid escape character inside');
      end;
    end
    else
    begin
      addChar();
    end;
    Inc(j);
  end;
  SetLength(Result, k);
end;

function TJSONReader.GetString: string;
var
  isUnescape: Boolean;
  startChar: PChar;
begin
  Result := '';
  if FText^ = '"' then
  begin
    isUnescape := False;
    NextChar();
    startChar := FText;
    while FText^ <> '"' do
    begin
      if FText^ = '\' then
      begin
        Inc(FText);
        if not isUnescape then
          isUnescape := True;
      end;
      NextChar();
    end;
    //---
    SetString(Result, startChar, FText - startChar);
    if isUnescape then
      Result := unescapeJsonString(Result);
  end
  else
  begin
    raise JSONException.Create('is not string');
  end;
  Inc(FText);
end;

function TJSONReader.GetType: TJSONType;
begin
  case FText^ of
    '{': Result := jtObject;
    '[': Result := jtArray;
    '"': Result := jtString;
    else
      Result := jtNull
  end;
end;

function TJSONReader.GetValue: string;
var
  startChar: PChar;
begin
  startChar := FText;
  SkipSpaces();
  while not CharInSet(FText^, ['[', ']', '{', '}', ',', '"', #0..#32]) do
  begin
    NextChar();
  end;
  SetString(Result, startChar, FText - startChar);
end;

function TJSONReader.IsBoolean(out ABol: Boolean): Boolean;
begin
  if (FLast - FText) >= 5 then // 'true' 'false'
  begin
    if CompareMem(FText, Pointer(STRUE), SBOOL_LENGTH[TRUE] * SizeOf(Char)) then
    begin
      ABol := True;
      Exit(True);
    end
    else
    if CompareMem(FText, Pointer(SFalse), SBOOL_LENGTH[FALSE] * SizeOf(Char)) then
    begin
      ABol := False;
      Exit(True);
    end
  end;
  Result := False;
end;

function TJSONReader.IsDouble(const AValue: string; out ADouble: Double): Boolean;
var
  fs: TFormatSettings;
begin
  fs := TFormatSettings.Create('en-US');
  fs.DecimalSeparator := '.';
  Result := TryStrToFloat(AValue, ADouble, fs);
end;

function TJSONReader.IsInteger(const AValue: string; out AInt: Int64): Boolean;
begin
  Result := TryStrToInt64(AValue, AInt);
end;

function TJSONReader.IsNull: Boolean;
begin
  Result := ((FLast - FText) >= SNULL_LENGTH)
              and CompareMem(FText, Pointer(SNULL), SNULL_LENGTH * SizeOf(Char));
end;


function TJSONReader.GetArray: IJSONArray;
var
  val: string;
  bol: Boolean;
  int: Int64;
  ext: Double;
begin
  Result := NewJSONArray();
  SkipSpaces();
  if FText^ = '[' then
  begin
    NextChar();
  end;
  while (FText <= FLast) and (FText^ <> ']') do
  begin
    SkipSpaces();
    case GetType() of
      jtObject: Result.Put(GetObject());
      jtArray: Result.Put(GetArray());
      jtString: Result.Put(GetString());
    else
      begin
        if IsNull() then
        begin
          Result.Put();
          NextChar(SNULL_LENGTH);
        end
        else
        if IsBoolean(bol) then
        begin
          Result.Put(bol);
          NextChar(SBOOL_LENGTH[bol]);
        end
        else
        begin
          val := GetValue();
          if IsInteger(val, int) then
            Result.Put(int)
          else
          if IsDouble(val, ext) then
            Result.Put(ext)
          else
            RaiseUnknowValueType(val)
        end;
      end
    end;
    SkipSpaces();
    if FText^ = ',' then
    begin
      NextChar()
    end
  end;
  Inc(FText);
end;

function TJSONReader.GetObject: IJSONObject;
var
  key: string;
  val: string;
  bol: Boolean;
  int: Int64;
  ext: Double;
begin
  Result := NewJSONObject();
  SkipSpaces();
  if FText^ = '{' then
  begin
    NextChar();
  end;
  while (FText <= FLast) and (FText^ <> '}') do
  begin
    SkipSpaces();
    key := GetString();
    SkipSpaces();
    if FText^ = ':' then
    begin
      Inc(FText);
      SkipSpaces();
      case GetType() of
        jtObject: Result.Put(key, GetObject());
        jtArray: Result.Put(key, GetArray());
        jtString: Result.Put(key, GetString());
      else
        begin
          if IsNull() then
          begin
            Result.Put(key);
            NextChar(SNULL_LENGTH);
          end
          else
          if IsBoolean(bol) then
          begin
            Result.Put(key, bol);
            NextChar(SBOOL_LENGTH[bol]);
          end
          else
          begin
            val := GetValue();
            if IsInteger(val, int) then
              Result.Put(key, int)
            else
            if IsDouble(val, ext) then
              Result.Put(key, ext)
            else
              RaiseUnknowValueType(val)
          end;
        end
      end
    end
    else
    begin
      raise JSONException.CreateFmt('Not value for key: "%s"', [key]);
    end;
    SkipSpaces();
    if FText^ = ',' then
    begin
      NextChar()
    end
  end;
  Inc(FText);
end;

function TJSONReader.readArray(const aText: string): IJSONArray;
begin
  if aText.IsEmpty then
  begin
    Result := NewJSONArray()
  end
  else
  begin
    InitText(aText);
    if SkipSpacesNotRaise() then
    begin
      Result := GetArray();
    end
    else
    begin
      Result := NewJSONArray()
    end
  end
end;

function TJSONReader.readObject(const aText: string): IJSONObject;
begin
  if aText.IsEmpty then
  begin
    Result := NewJsonObject()
  end
  else
  begin
    InitText(aText);
    if SkipSpacesNotRaise then
    begin
      Result := GetObject();
    end
    else
    begin
      Result := NewJsonObject()
    end
  end
end;


end.
