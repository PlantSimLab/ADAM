newPackage(
    "ADAMModel",
    Version => "0.1", 
    Date => "",
    Authors => {{Name => "Franziska Hinkelmann", 
            Email => "", 
            HomePage => ""},
        {Name => "Mike Stillman", 
            Email => "", 
            HomePage => ""}
        },
    Headline => "ADAM Model management",
    PackageExports => {"solvebyGB", "JSON"},
    DebuggingMode => true
    )

export {"Model", "polynomials", "findLimitCycles", "parseModel", "checkModel"}

Model = new Type of HashTable
vars Model := (M) -> (
    -- returns a list of strings
    M#"variables"/(x -> x#"id")//toList
    )
char Model := (M) -> (
     p := M#"variables"/(x -> #x#"states")//max;
     while not isPrime p do p = p+1;
     p
    )
ring Model := (M) -> (
    varnames := vars M;
    p := char M;
    R1 := ZZ/p[varnames];
    I1 := ideal for x in gens R1 list x^p-x;
    R1/I1
    )

checkModel = method()
checkModel Model := (M) -> (
    result := M#?"variables";
    if not result then return false;
    vars := M#"variables";
    for f in vars do (
        if not f#?"id" or not instance(f#"id", String) then return false;
        if not f#?"states" or not instance(f#"states", List) then return false;
        );
    if not M#?"updateRules" then return false;
    -- also to check:
    ---- updateRules has one key for each variable.
    ---- that updateRule#xi should be a hash table, with "possibleInputVariables" as key
    ----   which should be a list of some id's of the variables
    ----   and should have either: polynomialFunction, transitionTable, or ...
    result
    )

parseModel = method()
parseModel String := (str) -> (
    M := parseJSON str;
    if not M#?"model" then error "error: string is not the JSON for a Model";
    model := new Model from M#"model";
    if not checkModel model then error "error: string has incorrect format for a Model";
    model
    )

polynomials = method()
polynomials(Model,Ring) := (M, R) -> (
    varnames := vars M;
    for x in varnames list value M#"updateRules"#x#"polynomialFunction"
    )

polynomials(Model) := (M) -> (
    R := ring M;
    varnames := vars M;
    matrix(R, {for x in varnames list value M#"updateRules"#x#"polynomialFunction"})
    )

toArray = method()
toArray List := (L) -> new Array from (L/toArray)
toArray Thing := (L) -> L

findLimitCycles = method()
findLimitCycles(Model, ZZ) := (M, limitCycleLength) -> findLimitCycles(M, {limitCycleLength})
findLimitCycles(Model, List) := (M, limitCycleLengths) -> (
    PDS := polynomials M;
    H := for len in limitCycleLengths list (
        limitcycles := gbSolver(PDS, len);
        len => toArray limitcycles
        );
    hashTable H
    )

{*
--L = {"x3", "x1"}
--p = 2
--vals = {0,1,0,1}
interpolate = method()
interpolate (List, ZZ, List) := (L, p, vals) -> (
  params := select( vals, l -> ( class value toString l ) === Symbol );
  R := ZZ/p[params / value][L / value ];
  --R := ZZ/p[L];
  n := #L;
  QR := R / ideal apply( gens R, x -> x^p-x) ;
  vals = apply(vals, l -> value toString l );
  X := set (0..p-1);
  inputs := sort toList X^**n;
  --print toString L;
  --print toString vals;
  --print toString inputs;

  pol := sum ( inputs, vals, (source, t) -> t* product( source, gens QR, (i, xi) -> 1 - (xi-i)^(p-1) ) );
  print toString pol
)
*}

TEST ///
{*
  restart
*}
  needsPackage "ADAMModel"
  needsPackage "JSON"

  str = exampleJSON#0

  M = parseJSON str
  M = new Model from M#"model"
  
  M = parseModel str
  result = findLimitCycles(M,{1,2,3})
  ans = new HashTable from {1 => [[[0,1,1]]], 2 => [], 3 => []}
  assert(result === ans)
///

   sample2 = ///{"model": {
         "name": "Sample2 for testing",
         "description": "",
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
             },
             {
                 "name": "variable4",
                 "id": "x4",
                 "states": ["0", "1"]
             },
             {
                 "name": "variable5",
                 "id": "x5",
                 "states": ["0", "1"]
             }
         ],
         "updateRules": {
             "x1": { 
                 "possibleInputVariables": ["x2","x3", "x5", "x1"],
                 "transitionTables": [[0, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0], [0, 1, 1, 0], 
                 [1, 0, 0, 1], [1, 0, 1, 1], [1, 1, 0, 0], [1, 1, 1, 0]]
             },
             "x2": { 
                 "possibleInputVariables": ["x1","x2"],
                 "polynomialFunction": "x1+1"
             },
             "x3": { 
                 "possibleInputVariables": ["x1","x2"],
                 "polynomialFunction": "x1+x2"
             },
             "x4": { 
                 "possibleInputVariables": ["x1","x4"],
                 "polynomialFunction": "x1+x4"
             },
             "x5": { 
                 "possibleInputVariables": ["x2","x5"],
                 "polynomialFunction": "x2+x2*x5+x5"
             }
         }
     }}
    ///
   
TEST ///
  debug needsPackage "ADAMModel"
  model = parseModel sample2
///
end

beginDocumentation()

doc ///
Key
  Model
Headline
Description
  Text
  Example
Caveat
SeeAlso
///

doc ///
Key
Headline
Usage
Inputs
Outputs
Consequences
Description
  Text
  Example
  Code
  Pre
Caveat
SeeAlso
///

TEST ///
-- test code and assertions here
-- may have as many TEST sections as needed
///
