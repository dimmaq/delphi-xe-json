unit DelphiXe.JSON.IOHelper;

interface

type
  TJSONIOHelper = class
    class function RemoveWhiteSpace(const aInput : string) : string;
    class function getSpaces(aQuantity : integer) : string;
  end;

implementation

uses
  SysUtils, System.Math;

const
  PRE_SPACE_STR_COUNT = 16;

var
  SpaceStringList: array[0..PRE_SPACE_STR_COUNT] of string;

{ TJSONIO }

class function TJSONIOHelper.getSpaces(aQuantity: integer): string;
begin
  if InRange(aQuantity, 0, PRE_SPACE_STR_COUNT) then
    Exit(SpaceStringList[aQuantity]);

  Result := StringOfChar(' ', aQuantity)
end;

class function TJSONIOHelper.RemoveWhiteSpace(const aInput: string): string;
const
  whitespace = [#0, #8, #9, #10, #12, #13, ' '];
var
  i: integer;
  insideString: boolean;
begin
  i := 1;
  insideString := false;
  while i <= length(aInput) do
  begin
    if aInput[i] = '\' then
    begin
      result := result + aInput[i] + aInput[i + 1];
      inc(i, 2);
    end
    else if aInput[i] = '"' then
    begin
      result := result + aInput[i];
      insideString := not insideString;
      inc(i);
    end
    else if not insideString and CharInSet(aInput[i], whitespace) then
      inc(i)
    else
    begin
      result := result + aInput[i];
      inc(i);
    end;
  end;
end;

procedure FillSpaceStringList;
var j: Integer;
begin
  for j := 0 to PRE_SPACE_STR_COUNT do
    SpaceStringList[j] := StringOfChar(' ', j);
end;

initialization
  FillSpaceStringList();

end.
