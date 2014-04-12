-- -*- coding: utf-8 -*-

--load "gbHelper.m2"
newPackage(
     "functionalCircuits",
     Version => "1.0",
     Date => "July 22, 2010",
     Authors => {
	  {Name => "Bonny Guang" }},
     Headline => "Takes a list of functions and outputs the functional circuits",
     PackageExports => {"gbHelper"})

--needsPackage "gbHelper"

export{constructAdjacencyMatrix, circuits, circuitTable, printAdjacencyMatrix,
functionalCircuit, loopSort, isFunctional, shortcuts}
exportMutable{}

--constructAdjacencyMatrix: makes matrix of dimension nxn representing edges in the dependency graph
--Input: functionList, which must be a list of strings
constructAdjacencyMatrix = method()
constructAdjacencyMatrix (List) := Matrix => functionList -> (
  n := length functionList;
  varList := apply(n, i -> concatenate("x", toString (i+1)));
  map(ZZ^n, n, (i, j) -> if match(varList#j, functionList#i) then 1 else 0)
  --map(ZZ^n, n, (i, j) -> if i == j then 0 else if match(varList#j, functionList#i) then 1 else 0)
)


-- check if the loop is functional
-- loop is a list of xis in order
-- circuit is functional, if its context is non-empty, i.e., the "not-context
-- variety" is not the whole space, i.e., the polynomial is not 0
-- not context of i->j = V(f_j( ..., 0, ...) - f_j(..., 1, ...) )
isFunctional = method()
isFunctional (List, List) := Boolean => (loop, functions) -> (
  n := #functions;
  R := makeRing(n, 2); 
  functionsInR := matrix(R, {apply(functions, value)});
  p := product( #loop, ind-> (
    mySource := loop_ind;
    myTarget := loop_((ind+1)%#loop); -- the next element, wrap around
    i := value substring( mySource, 1);
    j := value substring( myTarget, 1);
    f := functionsInR_(j-1);
    g1 := sub(f, {(gens R)_(i-1) => 1});
    g2 := sub(f, {(gens R)_(i-1) => 0});
    g := first flatten entries (g1+g2)
  ));
  --return p!=0; 
  if p == 0 then return false   -- empty context
  else (
    -- there are points in the functionality context, assuming C has no
    -- shortcuts. Test for shortcuts and then for the extra condition
    
    shortcutSources := shortcuts(loop, functions);
    if shortcutSources == {} then return true
    else (
      pp := product( shortcutSources, sourc -> (
        i := value substring( sourc, 1);

        -- calculate p(..., xi+1, ...)
        sub(p, {(gens R)_(i-1) => (gens R)_(i-1) + 1}) 
      ) );
      return p*pp != 0 
    )
  )
)

-- returns a list of the sources of a shortcut
-- i.e., if ci -> ck != c(i+1), then return ci (as string)
-- returns empty list if there are no shortcuts
shortcuts = method()
shortcuts (List, List) := List => (loop, functions) -> (
  n := #functions;
  R := makeRing(n, 2); 
  A := constructAdjacencyMatrix functions;
  functions = matrix(R, {apply(functions, value)});
  select( loop, sourc -> (
    -- next entry in loop 
    targ := loop_((position( loop, i-> i == sourc ) + 1) % #loop);

    -- remove target from list
    otherCircuitElements := select( loop, i -> i != targ );

    -- check for sourc -> otherCircuitElement
    i := value substring( sourc, 1);
    shortCutTargets := select( otherCircuitElements, otherCircuitElement -> (
      k := value substring( otherCircuitElement, 1);
      A_(k-1, i-1) == 1
    ) );
    #shortCutTargets != 0
  ) )
)

functionalCircuit = method()
functionalCircuit (List) := String => functionList -> (
	C := circuits constructAdjacencyMatrix functionList;
  --print C;
	select(C, loop -> isFunctional (loop, functionList ))
)

-- print a matrix for debugging purposes
printAdjacencyMatrix = method()
printAdjacencyMatrix (Matrix) := A -> (
	print "<pre>";
	print A;
	print circuits A;
	print "</pre>"
)


--circuits: outputs all functional circuits
circuits = method()
circuits (Matrix) := List => adjacencyMatrix -> (

	n := numRows adjacencyMatrix;
	varList := apply(n, i -> concatenate("x", toString (i+1)));
	elementaryCircuits := {};

  -- a list of the walks currently known
  -- always a self-walk
	allPathes := apply(varList, i -> {i});

	--goes through j, the rows, and k, the columns, adding edges from xk to xj and checking
	--if there is a list xk, xp, ..., xq, xk. If so, drop xi (leaving xi, xp, ..., xq) and
	--add it to elementaryCircuits

  -- check walks of length i
	for i from 1 to n list (
		allPathesTemp := {};
		for j from 0 to n-1 list (
			for k from 0 to n-1 list (
	  			if adjacencyMatrix_(j, k) == 1 then    --      k->j
					scan(allPathes, x -> 
						if match(varList#k, last x) then  -- path ends in k, so k->j can be aded
							allPathesTemp = append(allPathesTemp, append(x, varList#j))
				);	
			 );
	  );

    allPathes = allPathesTemp;
    -- all walks of length i are in allPathes now
    -- find all loops of length i
    scan(allPathes, p -> 
      if match(first p, last p) then (  -- closed loop
        -- add the loop, but remove the end point because it is equal to the starting point
        elementaryCircuits = append(elementaryCircuits, take(p, {0, length p-2}));
      )
    );

    -- remove all walks from the list of current walks that contain a
    -- closed loop (elementary circuits: all nodes distinct)
    allPathes = select(allPathes, path -> #commonest path == #path)
	);
	elementaryCircuits = apply(elementaryCircuits, loopSort);
	unique elementaryCircuits
)


-- this sort works on a list of variables involved in a feedback loop
-- a regular sort would change the order of the loop
-- this sort begins every loop with the smallest index but the original order is containted 
-- example: {"x5", "x6", "x3", "x7", "x2", "x8", "x4"} -> {x2, x8, x4, x5, x6, x3, x7}
loopSort = method()
loopSort List := List => l -> (
  smallestEntry := min l;
  ind := position(l, i -> match(smallestEntry, i));

  -- move second half to front
  toList apply( (ind.. (#l-1)), i-> l_i) | apply( ind, i-> l_i)
)


--circuitTable makes HTML code for a table containing circuits
circuitTable = method()
circuitTable (List) := String => circuits -> (
  if circuits == {} then "There are no functional circuits!"
  else (
    circuits = apply(circuits, i -> (
      i = apply(i, j -> (
        j = concatenate j;
        concatenate(", ", j)
      ));
      i = replace(0, substring(first i, 2), i);
      concatenate("<tr><td>", i, "</td></tr>")
    ));
    concatenate("<table border=\"1\">", circuits, "</table>")
  )
)


beginDocumentation();

doc ///
     Key
     	  functionalCircuits
     Headline
     	  Takes a list of functions and outputs the functional circuits
     Description
     	  Text
	       Computes all functional circuits for a polynomial dyanmical system.
	  Example
	       circuits constructAdjacencyMatrix {"1+x1*x2", "x1"}
     SeeAlso
     	  "solvebyGB"

///

doc ///
     Key
     	 (circuits, Matrix)
	 circuits
     Headline
     	 Outputs the functional circuits from a matrix of directed edges
     Usage
     	 circuits matrixEdges
     Inputs
     	 matrixEdges:Matrix
	      A matrix representing the edges of a wiring diagram
     Outputs
     	 functionalLoops:List
	      A list of the functional circuits
     Description
         Text
	      circuits outputs the functional loops from a matrix of edges representing a wiring
	      diagram.
         Example
	      circuits constructAdjacencyMatrix {"1+x1*x2", "x1"}
     SeeAlso
     	  "constructAdjacencyMatrix"
///

doc ///
     Key
     	 (constructAdjacencyMatrix, List)
	 constructAdjacencyMatrix
     Headline
     	 Outputs a matrix of directed edges from a polynomial system
     Usage
     	 constructAdjacencyMatrix functionList
     Inputs
     	 functionList:List
	      A List containing the system of polynomial equations
     Outputs
     	 matrixEdges:Matrix
	      A matrix representing the edges of a wiring diagram
     Description
         Text
	      constructAdjacencyMatrix creates a matrix of edges representing a wiring diagram from a system of
	      polynomial equations.
         Example
	      constructAdjacencyMatrix {"1+x1*x2", "x1"}
     Caveat
     	 Input List must have entries of type String.
     SeeAlso
     	  "circuits"
///



TEST ///

assert(constructAdjacencyMatrix {"1+x1*x2", "x1"} == matrix{{1, 1}, {1, 0}})
assert(circuits constructAdjacencyMatrix {"1+x1*x2", "x1"} == {{"x1"},{"x1", "x2"}})
assert(circuitTable {{"x1"}, {"x1", "x2"}} == "<table border=\"1\"><tr><td>x1</td></tr><tr><td>x1, x2</td></tr></table>")
///

TEST ///
assert(constructAdjacencyMatrix {"x1*x3", "x4", "x1*x2*x4", "x2*x3"} == matrix{{1,0,1,0},{0,0,0,1},{1,1,0,1},{0,1,1,0}})
assert(circuits constructAdjacencyMatrix {"x1*x3", "x4", "x1*x2*x4", "x2*x3"} == { {"x1"},{"x1", "x3"}, {"x2", "x4"}, {"x3", "x4"}, {"x2", "x3", "x4"}})
///

TEST ///
assert(loopSort {"x1", "x3", "x2"} == {"x1", "x3", "x2"})
///

TEST ///
assert(circuits constructAdjacencyMatrix {"x2", "x3", "x1"} == { {"x1", "x3", "x2"}})
///


TEST ///
assert(functionalCircuit {"x2*x3", "x1+x1*x3", "x3"} == {{"x3"}} )
assert(functionalCircuit {"x2", "x1", "x3"} == { {"x3"}, {"x1", "x2"}})
///

TEST ///
assert(toString circuits constructAdjacencyMatrix {"x3", "x1+x5", "x4+x7",
"x2+x6", "x3", "x4", "x2+x6"} == toString {{x4, x6}, {x1, x2, x4, x3}, {x1, x2, x7, x3}, {x2, x4, x3, x5}, {x2, x7, x3, x5}, {x1, x2, x4, x6, x7, x3}, {x2, x4, x6, x7, x3, x5}} )
///

TEST ///
assert(toString shortcuts( {"x2", "x4", "x6", "x7", "x3", "x5"},{"x3", "x1+x5", "x4+x7",
"x2+x6", "x3", "x4", "x2+x6"}) == toString {x2, x4, x6} )
assert( shortcuts ( {"x1", "x2"},  {"x2", "x1", "x3"} ) == {} )
///

TEST ///
assert(toString circuits constructAdjacencyMatrix {"x3", "x1", "x1*x2"} ==
toString {{x1, x3}, {x1, x2, x3}})
assert(toString functionalCircuit {"x3", "x1", "x1*x2"} == toString {{"x1","x3"}})
///

TEST ///
assert( toString functionalCircuit {"x3", "x1*x5", "x4*x7", "x2*x6", "x3",
"x4", "x2*x6"} == toString { {x4, x6}, {x1, x2, x4, x3}, {x1, x2, x7, x3},
{x2, x4, x3, x5}, {x2, x7, x3, x5}}) -- checked with GINsim
///

TEST ///
assert( toString functionalCircuit { "x1+x2", "x1*x2*x3", "x1*x2+x3^2"} == 
toString{ {x1}, {x2}, {x3} }) -- checked with GINsim, over F2
///


end

f1 = x3 
f2 = x1+x5 
f3 = x4+x7
f4 = x2+x6 
f5 = x3 
f6 = x4 
f7 = x2+x6

loop = {x2, x4, x6, x7, x3, x5}


restart
loadPackage "functionalCircuits"
installPackage "functionalCircuits"
check "functionalCircuits"
