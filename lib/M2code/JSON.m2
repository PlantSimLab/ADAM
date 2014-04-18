newPackage(
    "JSON",
    Version => "0.1", 
    Date => "",
    Authors => {{Name => "", 
            Email => "", 
            HomePage => ""}},
    Headline => "",
    DebuggingMode => true
    )

-- 3 data types here:
-- (a) a list of options, array, basic elements e.g. strings, numbers
-- (b) Macaulay2 object, which includes hash tables, lists, and basic elements
-- (c) JSON format

export {parseJSON, toJSON, fromJSON, toHashTable, fromHashTable, exampleJSON}

skipWS = method()
skipWS(String, ZZ) := (str, startLoc) -> (
    i := startLoc;
    while i < #str and match("[[:space:]]", str#i) do i=i+1;
    i
    )

parseJSON = method()
-- takes a string, starting location, returns: JSON object, end location of parsed string
parseJSON(String, ZZ) := (jsonString, startLoc) -> (
    -- return (JSON, endLoc)
    loc := skipWS(jsonString, startLoc); -- loc will be the first location >= startLoc with jsonString#loc not whitespace.
    if loc == #jsonString then return null; -- look at the json spec.  Is this allowed?
    ch := jsonString#loc;
    if ch === "{" 
      then parseJSONObject(jsonString, loc)
    else if ch === "[" 
      then parseJSONArray(jsonString, loc)
    else if ch === "\""  -- " to fix syntax coloring!
      then parseJSONString(jsonString, loc)
    else if match("[[:digit:]]", ch) 
      then parseJSONNumber(jsonString, loc)
    else error("parse error in json formatted string, at location " | loc)
    )

parseJSONString = method()
parseJSONString(String, ZZ) := (str, startLoc) -> (
    if str#startLoc =!= "\"" -- "
      then error "internal error: expected first character to be a quote.";
    i := startLoc+1; -- this points to the char right after the quote
    while i < #str and not match(///"///, str#i) do -- " 
        i=i+1;
    if i == #str then error ("mismatched quotes in string, no matching end quote for quote at location "|startLoc);
    (substring(str, startLoc+1, i-startLoc-1), i+1)
    )

parseJSONNumber = method()
parseJSONNumber(String, ZZ) := (str, startLoc) -> (
    if not match("[[:digit:]]", str#startLoc) then error "internal error: expected digit";
    i := startLoc; -- this points to the first char of the number
    while i < #str and match("[[:digit:]]", str#i) do i=i+1;
    (value substring(str, startLoc, i-startLoc), i)
    )

parseJSONArray = method()
parseJSONArray(String, ZZ) := (str, startLoc) -> (
    if str#startLoc =!= "[" then error "internal error: expected '['";
    i := startLoc + 1;
    result := [];
    i = skipWS(str, i);
    if str#i === "]" then return (result, i+1);
    obj := null;
    while i < #str do (
        (obj, i) = parseJSON(str,i);
        result = append(result, obj);
        i = skipWS(str,i);
        if str#i === "," then 
            i = i+1
        else if str#i === "]" then
            return(result, i+1)
        else error ("unexpected character "|str#i|" in array detected at location "|i);
        );
    error("expected terminating ']' for array starting at location "|startLoc);
    )

parseJSONObject = method()
parseJSONObject(String, ZZ) := (str, startLoc) -> (
    )

TEST ///
  restart
  debug loadPackage "JSON"

  assert(skipWS(" hi there",0) == 1)
  assert(skipWS(" hi there",1) == 1)
  assert(skipWS(" hi \n there",3) == 6)

  assert(parseJSONString("\"hi\"", 0) == ("hi", 4))
  assert(parseJSONString("\"hi\"blah blah", 0) == ("hi", 4))
  assert try (parseJSONString("\"hi", 1); false) else true
  assert try (parseJSONString("hi", 0); false) else true

  parseJSONNumber("42", 0)
  parseJSONNumber("43+53", 0)
  parseJSONNumber("hi: 41", 4) 
  
  assert(parseJSONArray("[1,2,3]", 0) === ([1,2,3], 7))
  assert(parseJSONArray(///["hi",324,[1,2]]///, 0) === (["hi", 324, [1,2]], 16))
///
    

fromJSON = method()
fromJSON String := (fileContents) -> (
    fileContents = replace(":", " => ", fileContents);
    fileContents = replace("\\{", " hashTable { ", fileContents);
    value fileContents)
--fromJSON String := (fileContents) -> (
--    fileContents = replace(":", " => ", fileContents);
--    value fileContents)

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
    fromJSON
Headline
    translate a string containing JSON format to a Macaulay2 object
Usage
    H = fromJSON str
Inputs
    str:String
      The input containing the JSON data
Outputs
    H:
      The resulting value.  This is either a string, number, list or hash table.
      If an error occurs, then what should we do?
Description
  Text
  Example
Caveat
    Currently, the JSON is not checked strongly.
SeeAlso
    toJSON
///

TEST ///
-- test code and assertions here
-- may have as many TEST sections as needed
  H = fromJSON exampleJSON#0
  J = toJSON H  
  H1 = fromJSON J
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
