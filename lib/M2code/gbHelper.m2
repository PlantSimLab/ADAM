-- -*- coding: utf-8 -*-

newPackage(
     "gbHelper",
     Version => "1.1",
     Date => "July 28, 2010",
     Authors => {
	  {Name => "Bonny Guang, Madison Brandon, Rustin McNeill, Franziska Hinkelmann" }},    
     Headline => "A bunch of helper functions for solvebyGB and conjunctiveNetwork")


export{makeStates, getDivisors, composeSystem, makeRing, nextState, makeStatesHelper, booleanRing}
exportMutable {}

-- a state is a list of 0s and 1s in ZZ (not ZZ/2)

-- generate quotient ring with n variables
makeRing = method()
makeRing (ZZ,ZZ) := (nvars,c) -> (
     ll := apply( (1..nvars), i -> value concatenate("x",toString i));
     R1 :=ZZ/c[ll];
     --R1 := ZZ/2[vars(0..nvars-1), MonomialOrder=>Lex];
     L := ideal apply(gens R1, x -> x^c-x);
     R1/L
)

booleanRing = method()
booleanRing ZZ := (n) -> makeRing(n,2)

-- returns next state with base p
makeStatesHelper = method()
makeStatesHelper (List,ZZ) := List => (state,p) -> (
    lens := length state;
    assert(state != toList(lens:(p-1))); --this is the last state
    --get last digit
    pos := lens - 1;
    listNumber := state#pos;
    --if the last digit is not p-1 then add 1 to it
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

--creates p^n states
--p is the prime characteristic and n is the number of variables
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
     lens := length factors;
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

doc ///
  Key
    (makeRing, ZZ, ZZ)
    makeRing
  Headline
    generate quotient ring for boolean polynomials
  Usage
    makeRing(n,c)
  Inputs
    n:ZZ
      number of variables
    c:ZZ
      characteristic of the fiel
  Outputs
    QR:QuotientRing
  Description
    Text
      Generates $ZZ/2[x_1, \ldots, x_n]/ <x_1^2 +x_1, \ldots, x_n^2 + x_n >$. 
    Example
      makeRing(4, 5);
///

document {
     Key => {(getDivisors, ZZ), getDivisors},
     Headline => "takes an integer and outputs a list of all its divisors",
     Usage => "getDivisors c",
     Inputs => {"c"},
     Outputs => {{"A list of all the divisors of ", TT "c"}},
     }

TEST ///
  assert( makeStatesHelper( {0,4}, 5) == {1,0})
  assert(makeStatesHelper( {2,4}, 5) == {3,0})
  assert(makeStatesHelper( {0,2,1}, 5) == {0,2,2})
///

TEST ///

    n := 3 -- for now we work with 3 variable
    assert(makeStates (2,n) == {{0, 0, 0}, {0, 0, 1}, {0, 1, 0}, {0, 1, 1}, {1, 0, 0}, {1, 0, 1}, {1, 1, 0}, {1, 1, 1}})
    assert( makeStates( 3, 1) == {{0}, {1}, {2}} )
    assert( makeStates( 3, 2) == {{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 1}, {1, 2}, {2, 0}, {2, 1}, {2, 2}})

///

TEST ///

    QR = makeRing (3,2);    
    G := matrix(QR, {{x1+x3+x2, 1, x1*x3}})

///
    

TEST ///

     G = getDivisors 6;
     assert(G == {1,3,2,6})

///


TEST ///

    QR = makeRing (8,2);
     QR = makeRing(2,2);
     fxns = {x2,x1};
     assert(composeSystem(matrix{fxns},2)-matrix{ {x1,x2}}==0)

///

TEST ///

    QR = makeRing (8,2);
    assert( numgens QR == 8)
    QR = makeRing (8,5);
    assert( x1 != 0 )
    assert( x1*2 != 0 )
    assert( x1*3 != 0 )
    assert( x1*4 != 0 )
    assert( x1*5 == 0 )

     QR = makeRing(2,2);
     fxns = {x2,x1};
     assert(composeSystem(matrix{fxns},2)-matrix{ {x1,x2}}==0)

///

end

restart
installPackage "gbHelper"
check "gbHelper"
