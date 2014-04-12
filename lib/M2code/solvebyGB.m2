----load "FP.m2"
--loadPackage( "gbHelper")

newPackage(
     "solvebyGB",
     Version => "1.0",
     Date => "July 22, 2010",
     Authors => {
	     {Name => "Bonny Guang, Madison Brandon, Rustin McNeill, Franziska Hinkelmann" }},    
     Headline => "generates random networks over boolen ring and solves using Grobner basis",
     PackageExports => {"gbHelper"},
     PackageImports => {"FP"}
     )

--needsPackage "FP"
--needsPackage "gbHelper"

export{gbSolver, modifyOutput, sortOutput, gbTable}

exportMutable {}

-- Will solve for cycles of length l using Alan's code --'
-- returns empty list or solutions in nice outputFormat 
-- if fixed points are found, they are returned as a list of list
-- l: length of limit cycle, l=1 one fixed points
-- L: list with number of functions per variable, entries are >1 for probabilistic networks
gbSolver = method()
gbSolver (Matrix, ZZ) := List => (F, l) -> (
  n := numgens ring F;
  L := toList (n:1);
  gbSolver(F, l, L)
)

gbSolver (Matrix, ZZ, List) := List => (F, l, L) -> (
    if max L > 1 then 
      assert l == 1;
    newSystem := composeSystem(F, l);
    --solutions := T4( flatten entries newSystem, ring F);
    -- T4 gives some weird (wrong) results
    -- waiting for Alan to get back to us 20/7/2010
    solutions := T3( flatten entries newSystem, ring F, L);
    if solutions != {} then (
      solutions = modifyOutput(solutions, ring F);
      if ( l == 1) then solutions = apply(solutions, i -> 
	   (i = apply(i, j -> (j = lift(j, ZZ);
		  	       if (j < 0) then j = j + char ring F;
		  	       j
		 	       ));
	   {i} --hack so gbTable has less code
	   )) 
      else (
	   divisors := delete(l, getDivisors l);
	--select the solutions that do not equal themselves when applied i (a
  --divisor) times, i.e., get rid of fixed points and shorter limit cycles
        scan(divisors, i -> solutions = select(solutions,
           j -> j != fold((p, q) ->
		flatten entries nextState(p, q), prepend(j, toList(i:F)))));
   		--DDDDDDDDDDDDDDDDDDDDDD= I dun wanna comment this...
        --get full limit cycle of remaining solutions
  	solutions = apply(solutions,
    -- T4 has issues, sometimes it does not return all elements in a cycle
    -- therefore we add the missing elements by iterating through the cycle
 	   s -> append(accumulate((p, q) ->
			  flatten entries nextState(p, q), prepend(s, toList(l-1:F))),s));
	--lift all elements to ZZ so they can be sorted and unique'd
	solutions = apply(solutions, i -> (
	     i = apply(i, j -> apply(j, k -> (k = lift(k, ZZ);
			                      if(k < 0) then k = k + char ring F;
					      k
					      )));
	     sort i));
	solutions = unique solutions;
	);
    );
  solutions
)

--gbTable makes HTML code for a table containing fixed points
gbTable = method()
gbTable (List) := String => solutions -> (
     if solutions == {} then "You have no limit cycles!"
     else (
     solutions = apply(solutions,    --first nest: groupings of limit cycles
	  i -> (
	       i = apply(i,  --2nd nest: each list in the limit cycle
		      j -> ( --make every digit into strings and concatenate it
		    	   k := apply(j, toString);
		    	   k = concatenate k;
			   concatenate(", ", k)
		    	   )
		   );
	       i = replace(0, substring(first i, 2), i); 
	       concatenate("<tr><td>", i, "</td></tr>")
	       )
     );
     concatenate("<table border=\"1\">", solutions, "</table>")
     ))

-- Takes a sequence ( {x4,x2,x3,x1}, {0,1,0,1}) and sorts it
-- return {1,1,0,0}
sortOutput = method()
sortOutput (List, List) := List => (variables, vals) -> (
  x := new MutableHashTable;
  apply( variables, vals, (var, v) -> x#var = v);
  apply( rsort pairs x, l -> last l)
)

--Takes output from gbSolver, say L={ ({x3,x2},{0,1}), ( {x1,x2,x3,x4}, {0,1,0,1}) and reformats it
-- to {({x1,x2,x3,...}, {..,1,0,..}), ... }
-- need to pass the ring, because everything could be a fixed point (empty list)
-- assume things are in quotient ring!
modifyOutput = method()
modifyOutput (List, QuotientRing ) := List => (L, QR) -> (
  assert( all( L, l -> length l == 2)); -- should be a list of pairs
  n := numgens QR;
  out := {};
  apply( L, l-> (
    if (length first l == n ) then (
	 sortedOut := sortOutput toSequence l;
     	 out = append(out, sortedOut);
    ) else (
      remainingVariables := gens QR - set first l;
      states := makeStates(char QR, #remainingVariables );
      apply( states, s-> (
        variables := flatten( append( first l, remainingVariables) );
        varValues := flatten( append( last l, s) );
	sortedOut := sortOutput (variables, varValues);
	out = append(out, sortedOut);
      ))
    )
  ) );
     out
)      

beginDocumentation();
document {
     Key => solvebyGB,
     Headline => "generates random networks over a Boolean ring and solves for
          dynamics using Groebner bases",
     EM "solvebyGB", " generates random networks over a Boolean ring and solves for dynamics
     	  using Groebner bases."
     }
 
doc ///
  Key 
    (gbSolver, Matrix, ZZ)
    gbSolver
  Headline 
    Solves for cycles of length l using back substitution 
  Usage 
      gbSolver(F, l)
  Inputs
    F:Matrix
    l:ZZ
  Outputs 
    solutions:List
      Returns a list of sequences, every sequence for different fixed points of the system
  Description
    Example 
      QR = makeRing(2,2);
      F := matrix(QR, {{x2,x1}});
      gbSolver(F, 1)
      gbSolver(F, 5)

      F = matrix(QR,{{x1, 0}})
      gbSolver(F, 1)

///

document {
     Key => {(sortOutput, List, List), sortOutput},
     Headline => "Takes a sequence ( {xi, ..., xj}, {values associated with xi, ..., xj} )
     	  and sorts it to ( {x1, ..., xn}, {values associated with x1, ..., xn} )",
     Usage => "sortOutput(variables, vals)",
     Inputs => {"variables", "vals"},
     Outputs => {{"A sequence of two lists, the first list being {x1, ..., xn} and the second
	       list being {values associated with x1, ..., xn}"}},
     EXAMPLE {
     	  "QR := makeRing (4,2);
	  sortOutput ({x1,x2,x3,x4}, {1,2,3,4} )
	  --get back {1,2,3,4}
	  
	  sortOutput ({x4,x2,x3,x1}, {1,2,3,4} )
	  --get back {4,2,3,1}"
	  }
     }
     

doc ///     
  Key 
    (gbTable, List)
  Headline 
    Takes output from gbSolver and puts it into a String with HTML code for a table
  Usage
    gbTable(solutions)
  Inputs
    solutions:List
      A List in the format of solutions that gbSolver outputs
  Outputs
    solutions:String
      A String containing HTML code for a table
  Description
    Example 
      QR = makeRing(3,3);
      F = matrix(QR, {{x1*x2, (1+x3)*x1, x2+x1+x1^2*(1+x3)^2}});
      g = gbSolver(F, 1);
      gbTable g
///

doc ///     
  Key 
    modifyOutput
    (modifyOutput, List, QuotientRing)
  Headline 
    Takes output from T3 and reformats it to look readable
  Usage
    modifyOutput(L, QR)
  Inputs
    L:List
    QR:QuotientRing
  Outputs
    L:List 
      A list in the format {{...,0,...,1}, {..,1,0,..}), ...}
  Description
    Example 
      QR = makeRing (4,2);
      L := { ({x1,x2,x3,x4}, {1,2,3,4} ), ({x4,x2,x3,x1}, {1,2,3,4})}
      modifyOutput( L, QR)
  Caveat
    Assumes things are in a quotient ring already.
///
         
TEST ///
  
  QR = makeRing( 4,2); 
  assert( sortOutput ({x1,x2,x3,x4}, {1,2,3,4} ) == {1,2,3,4} )
  assert( sortOutput ({x4,x2,x3,x1}, {1,2,3,4} ) == {4,2,3,1} )

///
  
TEST ///

  QR = makeRing( 4,2); 
  L := { ({x1,x2,x3,x4}, {1,2,3,4} ), ({x4,x2,x3,x1}, {1,2,3,4})}
  assert( modifyOutput( L, QR ) == {{1, 2, 3, 4}, {4, 2, 3, 1}} )
  L = { ({x1_QR, x2_QR, x3_QR, x4_QR}, {1,2,3,4} ), ({x4,x2,x3,x1}, {1,2,3,4}), ({x1_QR, x2_QR, x3_QR}, {10,10,10})}
  assert( modifyOutput( L, QR) == {{1, 2, 3, 4}, {4, 2, 3, 1}, {10, 10, 10, 0}, {10, 10, 10, 1}} ) 
  L = {({x3_QR, x2_QR},{0,1})};
  assert (modifyOutput(L,QR) == {{0, 1, 0, 0}, {0, 1, 0, 1}, {1, 1, 0, 0}, {1, 1, 0, 1}});
  
  L = {({x3_QR,x2_QR},{0,1})};
  out := modifyOutput(L,QR);
  assert( out == {{0, 1, 0, 0}, {0, 1, 0, 1}, {1, 1, 0, 0}, {1, 1, 0, 1}})

///
  
TEST ///

  QR = makeRing (2,2); 
  F := matrix(QR,{{x2,x1}});
  assert( gbSolver(F, 1) == {{{0, 0}}, {{1, 1}}} )

  F = matrix(QR,{{x1, 0}});
  sol = gbSolver(F, 1) 
  assert(  sol == {{{0, 0}}, {{1, 0}}})

///

TEST ///

     QR = makeRing(6, 2);
     F = matrix(QR, {{1+x6, 1+x1, 1+x2, 1+x3, 1+x4, 1+x5}})
     assert(gbSolver(F, 2) == {{{0, 0, 0, 0, 0, 0}, {1, 1, 1, 1, 1, 1}}})
     assert(gbSolver(F, 6) == {{{0, 0, 0, 0, 0, 1}, {0, 0, 0, 1, 0, 0}, {0, 1, 0, 0, 0, 0}, {0, 1, 1, 1, 1, 1}, {1, 1, 0, 1, 1, 1}, {1, 1, 1, 1, 0, 1}}, {{0, 0, 0, 0, 1, 0}, {0, 0, 1, 0, 0, 0}, {1, 0, 0, 0, 0, 0}, {1, 0,
      1, 1, 1, 1}, {1, 1, 1, 0, 1, 1}, {1, 1, 1, 1, 1, 0}}, {{0, 0, 0, 0, 1, 1}, {0, 0, 1, 1, 0, 0}, {0, 1, 1, 1, 1, 0}, {1, 0, 0, 1, 1, 1}, {1, 1, 0, 0, 0, 0}, {1, 1, 1, 0, 0, 1}}, {{0, 0, 0, 1,
      0, 1}, {0, 1, 0, 0, 0, 1}, {0, 1, 0, 1, 0, 0}, {0, 1, 0, 1, 1, 1}, {0, 1, 1, 1, 0, 1}, {1, 1, 0, 1, 0, 1}}, {{0, 0, 0, 1, 1, 0}, {0, 0, 1, 1, 1, 1}, {0, 1, 1, 0, 0, 0}, {1, 0, 0, 0, 0, 1},
      {1, 1, 0, 0, 1, 1}, {1, 1, 1, 1, 0, 0}}, {{0, 0, 1, 0, 0, 1}, {0, 1, 0, 0, 1, 0}, {0, 1, 1, 0, 1, 1}, {1, 0, 0, 1, 0, 0}, {1, 0, 1, 1, 0, 1}, {1, 1, 0, 1, 1, 0}}, {{0, 0, 1, 0, 1, 0}, {1, 0,
      0, 0, 1, 0}, {1, 0, 1, 0, 0, 0}, {1, 0, 1, 0, 1, 1}, {1, 0, 1, 1, 1, 0}, {1, 1, 1, 0, 1, 0}}, {{0, 0, 1, 0, 1, 1}, {0, 1, 1, 0, 1, 0}, {1, 0, 0, 1, 1, 0}, {1, 0, 1, 0, 0, 1}, {1, 0, 1, 1, 0,
      0}, {1, 1, 0, 0, 1, 0}}, {{0, 0, 1, 1, 0, 1}, {0, 1, 0, 0, 1, 1}, {0, 1, 0, 1, 1, 0}, {0, 1, 1, 0, 0, 1}, {1, 0, 0, 1, 0, 1}, {1, 1, 0, 1, 0, 0}}})
     assert(gbSolver(F, 3) == {{{0, 0, 0, 1, 1, 1}, {0, 1, 1, 1, 0, 0}, {1, 1, 0, 0, 0, 1}}, {{0, 0, 1, 1, 1, 0}, {1, 0, 0, 0, 1, 1}, {1, 1, 1, 0, 0, 0}}})

///

TEST ///

  QR = makeRing (3,2); 
  F := matrix(QR, {{ x1+x3+x2, x2, x1*x3 }});
  assert( gbSolver(F, 1) == {{{0, 0, 0}}, {{1, 0, 0}}, {{1, 1, 1}}} )
  assert( gbSolver(F, 2) == {{{0, 1, 0}, {1, 1, 0}}} )

///

TEST ///

  QR = makeRing (5,2); 
  F := matrix{{ x1+x2*x4, x2+1, x1+x4, x4, x3+x2+x2*x3}};
  assert( gbSolver(F, 1) == {} );
  assert( gbSolver(F, 2) == {{{0, 0, 0, 0, 1}, {0, 1, 0, 0, 0}}, {{1, 0, 1, 0, 1}, {1, 1, 1, 0, 1}}})
  assert( gbSolver(F, 3) == {} );
  assert( gbSolver(F, 4) == {{{0, 0, 0, 1, 1}, {0, 1, 1, 1, 0}, {1, 0, 1, 1, 1}, {1, 1, 0, 1, 1}}})
  assert( gbSolver(F, 5) == {} );

///

TEST ///

  QR = makeRing (3,2); 
  F := matrix {{x2,x1,x1}}; 
  assert( gbSolver(F, 1) == {{{0, 0, 0}}, {{1, 1, 1}}} );
  assert( gbSolver(F, 2) == {{{0, 1, 1}, {1, 0, 0}}})

///

TEST ///

  QR = makeRing (3,2); 
  F := matrix{{1,0,x1}}; 
  assert( gbSolver(F, 1) ==  {{{1, 0, 1}}} );
  assert( gbSolver(F, 2) ==  {} );

///

TEST /// 

    QR = makeRing (3,2);    
    G := matrix(QR, {{x1+x3,x2+1,x1*x3}})
    assert(gbSolver(G, 1) === {}) 
    assert(gbSolver (G, 2) == {{{0, 0, 0}, {0, 1, 0}}, {{1, 0, 0}, {1, 1, 0}}} ) 

    G = matrix{{x1+x3+x2, 1, x1*x3}}
    assert( gbSolver(G, 1) == {{{1, 1, 1}}} )
    assert( gbSolver (G, 2) == {{{0, 1, 0}, {1, 1, 0}}} )

///

TEST ///

    QR = makeRing (4,2);
    G := matrix({{x1+x3, x2+1, x1*x3, x1*x4 + x3 + 1}})
    assert( gbSolver(G, 1) == {} ) 
    assert( sort gbSolver(G, 2) == {{{0, 0, 0, 1}, {0, 1, 0, 1}}, {{1, 0, 0, 0}, {1, 1, 0, 1}}, {{1, 0, 0, 1}, {1, 1, 0, 0}}})

    
///

TEST ///

    QR = makeRing (10,2);
    G := matrix({{x1+x3, x2+1, x1*x3, x1*x4 + x3 + 1, x9,x10+x1, x4+x5*x6+x7+1, x1, x5, x8+x1*x9}})
    -- 8 2-cycles
    -- 8 4-cycles
    assert( gbSolver(G, 1) == {} )
    assert( gbSolver(G, 2) == {{{0, 0, 0, 1, 0, 0, 0, 0, 0, 0}, {0, 1, 0, 1, 0, 0, 0, 0, 0, 0}}, {{0, 0, 0, 1, 0, 0, 0, 0, 1, 0}, {0, 1, 0, 1, 1, 0, 0, 0, 0, 0}}, {{0, 0, 0, 1, 0, 0, 1, 0, 0, 0}, {0, 1, 0, 1, 0, 0, 1, 0, 0, 0}}, {{0, 0, 0, 1, 0, 0, 1, 0, 1, 0}, {0, 1, 0, 1, 1, 0, 1, 0, 0, 0}}, {{0, 0, 0, 1, 1, 0, 0, 0, 0, 0}, {0, 1, 0, 1, 0, 0, 0, 0, 1, 0}}, {{0, 0, 0, 1, 1, 0, 0, 0, 1, 0}, {0, 1, 0, 1, 1, 0, 0, 0, 1, 0}}, {{0, 0, 0, 1, 1, 0, 1, 0, 0, 0}, {0, 1, 0, 1, 0, 0, 1, 0, 1, 0}}, {{0, 0, 0, 1, 1, 0, 1, 0, 1, 0}, {0, 1, 0, 1, 1, 0, 1, 0, 1, 0}}})

///

TEST ///

    QR = makeRing (3,2);
    G := matrix(QR, {{1,1,0}});
    assert( gbSolver(G, 1) == {{{1,1,0}}} )
    assert( all ( (2..4), i -> gbSolver(G, i) == {} ) )

///     

TEST /// 

  --installPackage "FP"
  --installPackage "solvebyGB"
  QR = makeRing(8,2)
  F := matrix(QR,{ { (1+x2)*(1+x8) , (1+x1)*(1+x3) , (1+x2)*(1+x4) ,
  (1+x3)*(1+x5) , (1+x4)*(1+x6) , (1+x5)*(1+x7) , (1+x6)*(1+x8) ,
  (1+x7)*(1+x1)} })
///

TEST ///

QR = makeRing(3, 3);
F = matrix(QR, {{x1*x2, (1+x3)*x1, x2+x1+x1^2*(1+x3)^2}});
g = gbSolver(F, 1)
assert(g == {{{2, 1, 1}}, {{0, 0, 0}}, {{1, 1, 0}}})
assert(gbTable g == "<table border=\"1\"><tr><td>211</td></tr><tr><td>000</td></tr><tr><td>110</td></tr></table>")
g = gbSolver(F, 2)
assert(gbTable g == "You have no limit cycles!")


///

TEST ///

QR = makeRing(3, 2)
F = matrix(QR, {{x3*x2, x1, x1}})
gbSolver(F, 1)
gbSolver(F, 2)

///

TEST ///

QR = makeRing(3, 5)
F = matrix(QR, {{(1+x1)*(1+x2), x2+x3+x2*x3, x1^3*x3^2+1}})
assert(gbSolver(F, 1) == {{{0, 4, 1}}})
F = matrix(QR, {{x2*x1+1, x2+x3+x2*x3, x1^3*x3^2+1}})
g = gbSolver(F, 2)
assert(g == {{{0, 4, 2}, {1, 4, 1}}, {{2, 4, 0}, {4, 4, 1}}, {{2, 4, 2}, {4, 4, 3}}, {{3, 4, 3}, {3, 4,
      4}}})
assert(gbTable g == "<table border=\"1\"><tr><td>042, 141</td></tr><tr><td>240, 441</td></tr><tr><td>242, 443</td></tr><tr><td>343, 344</td></tr></table>")


///

TEST ///

QR = makeRing(8,2)
F := matrix(QR,{ { (1+x2)*(1+x8) , (1+x1)*(1+x3) , (1+x2)*(1+x4) ,
(1+x3)*(1+x5) , (1+x4)*(1+x6) , (1+x5)*(1+x7) , (1+x6)*(1+x8) ,
(1+x7)*(1+x1)} })

assert( gbSolver(F, 1) == {{{1, 0, 0, 1, 0, 1, 0, 0}}, {{1, 0, 1, 0, 0, 1, 0, 0}}, {{0, 1, 0, 1, 0, 1, 0, 1}}, {{0, 0, 1, 0, 0, 1, 0, 1}}, {{0, 0, 1, 0, 1, 0, 0, 1}}, {{0, 1, 0, 0, 1, 0, 0, 1}}, {{1, 0, 1, 0, 1, 0, 1, 0}}, {{0, 1, 0, 0, 1, 0, 1, 0}}, {{0, 1, 0, 1, 0, 0, 1, 0}}, {{1, 0, 0, 1, 0, 0, 1, 0}}})

///

TEST ///

QR = makeRing(4, 2)
F = matrix(QR, {{1+x4, 1+x1, 1+x2, 1+x3}})
assert(gbSolver(F, 1) == {{{0, 1, 0, 1}}, {{1, 0, 1, 0}}})
assert(gbSolver(F, 2) == {{{0, 0, 0, 0}, {1, 1, 1, 1}}})
assert(gbSolver(F, 3) == {})
assert(gbSolver(F, 4) == {{{0, 0, 0, 1}, {0, 1, 0, 0}, {0, 1, 1, 1}, {1, 1, 0, 1}}, {{0, 0, 1, 0}, {1, 0, 0, 0}, {1, 0, 1, 1}, {1, 1, 1, 0}}, {{0, 0, 1, 1}, {0, 1, 1, 0}, {1, 0, 0, 1}, {1, 1, 0, 0}}})

///

TEST ///

QR = makeRing(2, 2)
F = matrix(QR, {{x1, x2}})
assert(gbSolver(F, 1) == {{{0, 0}}, {{0, 1}}, {{1, 0}}, {{1, 1}}})
assert(gbSolver(F, 2) == {})

///

end

dataFile = "Alanbenchmark.txt"
for i from 40 to 50 do(
QR = makeRing (i,2);
fout = openOutAppend dataFile;
fout << "Timing Alan's code" << endl;
bigNetwork := makeBooleanNetwork(QR,7,7);
t1 := cpuTime();
FPs = gbSolver(bigNetwork, QR);
t2 := cpuTime();
T := (t1 - t2)/60;
fout << "Variables used: " <<  i << endl << "Fixed points are: " << endl << FPs << endl << "Cpu time: " << T << " minutes" << endl;
fout << close;
)



restart
loadPackage "solvebyGB"

check "solvebyGB"

--


n = 30;
valence = 6;
nterms = 10;


QR = ZZ/2[a,b,c,d]/(a^2+a,b^2+b,c^2+c,d^2+d);
K = {a,c,b,d};
gbSolver(K,QR);
L = ({c,b},{0,1});
out = modifyOutput(L,QR);
out



QS = makeRing (8,2);
G = {(a*d), g, (b*h)+h+1, (a*c*f*h)+(a*c*h), a*b,1,(b*d*f)+(b*e*f)+(d*e)+f, (a*b)+(a*g)+g}
time gbSolver(G,QS)
gbSolver(G,QS)


--timing Alan's code

restart
installPackage "solvebyGB"


dataFile = "Alanbenchmark.txt"
for i from 40 to 50 do(
QR = makeRing( i,2);
fout = openOutAppend dataFile;
fout << "Timing Alan's code" << endl;
bigNetwork := makeBooleanNetwork(QR,4,4);
t1 := cpuTime();
FPs := gbSolver(bigNetwork, QR);
t2 := cpuTime();
T := (t1 - t2)/60;
fout << "Variables used: " << endl << i << "Fixed points are: " << endl << FPs << endl << "Cpu time: " << T << " minutes" << endl;
fout << close;
)
    
     

restart
loadPackage "solvebyGB"
installPackage "solvebyGB"
check "solvebyGB"
