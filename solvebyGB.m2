load "FP.m2"
load "limitcycle.m2"

newPackage(
     "solvebyGB",
     Version => "1.0",
     Date => "June 22, 2010",
     Authors => {
	  {Name => "Bonny Guang, Madison Brandon, Rustin McNeill, Franziska Hinkelmann" }},    
     Headline => "generates random networks over boolen ring and solves using Grobner basis")

needsPackage "FP"
needsPackage "limitcycle"

export{gbSolver, solveRandom, modifyOutput}
exportMutable {}


-- Will solve for fixed points and 2-cycles using Alan's code --'
gbSolver = method()
gbSolver (List,QuotientRing) := (F,QR) -> (
     fixedpoints := T4(F,QR);
     if fixedpoints == {} then (stdio << "There are no fixed points" << endl;)
     else (
       --fixedpoints = modifyOutput(toSequence fixedpoints, QR);
       stdio << "The fixed points are: " << fixedpoints << endl;
     );
--sub will not substitute 1 in for 1, has to be a variable
-- This will also include fixed points.  we will want to fix that     
     --F = apply(F, p -> sub(p, matrix{toList(F)}));
     --twoCycles := T4(F,QR);
     --if twoCycles == {} then (stdio << "There are no 2-cycles" << endl;)
     --else (stdio << "The cycles of length two are: " << twoCycles << endl;);        
)

solveRandom = method()
solveRandom (ZZ,ZZ,ZZ) := (n,valence,nterms) -> (
     QR = booleanRing(n);
     F = makeBooleanNetwork(QR,valence,nterms);
     gbSolver(F,QR);
)

--Takes output from gbSolver, say L=({c,b},{0,1}), and reformats it
-- to ({a,b,c,...}, {..,1,0,..})
modifyOutput = method()
modifyOutput (Sequence,QuotientRing) := List => (L,QR) -> (
     assert(length L == 2);
     RemVars := gens QR - set(apply(L_0, l -> lift(l,QR)));
     if RemVars == {} then (
	  x := new MutableHashTable;
     	  apply(L_0, L_1, (var,key) -> x#var = key);
	  S := {};
	  output := (gens QR, apply(gens QR, i-> append(S,x#i)));
     )
     else (
     	  n := #RemVars;
     	  states := makeStates(n);
     	  output = {};
     	  for i to (#states-1) do (
	       variables = flatten(append(L_0,RemVars));
	       stateList = flatten(append(L_1,states#i));
	       x = new MutableHashTable;
	       apply(variables, stateList, (var,key) -> x#var = key);
	       S = {};
	       apply(gens QR, i-> S = append(S,x#i));
	       out := (gens QR, S);
	       output = append(output,out);
     	       );
     );
     output
)      
         
TEST ///
  QR = ZZ/2[a,b,c,d]/(a^2+a,b^2+b,c^2+c,d^2+d);
  L = ({c,b},{0,1});
  assert (modifyOutput(L,QR) == {({a, b, c, d}, {0, 1, 0, 0}), ({a, b, c, d}, {0, 1, 0, 1}), ({a, b, c, d}, {1, 1, 0, 0}), ({a, b, c, d}, {1, 1, 0, 1})});

///

end

restart
loadPackage "solvebyGB"
check "solvebyGB"
installPackage "solvebyGB"

--
QR = booleanRing 2; 
F = {b,a};
gbSolver(F,QR);


n = 30;
valence = 6;
nterms = 10;
solveRandom(n,valence,nterms);

QR = booleanRing 4;
L = ({c,b},{0,1});
out = modifyOutput(L,QR);
out

QS = booleanRing 8;
G = {(a*d), g, (b*h)+h+1, (a*c*f*h)+(a*c*h), a*b,1,(b*d*f)+(b*e*f)+(d*e)+f, (a*b)+(a*g)+g}
time gbSolver(G,QS)
gbSolver(G,QS)
restart
loadPackage "solvebyGB"
check "solvebyGB"
installPackage "solvebyGB"
