load "FP.m2"
load "gbHelper.m2"

--installPackage "gbHelper"


newPackage(
     "solvebyGB",
     Version => "1.0",
     Date => "June 22, 2010",
     Authors => {
	  {Name => "Bonny Guang, Madison Brandon, Rustin McNeill, Franziska Hinkelmann" }},    
     Headline => "generates random networks over boolen ring and solves using Grobner basis")

needsPackage "FP"
needsPackage "gbHelper"
needsPackage "randfunc"

export{gbSolver, solveRandom, modifyOutput, sortOutput}

exportMutable {}

-- Will solve for cycles of length l using Alan's code --'
-- returns empty list or solutions in nice oututFormat
-- if fixed points are found, they are returned as a list of sequences, every sequence for different fixed points 
gbSolver = method()
gbSolver (Matrix, ZZ) := List => (F, l) -> (
    newSystem := composeSystem(F, l);
    solutions := T4( flatten entries newSystem, ring F);
    if solutions == {} then (stdio << "There are no cycles of length " << l << endl;)
    else (
      solutions = modifyOutput(solutions, ring F);
      if ( l != 1 ) then (
	   divisors := delete(l, getDivisors l);
	--select the solutions that don't equal themselves when applied i (a divisor) times
        scan(divisors, i -> solutions = select(solutions,
           j -> j != fold((p, q) ->
		flatten entries nextState(p, q), prepend(j, toList(i:F)))));
 --this code is commented out because I don't think unique works right now
 --if you uncomment it you'll get groupings of limit cycles but you'll get duplicate pairs
 --also it's ugly
--  	solutions = unique apply(solutions,
-- 	   s -> sort append(apply(accumulate(nextState, prepend(s, toList(l-1:F))),
--		     i -> flatten entries i),s));
	);
    stdio << "States with periodicity " << l << " are: " << solutions << endl;
    );
  solutions
)

solveRandom = method()
solveRandom (ZZ,ZZ,ZZ) := List => (n,valence,nterms) -> (
   QR := makeRing(n,2);
   F := makeBooleanNetwork(QR, valence, nterms);
   gbSolver(F,QR)
)

-- Takes a sequence ( {x4,x2,x3,x1}, {0,1,0,1}) and sorts it
-- return {1,1,0,0}
sortOutput = method()
sortOutput (List, List) := List => (variables, vals) -> (
  x := new MutableHashTable;
  apply( variables, vals, (var, v) -> x#var = v);
  apply( rsort pairs x, l -> last l)
)

--Takes output from gbSolver, say L={ ({x3,x2},{0,1}), ( {x1,x2,x3,x4}, {0,1,0,1}) and reformats it
-- to {({a,b,c,...}, {..,1,0,..}), ... }
-- need to pass the ring, because everything could be a fixed point (empty list)
-- assume things are in quotient ring!
modifyOutput = method()
modifyOutput (List, QuotientRing) := List => (L, QR) -> (
  assert( all( L, l -> length l == 2)); -- should be a list of pairs
  n := numgens QR;
  out := {};
  apply( L, l-> (
    if (length first l == n ) then (-- full list, sort and print
      out = append(out, sortOutput l)
    ) else (
      remainingVariables := gens QR - set first l;
      states = makeStates(2, #remainingVariables );
      apply( states, s-> (
        variables := flatten( append( first l, remainingVariables) );
        values := flatten( append( last l, s) );
        out = append(out, sortOutput( variables, values ))
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
     Key => {(solveRandom, ZZ, ZZ, ZZ), solveRandom},
     Headline => "Solves a random system with a set valence and number of terms for a Boolean
     	  ring with n variables",
     Usage => "solveRandom(n, valence, nterms)",
     Inputs => {"n", "valence", "nterms"},
     Outputs => {{"A list of sequences representing the fixed points that ",
	       TO "gbSolver", " solves for."}},
     }
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
    (modifyOutput, List, QuotientRing)
    modifyOutput
  Headline 
    Takes output from gbSolver and reformats it to look readable
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
      modifyOutput( L, QR )
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
  assert( modifyOutput( L, QR ) == {{1, 2, 3, 4}, {4, 2, 3, 1}, {10, 10, 10, 0}, {10, 10, 10, 1}} ) 
  L = {({x3_QR, x2_QR},{0,1})};
  assert (modifyOutput(L,QR) == {{0, 1, 0, 0}, {0, 1, 0, 1}, {1, 1, 0, 0}, {1, 1, 0, 1}});
  
  L = {({x3_QR,x2_QR},{0,1})};
  out := modifyOutput(L,QR);
  assert( out == {{0, 1, 0, 0}, {0, 1, 0, 1}, {1, 1, 0, 0}, {1, 1, 0, 1}})

///
  
TEST ///

  QR = makeRing (2,2); 
  F := matrix(QR,{{x2,x1}});
  assert( gbSolver(F, 1) == {{0, 0}, {1, 1}} )

  F = matrix(QR,{{x1, 0}});
  sol = gbSolver(F, 1) 
  assert(  sol == {{0, 0}, {1, 0}})

///

TEST ///

  QR = makeRing (3,2); 
  F := matrix(QR, {{ x1+x3+x2, x2, x1*x3 }});
  assert( gbSolver(F, 1) == {{0, 0, 0}, {1, 0, 0}, {1, 1, 1}} )
  assert( gbSolver(F, 2) == {{0, 1, 0}, {1, 1, 0}} )

///

TEST ///

  QR = makeRing (5,2); 
  F := matrix{{ x1+x2*x4, x2+1, x1+x4, x4, x3+x2+x2*x3}};
  assert( gbSolver(F, 1) == {} );
  assert( gbSolver(F, 2) == {{0, 1, 0, 0, 0}, {0, 0, 0, 0, 1}, {1, 0, 1, 0, 1}, {1, 1, 1, 0, 1}} );
  assert( gbSolver(F, 3) == {} );
  assert( gbSolver(F, 4) == {{0, 1, 0, 0, 0}, {0, 0, 0, 0, 1}, {1, 0, 1, 0, 1}, {1, 1, 1, 0, 1}, {0, 1, 1, 1, 0}, {1, 0, 1, 1, 1}, {0, 0, 0, 1, 1}, {1, 1, 0, 1, 1}} );
  assert( gbSolver(F, 5) == {} );

///

TEST ///

  QR = makeRing (3,2); 
  F := matrix {{x2,x1,x1}}; 
  assert( gbSolver(F, 1) == {{0, 0, 0}, {1, 1, 1}} );
  assert( gbSolver(F, 2) == {{1, 0, 0}, {0, 1, 1}});

///

TEST ///

  QR = makeRing (3,2); 
  F := matrix{{1,0,x1}}; 
  assert( gbSolver(F, 1) ==  {{1, 0, 1}} );
  assert( gbSolver(F, 2) ==  {} );

///

TEST /// 

    QR = makeRing (3,2);    
    G := matrix(QR, {{x1+x3,x2+1,x1*x3}})
    assert(gbSolver(G, 1) === {}) 
    assert(gbSolver (G, 2) == {{0, 0, 0}, {0, 1, 0}, {1, 0, 0}, {1, 1, 0}} ) 

    G = matrix{{x1+x3+x2, 1, x1*x3}}
    assert( nextState( {0,1,1}, G) - matrix{{0, 1, 0}} == 0 )
    assert( gbSolver(G, 1) == {{1, 1, 1}} )
    assert( gbSolver (G, 2) == {{{0, 1, 0}, {1, 1, 0}}} )

///

TEST ///

    QR = makeRing (4,2);
    G := matrix({{x1+x3, x2+1, x1*x3, x1*x4 + x3 + 1}})
    assert( gbSolver(G, 1) == {} ) 
    assert( sort gbSolver(G, 2) == sort {{0, 0, 0, 1}, {0, 1, 0, 1}, {1, 0, 0, 0}, {1, 1, 0, 1}, {1, 0, 0, 1}, {1, 1, 0, 0}} )
    
///

TEST ///

    QR = makeRing (10,2);
    G := matrix({{x1+x3, x2+1, x1*x3, x1*x4 + x3 + 1, x9,x10+x1, x4+x5*x6+x7+1, x1, x5, x8+x1*x9}})
    -- 8 2-cycles
    -- 8 4-cycles
    assert( gbSolver(G, 1) == {} )
    assert( sort gbSolver(G, 2) == sort {{0, 0, 0, 1, 0, 0, 0, 0, 0, 0}, {0, 1, 0, 1, 0, 0, 0, 0, 0, 0}, 
      {0, 0, 0, 1, 0, 0, 0, 0, 1, 0}, {0, 1, 0, 1, 1, 0, 0, 0, 0, 0}, 
      {0, 0, 0, 1, 0, 0, 1, 0, 0, 0}, {0, 1, 0, 1, 0, 0, 1, 0, 0, 0}, 
      {0, 0, 0, 1, 0, 0, 1, 0, 1, 0}, {0, 1, 0, 1, 1, 0, 1, 0, 0, 0}, 
      {0, 0, 0, 1, 1, 0, 0, 0, 0, 0}, {0, 1, 0, 1, 0, 0, 0, 0, 1, 0}, 
      {0, 0, 0, 1, 1, 0, 0, 0, 1, 0}, {0, 1, 0, 1, 1, 0, 0, 0, 1, 0}, 
      {0, 0, 0, 1, 1, 0, 1, 0, 0, 0}, {0, 1, 0, 1, 0, 0, 1, 0, 1, 0}, 
      {0, 0, 0, 1, 1, 0, 1, 0, 1, 0}, {0, 1, 0, 1, 1, 0, 1, 0, 1, 0}} )

///

TEST ///
    QR = makeRing (3,2);
    G := matrix(QR, {{1,1,0}});
    assert( gbSolver(G, 1) == {{1,1,0}} )
    assert( all ( (2..4), i -> gbSolver(G,i) == {{1,1,0}} ) )

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
solveRandom(n,valence,nterms);


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
installPackage "solvebyGB"
check "solvebyGB"
