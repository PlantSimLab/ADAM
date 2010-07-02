-- -*- coding: utf-8 -*-
load "gbHelper.m2"
load "randfunc.m2"

newPackage(
     "conjunctiveNetwork",
     Version => "1.0",
     Date => "June 22, 2010",
     Authors => {
	  {Name => "Bonny Guang" }},    
     Headline => "takes a dependency graph and computes the loop number")

needsPackage "gbHelper"
needsPackage "randfunc"

--COMMENT: Assumes a conjunctive (or disjunctive) network
export{loopNum, isStronglyConnected, limCycles, jlvFormula}
exportMutable {}

--parseGraph: returns n, the number of nodes, and edgeList,
--     a list of edges in the graph. Removes extraneous
--     items in the dot file like "digraph test{", etc.
--Assumption: file is a dot file, format of dot file is as in DVD
parseGraph = method()
parseGraph String := (ZZ, List) => file -> (
     --turn file into a list of strings; each string is a line in file
     --"}" is the last line in DVD input so delete it
     contents := lines get file;
     contentsList := delete("}", contents);
     lastEdge := last contentsList; --now the last element is "nodei -> noden;"
     nodes := separate("->", lastEdge); --nodes = {nodei , noden;}
     
     --get index and length of characters that are digits
     --make list where only elements are of form "nodei -> nodej"
     nIndex := regex("[[:digit:]]+", last nodes);
     n := value substring(nIndex#0, last nodes);
     roughEdgeList := drop(contentsList, {0, n});
     
     (n, roughEdgeList)
     )

--makeEdgeList: formats roughEdgeList into a list of integer pairs, where the
--    first integer is the head and the second integer is the tail
makeEdgeList = method()
makeEdgeList List := List => roughEdgeList -> (
     --separate "nodei -> nodej;" to {nodei , nodej;}; i and j are in ZZ
     separatedPairs := apply(roughEdgeList, p -> separate("->", p));
     --get indices and lengths of i and j
     numIndices := apply(separatedPairs, p -> apply(p, q -> regex("[[:digit:]]+", q)));
     --make list of pairs (i, j)
     edgeList := apply(separatedPairs,
	               numIndices,
		       (i, j) -> apply(i, j, (p, q) -> value substring(q#0, p)))
     )

--loopNum: takes a dependencyGraph and outputs the loop number by computing
--    the GCD of all the circuit lengths
--Assumption: dependencyGraph is a dot file in the format of the DVD output
--Algorithm: see Colon-Reyes 2004, Boolean Monomial Dynamical Systems
loopNum = method()
loopNum String := ZZ => dependencyGraph -> (
     (n, matrixRep) := makeMatrix dependencyGraph;
     count := 1;
     loopLengths := {0}; --allows us to take gcd in the for loop
     GCD := 0;
     matrixRep2 := matrixRep;

     --if M^i has non-zero entries on the diagonal then it has loops of length i
     --heuristic: if GCD == 1 then exit; no point in searching more
     for i from 0 to n when i < n and GCD != 1 list (
     	  if trace(matrixRep2) > 0 then loopLengths = append(loopLengths, count);
	  GCD = gcd(loopLengths);
	  matrixRep2 = matrixRep2*matrixRep;
	  count = count + 1 );
     
     GCD
     )

--makeMatrix: makes matrix of dimension nxn representing edges in the dependency graph
--     also returns n, the number of nodes in the graph
makeMatrix = method()
makeMatrix String := (ZZ, Matrix) => dependencyGraph -> (
     (n, roughEdgeList) := parseGraph(dependencyGraph);
     edgeList := makeEdgeList(roughEdgeList);
     --if there is an edge from j+1 to i+1 then M_(i, j) = 1
     --use j+1 and i+1 because matrix indices start at 0 but DVD nodes start at 1
     matrixRep := map(ZZ^n, n, (i, j) -> if member({j+1, i+1}, edgeList) then 1 else 0);
     (n, matrixRep)
     )

--isStronglyConnected: checks if a dependency graph is strongly connected
--     by checking if all entries in a matrix representation of the edges
--     are non-zero up to the nth power of the matrix
isStronglyConnected = method()
isStronglyConnected String := Boolean => dependencyGraph -> (
     (n, matrixRep) := makeMatrix dependencyGraph;
     matrixRep2 := matrixRep;
     k := false;
     for i from 1 to n when i != n list(
     	  if any(flatten entries matrixRep2, zero)
	       then matrixRep2 = matrixRep2 + power(matrixRep, i+1)
	  else (
	       k = true;
	       break
	       ) );
     k
     )

--limCycles: returns number of limit cycles from a dependency graph. Output is
--     a list of pairs, where the second element is the period and the first
--     element is the number of limit cycles of that period
--Assumption: graph is dot format from DVD output; graph is strongly connected
--Algorithm: see Jarrah-Laubenbacher-Veliz-Cuba 2010, The Dynamics of Conjunctive
--   and Disjunctive Boolean Network Models, Theorem 3.8
limCycles = method()
limCycles String := List => dependencyGraph -> (
     if not isStronglyConnected dependencyGraph
     then (stdio << "Graph isn't strongly connected,";
	   stdio << " can't tell anything at this time." << endl;
	   {"end."}
	   )
     else (
     	  (n, throwAway) := parseGraph(dependencyGraph);
     	  c := loopNum(dependencyGraph);
     	  if c == 1
	  then (
	       stdio << "There are two fixed points: " << {n:0, n:1} << endl;
	       stdio << "No other limit cycles exist." << endl;
	       {n:0, n:1}
	       )
     	  else (
	       --get functions and ring
	       QR := makeRing (n,2);
	       use QR;
	       edgeList := makeEdgeList(throwAway);
	       functionList := {};
	       for i from 1 to n list (
		    workingEdges := select(edgeList, j -> j#1 == i);
		    workingFunction := apply(workingEdges,
			 v -> concatenate("x", toString v#0));
		    workingFunction = value fold(workingFunction,
			 (i, j) -> concatenate(i, "*", j));
		    functionList = append(functionList, workingFunction);
		    );
	       
	       --get number of limit cycles and what they are
	       cDivisors := getDivisors c;
	       numCycles := apply(cDivisors, i -> jlvFormula i / i);
	       stdio << "There are ";
	       scan(numCycles, cDivisors, (i, j) -> (
	       stdio << i << " limit cycles of period " << j << ":" << endl;
	       stdio << cycles(j, functionList) << endl));
	       stdio << "and no other limit cycles." << endl;
	       apply(numCycles, cDivisors, (i, j) -> {i, j})
     	       )
     ))

--jlvFormula: computes the number of periodic states for a period of m
--Assumptions: network is strongly connected
--Algorithm: see Jarrah-Laubenbacher-Veliz-Cuba 2010, The Dynamics of Conjunctive
--   and Disjunctive Boolean Network Models, Eq.1
jlvFormula = method()
jlvFormula ZZ := ZZ => m -> (
     factors := apply(toList factor m, j -> toList j);
     r := length factors;
     primes := apply(factors, j -> first j);
     primePowers := apply(factors, j -> last j);
     iCombos = makeStates (2,r);
     sum apply(iCombos, i -> jlvTerm1(i)*jlvTerm2(primes, primePowers, i))
     )

--jlvTerm1 and jlvTerm2: functions that help make putting together the
--     jlvFormula easier/more comprehensible
--Algorithm: see jlvFormula
jlvTerm1 = i -> power(-1, sum i)
jlvTerm2 = (p, k, i) -> (
     expList := apply(k, i, (x, y) -> x - y);
     power(2, product(p, expList, (x, y) -> x^y))
     )

beginDocumentation();

document {
     Key => {(loopNum, String), loopNum},
     Headline => "Computes all the circuit lengths of a dependency graph to find the loop number",
     Usage => "loopNum(dependencyGraph)",
     Inputs => {"A dependency graph"},
     Outputs => {"An integer, the loop number of the dependency graph"}, 
     Caveat => "Dependency graph must be in DVD dot file format"
     }

document {
     Key => {(isStronglyConnected, String), isStronglyConnected},
     Headline => "Takes a dependency graph and determines if it is strongly connected or not",
     Usage => "isStronglyConnected(dependencyGraph)",
     Inputs => {"A dependency graph"},
     Outputs => {"True if the graph is strongly connected, false if it is not"},
     Caveat => "Dependency graph must be in DVD dot file format"
     }

document {
     Key => {(limCycles, String), limCycles},
     Headline => "Calls isStronglyConnected, if the graph is strongly connected it lists the fixed points 
     and limit cycles of the graph, and how many of each there are",
     Usage => "limCycles(dependencyGraph)",
     Inputs => {"A dependency graph"},
     Outputs => {"A list of pairs of integers (the first integer in the pair is the number of limit cycles
     the second integer is the period of those limit cycles)"},
     Caveat => "Dependency graph must be in DVD dot file format"
     }

document {
     Key => {(jlvFormula, ZZ), jlvFormula},
     Headline => "Given an integer, computes the number of periodic states for that integer",
     Usage => "jlvFormula m",
     Inputs => {"An integer (a period)"},
     Outputs => {"The number of periodic states for the entered period"}
     }

TEST ///
  assert true
  f = openOut "dvdNetwork.dot";
  f << "digraph test {
node1 [label=\"x1\", shape=\"box\"];
node2 [label=\"x2\", shape=\"box\"];
node3 [label=\"x3\", shape=\"box\"];
node1 -> node1;
node2 -> node1;
node1 -> node2;
node2 -> node2;
node3 -> node2;
node1 -> node3;
node2 -> node3;
node3 -> node3;
}";
f << close;
  assert( loopNum "dvdNetwork.dot" == 1 ) 
--  assert( loopNum "twoAndThree.dot" == 1 )
--  assert( loopNum "twoLoopNetwork.dot" == 2 )
///

end

restart
loadPackage "conjunctiveNetwork"
check "conjunctiveNetwork"

--some tests; the dot files are all in the repository
b1 := isStronglyConnected "dvdNetwork.dot"
n1 := loopNum("dvdNetwork.dot")
l1 := limCycles("dvdNetwork.dot")

b2 := isStronglyConnected "twoAndThree.dot"
n2 := loopNum("twoAndThree.dot")
l2 := limCycles("twoAndThree.dot")

b3 := isStronglyConnected "twoLoopNetwork.dot"
n3 := loopNum("twoLoopNetwork.dot")
l3 := limCycles("twoLoopNetwork.dot")

--b4 should be false, n4 should be 1
b4 := isStronglyConnected "notStronglyConnected.dot"
n4 := loopNum "notStronglyConnected.dot"
l4 := limCycles "notStronglyConnected.dot"

--A1 should be 2 from Corollary 3.7
A1 := jlvFormula 2
--A2 should be 54 from hand calculations
A2 := jlvFormula 6
