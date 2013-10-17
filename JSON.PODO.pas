unit JSON.PODO;

interface

uses
  JSON,
  CodeGeneratorUnit;

type
  TCodeGen = class
  private
    procedure AddPropertyToClass(aClass: TGeneratableClass; const aName, aType: string);
    procedure AddReadOnlyPropertyToClass(aClass: TGeneratableClass; const aName, aType: string);

    procedure AddLifecycleForField(const aName, aType: string; aConstructor, aDestructor: TGeneratableMethod);
    procedure AddLoadSaveForField(const aName, aType: string; aLoadMethod, aSaveMethod: TGeneratableMethod);

    procedure AddLoadFromFileMethod(aClass: TGeneratableClass);
    procedure AddSaveToFileMethod(aClass: TGeneratableClass);

    function JSONObjectToClasses(jo: IJSONObject; aClassName: string = 'TGeneratedClass'): TListOfGeneratableClass;
    function JSONArrayToClasses(ja: IJSONArray; aClassName: string = 'TGeneratedClass'): TListOfGeneratableClass;
  public
    function JSONToPODO(jo: IJSONObject): string;
  end;

implementation

uses
  TypInfo,
  Generics.Collections;

{ TCodeGen }

procedure TCodeGen.AddLifecycleForField(const aName, aType: string; aConstructor, aDestructor: TGeneratableMethod);
begin
  aConstructor.BodyText.Add('  f' + aName + ' := T' + aName + '.Create;');
  aDestructor.BodyText.Add('  f' + aName + '.Free;');
end;

procedure TCodeGen.AddLoadFromFileMethod(aClass: TGeneratableClass);
var
  m: TGeneratableMethod;
begin
  m := TGeneratableMethod.Create(aClass, 'LoadFromFile', vPublic);
  m.Parameters := 'aFilename : string';
  m.LocalVars.Add('s', 'string');
  m.LocalVars.Add('jo', 'IJSONObject');
  m.BodyText.Add('  s := TFile.ReadAllText(aFilename);');
  m.BodyText.Add('  jo := TJSON.NewObject(s);');
  m.BodyText.Add('  LoadFromJSON(jo);');
end;

procedure TCodeGen.AddLoadSaveForField(const aName, aType: string; aLoadMethod, aSaveMethod: TGeneratableMethod);
begin
  // TODO: Check aType in allowedTypes
  aLoadMethod.BodyText.Add('  f' + aName + ' := jo.Get' + aType + '(''' + aName + ''');');
  aSaveMethod.BodyText.Add('  jo.Put(''' + aName + ''', f' + aName + ');');
end;

procedure TCodeGen.AddPropertyToClass(aClass: TGeneratableClass; const aName, aType: string);
var
  prop: TGeneratableProperty;
begin
  TGeneratableField.Create(aClass, 'f' + aName, aType, vStrictPrivate);
  prop := TGeneratableProperty.Create(aClass, aName, aType, vPublic);
  prop.ReadMember := 'f' + aName;
  prop.WriteMember := 'f' + aName;
end;

procedure TCodeGen.AddReadOnlyPropertyToClass(aClass: TGeneratableClass; const aName, aType: string);
var
  prop: TGeneratableProperty;
begin
  TGeneratableField.Create(aClass, 'f' + aName, aType, vStrictPrivate);
  prop := TGeneratableProperty.Create(aClass, aName, aType, vPublic);
  prop.ReadMember := 'f' + aName;
end;

procedure TCodeGen.AddSaveToFileMethod(aClass: TGeneratableClass);
var
  m: TGeneratableMethod;
begin
  m := TGeneratableMethod.Create(aClass, 'SaveToFile', vPublic);
  m.Parameters := 'aFilename : string';
  m.LocalVars.Add('jo', 'IJSONObject');
  m.BodyText.Add('  jo := TJSON.NewObject;');
  m.BodyText.Add('  SaveToJSON(jo);');
  m.BodyText.Add('  TFile.WriteAllText(aFilename, jo.ToString);');
end;

function TCodeGen.JSONArrayToClasses(ja: IJSONArray; aClassName: string): TListOfGeneratableClass;
begin
  result := TListOfGeneratableClass.Create;
end;

function TCodeGen.JSONObjectToClasses(jo: IJSONObject; aClassName: string): TListOfGeneratableClass;
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
  AddLoadFromFileMethod(lClass);
  AddSaveToFileMethod(lClass);

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
        AddLifecycleForField(key, 'T' + key, lConstructor, lDestructor);
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

function TCodeGen.JSONToPODO(jo: IJSONObject): string;
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
