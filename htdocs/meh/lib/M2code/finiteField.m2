load "randfunc.m2"

newPackage(
     "finiteField"
     Version => "1.1",
     Date => "June 29, 2010",
     Authors => {
	  {Name => "Bonny Guang, Madison Brandon, Rustin McNeill, Franziska Hinkemann" }},
     Headline => "helper functions for solvebyGB and conjunctiveNetwork for finite field of prime characteristic")

needsPackage "randfunc"

export{makeStates,makeStateHelper}
exportMutable {}

--creates m^n states where m is the number of states of the object and n is the number of objects
makeStates = method()
makeStates (ZZ,ZZ) := List => (m,n) -> (
     state := toList(n:0);
     stateList := {state};     
     while state != toList(n:m)
         list (state = makeStateHelper(state); stateList = append(stateList, state));
     stateList
     )

-- returns next state
makeStateHelper = method()
makeStateHelper List := List => state -> (
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



end
