newPackage(
    "JSON",
    Version => "0.1", 
    Date => "",
    Authors => {{Name => "Franziska Hinkelmann", 
            Email => "", 
            HomePage => ""},
        {Name => "Mike Stillman", 
            Email => "", 
            HomePage => ""}
        },
    Headline => "",
    DebuggingMode => true
    )

-- 3 data types here:
-- (a) a list of options, array, basic elements e.g. strings, numbers
-- (b) Macaulay2 object, which includes hash tables, lists, and basic elements
-- (c) JSON format

export {parseJSON, toJSON, toHashTable, fromHashTable, exampleJSON}

skipWS = method()
skipWS(String, ZZ) := (str, startLoc) -> (
    i := startLoc;
    while i < #str and match("[[:space:]]", str#i) do i=i+1;
    i
    )

errorObject = method()
errorObject String := (s) -> new HashTable from {"error" => s}

noError = null

parseJSON = method()
parseJSONWorker = method()

parseJSON String := (str) -> (
    (returnObject, returnErrorObject, loc) := parseJSONWorker(str, 0);
    if returnErrorObject === null then 
        returnObject
    else
        returnErrorObject
    )

-- takes a string, starting location
-- returns a triple:
--   (object, errorObject, endLoc)
-- where either:
--   (a) errorObject == null and object is a valid object
-- or
--   (b) errorObject is a hashtable with the one key "error", whose value is a string,
--       (and object is undefined))
-- Note: object == null is a valid output.
-- All of the parseJSON* routines have this same return code
parseJSONWorker(String, ZZ) := (jsonString, startLoc) -> (
    -- return (JSON, endLoc)
    loc := skipWS(jsonString, startLoc); -- loc will be the first location >= startLoc with jsonString#loc not whitespace.
    if loc == #jsonString then 
        return (null, errorObject"no object found", loc); -- look at the json spec.  Is this allowed?
    ch := jsonString#loc;
    if ch === "{" 
      then parseJSONObject(jsonString, loc)
    else if ch === "[" 
      then parseJSONArray(jsonString, loc)
    else if ch === "\""  -- " to fix syntax coloring!
      then parseJSONString(jsonString, loc)
    else if match("[[:digit:]]", ch) 
      then parseJSONNumber(jsonString, loc)
--    else if match("[tfn]", ch) -- true, false, null
--      then parseJSONName(jsonString, loc)
    else (null, errorObject("unexpected character at location " | loc), loc)
    )

parseJSONString = method()
parseJSONString(String, ZZ) := (str, startLoc) -> (
    if str#startLoc =!= "\"" -- "
      then error "internal error: expected first character to be a quote.";
    i := startLoc+1; -- this points to the char right after the quote
    while i < #str and not match(///"///, str#i) do -- " 
        i=i+1;
    if i == #str then 
        (null, errorObject("mismatched quotes in string, no matching end quote for quote at location "|startLoc), i)
    else
        (substring(str, startLoc+1, i-startLoc-1), noError, i+1)
    )

parseJSONNumber = method()
parseJSONNumber(String, ZZ) := (str, startLoc) -> (
    if not match("[[:digit:]]", str#startLoc) then error "internal error: expected digit";
    i := startLoc; -- this points to the first char of the number
    while i < #str and match("[[:digit:]]", str#i) do i=i+1;
    (value substring(str, startLoc, i-startLoc), noError, i)
    )

parseJSONArray = method()
parseJSONArray(String, ZZ) := (str, startLoc) -> (
    if str#startLoc =!= "[" then error "internal error: expected '['";
    i := startLoc + 1;
    result := [];
    i = skipWS(str, i);
    if str#i === "]" then return (result, noError, i+1);
    obj := null;
    err := null;
    while i < #str do (
        (obj, err, i) = parseJSONWorker(str,i);
        if err =!= null then return(null, err, i);
        result = append(result, obj);
        i = skipWS(str,i);
        if str#i === "," then 
            i = i+1
        else if str#i === "]" then
            return(result, null, i+1)
        else return(null, errorObject ("unexpected character "|str#i|" in array detected at location "|i), i);
        );
    (null, errorObject("expected terminating ']' for array starting at location "|startLoc), i);
    )

parseJSONObject = method()
parseJSONObject(String, ZZ) := (str, startLoc) -> (
    if str#startLoc =!= "{" then error "internal error: expected '{'";
    i := startLoc + 1;
    result := {};
    i = skipWS(str, i);
    if str#i === "}" then return (new HashTable from result, noError, i+1);
    keyString := null;
    obj := null;
    err := null;
    while i < #str do (
        i = skipWS(str,i);
        if i == #str then break;
        -- first get the key, which must be a string.
        -- then check for ":"
        -- then read the object
        -- finally: expect a "," or "}", as for arrays.
        (keyString, err, i) = parseJSONString(str, i);
        if err =!= null then return (null, err, i);
        i = skipWS(str,i);
        if i === #str or str#i =!= ":" then 
            return (null, 
                    errorObject ("parse error in JSON: expected a ':' at location "
                                 |i|" in string"),
                    i);
        i = skipWS(str,i+1);
        if i == #str then break;
        (obj, err, i) = parseJSONWorker(str,i);
        if err =!= null then return (null, err, i);
        result = append(result, keyString => obj);
        i = skipWS(str,i);
        if i == #str then break;
        if str#i === "," then 
            i = i+1
        else if str#i === "}" then
            return(new HashTable from result, noError, i+1)
        else return (null, errorObject ("unexpected character "|str#i|" in json detected at location "|i), i);
        );
    (null, errorObject("expected terminating '}' for json object starting at location "|startLoc), i)
    )

{*
  parseJSON ///{"a":"b"}///
  parseJSON ///{"a":   "b"}///
  parseJSON ///{"a":   "b",    "c3d4"  :  [2,3,4] }///
  parseJSON ///{"a":"b","c3d4":[2,3,4]}///
  parseJSON ///{"a" :"b","c3d4":[2,3,4]}///
  parseJSON ///{"a": "b","c3d4":[2,3,4]}///
  parseJSON ///{"a":"b" ,"c3d4":[2,3,4]}///
  parseJSON ///{"a":
          "b", "c3d4":[2,3 ,4]}///

  -- some errors:
  str = ///{"a":"b" ,"c3d4":[2,3,4}///
  parseJSON str

  str = ///{"a":"b" ,"c3d4":[2,3,4]     a}///
  parseJSON str

  str = ///{"a":"b" ,"c3d4":[2,3,4]     ///
  parseJSON str
*}

TEST ///
  restart
  debug loadPackage "JSON"

  assert(skipWS(" hi there",0) == 1)
  assert(skipWS(" hi there",1) == 1)
  assert(skipWS(" hi \n there",3) == 6)

  assert(parseJSONString("\"hi\"", 0) == ("hi", null, 4))
  assert(parseJSONString("\"hi\"blah blah", 0) == ("hi", null, 4))
  assert try (parseJSONString("\"hi", 1); false) else true -- "
  assert try (parseJSONString("hi", 0); false) else true

  parseJSONNumber("42", 0)
  parseJSONNumber("43+53", 0)
  parseJSONNumber("hi: 41", 4) 
  
  assert(parseJSONArray("[1,2,3]", 0) === ([1,2,3], ,7))
  assert(parseJSONArray("[\"hi\",324,[1,2]]", 0) === (["hi", 324, [1,2]], ,16))
  
  assert(parseJSONWorker("[2,3]",0) == ([2,3],, 5))

///

toJSON = method()
toJSON Symbol := (a) -> toJSON toString a
toJSON String := (s) -> "\"" | s | "\""
toJSON Number := (n) -> toString n
toJSON BasicList := (L) -> (
    M := for a in L list toJSON a;
    "[" | concatenate between(",",M) | "]"
    )
toJSON HashTable := (H) -> (
    K := sort keys H;
    L := for k in K list (
        k1 := if instance(k, Number) then toJSON toString k else toJSON k;
        k1 | ": " | toJSON (H#k)
        );
    L = between(",",L);
    "{" | concatenate L | "}"
    )

spaces = (n) -> concatenate(n:" ")

{*
prettyPrintJSON = method()
ppJSON = method()
ppJSON(Symbol, ZZ) := (a, nspaces) -> ppJSON(toString a, nspaces)
ppJSON(String, ZZ) := (s, nspaces) -> (spaces nspaces) | "\"" | s | "\""
ppJSON(Number, ZZ) := (n, nspaces) -> (spaces nspaces) | toString n
ppJSON(BasicList, ZZ) := (L, nspaces) -> (
    M := for a in L list ppJSON(a, 0);
    (spaces nspaces) | "[" | concatenate between(",",M) | "]"
    )
prettyPrintJSON HashTable := (H) -> (
    K := sort keys H;
    L := for k in K list (
        k1 := if instance(k, Number) then prettyPrintJSON toString k else toJSON k;
        k1 | ": " | prettyPrintJSON (H#k)
        );
    L = between(",",L);
    "{" | concatenate L | "}"
    )
*}

toHashTable = method()
toHashTable Thing := (s) -> s
toHashTable Option := (a) -> (toHashTable a#0) => (toHashTable a#1)
toHashTable List := (L) -> (
    -- L should be a list of pairs, to be made into a hashtable
    H := L/toHashTable;
    new HashTable from H
    )
toHashTable Array := (A) -> (toList A)/toHashTable

fromHashTable = method()
fromHashTable Thing := (a) -> a
fromHashTable HashTable := (H) -> (
    K := sort keys H;
    L := for k in K list (
        k1 := fromHashTable k;
        k2 := fromHashTable H#k;
        k1 => k2
        )
    )
fromHashTable BasicList := (L) -> (
    M := for a in L list fromHashTable a;
    new Array from M
    )

exampleJSON = {///
{"model": {
    "name": "Sample for testing",
    "description": "most basic file to get started with JSON between adam_largeNetworks.rb and M2 solver",
    "version": "1.0",
    "variables": [
        {
            "name": "variable1",
            "id": "x1",
            "states": ["0", "1"]
        },
        {
            "name": "variable2",
            "id": "x2",
            "states": ["0", "1"]
        },
        {
            "name": "variable3",
            "id": "x3",
            "states": ["0", "1"]
        }
    ],
    "updateRules": {
        "x1": { 
            "possibleInputVariables": ["x1","x2"],
            "polynomialFunction": "x1*x2"
        },
        "x2": { 
            "possibleInputVariables": ["x1","x2"],
            "polynomialFunction": "x1+1"
        },
        "x3": { 
            "possibleInputVariables": ["x1","x2"],
            "polynomialFunction": "x1+x2"
        }
    }
}}
///
}
beginDocumentation()

doc ///
Key
  JSON
Headline
  translation of JSON (Javascript object notation)
Description
Caveat
SeeAlso
///

doc ///
Key
    parseJSON
Headline
    translate a string containing JSON format to a Macaulay2 object
Usage
    H = parseJSON str
Inputs
    str:String
      The input containing the JSON data
Outputs
    H:
      The resulting value.  This is either a string, number, list or hash table.
      If an error occurs, then the result is a hash table of the form
      { "error" => error-string }
Description
  Text
  Example
Caveat
    Currently, the JSON does not handle all forms of integers or string escape characters.
    Also it does not handle values true, false, null.
SeeAlso
    toJSON
///

TEST ///
-- test code and assertions here
-- may have as many TEST sections as needed
  H = parseJSON exampleJSON#0
  J = toJSON H  
  H1 = parseJSON J
  assert(H === H1)
  L1 = fromHashTable H
  H3 = toHashTable L1
  H3 === H1 -- false
///

end

restart
loadPackage "JSON"
instance(fromJSON "3", ZZ)
fromJSON "[4,3,3]"  == [4,3,3] -- do we want it to go to a list?
fromJSON toJSON {4,3,3} == {4,3,3}

{a => {b => c, c => d, e => f}}
H = toHashTable oo
toJSON H
fromJSON oo

L1 = {"a" => {"b" => "c", "c" => "d", "e" => ["f", 3, 4]}}
L2 = toHashTable L1
str = toJSON L2
toHashTable fromJSON str
L2 === oo

H = fromJSON exampleJSON#0
toJSON oo
