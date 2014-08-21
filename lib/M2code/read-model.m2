-- This code is not production code: it is being used by Mike S to 
-- change the format of the PlantSimLab models into json format.


{*
readVariable: Expects its input to be something like the lines below.
          returns a HashTable with the given information collected.

AbrevName:      Psy
FullName:       P._syringae
Color:  0
Shape:  0
Radius: 24.25
States: 2       absent  present
Loc:    1675    1705
Table:  Tables/Psy.csv
*}

splitOnSpace =(str) -> (
    separateRegexp("[[:space:]]+", str)
    )

-- not being used anymore:
splitOnColon = (str) -> (
    matches1 := select("([[:alnum:]]+):[[:space:]]*([[:alnum:]]+)", "\\1", str);
    --matches2 := select("([[:alnum:]]+):[[:space:]]*([[:alnum:]]+)", "\\2", str);
    matches2 := select("([[:alnum:]]+):[[:space:]]*([^[:space:]]*)", "\\2", str);
    if #matches1 == 0 or #matches2 == 0 then return null;
    (first matches1) => (first matches2)
    )

removeLeadingTrailingSpace = (str) -> (
    str1 = replace("^[[:space:]]+", "", str);
    replace("[[:space:]]+$", "", str1)
    )

toNumber = method()
toNumber String := (str) -> (
    -- if the first char of 'str' is a digit, then parse as a number
    -- otherwise just return str.
    if match("^[[:digit:]\\.]+$", str) then value str else str
    )
toNumber List := (L) -> L/toNumber

splitOnColon1 = (str) -> (
    L := separate(":", str);
    if #L != 2 then error "expected exactly one colon on line";
    L = L/removeLeadingTrailingSpace;
    val := if match("[[:space:]]", L#1) then (splitOnSpace L#1)/toNumber else toNumber L#1;
    L#0 => val
    )


readVariable = method()
readVariable String := (s) -> (
    if match("Table:", s) then (
        L := lines s;
        L/splitOnColon1
        )
    )

readVariables = method()
readVariables(String,String) := (prefix, filename) -> (
    L := get (prefix|filename);
    L1 := separateRegexp("\n[[:space:]]*\n", L);
    L2 := for f in L1 list readVariable f;
    L3 := delete(,L2);
    nextId := 1;
    --error "debug me";
    L4 := for f in L3 list (
        idinfo := "ID" => ("x"|(toString nextId));
        nextId = nextId + 1;
        hashTable prepend(idinfo, f))
    )

readTransitionTable = method()
readTransitionTable(String,String,HashTable) := (prefix,filename,mapping) -> (
    -- mapping is a hash table: Abrevname => ID
    L := get (prefix|filename);
    L1 := separate("\n", L);
    L2 := L1 / removeLeadingTrailingSpace;
    L2 = for f in L2 list if #f == 0 then continue else f;
    L2 = L2 / splitOnSpace / toNumber;
    -- format of file:
    -- line 1:  "SPEED:  x", where x is a number
    -- line 2: a list of abbrev names
    -- rest of lines: transition table
    if L2#0#0 =!= "SPEED:" then error "transition file not in the correct format";
    -- now we get the list of variables, which we switch to ID's for some reason
    -- using 'mapping'
    -- hack note: for some reason, vertical bars appear in some of the Table files for variable names
    vars := L2#1/(x -> (y := replace("\\|", "", x); mapping#y));
    -- now we get the tables themselves
    L3 := drop(L2,2); -- drop SPEED line, and the list of variables.  The rest should be the 
    -- put it all together:
    hashTable {{"Speed", L2#0#1}, {"InputIDs", vars}, {"TransitionTable", matrix L3}}
    )

readModelFile = method()
readModelFile(String,String) := (prefix,filename) -> (
    V := readVariables(prefix,filename);
    -- we need to make the hash table: abbrevname => id
    mapping := V/(v -> {if v#?"AbrevName" then v#"AbrevName" else v#"Name", v#"ID"})//hashTable;
    -- now go through each element of V, and replace the Table with TransitionTable
    V1 := V/(v -> (
            T := v#"Table";
            TT := readTransitionTable(prefix, T, mapping);
            hashTable append(pairs v, {"Transition", TT})
        ));
    V1
    )

getVariables = method()
getVariables List := (M) -> (
    for v in M list (
        states := v#"States";
        nstates := states#0;
        states = drop(states, 1);
        if #states != nstates then error("number of states expected("|toString nstates|") is wrong, in "|toString states);
        new HashTable from {
            "name" => if v#?"AbrevName" then v#"AbrevName" else 
                      if v#?"Name" then v#"Name" else
                      if v#?"FullName" then v#"FullName" else error ("can't find name in "|toString v),
            "id" => v#"ID",
            "states" => states
            }
        )
    )
getUpdateRules = method()
getUpdateRules List := (M) -> (
    -- first, we need the list of ID's
    idList := hashTable(M/(v -> v#"ID" => v));
    hashTable for idv in keys idList list (
        table := idList#idv#"Transition"#"TransitionTable";
        tab := for v in entries table list [new Array from drop(v,-1), v#-1];
        idv => 
        new HashTable from {
            -- the last entry in this list is the output variable, not the possible inputs
            "possibleInputVariables" => drop(idList#idv#"Transition"#"InputIDs", -1),
            "transitionTables" => tab
            })
    )

needsPackage "ADAMModel"
toADAMModel = method()
toADAMModel(List, String, String) := (M, name, version) -> (
    -- M is the output of "readModelFile"
    -- first, make the "variables" list.  Each entry has 3 parts: "name", "id", "states"
    model(name, 
        "description" => "",
        "version" => version,
        "variables" => getVariables M,
        "updateRules" => getUpdateRules M
        )
    )
end

restart
load "read-model.m2"
pre = "~/src/reinhard/plantsimlab-sample-models/Models/"
post = "~/src/reinhard/ADAM/exampleJSON/"

H = readModelFile(pre|"SecondVersion1/", "SecondVersion1.csv")
  M = toADAMModel(H, "SecondVersion1", "1.0")
  (post|"SecondVersion1-Model.json") << prettyPrintJSON M << endl << close;
H = readModelFile(pre|"SimplestVersion1/", "SimplestVersion1.csv")
  M = toADAMModel(H, "SimplestVersion1", "1.0")
  M = new HashTable from {"model" => M}
  (post|"SimplestVersion1-Model.json") << prettyPrintJSON M << endl << close;
H = readModelFile(pre|"ThirdVersion1/", "ThirdVersion1.csv")
  M = toADAMModel(H, "ThirdVersion1", "1.0")
  M = new HashTable from {"model" => M}
  (post|"ThirdVersion1-Model.json") << prettyPrintJSON M << endl << close;
H = readModelFile(pre|"demo/", "demo.csv")
  M = toADAMModel(H, "demo", "1.0")
  M = new HashTable from {"model" => M}  
  (post|"demo-Model.json") << prettyPrintJSON M << endl << close;
H = readModelFile(pre|"lac_operon_reduced/", "lac_operon_reduced.csv")
  M = toADAMModel(H, "lac_operon_reduced", "1.0")
  M = new HashTable from {"model" => M}  
  (post|"lac-operon-reduced-Model.json") << prettyPrintJSON M << endl << close;  
H = readModelFile(pre|"lac_operon_full/", "lac_operon_full.csv")
  M = toADAMModel(H, "lac_operon_full", "1.0")
  M = new HashTable from {"model" => M}  
  (post|"lac-operon-full-Model.json") << prettyPrintJSON M << endl << close;

