unit JSON.PODO;

interface

uses
  JSON,
  CodeGeneratorUnit;

type
  TCodeGen = class
  private
    function getArrayType(ja: IJSONArray; aClassName: string = 'TGeneratedClass'): string;
    function JSONObjectToClasses(jo: IJSONObject; aClassName: string = 'TGeneratedClass'): TListOfGeneratableClass;
  public
    function JSONToPODO(jo: IJSONObject): string;
  end;

implementation

uses
  TypInfo;

{ TCodeGen }

function TCodeGen.getArrayType(ja: IJSONArray; aClassName: string = 'TGeneratedClass'): string;
begin
  if ja.Count > 0 then
  begin
    if ja.isString(0) then
      result := 'TList<string>'
    else if ja.isInteger(0) then
      result := 'TList<integer>'
    else if ja.isBoolean(0) then
      result := 'TList<boolean>'
    else if ja.isDouble(0) then
      result := 'TList<double>'
    else if ja.isJSONArray(0) then
      result := 'TObjectList<' + getArrayType(ja.GetJSONArray(0)) + '>'
    else if ja.isJSONObject(0) then
      result := 'TObjectList<' + aClassName + '>'
    else
      result := '';
  end
  else
    result := '';
end;

function TCodeGen.JSONObjectToClasses(jo: IJSONObject; aClassName: string): TListOfGeneratableClass;
var
  key: string;
  lClasses: TListOfGeneratableClass;
  lClass: TGeneratableClass;
  lProperty: TGeneratableProperty;

  lLoadMethod, lSaveMethod: TGeneratableMethod;
  lLoadJSONMethod, lSaveJSONMethod: TGeneratableMethod;
  lConstructor, lDestructor: TGeneratableMethod;
begin
  result := TListOfGeneratableClass.Create;
  lClass := TGeneratableClass.Create(nil, aClassName, 'TObject', true);

  lClass.InterfaceUnits.Add('Generics.Collections');
  lClass.InterfaceUnits.Add('JSON');
  lClass.ImplementationUnits.Add('IOUtils');

  lConstructor := TGeneratableMethod.Create(lClass, 'Create', vPublic);
  lConstructor.MethodKind := mkConstructor;
  lDestructor := TGeneratableMethod.Create(lClass, 'Destroy', vPublic, bkOverride);
  lDestructor.MethodKind := mkDestructor;

  lLoadMethod := TGeneratableMethod.Create(lClass, 'LoadFromFile', vPublic);
  lLoadMethod.Parameters := 'aFilename : string';
  lLoadMethod.LocalVars.Add('s', 'string');
  lLoadMethod.LocalVars.Add('jo', 'IJSONObject');
  lLoadMethod.BodyText.Add('  s := TFile.ReadAllText(aFilename);');
  lLoadMethod.BodyText.Add('  jo := TJSON.NewObject(s);');
  lLoadMethod.BodyText.Add('  LoadFromJSON(jo);');

  lSaveMethod := TGeneratableMethod.Create(lClass, 'SaveToFile', vPublic);
  lSaveMethod.Parameters := 'aFilename : string';
  lSaveMethod.LocalVars.Add('jo', 'IJSONObject');
  lSaveMethod.BodyText.Add('  jo := TJSON.NewObject;');
  lSaveMethod.BodyText.Add('  SaveToJSON(jo);');
  lSaveMethod.BodyText.Add('  TFile.WriteAllText(aFilename, jo.ToString);');

  lLoadJSONMethod := TGeneratableMethod.Create(lClass, 'LoadFromJSON', vPublic);
  lLoadJSONMethod.Parameters := 'jo : IJSONObject';
  lSaveJSONMethod := TGeneratableMethod.Create(lClass, 'SaveToJSON', vPublic);
  lSaveJSONMethod.Parameters := 'jo : IJSONObject';

  for key in jo.GetKeys do
  begin
    if jo.isString(key) then
    begin
      TGeneratableField.Create(lClass, 'f' + key, 'string', vStrictPrivate);
      lProperty := TGeneratableProperty.Create(lClass, key, 'string', vPublic);
      lProperty.ReadMember := 'f' + key;
      lProperty.WriteMember := 'f' + key;
      lLoadJSONMethod.BodyText.Add('  f' + key + ' := jo.GetString(''' + key + ''');');
      lSaveJSONMethod.BodyText.Add('  jo.Put(''' + key + ''', f' + key + ');');
    end
    else if jo.isInteger(key) then
    begin
      TGeneratableField.Create(lClass, 'f' + key, 'integer', vStrictPrivate);
      lProperty := TGeneratableProperty.Create(lClass, key, 'integer', vPublic);
      lProperty.ReadMember := 'f' + key;
      lProperty.WriteMember := 'f' + key;
      lLoadJSONMethod.BodyText.Add('  f' + key + ' := jo.GetInteger(''' + key + ''');');
      lSaveJSONMethod.BodyText.Add('  jo.Put(''' + key + ''', f' + key + ');');
    end
    else if jo.isBoolean(key) then
    begin
      TGeneratableField.Create(lClass, 'f' + key, 'boolean', vStrictPrivate);
      lProperty := TGeneratableProperty.Create(lClass, key, 'boolean', vPublic);
      lProperty.ReadMember := 'f' + key;
      lProperty.WriteMember := 'f' + key;
      lLoadJSONMethod.BodyText.Add('  f' + key + ' := jo.GetBoolean(''' + key + ''');');
      lSaveJSONMethod.BodyText.Add('  jo.Put(''' + key + ''', f' + key + ');');
    end
    else if jo.isDouble(key) then
    begin
      TGeneratableField.Create(lClass, 'f' + key, 'double', vStrictPrivate);
      lProperty := TGeneratableProperty.Create(lClass, key, 'double', vPublic);
      lProperty.ReadMember := 'f' + key;
      lProperty.WriteMember := 'f' + key;
      lLoadJSONMethod.BodyText.Add('  f' + key + ' := jo.GetDouble(''' + key + ''');');
      lSaveJSONMethod.BodyText.Add('  jo.Put(''' + key + ''', f' + key + ');');
    end
    else if jo.isJSONObject(key) then
    begin
      lConstructor.BodyText.Add('  f' + key + ' := T' + key + '.Create;');
      lDestructor.BodyText.Add('  f' + key + '.Free;');
      lClasses := JSONObjectToClasses(jo.GetJSONObject(key), 'T' + key);
      result.AddRange(lClasses.ToArray);
      lClasses.Free;
      TGeneratableField.Create(lClass, 'f' + key, 'T' + key, vStrictPrivate);
      lProperty := TGeneratableProperty.Create(lClass, key, 'T' + key, vPublic);
      lProperty.ReadMember := 'f' + key;
      lProperty.WriteMember := 'f' + key;
      lLoadJSONMethod.BodyText.Add('  f' + key + '.LoadFromJSON(jo.GetJSONObject(''' + key + '''));');
      lSaveJSONMethod.BodyText.Add('  jo.Put(''' + key + ''', f' + key + ');');
    end
    else if jo.isJSONArray(key) then
    begin
      lConstructor.BodyText.Add('  f' + key + ' := ' + getArrayType(jo.GetJSONArray(key), 'T' + key) + '.Create;');
      lDestructor.BodyText.Add('  f' + key + '.Free;');
      TGeneratableField.Create(lClass, 'f' + key, getArrayType(jo.GetJSONArray(key), 'T' + key), vStrictPrivate);
      lProperty := TGeneratableProperty.Create(lClass, key, getArrayType(jo.GetJSONArray(key), 'T' + key), vPublic);
      lProperty.ReadMember := 'f' + key;


      lLoadJSONMethod.LocalVars.AddOrSetValue('i','integer');
      lLoadJSONMethod.LocalVars.AddOrSetValue('ja','IJSONArray');
      lLoadJSONMethod.BodyText.Add('  ja := jo.GetJSONArray(''' + key + ''')');

      lLoadJSONMethod.BodyText.Add('  for i := 0 to ja.Count - 1 do');
      lLoadJSONMethod.BodyText.Add('    f'+key+'.Add(ja.Get)'); // TODO: Code is depending on type

      lSaveJSONMethod.LocalVars.AddOrSetValue('i','integer');
      lSaveJSONMethod.LocalVars.AddOrSetValue('ja','IJSONArray');
      lSaveJSONMethod.BodyText.Add('  ja := TJSON.NewArray;');
      lSaveJSONMethod.BodyText.Add('  for i := 0 to f'+key+'.Count -1 do');
      lSaveJSONMethod.BodyText.Add('    ja.Put(f' + key + '[i]);'); // TODO: Code is depending on type
      {
        simple type:
          ja.put('fKey',fkey[i]);
        object type:
        begin
          joKey := TJSON.NewObject;
          fkey[i].SaveToJSON(joKey);
          ja.put(joKey);
        end;
        array type:
        begin
          jaKey := TJSON.NewArray;
          ???
        end;
      }
      lSaveJSONMethod.BodyText.Add('  jo.Put(''' + key + ''', ja);');
    end;
  end;

  lDestructor.BodyText.Add('  inherited;');
  result.Add(lClass);
end;

function TCodeGen.JSONToPODO(jo: IJSONObject): string;
var
  lUnit: TGeneratableUnit;
  lClasses: TListOfGeneratableClass;
begin
  lUnit := TGeneratableUnit.Create(nil, 'GeneratedUnit');
  lClasses := JSONObjectToClasses(jo);
  lUnit.Classes.AddRange(lClasses.ToArray);
  lClasses.Free;
  result := lUnit.ToString;
  lUnit.Free;
end;

end.
