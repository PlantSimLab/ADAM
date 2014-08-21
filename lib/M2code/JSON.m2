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

export {
    "parseJSON", 
    "toJSON", 
    "prettyPrintJSON", 
    "toHashTable", 
    "fromHashTable", 
    "exampleJSON",
    "ErrorPacket", -- errors get passed around as packets
    "errorPacket" -- create an error packet
    }

ErrorPacket = new Type of HashTable

-- All errors are passed around as an "error packet".
-- An error packet is a hash table with one key, "error", whose value is a String.
-- All functions which take a "Model" will also take an error packet.  But, 
-- such functions will just pass on the error packet.
errorPacket = method()
errorPacket String := (str) -> new ErrorPacket from {"error" => str}


skipWS = method()
skipWS(String, ZZ) := (str, startLoc) -> (
    i := startLoc;
    while i < #str and match("[[:space:]]", str#i) do i=i+1;
    i
    )

errorObject = method()
errorObject String := errorPacket -- (s) -> new HashTable from {"error" => s}

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
    else if match("[-[:digit:]]", ch) 
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
    neg := false;
    if str#startLoc == "-" then (neg = true; startLoc = startLoc+1);
    if not match("[[:digit:]]", str#startLoc) then error "internal error: expected digit";
    i := startLoc; -- this points to the first char of the number
    while i < #str and match("[[:digit:]]", str#i) do i=i+1;
    num := value substring(str, startLoc, i-startLoc);
    (if neg then -num else num, noError, i)
    )

parseJSONArray = method()
parseJSONArray(String, ZZ) := (str, startLoc) -> (
    if str#startLoc =!= "[" then error "internal error: expected '['";
    i := startLoc + 1;
    result := {}; -- if we want brace type lists...
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
{*
  restart
  *}
  debug needsPackage "JSON"

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
  
  assert(parseJSONArray("[1,2,3]", 0) === ({1,2,3}, ,7))
  assert(parseJSONArray("[\"hi\",324,[1,2]]", 0) === ({"hi", 324, {1,2}}, ,16))
  
  assert(parseJSONWorker("[2,3]",0) == ({2,3},, 5))

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
    keysH := delete(symbol cache, keys H);
    K := sort keysH;
    L := for k in K list (
        k1 := if instance(k, Number) then toJSON toString k else toJSON k;
        k1 | ": " | toJSON (H#k)
        );
    L = between(",",L);
    "{" | concatenate L | "}"
    )

spaces = (n) -> concatenate(n:" ")

prettyPrintJSON = method()
prettyPrintJSON HashTable := 
prettyPrintJSON BasicList := 
prettyPrintJSON Symbol := 
prettyPrintJSON String := 
prettyPrintJSON Number := (H) -> ppJSON(H,0)

ppJSON = method()
ppJSON(Symbol, ZZ) := (a, nindent) -> ppJSON(toString a, nindent)
ppJSON(String, ZZ) := (s, nindent) -> "\"" | s | "\""
ppJSON(Number, ZZ) := (n, nindent) -> toString n
ppJSON(BasicList, ZZ) := (L, nindent) -> (
    if all(L, a -> instance(a, Number) or instance(a, String)) then (
        -- place this all on one line
        M := for a in L list ppJSON(a, nindent+2);
        Mstr := concatenate between(",",M);
        "[" | Mstr | "]"
        )
    else (
        M = for a in L list ((spaces (nindent+2)) | ppJSON(a, nindent+2));
        Mstr = concatenate between(",\n",M);
        "[\n" | Mstr | "\n" | (spaces nindent) | "]" 
        )
    )
ppJSON(HashTable, ZZ) := (H, nindent) -> (
    keysH := delete(symbol cache, keys H);
    K := sort keysH;
    L := for k in K list (
        k1 := if instance(k, Number) then ppJSON(toString k, 0) else ppJSON(k, 0);
        (spaces nindent) | k1 | ": " | ppJSON (H#k, nindent+2)
        );
    L = between(",\n",L);
    Lstr := concatenate L;
    "{\n" | Lstr | "\n" | (spaces nindent) | "}"
    )

TEST ///
{*
  restart
*}
  debug needsPackage "JSON"

  H = [3, 4, "hi there", 6]
  ppJSON(H, 4)
  H = toHashTable { "a" => "b" }

  str = exampleJSON#1;
  --str = get (currentDirectory()|"JSON/sampleModelPrettyPrint.json");
  H = parseJSON str
  str1 = prettyPrintJSON H
  H1 = parseJSON str1
  str2 = prettyPrintJSON H1
  assert(str1 == str2)
///

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
///,
///{
  "model": {
    "name": "Sample for testing",
    "description": "most basic file to get started with JSON between adam_largeNetworks.rb and M2 solver",
    "version": "1.0",
    "variables": [
      {
        "name": "variable1",
        "id": "x1",
        "states": [
          "0",
          "1"
        ]
      },
      {
        "name": "variable2",
        "id": "x2",
        "states": [
          "0",
          "1"
        ]
      },
      {
        "name": "variable3",
        "id": "x3",
        "states": [
          "0",
          "1"
        ]
      }
    ],
    "updateRules": {
      "x1": {
        "possibleInputVariables": [
          "x1",
          "x2"
        ],
        "polynomialFunction": "x1*x2"
      },
      "x2": {
        "possibleInputVariables": [
          "x1",
          "x2"
        ],
        "polynomialFunction": "x1+1"
      },
      "x3": {
        "possibleInputVariables": [
          "x1",
          "x2"
        ],
        "polynomialFunction": "x1+x2"
      }
    }
  }
}
///,
///{"nodes":[{"id":0,  "shortname":"CCC","fullname":"CCC_fullname","numstates":"4","color":"3","shape":"0","x":553,"y":316},{"id":1,"shortname":"BBB","fullname":"BBB_fullname","numstates":"3","color":"13","shape":"1","x":275,"y":318},{"id":2,"shortname": "AAA","fullname":"AAA_fullname","numstates":"2","color":"7","shape":"2","x":421,"y":95}],"edges":[{"edgeid":0,"edgename":"Activator","edgetype":1,"startnode":2,"endnode":1,"timescale":"normal"},{"edgeid":1,"edgename":"Inhibitor","edgetype":4,"startnode":0,"endnode":2,"timescale":"normal"},{"edgeid":2,"edgename":"","edgetype":1,"startnode":1,"endnode":0,"timescale":"normal"}],"nodeStates":[["low","low-med","med-high","high"],["low","med","high"],["low","high"]],"inEdgesOf":[[2],[0],[1]],"sourceNodesOf":[[1],[2],[0]],"options":{"stagePositionX":29,"stagePositionY":18},"eachTransitDiffArray":[{"0":[0,0,0,0],"1":[0,1,1,0],"2":[0,2,2,0],"3":[1,0,1,1],"4":[1,1,2,1],"5":[1,2,2,1],"maxrow":6},{"0":[0,0,0,0],"1":[0,1,1,0],"2":[1,0,0,-1],"3":[1,1,0,-1],"4":[2,0,0,-2],"5":[2,1,0,-2],"6":[3,0,0,-3],"7":[3,1,0,-3],"maxrow":8},{"0":[0,0,0,0],"1":[0,1,1,0],"2":[0,2,2,0],"3":[0,3,3,0],"4":[1,0,1,1],"5":[1,1,2,1],"6":[1,2,3,1],"7":[1,3,3,1],"8":[2,0,2,2],"9":[2,1,3,2],"10":[2,2,3,2],"11":[2,3,3,2],"maxrow":12}],"experiments":[]}///
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
  parseJSON
  toJSON
  prettyPrintJSON
  fromHashTable  
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
  H3 === H1 -- ok now: we transfer JSON arrays with brackets, to M2 arrays with braces
///

end

restart
debug needsPackage "JSON"
instance(parseJSON "3", ZZ)
parseJSON "[4,3,3]"  == {4,3,3} -- do we want it to go to a list?
parseJSON toJSON {4,3,3} == {4,3,3}

{a => {b => c, c => d, e => f}}
H = toHashTable oo
toJSON H
Ha = parseJSON oo
Ha === H
L1 = {"a" => {"b" => "c", "c" => "d", "e" => ["f", 3, 4]}}
L2 = toHashTable L1
str = toJSON L2
toHashTable parseJSON str
L2 === oo

H = parseJSON exampleJSON#0
toJSON oo

restart
needsPackage "Parsing"
f = charAnalyzer ///{ "a" : "bcd" }///
f()
P = NNParser : charAnalyzer
P "  12345  78"

