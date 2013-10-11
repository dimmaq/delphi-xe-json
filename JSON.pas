unit JSON;

interface

uses
  System.Rtti, System.SysUtils;

type
  IJSONArray = interface;
  IJSONObject = interface;

  IJSONObject = interface
  ['{D00A665F-3CBB-4DDB-8300-FB8020DA564B}']
    /// <summary>Converts the stored key-value-pairs to their string representation</summary>
    ///  <param name="aReadable">if set to true, the result will contain whitespace, so it can be read easily by humans</param>
    ///  <returns>the string representation of the IJSONObject</returns>
    function ToString(aReadable : boolean = false) : string;
    /// <summary>
    ///   returns true if the item is an IJSONObject
    ///   returns false if not or if the key is not set
    /// </summary>
    ///  <param name="aKey">the key of the item</param>
    function isJSONObject(const aKey : string) : boolean;
    /// <summary>
    ///   returns true if the item is an IJSONArray
    ///   returns false if not or if the key is not set
    /// </summary>
    ///  <param name="aKey">the key of the item</param>
    function isJSONArray(const aKey : string) : boolean;
    /// <summary>
    ///   returns true if the item is a string
    ///   returns false if not or if the key is not set
    ///  <param name="aKey">the key of the item</param>
    /// </summary>
    function isString(const aKey : string) : boolean;
    /// <summary>
    ///   returns true if the item is an integer
    ///   returns false if not or if the key is not set
    /// </summary>
    ///  <param name="aKey">the key of the item</param>
    function isInteger(const aKey : string) : boolean;
    /// <summary>
    ///   returns true if the item is a boolean
    ///   returns false if not or if the key is not set
    /// </summary>
    ///  <param name="aKey">the key of the item</param>
    function isBoolean(const aKey : string) : boolean;
    /// <summary>
    ///   returns true if the item is a double
    ///   returns false if not or if the key is not set
    /// </summary>
    ///  <param name="aKey">the key of the item</param>
    function isDouble(const aKey : string) : boolean;
    /// <summary>
    ///  Stores the Value <paramref name="aValue"/> for the Key <paramref name="aKey"/>.
    ///  Overwrites the Value for the specified Key, if it is already set
    /// </summary>
    /// <param name="aKey">The Key</param>
    /// <param name="aValue">The Value</param>
    procedure Put(const aKey: string; const aValue: string); overload;
    /// <summary>
    ///  Stores the Value <paramref name="aValue"/> for the Key <paramref name="aKey"/>.
    ///  Overwrites the Value for the specified Key, if it is already set
    /// </summary>
    /// <param name="aKey">The Key</param>
    /// <param name="aValue">The Value</param>
    procedure Put(const aKey: string; aValue: integer); overload;
    /// <summary>
    ///  Stores the Value <paramref name="aValue"/> for the Key <paramref name="aKey"/>.
    ///  Overwrites the Value for the specified Key, if it is already set
    /// </summary>
    /// <param name="aKey">The Key</param>
    /// <param name="aValue">The Value</param>
    procedure Put(const aKey: string; aValue: double); overload;
    /// <summary>
    ///  Stores the Value <paramref name="aValue"/> for the Key <paramref name="aKey"/>.
    ///  Overwrites the Value for the specified Key, if it is already set
    /// </summary>
    /// <param name="aKey">The Key</param>
    /// <param name="aValue">The Value</param>
    procedure Put(const aKey: string; aValue: boolean); overload;
    /// <summary>
    ///  Stores the Value <paramref name="aValue"/> for the Key <paramref name="aKey"/>.
    ///  Overwrites the Value for the specified Key, if it is already set
    /// </summary>
    /// <param name="aKey">The Key</param>
    /// <param name="aValue">The Value</param>
    ///  <exception cref="JSONException">raises a JSONExcpetion if <paramref name="aValue"/> is nil</exception>
    procedure Put(const aKey: string; const aValue: IJSONObject); overload;
    /// <summary>
    ///  Stores the Value <paramref name="aValue"/> for the Key <paramref name="aKey"/>.
    ///  Overwrites the Value for the specified Key, if it is already set
    /// </summary>
    /// <param name="aKey">The Key</param>
    /// <param name="aValue">The Value</param>
    ///  <exception cref="JSONException">raised when <paramref name="aValue"/> is nil</exception>
    procedure Put(const aKey: string; const aValue: IJSONArray); overload;
    /// <summary>
    ///  Stores null for the Key <paramref name="aKey"/>.
    ///  Overwrites the Value for the specified Key, if it is already set
    /// </summary>
    /// <param name="aKey">The Key</param>
    procedure Put(const aKey: string); overload;
    /// <summary>
    ///   Gets the IJSONObject stored for <paramref name="aKey"/>
    /// </summary>
    ///  <param name="aKey">The Key</param>
    ///  <returns>the IJSONObject stored for <paramref name="aKey"/></returns>
    ///  <exception cref="EListError">raised when <paramref name="aKey"/> is not found</exception>
    ///  <exception cref="EInvalidCast">raised when the stored item can''t be casted to IJSONObject</exception>
    function GetJSONObject(const aKey: string): IJSONObject; overload;
    /// <summary>
    ///   Gets the IJSONArray stored for <paramref name="aKey"/>
    /// </summary>
    ///  <param name="aKey">The Key</param>
    ///  <returns>the IJSONArray stored for <paramref name="aKey"/></returns>
    ///  <exception cref="EListError">raised when <paramref name="aKey"/> is not found</exception>
    ///  <exception cref="EInvalidCast">raised when the stored item can''t be casted to IJSONArray</exception>
    function GetJSONArray(const aKey: string): IJSONArray; overload;
    /// <summary>
    ///   Gets the string stored for <paramref name="aKey"/>
    /// </summary>
    ///  <param name="aKey">The Key</param>
    ///  <returns>the string stored for <paramref name="aKey"/></returns>
    ///  <exception cref="EListError">raised when <paramref name="aKey"/> is not found</exception>
    ///  <exception cref="EInvalidCast">raised when the stored item can''t be casted to string</exception>
    function GetString(const aKey: string): string; overload;
    /// <summary>
    ///   Gets the integer stored for <paramref name="aKey"/>
    /// </summary>
    ///  <param name="aKey">The Key</param>
    ///  <returns>the integer stored for <paramref name="aKey"/></returns>
    ///  <exception cref="EListError">raised when <paramref name="aKey"/> is not found</exception>
    ///  <exception cref="EInvalidCast">raised when the stored item can''t be casted to integer</exception>
    function GetInteger(const aKey: string): integer; overload;
    /// <summary>
    ///   Gets the boolean stored for <paramref name="aKey"/>
    /// </summary>
    ///  <param name="aKey">The Key</param>
    ///  <returns>the boolean stored for <paramref name="aKey"/></returns>
    ///  <exception cref="EListError">raised when <paramref name="aKey"/> is not found</exception>
    ///  <exception cref="EInvalidCast">raised when the stored item can''t be casted to boolean</exception>
    function GetBoolean(const aKey: string): boolean; overload;
    /// <summary>
    ///   Gets the double stored for <paramref name="aKey"/>
    /// </summary>
    ///  <param name="aKey">The Key</param>
    ///  <returns>the double stored for <paramref name="aKey"/></returns>
    ///  <exception cref="EListError">raised when <paramref name="aKey"/> is not found</exception>
    ///  <exception cref="EInvalidCast">raised when the stored item can''t be casted to double</exception>
    function GetDouble(const aKey: string): double; overload;
    /// <summary>
    ///   Gets the IJSONObject stored for <paramref name="aKey"/> or <paramref name="aDefault"/> if the key is not found
    /// </summary>
    ///  <param name="aKey">The Key</param>
    ///  <param name="aDefault">The default return value</param>
    ///  <returns>the IJSONObject stored for <paramref name="aKey"/></returns>
    ///  <exception cref="EListError">raised when <paramref name="aKey"/> is not found</exception>
    ///  <exception cref="EInvalidCast">raised when the stored item can''t be casted to IJSONObject</exception>
    function GetJSONObject(const aKey: string; const aDefault : IJSONObject): IJSONObject; overload;
    /// <summary>
    ///   Gets the IJSONArray stored for <paramref name="aKey"/> or <paramref name="aDefault"/> if the key is not found
    /// </summary>
    ///  <param name="aKey">The Key</param>
    ///  <param name="aDefault">The default return value</param>
    ///  <returns>the IJSONArray stored for <paramref name="aKey"/></returns>
    ///  <exception cref="EListError">raised when <paramref name="aKey"/> is not found</exception>
    ///  <exception cref="EInvalidCast">raised when the stored item can''t be casted to IJSONArray</exception>
    function GetJSONArray(const aKey: string; const aDefault : IJSONArray): IJSONArray; overload;
    /// <summary>
    ///   Gets the string stored for <paramref name="aKey"/> or <paramref name="aDefault"/> if the key is not found
    /// </summary>
    ///  <param name="aKey">The Key</param>
    ///  <param name="aDefault">The default return value</param>
    ///  <returns>the string stored for <paramref name="aKey"/></returns>
    ///  <exception cref="EListError">raised when <paramref name="aKey"/> is not found</exception>
    ///  <exception cref="EInvalidCast">raised when the stored item can''t be casted to string</exception>
    function GetString(const aKey: string; const aDefault : string): string; overload;
    /// <summary>
    ///   Gets the integer stored for <paramref name="aKey"/> or <paramref name="aDefault"/> if the key is not found
    /// </summary>
    ///  <param name="aKey">The Key</param>
    ///  <param name="aDefault">The default return value</param>
    ///  <returns>the integer stored for <paramref name="aKey"/></returns>
    ///  <exception cref="EListError">raised when <paramref name="aKey"/> is not found</exception>
    ///  <exception cref="EInvalidCast">raised when the stored item can''t be casted to integer</exception>
    function GetInteger(const aKey: string; aDefault : integer): integer; overload;
    /// <summary>
    ///   Gets the boolean stored for <paramref name="aKey"/> or <paramref name="aDefault"/> if the key is not found
    /// </summary>
    ///  <param name="aKey">The Key</param>
    ///  <param name="aDefault">The default return value</param>
    ///  <returns>the boolean stored for <paramref name="aKey"/></returns>
    ///  <exception cref="EListError">raised when <paramref name="aKey"/> is not found</exception>
    ///  <exception cref="EInvalidCast">raised when the stored item can''t be casted to boolean</exception>
    function GetBoolean(const aKey: string; aDefault : boolean): boolean; overload;
    /// <summary>
    ///   Gets the double stored for <paramref name="aKey"/> or <paramref name="aDefault"/> if the key is not found
    /// </summary>
    ///  <param name="aKey">The Key</param>
    ///  <param name="aDefault">The default return value</param>
    ///  <returns>the double stored for <paramref name="aKey"/></returns>
    ///  <exception cref="EListError">raised when <paramref name="aKey"/> is not found</exception>
    ///  <exception cref="EInvalidCast">raised when the stored item can''t be casted to double</exception>
    function GetDouble(const aKey: string; aDefault : double): double; overload;
    /// <summary>
    ///   Gets all keys, that are stored in this IJSONObject
    /// </summary>
    ///  <returns>a TArray&lt;string&gt; containing all keys</returns>
    function GetKeys : TArray<string>;
    /// <summary>
    ///   Gets the value for <paramref name="aKey"/>
    /// </summary>
    ///  <param name="aKey">The Key</param>
    ///  <returns>the raw TValue that is used to store the data</returns>
    ///  <exception cref="EListError">raised when <paramref name="aKey"/> is not found</exception>
    function GetValue (const aKey : string) : TValue;
    /// <summary>
    ///   returns true if <paramref name="aKey"/> is found in the IJSONObject, otherwise returns false
    /// </summary>
    ///  <param name="aKey">The Key</param>
    function HasKey(const aKey : string) : boolean;
    function GetCount : integer;
    /// <summary>
    ///   Gets the count of Key-Value-Pairs in this IJSONObject
    /// </summary>
    property Count : integer read getCount;
    /// <summary>
    ///   Removes all Key-Value-Pairs from this IJSONObject
    /// </summary>
    procedure Clear;
    /// <summary>
    ///   Removes the Key-Value-Pair for <paramref name="aKey"/> from this IJSONObject
    /// </summary>
    ///  <param name="aKey">The Key</param>
    procedure DeleteKey(const aKey : string);
  end;

  IJSONArray = interface
  ['{B120D59A-1D00-469E-97CE-AE2A635A51ED}']
    function ToString(aReadable : boolean = false) : string;
    function isJSONObject(aIndex : integer) : boolean;
    function isJSONArray(aIndex : integer) : boolean;
    function isString(aIndex : integer) : boolean;
    function isInteger(aIndex : integer) : boolean;
    function isBoolean(aIndex : integer) : boolean;
    function isDouble(aIndex : integer) : boolean;
    procedure Put(const aValue: string); overload;
    procedure Put(aValue: integer); overload;
    procedure Put(aValue: double); overload;
    procedure Put(aValue: boolean); overload;
    procedure Put(const aValue: IJSONObject); overload;
    procedure Put(const aValue: IJSONArray); overload;
    procedure Put; overload;
    function GetJSONObject(aIndex : integer): IJSONObject;
    function GetJSONArray(aIndex : integer): IJSONArray;
    function GetString(aIndex : integer): String;
    function GetInteger(aIndex : integer): integer;
    function GetBoolean(aIndex : integer): boolean;
    function GetDouble(aIndex : integer): double;
    function GetValue(aIndex : integer) : TValue;
    function GetCount : integer;
    property Count : integer read getCount;
    procedure Clear;
    procedure Delete(aIndex : integer);
  end;

  /// <summary>
  ///   This class summarizes the methods to create and parse IJSONObjects and IJSONArrays
  /// </summary>
  TJSON = class
  private
  public
    /// <summary>
    ///   Parses <paramref name="aText"/> into a new IJSONObject. If <paramref name="aText"/> is empty, an empty IJSONObject is returned.
    /// </summary>
    ///  <param name="aText">the Text that will be parsed</param>
    ///  <exception cref="JSONException">raised when invalid text is parsed</exception>
    class function NewObject(const aText : string = '') : IJSONObject;
    /// <summary>
    ///   Parses <paramref name="aText"/> into a new IJSONArray. If <paramref name="aText"/> is empty, an empty IJSONArray is returned.
    /// </summary>
    ///  <param name="aText">the Text that will be parsed</param>
    ///  <exception cref="JSONException">raised when invalid text is parsed</exception>
    class function NewArray(const aText : string = '') : IJSONArray;
  end;

  JSONException = class (Exception);
  
implementation

uses
  JSON.Reader;

{ TJSON }

class function TJSON.NewArray(const aText: string): IJSONArray;
var
  reader : IJSONReader;
begin
  reader := getJSONReader;
  result := reader.readArray(aText);
end;

class function TJSON.NewObject(const aText: string): IJSONObject;
var
  reader : IJSONReader;
begin
  reader := getJSONReader;
  result := reader.readObject(aText);
end;

end.
