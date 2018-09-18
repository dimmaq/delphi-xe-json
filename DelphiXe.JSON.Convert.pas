unit DelphiXe.JSON.Convert;

interface

uses
  Windows, DelphiXe.JSON;

type
  TJSONConvert = class
  public
    class function ToJSON(aRect : TRect) : IJSONObject; overload;
    class function ToRect(aObject : IJSONObject) : TRect;
    class function ToJSON(aPoint : TPoint) : IJSONObject; overload;
    class function ToPoint(aObject : IJSONObject) : TPoint;
  end;

implementation

{ TJSONConvert }

class function TJSONConvert.ToPoint(aObject: IJSONObject): TPoint;
begin
  result.X := aObject.GetInteger('X');
  result.Y := aObject.GetInteger('Y');
end;

class function TJSONConvert.ToRect(aObject: IJSONObject): TRect;
begin
  result.Left := aObject.GetInteger('Left');
  result.Top := aObject.GetInteger('Top');
  result.Width := aObject.GetInteger('Width');
  result.Height := aObject.GetInteger('Height');
end;

class function TJSONConvert.ToJSON(aPoint: TPoint): IJSONObject;
begin
  result := TJSON.NewObject;
  result.Put('X',aPoint.X);
  result.Put('Y',aPoint.Y);
end;

class function TJSONConvert.ToJSON(aRect: TRect): IJSONObject;
begin
  result := TJSON.NewObject;
  result.Put('Left',aRect.Left);
  result.Put('Top',aRect.Top);
  result.Put('Width',aRect.Width);
  result.Put('Height',aRect.Height);
end;

end.
