-- -*- coding: utf-8 -*-
load "randfunc.m2"

newPackage(
     "gbHelper",
     Version => "1.1",
     Date => "June 28, 2010",
     Authors => {
	  {Name => "Bonny Guang, Madison Brandon, Rustin McNeill, Franziska Hinkelmann" }},    
     Headline => "A bunch of helper functions for solvebyGB and conjunctiveNetwork")

needsPackage "randfunc"

export{makeStates, getDivisors, nextState, composeSystem}
exportMutable {}

-- a state is a list of 0s and 1s in ZZ (not ZZ/2)

-- returns next binary state
makeStatesHelper = method()
makeStatesHelper (List,ZZ) := List => (state,p) -> (
    lens := length state;
    assert(state != toList(lens:(p-1))); --this is the last state
    --get last digit
    pos := lens - 1;
    listNumber := state#pos;
    --if the last digit isn't p-1 then add 1 to it
    if listNumber != (p-1) then (state = replace(pos,listNumber+1,state))
    --otherwise change all consecutive preceding digits that are p-1 to 0
    else(
    state = replace(pos,0,state);
    pos = pos - 1;
    while state#pos == p-1 do(
	 state = replace(pos,0,state);
	 pos = pos - 1;
	 );
    state = replace(pos,(state#pos) + 1,state)
    ))

--creates 2^n states
makeStates = method()
makeStates (ZZ,ZZ) := List => (p,n) -> (
     state := toList(n:0);
     stateList := {state};     
     while state != toList(n:p-1)
         list (state = makeStatesHelper(state,p); stateList = append(stateList, state));
     stateList
     )

-- iterates a state by applying a sequence of functions, returns the resulting state
nextState = method()
nextState (List, Matrix) := List => (state, F) ->  sub(F, matrix(ring F, {state}) )

-- returns true if x is a fixed point
isFixedpoint = method()
isFixedpoint (List , Sequence) := Boolean => (x,G) -> (
     G0 := nextState(x, G);
     all (length x,i->G0#i-x#i==0)
     )


--compose F n times
composeSystem = method() 
composeSystem(Matrix, ZZ) := (F, n) -> (
  G := F;
  for i from 2 to n do 
    G = sub(G,F);
  G  
)
  
  
--getDivisors: takes an integer and outputs a list of all its divisors
getDivisors = method()
getDivisors ZZ := List => c -> (
     --get a list of the factors
     factorExponents := apply(toList(factor c), j -> toList(j));
     factors := splice apply(factorExponents, j ->
     	  if j#1 == 1 then (j#0)
	  else lift(j#1, ZZ):j#0);
     
     --get a list of all possible exponents (2^# of factors)
     lens = length factors;
     exponentList := makeStates(2, lens);
     
     --get a list of the divisors
     divisorCombos := apply(exponentList, i -> apply(factors, i, (p, q) -> p^q));
     divisors := apply(divisorCombos, i -> times toSequence(i));
     divisors = unique divisors
     	  )

beginDocumentation()
document {
     Key => gbHelper,
     Headline => "A bunch of helper functions for solvebyGB and conjunctiveNetwork",
     EM "gbHelper", " A bunch of helper functions for solvebyGB and conjunctiveNetwork"
     }
document {
     Key => {(makeStates, ZZ, ZZ), makeStates},
     Headline => "creates 2^n states",
     Usage => "makeStates n",
     Inputs => {"characteristic P", "number of variables n"},
     Outputs => {{"A list containing all 2^", TT "n", " Boolean states"}}
     }
document {
     Key => {(nextState, List, Matrix), nextState},
     Headline => "iterates a state by applying a sequence of functions",
     Usage => "nextState(state, system)",
     Inputs => {"state", "system"},
     Outputs => {"the resulting state as a list"}
     }
doc ///
  Key
    (composeSystem,Matrix,ZZ)
    composeSystem
  Headline 
    creates the system $F^l(x)$
  Usage
    composeSystem(F,l)
  Inputs
    F:Matrix
      input system
    l:ZZ
      how many times to compose F
  Outputs 
    F:Matrix
      F compositions with itself l times
///

document {
     Key => {(getDivisors, ZZ), getDivisors},
     Headline => "takes an integer and outputs a list of all its divisors",
     Usage => "getDivisors c",
     Inputs => {"c"},
     Outputs => {{"A list of all the divisors of ", TT "c"}},
     }

TEST ///

    n := 3 -- for now we work with 3 variable
    assert(makeStates n == {{0, 0, 0}, {0, 0, 1}, {0, 1, 0}, {0, 1, 1}, {1, 0, 0}, {1, 0, 1}, {1, 1, 0}, {1, 1, 1}})

///

TEST ///

    QR = makeRing (3,2);    
    G := matrix(QR, {{x1+x3+x2, 1, x1*x3}})
    assert( nextState( {0,1,1}, G) - matrix(QR,{{0, 1, 0}} ) == 0  )

///
    


end

restart
loadPackage "gbHelper"
check "gbHelper"
installPackage "gbHelper"

    QR = makeRing (3,2);    
    use QR;
    G = (x1+x3, x2+1,x1*x3) 

G = matrix{{1_QR,1,0}}
G = matrix(QR,{{1,1,0}} )
G = (1, x1*x3+x1+x2+x1*x2, 1+x3+x1*x2)
GG = matrix {{1, x1*x3+x1+x2+x1*x2, 1+x3+x1*x2}}
composeSystem(GG,2)
composeSystem(GG,3)


G = (0, x1+x2, 1+x3+x1*x2)

restart
installPackage "gbHelper"
loadPackage "gbHelper"
check "gbHelper"
