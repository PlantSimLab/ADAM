
newPackage(
    "Controller",
    Version => "0.9", 
    Date => "July, 7, 2010",
    Authors => {{Name => "Franziska Hinkelmann", 
    Email => "fhinkel@vt.edu", 
    HomePage => "http://www.math.vt.edu/people/fhinkel/"}, 
    {Name => "Reinhard Laubenbacher"}},
    Headline => "Find a heuristic controller for a controlled PDS",
    DebuggingMode => true
    )


export {findControl, distance, makeControlRing}

-- make a ring quotient ring with characteristic p with n+m variables 
-- x1, .., xn, u1, ..., um
makeControlRing = method()
makeControlRing (ZZ,ZZ,ZZ) := QuotientRing => (n,m,p) -> (
  lx := apply( (1..n), i -> value( "x"| toString i) );
  lu := apply( (1..m), i -> value( "u"| toString i) );
  R1 := ZZ/p[lx|lu];
  L := ideal apply(gens R1, x-> x^p-x);
  R1/L
)


-- compute Hamming distance between two lists
distance = method() 
distance (List,List) := ZZ => (x,y) -> (
  scan( (x,y),  i -> assert( class i === List ) );
  assert( length x == length y );
  sum( apply( x,y, (xi, yi) -> abs( lift(xi, ZZ) - lift(yi, ZZ) ) ) )
)

-- get the element in a hash table, that has minimum value
minInHash = (H) -> (
  assert( #H > 0 );
  m := min values H;
  mins := select( pairs H, (k,v) -> v == m );
  if #mins > 1 then (
    mm := min apply( keys H, k -> sum k);
    first select( pairs H, (k,v) -> sum k == mm)
  )
  else 
    first mins
)

-- make a list with all 2^n Boolean states
sub01 = (n) -> (
  if n === 0 then {{}}
  else (x := sub01 (n-1); set1 := apply(x, x -> prepend(0, x)); set2 := apply(x, x -> prepend(1, x)); join(set1,set2))
)

-- find a control sequence for the system F and compute the trajectory
-- F a PDS
-- 
findControl = method()
findControl (Matrix, List, List, List)  :=  List => (F, initialState, finalState, u) -> (
  R = ring F;
  n := numgens ring F;
  numberOfControls = (#first u);
  l := sub01( n - numberOfControls ); 

  U := {};
  VS := {initialState};
  x := initialState;
  H := new MutableHashTable;
  while ( x != finalState ) do (
    H = new MutableHashTable;
    x1 = apply( u, ui ->  flatten entries sub( F, matrix(R, { flatten append( x, ui)})));
    apply( u , x1, (ui,x) -> H#ui = distance( finalState, x) );
    bestControl = first minInHash H;
    --print ("Trying control ", bestControl, " to ", x ); 
    while ( potentialNewState := flatten entries sub( F, matrix( R, {flatten append(x, bestControl)})); any( VS, i -> i == potentialNewState )  ) do (
      remove( H, bestControl );
      if ( #H == 0 ) then ( -- the last element has been removed
        print "No control sequence found";
        return {}
      );
      bestControl = first minInHash H;
      --print ("Trying control ", bestControl, " to ", x )
    );
    x = potentialNewState;
    --print( "## add state ", x, " to trajectory with control ", bestControl);
    VS = VS | {x} ; -- add state x to list of visited states
    U = U | {bestControl}
  );
  {VS, U}
)


beginDocumentation()

doc ///
Key
  Controller
Headline
  Find a heuristic controller for a controlled PDS
Description
  Text
    Find a controller
  Example
Caveat
  Not working yet
SeeAlso
///

doc ///
Key
  (findControl, Matrix, List, List, List) 
  findControl
Headline
  Find control from initial to final state for system F
Usage
  findControl( F, initialState, finalState, u)
Inputs
  F:Matrix
    the system, a PDS
  initialState:List 
    an initial state
  finalState:List
    admissible final state
  u:List
    List of possible controls represented as lists
Outputs
  l:List
    the states visited in the trajectory and the applied control
Consequences
Description
  Text
    This is a heuristic optimal controller. It tries to find 
    the optimal control from an initial state to a final state. This is done
    with the following algorithm: 
    First, for $x = x_0$, all controls are applied, then the control that
    results in the state closest to $x_f$ is picked. Close means close in the
    sense of the @TO distance@ functions. If multiple states are equally
    close, then the cheapest control is being chosen. This is repeated for $x
    = F(x,u)$, until either the final state is reached, or the controller has
    tried all outgoing path from a state and did not find an admissible
    control sequence. 

    If the closest state is a state, that has already been visited, this state
    is not picked (it would results in an infinite loop through the state
    space). @TO findControl@ returns and empty list, if it ever reaches a
    state, such that all its neighbors have been visited. 
  Example
    loadPackage "randfunc";
    R = booleanRing 4;
    F := matrix{ {a+b+d, a*c, b*d} };
    u := {{0_R},{1_R}}; -- list of possible controls
    initialState := {1_R,1_R,1_R};
    finalState := {0_R,0_R,0_R};
    findControl( F, initialState, finalState, u)
    findControl( F, {1,1,0}, {0,0,1}, {{0}, {1}})
  Example
    R = makeControlRing( 2, 2, 2);
    F = matrix{ {x1+x2+u1, u2} };
    initialState = {0,0};
    finalState = {1,0};
    u = {{0,0}, {0,1}, {1,0},{1,1}}; -- list of possible controls
    findControl( F, initialState, finalState, u) 
  Code
  Pre
Caveat
SeeAlso
  makeControlRing
  distance
///

doc ///
Key
  (makeControlRing, ZZ, ZZ, ZZ) 
  makeControlRing
Headline
  Generate Ring with state and control variables
Usage
  makeControlRing( 5, 3, 2)
Inputs
  n:ZZ
    number of state variables
  m:ZZ
    number of control variables
  p:ZZ
    characteristic p (prime number)
Outputs
  R:QuotientRing
Consequences
Description
  Text
    Generates the polynomial ring $\mathbb F_p$ with the variables $x_1, \ldots, x_n$ 
    and the control variables $u_1, \ldots, u_m$. The ring has characteristic $p$ and we mod out by the field polynomials. 
  Example
    R = makeControlRing( 4, 2, 2);
    describe R
  Code
  Pre
Caveat
SeeAlso
  findControl
///


doc ///
Key
  (distance, List, List) 
  distance
Headline
  Compuate the distance between two states
Usage
  distance( x,y )
Inputs
  x:List 
    a state
  y:List 
    another state
Outputs
  d:ZZ
    the distance between x and y
Consequences
Description
  Text
    This function computes the Hamming distance between two states. 
  Example
    loadPackage "randfunc";
    R = booleanRing 4;
    x = {1,0,0,1};
    y = {0,1,0,1};
    distance(x,y)
  Code
  Pre
Caveat
SeeAlso
  findControl
///

TEST /// -- distance
    loadPackage "randfunc";
    R = booleanRing 4;
    x = {1,0,0,1};
    y = {0,1,0,1};
    assert( distance(x,y) == 2 );
    assert( distance({0,0,0,0}, {1,1,1,1} ) == 4  )
    assert( distance({0,0,0,0}, {0,0,0,0} ) == 0  )
    assert( distance({1,1,1,1}, {1,1,1,1} ) == 0  )
    assert( distance({0,0,0,0}, {0,0,0,1} ) == 1  )
    assert( distance({0,0,0,0}, {0,0,0,1} ) == 1  )
///

TEST /// -- findControl
    loadPackage "randfunc";
    R = booleanRing 4;
    F := matrix{ {a+b+d, a*c, b*d} };
    u := {{0_R},{1_R}}; -- list of possible controls
    initialState := {1_R,1_R,1_R};
    finalState := {0_R,0_R,0_R};
    assert( findControl( F, initialState, finalState, u) == {{{1, 1, 1}, {0, 1, 0}, {1, 0, 0}, {0, 0, 0}}, {{0}, {0}, {1}}} ) 
    initialState = {1_R,1_R,0_R}
    finalState = {0_R,0_R,1_R}
    assert( findControl( F, initialState, finalState, u) == {} )
    assert( findControl( F, {1,1,0}, {0,0,1}, {{0}, {1}}) == {} )
///

TEST /// -- more than 1 control variable
  R = makeControlRing( 3, 1, 2)
  F := matrix{ {x1+x2+u1, x1*x3, x2*u1} }
  initialState := {1_R,1_R,1_R}
  finalState := {0_R,0_R,0_R}
  u := {{0_R},{1_R}}; -- list of possible controls
  assert( findControl( F, initialState, finalState, u) == {{{1, 1, 1}, {0, 1, 0}, {1, 0, 0}, {0, 0, 0}}, {{0}, {0}, {1}}} )
///

TEST /// -- more than 1 control variable
  R = makeControlRing( 2, 2, 2)
  F := matrix{ {x1+x2+u1, u2} }
  initialState := {0,0}
  finalState := {1,0}
  u := {{0,0}, {0,1}, {1,0},{1,1}}; -- list of possible controls
  assert( findControl( F, initialState, finalState, u) == {{{0, 0}, {1, 0}}, {{1, 0}}})

///

end
--

restart
loadPackage "randfunc"
installPackage "Controller"
check "Controller"
R = makeControlRing( 3, 1, 2)
F := matrix{ {x1+x2+u1, x1*x3, x2*x1} }
initialState := {1_R,1_R,1_R}
finalState := {0_R,0_R,0_R}
u := {{0_R},{1_R}}; -- list of possible controls
findControl( F, initialState, finalState, u)
findControl( F, {1,1,1}, {0,0,0}, u)
findControl( F, {1,1,0}, {0,0,1}, u)
initialState := {1_R,1_R,0_R}
finalState := {0_R,0_R,1_R}
findControl( F, initialState, finalState, u)
viewHelp findControl
