unit JSON.Classes;

interface

uses
  JSON;

function NewJSONObject: IJSONObject;
function NewJSONArray: IJSONArray;

implementation

uses
  System.SysUtils, System.Rtti, Generics.Collections, System.TypInfo, JSON.Writer;

type
  TJSONObject = class(TInterfacedObject, IJSONObject)
  private
    fValues: TDictionary<string, TValue>;
    function GetCount: integer;
  public
    constructor Create;
    destructor Destroy; override;
    function ToString(aReadable: boolean = false): string; reintroduce;
    function isJSONObject(const aKey: string): boolean;
    function isJSONArray(const aKey: string): boolean;
    function isString(const aKey: string): boolean;
    function isInteger(const aKey: string): boolean;
    function isBoolean(const aKey: string): boolean;
    function isDouble(const aKey: string): boolean;
    procedure Put(const aKey: string; const aValue: string); overload;
    procedure Put(const aKey: string; aValue: int64); overload;
    procedure Put(const aKey: string; aValue: double); overload;
    procedure Put(const aKey: string; aValue: boolean); overload;
    procedure Put(const aKey: string; const aValue: IJSONObject); overload;
    procedure Put(const aKey: string; const aValue: IJSONArray); overload;
    procedure Put(const aKey: string); overload;
    function GetJSONObject(const aKey: string): IJSONObject; overload;
    function GetJSONArray(const aKey: string): IJSONArray; overload;
    function GetString(const aKey: string): string; overload;
    function GetInteger(const aKey: string): int64; overload;
    function GetBoolean(const aKey: string): boolean; overload;
    function GetDouble(const aKey: string): double; overload;
    function GetJSONObject(const aKey: string; const aDefault: IJSONObject): IJSONObject; overload;
    function GetJSONArray(const aKey: string; const aDefault: IJSONArray): IJSONArray; overload;
    function GetString(const aKey: string; const aDefault: string): string; overload;
    function GetInteger(const aKey: string; aDefault: int64): int64; overload;
    function GetBoolean(const aKey: string; aDefault: boolean): boolean; overload;
    function GetDouble(const aKey: string; aDefault: double): double; overload;
    function GetKeys: TArray<string>;
    function GetValues: TArray<TValue>;
    function GetValue(const aKey: string): TValue;
    function HasKey(const aKey: string): boolean;
    property Count : integer read GetCount;
    procedure Clear;
    procedure DeleteKey(const aKey : string);
  end;

  TJSONArray = class(TInterfacedObject, IJSONArray)
  private
    fValues: TList<TValue>;
    function GetCount : integer;
  public
    constructor Create;
    destructor Destroy; override;
    function ToString(aReadable: boolean = false): string; reintroduce;
    function isJSONObject(aIndex: integer): boolean;
    function isJSONArray(aIndex: integer): boolean;
    function isString(aIndex: integer): boolean;
    function isInteger(aIndex: integer): boolean;
    function isBoolean(aIndex: integer): boolean;
    function isDouble(aIndex: integer): boolean;
    procedure Put(const aValue: string); overload;
    procedure Put(aValue: int64); overload;
    procedure Put(aValue: double); overload;
    procedure Put(aValue: boolean); overload;
    procedure Put(const aValue: IJSONObject); overload;
    procedure Put(const aValue: IJSONArray); overload;
    procedure Put; overload;
    function GetJSONObject(aIndex: integer): IJSONObject;
    function GetJSONArray(aIndex: integer): IJSONArray;
    function GetString(aIndex: integer): string;
    function GetInteger(aIndex: integer): int64;
    function GetBoolean(aIndex: integer): boolean;
    function GetDouble(aIndex: integer): double;
    property Count : integer read GetCount;
    function GetValue(aIndex: integer): TValue;
    procedure Clear;
    procedure Delete(aIndex: integer);
  end;

function NewJSONObject: IJSONObject;
begin
  result := TJSONObject.Create;
end;

function NewTJSONObject: TJSONObject;
begin
  result := TJSONObject.Create;
end;

function NewJSONArray: IJSONArray;
begin
  result := TJSONArray.Create;
end;

procedure TJSONObject.Clear;
begin
  fValues.Clear;
end;

function TJSONObject.GetCount: integer;
begin
  result := fValues.Count;
end;

constructor TJSONObject.Create;
begin
  inherited;
  fValues := TDictionary<string, TValue>.Create;
end;

procedure TJSONObject.DeleteKey(const aKey: string);
begin
  fValues.Remove(aKey);
end;

destructor TJSONObject.Destroy;
begin
  fValues.Free;
  inherited;
end;

function TJSONObject.GetBoolean(const aKey: string; aDefault: boolean): boolean;

begin
  if HasKey(aKey) then
    result := GetBoolean(aKey)
  else
    result := aDefault;
end;

function TJSONObject.GetBoolean(const aKey: string): boolean;
begin
  result := fValues[aKey].AsBoolean;
end;

function TJSONObject.GetDouble(const aKey: string): double;
begin
  result := fValues[aKey].AsExtended;
end;

function TJSONObject.GetDouble(const aKey: string; aDefault: double): double;
begin
  if HasKey(aKey) then
    result := GetDouble(aKey)
  else
    result := aDefault;
end;

function TJSONObject.GetInteger(const aKey: string): int64;
begin
  result := fValues[aKey].AsInt64;
end;

function TJSONObject.GetInteger(const aKey: string; aDefault: int64): int64;
begin
  if HasKey(aKey) then
    result := GetInteger(aKey)
  else
    result := aDefault;
end;

function TJSONObject.GetJSONArray(const aKey: string; const aDefault: IJSONArray): IJSONArray;
begin
  if HasKey(aKey) then
    result := GetJSONArray(aKey)
  else
    result := aDefault;
end;

function TJSONObject.GetJSONArray(const aKey: string): IJSONArray;
begin
  result := fValues[aKey].AsType<IJSONArray>;
end;

function TJSONObject.GetJSONObject(const aKey: string): IJSONObject;
begin
  result := fValues[aKey].AsType<IJSONObject>;
end;

function TJSONObject.GetJSONObject(const aKey: string; const aDefault: IJSONObject): IJSONObject;
begin
  if HasKey(aKey) then
    result := GetJSONObject(aKey)
  else
    result := aDefault;
end;

function TJSONObject.GetKeys: TArray<string>;
var
  s: string;
begin
  for s in fValues.Keys do
  begin
    setlength(result, length(result) + 1);
    result[high(result)] := s;
  end;
end;

function TJSONObject.GetValues: TArray<TValue>;
var
  val: TValue;
  l,k: Integer;
begin
  l := fValues.Count;
  k := 0;
  SetLength(Result, l);
  for val in fValues.Values do
  begin
    if k > l then
      raise Exception.Create('k > l; TJSONObject.GetValues');
    Result[k] := val;
    Inc(k)
  end;
end;

function TJSONObject.GetString(const aKey: string): string;
begin
  result := fValues[aKey].AsString;
end;

function TJSONObject.GetString(const aKey: string; const aDefault: string): string;
begin
  if HasKey(aKey) then
    result := GetString(aKey)
  else
    result := aDefault;
end;

procedure TJSONObject.Put(const aKey: string; aValue: double);
begin
  if fValues.ContainsKey(aKey) then
    fValues[aKey] := aValue
  else
    fValues.Add(aKey, aValue);
end;

procedure TJSONObject.Put(const aKey: string; aValue: boolean);
begin
  if fValues.ContainsKey(aKey) then
    fValues[aKey] := aValue
  else
    fValues.Add(aKey, aValue);
end;

procedure TJSONObject.Put(const aKey, aValue: string);
begin
  if fValues.ContainsKey(aKey) then
    fValues[aKey] := aValue
  else
    fValues.Add(aKey, aValue);
end;

procedure TJSONObject.Put(const aKey: string; aValue: int64);
begin
  if fValues.ContainsKey(aKey) then
    fValues[aKey] := aValue
  else
    fValues.Add(aKey, aValue);
end;

procedure TJSONObject.Put(const aKey: string; const aValue: IJSONArray);
begin
  if aValue = nil then
    raise JSONException.Create('Can''t add nil-object');
  if fValues.ContainsKey(aKey) then
    fValues[aKey] := TValue.From(aValue)
  else
    fValues.Add(aKey, TValue.From(aValue));
end;

procedure TJSONObject.Put(const aKey: string; const aValue: IJSONObject);
begin
  if aValue = nil then
    raise JSONException.Create('Can''t add nil-object');

  if fValues.ContainsKey(aKey) then
    fValues[aKey] := TValue.From(aValue)
  else
    fValues.Add(aKey, TValue.From(aValue));
end;

function TJSONObject.ToString(aReadable: boolean): string;
var
  Writer: IJSONWriter;
begin
  if aReadable then
    Writer := getReadableJSONWriter
  else
    Writer := getJSONWriter;
  result := Writer.writeObject(self);
end;

function TJSONObject.GetValue(const aKey: string): TValue;
begin
  result := fValues[aKey];
end;

function TJSONObject.HasKey(const aKey: string): boolean;
begin
  result := fValues.ContainsKey(aKey);
end;

function TJSONObject.isBoolean(const aKey: string): boolean;
var
  v: TValue;
begin
  v := GetValue(aKey);
  result := v.Kind = tkEnumeration;
end;

function TJSONObject.isDouble(const aKey: string): boolean;
var
  v: TValue;
begin
  v := GetValue(aKey);
  result := v.Kind = tkFloat;
end;

function TJSONObject.isInteger(const aKey: string): boolean;
var
  v: TValue;
begin
  v := GetValue(aKey);
  result := v.Kind in [tkInteger, tkInt64];
end;

function TJSONObject.isJSONArray(const aKey: string): boolean;
var
  v: TValue;
begin
  v := GetValue(aKey);
  if v.IsEmpty then
    result := false
  else if v.Kind = tkInterface then
    result := v.TypeInfo.Name = 'IJSONArray'
  else
    result := false;
end;

function TJSONObject.isJSONObject(const aKey: string): boolean;
var
  v: TValue;
begin
  v := GetValue(aKey);
  if v.IsEmpty then
    result := false
  else if v.Kind = tkInterface then
    result := v.TypeInfo.Name = 'IJSONObject'
  else
    result := false;
end;

function TJSONObject.isString(const aKey: string): boolean;
var
  v: TValue;
begin
  v := GetValue(aKey);
  result := v.Kind in [tkString, tkChar, tkWChar, tkLString, tkWString, tkUString];
end;

{ TJSONArray }

procedure TJSONArray.Clear;
begin
  fValues.Clear;
end;

function TJSONArray.GetCount: integer;
begin
  result := fValues.Count;
end;

constructor TJSONArray.Create;
begin
  inherited;
  fValues := TList<TValue>.Create;
end;

procedure TJSONArray.Delete(aIndex: integer);
begin
  fValues.Delete(aIndex);
end;

destructor TJSONArray.Destroy;
begin
  fValues.Free;
  inherited;
end;

function TJSONArray.GetBoolean(aIndex: integer): boolean;
begin
  result := fValues[aIndex].AsBoolean;
end;

function TJSONArray.GetDouble(aIndex: integer): double;
begin
  result := fValues[aIndex].AsExtended;
end;

function TJSONArray.GetInteger(aIndex: integer): int64;
begin
  result := fValues[aIndex].AsInt64;
end;

function TJSONArray.GetJSONArray(aIndex: integer): IJSONArray;
begin
  result := fValues[aIndex].AsType<IJSONArray>;
end;

function TJSONArray.GetJSONObject(aIndex: integer): IJSONObject;
begin
  result := fValues[aIndex].AsType<IJSONObject>;
end;

function TJSONArray.GetString(aIndex: integer): string;
begin
  result := fValues[aIndex].AsString;
end;

function TJSONArray.GetValue(aIndex: integer): TValue;
begin
  result := fValues[aIndex];
end;

function TJSONArray.isBoolean(aIndex: integer): boolean;
var
  v: TValue;
begin
  v := GetValue(aIndex);
  result := v.Kind = tkEnumeration;
end;

function TJSONArray.isDouble(aIndex: integer): boolean;
var
  v: TValue;
begin
  v := GetValue(aIndex);
  result := v.Kind = tkFloat;
end;

function TJSONArray.isInteger(aIndex: integer): boolean;
var
  v: TValue;
begin
  v := GetValue(aIndex);
  result := v.Kind in [tkInteger, tkInt64];
end;

function TJSONArray.isJSONArray(aIndex: integer): boolean;
var
  v: TValue;
begin
  v := GetValue(aIndex);
  if v.IsEmpty then
    result := false
  else if v.Kind = tkInterface then
    result := v.TypeInfo.Name = 'IJSONArray'
  else
    result := false;
end;

function TJSONArray.isJSONObject(aIndex: integer): boolean;
var
  v: TValue;
begin
  v := GetValue(aIndex);
  if v.IsEmpty then
    result := false
  else if v.Kind = tkInterface then
    result := v.TypeInfo.Name = 'IJSONObject'
  else
    result := false;
end;

function TJSONArray.isString(aIndex: integer): boolean;
var
  v: TValue;
begin
  v := GetValue(aIndex);
  result := v.Kind in [tkString, tkChar, tkWChar, tkLString, tkWString, tkUString];
end;

procedure TJSONArray.Put;
begin
  fValues.Add(TValue.Empty);
end;

procedure TJSONArray.Put(aValue: int64);
begin
  fValues.Add(aValue);
end;

procedure TJSONArray.Put(const aValue: string);
begin
  fValues.Add(aValue);
end;

procedure TJSONArray.Put(aValue: double);
begin
  fValues.Add(aValue);
end;

procedure TJSONArray.Put(const aValue: IJSONArray);
begin
  if aValue = nil then
    raise JSONException.Create('Can''t add nil-object');
  fValues.Add(TValue.From(aValue));
end;

procedure TJSONArray.Put(const aValue: IJSONObject);
begin
  if aValue = nil then
    raise JSONException.Create('Can''t add nil-object');
  fValues.Add(TValue.From(aValue));
end;

procedure TJSONArray.Put(aValue: boolean);
begin
  fValues.Add(aValue);
end;

function TJSONArray.ToString(aReadable: boolean): string;
var
  Writer: IJSONWriter;
begin
  if aReadable then
    Writer := getReadableJSONWriter
  else
    Writer := getJSONWriter;
  result := Writer.writeArray(self);
end;

procedure TJSONObject.Put(const aKey: string);
begin
  fValues.Add(aKey, TValue.Empty);
end;

end.
