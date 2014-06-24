newPackage(
        "ADAMModel",
        Version => "0.1", 
        Date => "",
        Authors => {{Name => "", 
                  Email => "", 
                  HomePage => ""}},
        Headline => "ADAM Model management",
        PackageExports => {"solvebyGB"},
        DebuggingMode => true
        )

export {"Model", "polynomials", "findLimitCycles"}

Model = new Type of HashTable
vars Model := (M) -> (
    -- returns a list of strings
    M#"variables"/(x -> x#"id")//toList
    )
char Model := (M) -> (
    M#"variables"/(x -> #x#"states")//max
    )
ring Model := (M) -> (
    varnames := vars M;
    p := char M;
    R1 := ZZ/p[varnames];
    I1 := ideal for x in gens R1 list x^p-x;
    R1/I1
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

TEST ///
{*
  restart
*}
  needsPackage "ADAMModel"
  needsPackage "JSON"

  str = get "~/Sites/ADAM/sampleJSON/sampleModel.json"
  M = parseJSON str
  M = new Model from M#"model"
  findLimitCycles(M,{1,2,3})

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
