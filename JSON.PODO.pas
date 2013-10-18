unit JSON.PODO;

interface

uses
  JSON;

type
  IPODOGenerator = interface
    function JSONObjectToPODO(jo: IJSONObject): string; overload;
    function JSONArrayToPODO(ja: IJSONArray): string; overload;
  end;

function getPODOGenerator: IPODOGenerator;

implementation

uses
  TypInfo,
  Generics.Collections,
  CodeGeneratorUnit;

type
  TJSONType = (jsonObject, jsonArray);

  TPODOGenerator = class(TInterfacedObject, IPODOGenerator)
  private
    procedure AddPropertyToClass(aClass: TGeneratableClass; const aName, aType: string);
    procedure AddReadOnlyPropertyToClass(aClass: TGeneratableClass; const aName, aType: string);

    procedure AddLifecycleForField(const aName, aType: string; aConstructor, aDestructor: TGeneratableMethod);
    procedure AddLoadSaveForField(const aName, aType: string; aLoadMethod, aSaveMethod: TGeneratableMethod);

    procedure AddLoadFromFileMethod(aClass: TGeneratableClass; aType: TJSONType);
    procedure AddSaveToFileMethod(aClass: TGeneratableClass; aType: TJSONType);

    function JSONObjectToClasses(jo: IJSONObject; aClassName: string = 'TGeneratedClass'): TListOfGeneratableClass;
    function JSONArrayToClasses(ja: IJSONArray; const aClassName: string = 'TGeneratedClass'): TListOfGeneratableClass;
  public
    function JSONObjectToPODO(jo: IJSONObject): string; overload;
    function JSONArrayToPODO(ja: IJSONArray): string; overload;
  end;

function getPODOGenerator: IPODOGenerator;
begin
  result := TPODOGenerator.Create;
end;

{ TCodeGen }

procedure TPODOGenerator.AddLifecycleForField(const aName, aType: string; aConstructor, aDestructor: TGeneratableMethod);
begin
  aConstructor.BodyText.Add('  f' + aName + ' := ' + aType + '.Create;');
  aDestructor.BodyText.Add('  f' + aName + '.Free;');
end;

procedure TPODOGenerator.AddLoadFromFileMethod(aClass: TGeneratableClass; aType: TJSONType);
var
  m: TGeneratableMethod;
begin
  m := TGeneratableMethod.Create(aClass, 'LoadFromFile', vPublic);
  m.Parameters := 'aFilename : string';
  m.LocalVars.Add('s', 'string');
  case aType of
    jsonObject: m.LocalVars.Add('json', 'IJSONObject');
    jsonArray: m.LocalVars.Add('json', 'IJSONArray');
  end;
  m.BodyText.Add('  s := TFile.ReadAllText(aFilename);');
  case aType of
    jsonObject: m.BodyText.Add('  json := TJSON.NewObject(s);');
    jsonArray: m.BodyText.Add('  json := TJSON.NewArray(s);');
  end;
  m.BodyText.Add('  LoadFromJSON(json);');
end;

procedure TPODOGenerator.AddLoadSaveForField(const aName, aType: string; aLoadMethod, aSaveMethod: TGeneratableMethod);
begin
  // TODO: Check aType in allowedTypes
  aLoadMethod.BodyText.Add('  f' + aName + ' := jo.Get' + aType + '(''' + aName + ''');');
  aSaveMethod.BodyText.Add('  jo.Put(''' + aName + ''', f' + aName + ');');
end;

procedure TPODOGenerator.AddPropertyToClass(aClass: TGeneratableClass; const aName, aType: string);
var
  prop: TGeneratableProperty;
begin
  TGeneratableField.Create(aClass, 'f' + aName, aType, vStrictPrivate);
  prop := TGeneratableProperty.Create(aClass, aName, aType, vPublic);
  prop.ReadMember := 'f' + aName;
  prop.WriteMember := 'f' + aName;
end;

procedure TPODOGenerator.AddReadOnlyPropertyToClass(aClass: TGeneratableClass; const aName, aType: string);
var
  prop: TGeneratableProperty;
begin
  TGeneratableField.Create(aClass, 'f' + aName, aType, vStrictPrivate);
  prop := TGeneratableProperty.Create(aClass, aName, aType, vPublic);
  prop.ReadMember := 'f' + aName;
end;

procedure TPODOGenerator.AddSaveToFileMethod(aClass: TGeneratableClass; aType: TJSONType);
var
  m: TGeneratableMethod;
begin
  m := TGeneratableMethod.Create(aClass, 'SaveToFile', vPublic);
  m.Parameters := 'aFilename : string';
  case aType of
    jsonObject:
      begin
        m.LocalVars.Add('json', 'IJSONObject');
        m.BodyText.Add('  json := TJSON.NewObject;');
      end;
    jsonArray:
      begin
        m.LocalVars.Add('json', 'IJSONArray');
        m.BodyText.Add('  json := TJSON.NewArray;');
      end;
  end;
  m.BodyText.Add('  SaveToJSON(json);');
  m.BodyText.Add('  TFile.WriteAllText(aFilename, json.ToString);');
end;

function TPODOGenerator.JSONArrayToClasses(ja: IJSONArray; const aClassName: string): TListOfGeneratableClass;
var
  lClasses: TListOfGeneratableClass;
  lClass: TGeneratableClass;
  lLoadMethod, lSaveMethod: TGeneratableMethod;
  lLoadJSONMethod, lSaveJSONMethod: TGeneratableMethod;
begin
  result := TListOfGeneratableClass.Create;
  lClass := nil;
  if ja.Count > 0 then
  begin
    if ja.isString(0) then lClass := TGeneratableClass.Create(nil, aClassName, 'TList<string>', true)
    else if ja.isInteger(0) then lClass := TGeneratableClass.Create(nil, aClassName, 'TList<integer>', true)
    else if ja.isBoolean(0) then lClass := TGeneratableClass.Create(nil, aClassName, 'TList<boolean>', true)
    else if ja.isDouble(0) then lClass := TGeneratableClass.Create(nil, aClassName, 'TList<double>', true)
    else if ja.isJSONObject(0) then
    begin
      lClass := TGeneratableClass.Create(nil, aClassName, 'TList<' + aClassName + 'Item>', true);
      lClasses := JSONObjectToClasses(ja.GetJSONObject(0), aClassName + 'Item');
      result.AddRange(lClasses);
      lClasses.Free;
    end
    else if ja.isJSONArray(0) then
    begin
      lClass := TGeneratableClass.Create(nil, aClassName, 'TList<' + aClassName + 'Item>', true);
      lClasses := JSONArrayToClasses(ja.GetJSONArray(0), aClassName + 'Item');
      result.AddRange(lClasses);
      lClasses.Free;
    end;
  end;

  if assigned(lClass) then
  begin
    lClass.InterfaceUnits.Add('Generics.Collections');
    lClass.InterfaceUnits.Add('JSON');
    lClass.ImplementationUnits.Add('IOUtils');

    AddLoadFromFileMethod(lClass, jsonArray);
    AddSaveToFileMethod(lClass, jsonArray);

    lLoadJSONMethod := TGeneratableMethod.Create(lClass, 'LoadFromJSON', vPublic);
    lLoadJSONMethod.Parameters := 'ja : IJSONArray';
    lLoadJSONMethod.LocalVars.Add('i', 'integer');
    lLoadJSONMethod.BodyText.Add('  for i := 0 to ja.Count - 1 do');
    lLoadJSONMethod.BodyText.Add('  begin');

    lSaveJSONMethod := TGeneratableMethod.Create(lClass, 'SaveToJSON', vPublic);
    lSaveJSONMethod.Parameters := 'ja : IJSONArray';
    lSaveJSONMethod.LocalVars.Add('i', 'integer');
    lSaveJSONMethod.BodyText.Add('  for i := 0 to ja.Count - 1 do');
    lSaveJSONMethod.BodyText.Add('  begin');

    if ja.isString(0) then
    begin
      lLoadJSONMethod.BodyText.Add('    Items[i] := ja.GetString(i);');
      lSaveJSONMethod.BodyText.Add('    ja.put(Items[i]);');
    end
    else if ja.isInteger(0) then
    begin
      lLoadJSONMethod.BodyText.Add('    Items[i] := ja.GetInteger(i);');
      lSaveJSONMethod.BodyText.Add('    ja.put(Items[i]);');
    end
    else if ja.isBoolean(0) then
    begin
      lLoadJSONMethod.BodyText.Add('    Items[i] := ja.GetBoolean(i);');
      lSaveJSONMethod.BodyText.Add('    ja.put(Items[i]);');
    end
    else if ja.isDouble(0) then
    begin
      lLoadJSONMethod.BodyText.Add('    Items[i] := ja.GetDouble(i);');
      lSaveJSONMethod.BodyText.Add('    ja.put(Items[i]);');
    end
    else if ja.isJSONObject(0) then
    begin
      lLoadJSONMethod.LocalVars.AddOrSetValue('item', aClassName + 'Item');
      lLoadJSONMethod.BodyText.Add('    item := ' + aClassName + 'Item.Create;');
      lLoadJSONMethod.BodyText.Add('    item.LoadFromJSON(ja.GetJSONObject(i));');
      lLoadJSONMethod.BodyText.Add('    Add(item);');
      lSaveMethod.LocalVars.AddOrSetValue('joItem', 'IJSONObject');
      lSaveJSONMethod.BodyText.Add('    joItem := TJSON.NewObject;');
      lSaveJSONMethod.BodyText.Add('    item.SaveToJSON(joItem);');
      lSaveJSONMethod.BodyText.Add('    ja.Put(joItem);');
    end
    else if ja.isJSONArray(0) then
    begin
      lLoadJSONMethod.LocalVars.AddOrSetValue('item', aClassName + 'Item');
      lLoadJSONMethod.BodyText.Add('    item := ' + aClassName + 'Item.Create;');
      lLoadJSONMethod.BodyText.Add('    item.LoadFromJSON(ja.GetJSONObject(i));');
      lLoadJSONMethod.BodyText.Add('    Add(item);');
      lSaveMethod.LocalVars.AddOrSetValue('jaItem', 'IJSONArray');
      lSaveJSONMethod.BodyText.Add('    jaItem := TJSON.NewArray;');
      lSaveJSONMethod.BodyText.Add('    item.SaveToJSON(jaItem);');
      lSaveJSONMethod.BodyText.Add('    ja.Put(jaItem);');
    end;

    lLoadJSONMethod.BodyText.Add('  end;');
    lSaveJSONMethod.BodyText.Add('  end;');

    result.Add(lClass);
  end;
end;

function TPODOGenerator.JSONObjectToClasses(jo: IJSONObject; aClassName: string): TListOfGeneratableClass;
var
  ja: IJSONArray;
  key: string;
  lClasses: TListOfGeneratableClass;
  lClass: TGeneratableClass;
  lLoadJSONMethod, lSaveJSONMethod: TGeneratableMethod;
  lConstructor, lDestructor: TGeneratableMethod;
begin
  result := TListOfGeneratableClass.Create;
  lClass := TGeneratableClass.Create(nil, aClassName, 'TObject', true);

  lClass.InterfaceUnits.Add('Generics.Collections');
  lClass.InterfaceUnits.Add('JSON');
  lClass.ImplementationUnits.Add('IOUtils');
  AddLoadFromFileMethod(lClass, jsonObject);
  AddSaveToFileMethod(lClass, jsonObject);

  lConstructor := TGeneratableMethod.Create(lClass, 'Create', vPublic);
  lConstructor.MethodKind := mkConstructor;
  lDestructor := TGeneratableMethod.Create(lClass, 'Destroy', vPublic, bkOverride);
  lDestructor.MethodKind := mkDestructor;

  lLoadJSONMethod := TGeneratableMethod.Create(lClass, 'LoadFromJSON', vPublic);
  lLoadJSONMethod.Parameters := 'jo : IJSONObject';
  lSaveJSONMethod := TGeneratableMethod.Create(lClass, 'SaveToJSON', vPublic);
  lSaveJSONMethod.Parameters := 'jo : IJSONObject';

  for key in jo.GetKeys do
  begin
    if jo.isString(key) then
    begin
      AddPropertyToClass(lClass, key, 'string');
      AddLoadSaveForField(key, 'String', lLoadJSONMethod, lSaveJSONMethod);
    end
    else if jo.isInteger(key) then
    begin
      AddPropertyToClass(lClass, key, 'integer');
      AddLoadSaveForField(key, 'Integer', lLoadJSONMethod, lSaveJSONMethod);
    end
    else if jo.isBoolean(key) then
    begin
      AddPropertyToClass(lClass, key, 'boolean');
      AddLoadSaveForField(key, 'Boolean', lLoadJSONMethod, lSaveJSONMethod);
    end
    else if jo.isDouble(key) then
    begin
      AddPropertyToClass(lClass, key, 'double');
      AddLoadSaveForField(key, 'Double', lLoadJSONMethod, lSaveJSONMethod);
    end
    else if jo.isJSONObject(key) then
    begin
      AddLifecycleForField(key, 'T' + key, lConstructor, lDestructor);
      AddReadOnlyPropertyToClass(lClass, key, 'T' + key);

      lLoadJSONMethod.BodyText.Add('  f' + key + '.LoadFromJSON(jo.GetJSONObject(''' + key + '''));');

      lSaveJSONMethod.LocalVars.AddOrSetValue('jo' + key, 'IJSONObject');
      lSaveJSONMethod.BodyText.Add('  jo' + key + ' := TJSON.NewObject;');
      lSaveJSONMethod.BodyText.Add('  f' + key + '.SaveToJSON(jo' + key + ')');
      lSaveJSONMethod.BodyText.Add('  jo.Put(''' + key + ''', jo' + key + ');');

      lClasses := JSONObjectToClasses(jo.GetJSONObject(key), 'T' + key);
      result.AddRange(lClasses);
      lClasses.Free;
    end
    else if jo.isJSONArray(key) then
    begin
      ja := jo.GetJSONArray(key);
      if ja.Count > 0 then
      begin
        AddLifecycleForField(key, 'T' + key + 'List', lConstructor, lDestructor);
        AddReadOnlyPropertyToClass(lClass, key, 'T' + key + 'List');

        lLoadJSONMethod.BodyText.Add('  f' + key + '.LoadFromJSON(jo.GetJSONArray(''' + key + '''));');

        lSaveJSONMethod.LocalVars.AddOrSetValue('ja' + key, 'IJSONArray');
        lSaveJSONMethod.BodyText.Add('  ja' + key + ' := TJSON.NewArray;');
        lSaveJSONMethod.BodyText.Add('  f' + key + '.SaveToJSON(ja' + key + ')');
        lSaveJSONMethod.BodyText.Add('  jo.Put(''' + key + ''', ja' + key + ');');

        lClasses := JSONArrayToClasses(ja, 'T' + key + 'List');
        result.AddRange(lClasses);
        lClasses.Free;
      end;
    end;
  end;

  lDestructor.BodyText.Add('  inherited;');
  result.Add(lClass);
end;

function TPODOGenerator.JSONArrayToPODO(ja: IJSONArray): string;
var
  lUnit: TGeneratableUnit;
  lClasses: TListOfGeneratableClass;
begin
  lUnit := TGeneratableUnit.Create(nil, 'GeneratedUnit');
  lClasses := JSONArrayToClasses(ja);
  lUnit.Classes.AddRange(lClasses);
  lClasses.Free;
  result := lUnit.ToString;
  lUnit.Free;
end;

function TPODOGenerator.JSONObjectToPODO(jo: IJSONObject): string;
var
  lUnit: TGeneratableUnit;
  lClasses: TListOfGeneratableClass;
begin
  lUnit := TGeneratableUnit.Create(nil, 'GeneratedUnit');
  lClasses := JSONObjectToClasses(jo);
  lUnit.Classes.AddRange(lClasses);
  lClasses.Free;
  result := lUnit.ToString;
  lUnit.Free;
end;

end.
