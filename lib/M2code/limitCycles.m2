#!/usr/bin/env M2 --script

path = prepend(currentDirectory()|"lib/M2code", path)

if #scriptCommandLine != 3 then (
    stderr << "limitCycles.m2 <json model file> <size of limit cycles to be found>" << endl;
    stderr << "  json model file: a model file including polynomials" << endl;
    stderr << "  size of limit cycles: an integer, >= 1" << endl;
    stderr << "  output: a file containing limit cycle or limit point information" << endl;
    exit(1);
    )

fileName = scriptCommandLine#1
limitCycleLength = value scriptCommandLine#2
if not instance(limitCycleLength, ZZ) or limitCycleLength <= 0 then (
    stderr << "expected the limit cycle length to be a positive integer" << endl;
    exit(2);
    )

if not fileExists fileName then (
    stderr << "internal error: cannot find input file: " << fileName << endl;
    exit(2);
    )

-----------------------------------
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

toJSON = method()
toJSON String := (s) -> "\"" | s | "\""
toJSON Number := (n) -> toString n
toJSON List := (L) -> (
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

limitCyclesToJSON = (limitCycles) -> (
    C := limitCycles/(c -> new HashTable from {"steadyState" => c});
    C1 := new HashTable from {"components" => C};
    C2 := new HashTable from {"output" => C1};
    toJSON C2
    )
--------------------------------

needsPackage "solvebyGB"

--file = "sampleModel.json"
--limitCycleLength = 1
fileContents = get fileName

fileContents = replace(":", " => ", fileContents)
fileContents = replace("\\{", " hashTable { ", fileContents)
M = value fileContents
M = new Model from M#"model"

R = ring M
PDS = matrix {polynomials(M,R)}
resultLimitCycles = gbSolver(PDS, limitCycleLength)
print limitCyclesToJSON resultLimitCycles

end

stdio << (length resultLimitCycles) | "?" | toString resultLimitCycles << endl;

-- output format is the following (as a string)
egcycles = {{{0, 0, 0}}, {{0, 0, 1}}, {{1, 0, 0}}, {{1, 0, 1}}}
limitCyclesToJSON egcycles
toJSON oo
resultLimitCycles = egcycles
print limitCyclesToJSON resultLimitCycles
{*
{output: {
        limitcycles: [
            "1" : [ [[0,1,2]], ....],
            "2" : [ [[0,1,2],[1,2,3]], ... ]
            ]
        }
    }    
*}