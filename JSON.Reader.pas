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
    function EndOfText: Boolean;
    function NextChar(ARaiseOnEnd: Boolean; ACount: Integer): Boolean; overload;
    function NextChar(ARaiseOnEnd: Boolean): Boolean; overload;
    function NextChar(ACount: Integer): Boolean; overload;
    function NextChar(): Boolean; overload;
    function SkipSpaces(ARaiseOnEnd: Boolean = True): Boolean;
    function IsObject: Boolean;
    function IsArray: Boolean;
    function IsString: Boolean;
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

function TJSONReader.GetArray: IJSONArray;
var
  val: string;
  bol: Boolean;
  int: Int64;
  ext: Double;
begin
  Result := NewJSONArray();
  SkipSpaces();
  if IsArray() then
  begin
    NextChar();
  end;
  while (not EndOfText()) and (FText^ <> ']') do
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
          NextChar(True, SNULL_LENGTH);
        end
        else
        if IsBoolean(bol) then
        begin
          Result.Put(bol);
          NextChar(True, SBOOL_LENGTH[bol]);
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
  NextChar(False)
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
  if IsObject() then
  begin
    NextChar();
  end;
  while (not EndOfText()) and (FText^ <> '}') do
  begin
    SkipSpaces();
    key := GetString();
    SkipSpaces();
    if FText^ = ':' then
    begin
      NextChar();
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
            NextChar(True, SNULL_LENGTH);
          end
          else
          if IsBoolean(bol) then
          begin
            Result.Put(key, bol);
            NextChar(True, SBOOL_LENGTH[bol]);
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
  NextChar(False);
end;

function TJSONReader.GetString: string;
var
  k: Integer;
  hex: string;
  pch: PChar;
  sb: TStringBuilder;
begin
  if IsString() then
  begin
    sb := TStringBuilder.Create;
    try
      while NextChar() and (not IsString()) do
      begin
        if FText^ = '\' then
        begin
          NextChar();
          case FText^ of
            '"': sb.Append('"');
            '\': sb.Append('\');
            '/': sb.Append('/');
            'b': sb.Append(#08);
            'f': sb.Append(#12);
            'n': sb.Append(#10);
            'r': sb.Append(#13);
            't': sb.Append(#09);
            'u': begin
                pch := FText;
                Inc(pch);
                NextChar(4);
                SetString(hex, pch, 4);
                hex := '$' + hex;
                if TryStrToInt(hex, k) then
                begin
                  sb.Append(Char(k));
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
          sb.Append(FText^);
        end;
      end;
      //---
      NextChar(False);
      Result := sb.ToString;
    finally
      sb.Free
    end;
  end
  else
  begin
    raise JSONException.Create('is not string');
  end
end;

function TJSONReader.GetType: TJSONType;
begin
  if IsObject() then
    Result := jtObject
  else if IsArray() then
    Result := jtArray
  else if IsString() then
    Result := jtString
  else
    Result := jtNull
end;

function TJSONReader.GetValue: string;
const
  CONTROL_CHARS = ['[', ']', '{', '}', ',', '"', #0..#32];
var
  pch: PChar;
begin
  pch := FText;
  SkipSpaces();
  while NextChar() and (not CharInSet(FText^, CONTROL_CHARS)) do
    ;
  SetString(Result, pch, FText - pch);
end;

procedure TJSONReader.InitText(const AText: string);
begin
  FText := PChar(AText);
  FLast := FText;
  Inc(FLast, AText.Length);
end;

function TJSONReader.IsArray: Boolean;
begin
  Result := FText^ = '['
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

function TJSONReader.EndOfText: Boolean;
begin
  Result := (FText = nil) or (FText > FLast)
end;

function TJSONReader.IsNull: Boolean;
begin
  Result := ((FLast - FText) >= SNULL_LENGTH)
              and CompareMem(FText, Pointer(SNULL), SNULL_LENGTH * SizeOf(Char));
end;

function TJSONReader.IsObject: boolean;
begin
  Result := FText^ = '{'
end;

function TJSONReader.IsString: Boolean;
begin
  Result := FText^ = '"'
end;

function TJSONReader.NextChar(ARaiseOnEnd: Boolean; ACount: Integer): Boolean;
begin
  Inc(FText, ACount);
  Result := FText <= FLast;
  if ARaiseOnEnd and (not Result) then
  begin
    RaiseEndOfData();
  end;
end;
function TJSONReader.NextChar(ARaiseOnEnd: Boolean): Boolean;
begin
  Inc(FText, 1);
  Result := FText <= FLast;
  if ARaiseOnEnd and (not Result) then
  begin
    RaiseEndOfData();
  end;
end;
function TJSONReader.NextChar(ACount: Integer): Boolean;
begin
  Inc(FText, ACount);
  Result := FText <= FLast;
  if not Result then
  begin
    RaiseEndOfData();
  end;
end;
function TJSONReader.NextChar(): Boolean;
begin
  Inc(FText, 1);
  Result := FText <= FLast;
  if not Result then
  begin
    RaiseEndOfData();
  end;
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
    if SkipSpaces(False) then
    begin
      Result := GetArray();
    end
    else
    begin
      Result := NewJSONArray()
    end
  end
end;

function TJSONReader.SkipSpaces(ARaiseOnEnd: Boolean): Boolean;
begin
  while (FText^ <= ' ') and (FText <= FLast) do
  begin
    Inc(FText);
  end;
  Result := FText <= FLast;
  if ARaiseOnEnd and (not Result) then
  begin
    RaiseEndOfData();
  end;
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
    if SkipSpaces(False) then
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
