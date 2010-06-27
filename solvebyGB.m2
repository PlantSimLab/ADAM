load "FP.m2"
load "limitcycle.m2"

--installPackage "limitcycle"

newPackage(
     "solvebyGB",
     Version => "1.0",
     Date => "June 22, 2010",
     Authors => {
	  {Name => "Bonny Guang, Madison Brandon, Rustin McNeill, Franziska Hinkelmann" }},    
     Headline => "generates random networks over boolen ring and solves using Grobner basis")

needsPackage "FP"
needsPackage "limitcycle"

export{gbSolver, solveRandom, modifyOutput, sortOutput}
exportMutable {}


-- Will solve for cycles of length l using Alan's code --'
-- returns empty list or solutions in nice oututFormat
-- if fixed points are found, they are returned as a list of sequences, every sequence for different fixed points 
gbSolver = method()
gbSolver (List, QuotientRing, ZZ) := (F, QR, l) -> (
    F = toList createSystemForCycles(l, F);
    solutions := T4( F, QR);
    if solutions == {} then (
      stdio << "There are no cycles of length " << l << endl;
    )
    else (
      solutions = modifyOutput(solutions, QR);
      stdio << "States with periodicity " << l << " are:" << solutions << endl;
    );
    solutions
)

solveRandom = method()
solveRandom (ZZ,ZZ,ZZ) := (n,valence,nterms) -> (
   QR := booleanRing(n);
   F := makeBooleanNetwork(QR, valence, nterms);
   gbSolver(F,QR);
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
modifyOutput (List, QuotientRing) := List => (L,QR) -> (
  assert( all( L, l -> length l == 2)); -- should be a list of pairs
  n := numgens QR;
  out := {};
  apply( L, l-> (
    if (length first l == n ) then (-- full list, sort and print
      out = append(out, sortOutput l)
    ) else (
      remainingVariables := gens QR - set first l;
      --remainingVariables := gens QR - set apply(first l, x-> promote(x,QR));
      states = makeStates( #remainingVariables );
      apply( states, s-> (
        variables := flatten( append( first l, remainingVariables) );
        values := flatten( append( last l, s) );
        out = append(out, sortOutput( variables, values ))
      ))
    )
  ) );
  out
)      
         
TEST ///
  
  QR := booleanRing 4; 
  assert( sortOutput ({x1,x2,x3,x4}, {1,2,3,4} ) == {1,2,3,4} )
  assert( sortOutput ({x4,x2,x3,x1}, {1,2,3,4} ) == {4,2,3,1} )

///
  
TEST ///

  QR := booleanRing 4; 
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

  QR := booleanRing 2; 
  F := {x2,x1};
  assert( gbSolver(F, QR, 1) == {{0, 0}, {1, 1}} )

  F = {x1, 0}
  sol = gbSolver(F,QR,1) 
  assert(  sol == {{0, 0}, {1, 0}})

///

TEST ///

  QR := booleanRing 3; 
  F := { x1+x3+x2, x2, x1*x3 };
  assert( gbSolver(F, QR, 1) == {{0, 0, 0}, {1, 0, 0}, {1, 1, 1}} )
  assert( gbSolver(F, QR, 2) == {{0, 0, 0}, {1, 0, 0}, {0, 1, 0}, {1, 1, 0}, {1, 1, 1}} )

///

TEST ///

  QR := booleanRing 5; 
  F := { x1+x2*x4, x2+1, x1+x4, x4, x3+x2+x2*x3};
  assert( gbSolver(F, QR, 1) == {} );
  assert( gbSolver(F, QR, 2) == {{0, 1, 0, 0, 0}, {0, 0, 0, 0, 1}, {1, 0, 1, 0, 1}, {1, 1, 1, 0, 1}} );
  assert( gbSolver(F, QR, 3) == {} );
  assert( gbSolver(F, QR, 4) == {{0, 1, 0, 0, 0}, {0, 0, 0, 0, 1}, {1, 0, 1, 0, 1}, {1, 1, 1, 0, 1}, {0, 1, 1, 1, 0}, {1, 0, 1, 1, 1}, {0, 0, 0, 1, 1}, {1, 1, 0, 1, 1}} );
  assert( gbSolver(F, QR, 5) == {} );

///


end

restart
loadPackage "solvebyGB"
check "solvebyGB"

--


n = 30;
valence = 6;
nterms = 10;
solveRandom(n,valence,nterms);


QS = booleanRing 8;
G = {(a*d), g, (b*h)+h+1, (a*c*f*h)+(a*c*h), a*b,1,(b*d*f)+(b*e*f)+(d*e)+f, (a*b)+(a*g)+g}
time gbSolver(G,QS)
gbSolver(G,QS)

restart
installPackage "solvebyGB"
check "solvebyGB"
