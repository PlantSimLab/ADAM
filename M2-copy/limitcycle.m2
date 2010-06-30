-- -*- coding: utf-8 -*-
load "randfunc.m2"

--installPackage "randfunc"
newPackage(
     "limitcycle",
     Version => "1.0",
     Date => "June 17, 2010",
     Authors => {
	  {Name => "Bonny Guang, Madison Brandon, Rustin McNeill, Franziska Hinkelmann" }},    
     Headline => "computes limit cycles and fixed points for dynamical systems of arbitrary size")

needsPackage "randfunc"

export{makeStates, nextState, fixedPoints, cycles, createSystemForCycles}
exportMutable {}
    

-- a state is a list of 0s and 1s in ZZ (not ZZ/2)

-- returns next binary state
nextBool = method()
nextBool List := List => state -> (
    lens := length state;
    assert(state != toList(lens:1)); --this is the last state
    --get position of the last digit that is 0 and replace with a 1
    pos := position(state, zero, Reverse=>true);
    state = replace(pos, 1, state);
    --make all spots after the replacement 0
   -- while (pos + 1) < n list state = replace(pos + 1, 0, state) do pos = pos + 1;
    scan( (pos+1..lens-1), i -> state = replace(i, 0, state) );
    state
)

--creates 2^n states
makeStates = method()
makeStates ZZ := List => n -> (
     state := toList(n:0);
     stateList := {state};     
     while state != toList(n:1)
         list (state = nextBool(state); stateList = append(stateList, state));
     stateList
     )

-- iterates a state by applying a sequence of functions, returns the resulting state
nextState = method()
nextState (List, VisibleList) := List => (state, system) -> (
     G0 := apply(system, p -> if p == 1 or p == 0 then p else sub(p, matrix{state}));

     ourRing := ring system_(position(system, i -> i != 1 and i != 0));
     G0 = toList apply( G0, i -> lift( i_(ourRing), ZZ))
    )

-- returns true if x is a fixed point
isFixedpoint = method()
isFixedpoint (List , Sequence) := Boolean => (x,G) -> (
     G0 := nextState(x, G);
--     stdio << "x is: " << x << " and nextState is: " << G0 << endl;
     all (length x,i->G0#i-x#i==0)
     )

-- checks all states if they are a fixed point 
-- returns list of fixed points
fixedPoints = G -> 
     select(makeStates (length G), x->isFixedpoint(x, G))

--return F^n
createSystemForCycles = method()
createSystemForCycles (ZZ, Sequence) := Sequence => (n, system) -> (
     --applies system to itself n times, aka gets f^n
     newSystem := system;
     for i from 1 to n when i != n list
     	 newSystem = apply(newSystem, p -> if p == 1 or zero p then p else sub(p, matrix{toList system}));
     newSystem
)

createSystemForCycles (ZZ, List) := Sequence => (n, system) -> 
    createSystemForCycles( n, toSequence system)


-- computes limit cycles of length n
-- currently does not work if there is a 1 or 0
cycles = (n, system) -> (
     newSystem := createSystemForCycles(n, system);
     --get limit cycles and remove actual fixed points
     cycleList := fixedPoints newSystem;

     -- TODO we should remove all divisors, but not fps from cycles of length 1
     if ( n != 1 ) then (
       print "remove fixedpoints";
       cycleList = select(cycleList, v -> not isFixedpoint(v,system) )
     );

     -- group n-cycles together
     -- first make n-tuples of corresponding cycles, then delete duplicate pairs
     unique apply( cycleList,
	  s ->  sort append(accumulate(nextState, prepend(s, toList(n-1:system))), s))
     )

beginDocumentation()
document {
     Key => limitcycle,
     Headline => "computes limit cycles and fixed points for dynamical systems of arbitrary size",
     EM "limitcycle",
        " computes limit cycles and fixed points for dynamical systems of arbitrary size"
	}
--document {
--     Key => makeStates,
--     Headline => ""
--    }

TEST ///

    n := 3 -- for now we work with 3 variable
    assert(makeStates n == {{0, 0, 0}, {0, 0, 1}, {0, 1, 0}, {0, 1, 1}, {1, 0, 0}, {1, 0, 1}, {1, 1, 0}, {1, 1, 1}})

    QR := booleanRing 3;    
    G := (x1+x3,x2+1,x1*x3) 
    assert(fixedPoints G === {}) 
    assert(cycles(1, G) === {}) 
    assert(cycles (2, G) === {{{0, 0, 0}, {0, 1, 0}}, {{1, 0, 0}, {1, 1, 0}}} ) 

    G = (x1+x3+x2, 1, x1*x3)
    assert( nextState( {0,1,1}, G) == {0, 1, 0} )
    assert( fixedPoints G == {{1, 1, 1}} )
    assert( cycles(1, G) == {{{1, 1, 1}}} )
    assert( cycles (2, G) == {{{0, 1, 0}, {1, 1, 0}}} )

    QR = booleanRing 4;
    G = (x1+x3, x2+1, x1*x3, x1*x4 + x3 + 1)
    assert( fixedPoints G == {} ) 
    assert( cycles (2, G) == {{{0, 0, 0, 1}, {0, 1, 0, 1}}, {{1, 0, 0, 0}, {1, 1, 0, 1}}, {{1, 0, 0, 1}, {1, 1, 0, 0}}} )
    
    -- this test takes a little longer, maybe a minute
    QR = booleanRing 10;
    use QR
    G = (x1+x3, x2+1, x1*x3, x1*x4 + x3 + 1, x9,x10+x1, x4+x5*x6+x7+1, x1, x5, x8+x1*x9)
    -- 8 2-cycles
    -- 8 4-cycles
    assert( fixedPoints G == {} )
    assert( cycles (2, G) == {{{0, 0, 0, 1, 0, 0, 0, 0, 0, 0}, {0, 1, 0, 1, 0, 0, 0, 0, 0, 0}}, 
      {{0, 0, 0, 1, 0, 0, 0, 0, 1, 0}, {0, 1, 0, 1, 1, 0, 0, 0, 0, 0}}, 
      {{0, 0, 0, 1, 0, 0, 1, 0, 0, 0}, {0, 1, 0, 1, 0, 0, 1, 0, 0, 0}}, 
      {{0, 0, 0, 1, 0, 0, 1, 0, 1, 0}, {0, 1, 0, 1, 1, 0, 1, 0, 0, 0}}, 
      {{0, 0, 0, 1, 1, 0, 0, 0, 0, 0}, {0, 1, 0, 1, 0, 0, 0, 0, 1, 0}}, 
      {{0, 0, 0, 1, 1, 0, 0, 0, 1, 0}, {0, 1, 0, 1, 1, 0, 0, 0, 1, 0}}, 
      {{0, 0, 0, 1, 1, 0, 1, 0, 0, 0}, {0, 1, 0, 1, 0, 0, 1, 0, 1, 0}}, 
      {{0, 0, 0, 1, 1, 0, 1, 0, 1, 0}, {0, 1, 0, 1, 1, 0, 1, 0, 1, 0}}} )

    QR = booleanRing 3;
    G = (1, x1*x3+x1+x2+x1*x2, 1+x3+x1*x2)
    assert( fixedPoints G == {{1, 1, 0}} )
    assert( cycles(1, G) == {{{1, 1, 0}}} )
    assert( cycles(2, G) == {} )
    assert( cycles(3, G) ==  {{{1, 0, 0}, {1, 0, 1}, {1, 1, 1}}} )
    assert( cycles(4, G) == {} )

    G = (x1+x3, x2+1,x1*x3) 
    assert( fixedPoints G == {} )
    assert( cycles(2, G) == {{{0, 0, 0}, {0, 1, 0}}, {{1, 0, 0}, {1, 1, 0}}} )
    assert( cycles(3, G) == {} )

  -- these tests show where the code still needs work
    -- assert( cycles(4, G) == {} )
  --  G = (1,1,0)
  --  assert( fixedPoints G == {{1,1,0}} )
  --  assert( all ( (2..4), i -> cycles(i, G) == {} ) )

///     

end

restart
loadPackage "limitcycle"
check "limitcycle"
installPackage "limitcycle"

    QR := booleanRing 3;    
    G = (x1+x3, x2+1,x1*x3) 
    cycles(2, G)
    cycles(3, G)
cycles(4, G)

G = (1, x1*x3+x1+x2+x1*x2, 1+x3+x1*x2)
fixedPoints G
cycles(2, G)
cycles(3, G)
cycles(4, G)

G = (0, x1+x2, 1+x3+x1*x2)
fixedPoints G
cycles(2, G)

restart
installPackage "limitcycle"
loadPackage "limitcycle"
check "limitcycle"
