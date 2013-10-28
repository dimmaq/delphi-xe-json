unit JSON.IOHelper;

interface

type
  TJSONIOHelper = class
    class function RemoveWhiteSpace(const aInput : string) : string;
    class function getSpaces(aQuantity : integer) : string;
  end;

implementation

uses
  SysUtils;

{ TJSONIO }

class function TJSONIOHelper.getSpaces(aQuantity: integer): string;
begin
  result := '';
  while aQuantity > 0 do
  begin
    result := result + ' ';
    dec(aQuantity);
  end;
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

end.
