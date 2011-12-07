
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


export {findControl, distance, makeControlRing, makeListOfAllStates,
findOptimalControl, minInHash, costOf}

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

-- take a final state, a list of previous states and a list of controls and
-- generate a list of the form {VS, U}
makeResultList = method()
makeResultList (List, HashTable, HashTable) := List => (finalState, previous, previousControl) -> (
  VS := { finalState };
  U := {};
  cost := 0;
  x := finalState;
  while  previous#?x do (
    u := previousControl#x;
    cost = cost + costOf u;
    x = previous#x;
    VS = {x} | VS;
    U = {u} | U;
  );
  VScopy = apply( #U, i -> VS_(i+1)); -- remove first element 
  scan(VScopy, U, (x, bestControl) -> (
    print( "Add state " | toString x | " to trajectory with control " | toString bestControl)
  ) );
  print ( "Found control sequence of cost " | toString cost );
  {VS, U}
)

-- compute all path from a to b and pick the optimal path
-- matrix F is the cPDS
-- List initialState
-- List finalState
-- List u, a vector of all possible controls to appply
findOptimalControl = method()
findOptimalControl (Matrix, List, List, List) := List => (F, initialState, finalState, u) -> ( 
  R = ring F;
  dist := new MutableHashTable; -- nodes and distance to initial state
  previous := new MutableHashTable; -- previous node to a node
  previousControl := new MutableHashTable; 
  initialState = apply(initialState, i -> i_R);
  finalState = apply(finalState, i -> i_R);
  Q := {};
  dist#initialState = 0;
  --print ("initial state " | toString initialState);
  maxNumberOfStates := (char R)^ (#initialState);
  while #Q < maxNumberOfStates do (
    x := first minInHash dist; 
    copyDist := copy dist;
    while( member(x, Q) ) do (
      remove(copyDist, x);
      if #copyDist == 0 then (
        print "Did not find a control sequence";
        --return makeResultList(finalState, previous, previousControl)
        return {{}}
      );
      x = first minInHash copyDist
    ); 
    if x == finalState then (
      --print "reached final state";
      return makeResultList(finalState, previous, previousControl)
    --) else (
    --  print ("picking " | toString x | " as first u");
    --  print (toString x |" != " | toString finalState)
    );
    Q = Q | {x};
    apply( u, ui -> (
      v := flatten entries sub( F, matrix( R, {flatten append(x, ui)}));
      --print ("neighbor of " | toString x | " is " | toString v);
      alt := dist#x + costOf ui;
      if not dist#?v or alt < dist#v then (
        --print ("setting distance of " | toString v | " to " | alt);
        dist#v = alt;
        previous#v = x;
        previousControl#v = ui
      )
    ))
  );
  print "Warning warning warning, this should never happen";
  return makeResultList(finalState, previous, previousControl)
)
      
-- u is the number of control variables, using all p^u controls
findOptimalControl (Matrix, List, List) := List => (F, initialState, finalState) -> ( 
  n := #initialState;
  u := numgens ring F - n;
  uu := makeListOfAllStates(u, char ring F);
  findOptimalControl(F, initialState, finalState, uu )
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
    mm := min apply( mins, (k,v) -> sum k);
    --mm := min apply( keys mins, k -> sum k);
    first select( mins, (k,v) -> sum k == mm)
    --first select( pairs mins, (k,v) -> sum k == mm)
  )
  else 
    first mins
)

-- make a list with all 2^n Boolean states
sub01 = (n) -> (
  if n === 0 then {{}}
  else (x := sub01 (n-1); set1 := apply(x, x -> prepend(0, x)); set2 := apply(x, x -> prepend(1, x)); join(set1,set2))
)

-- make a list with all p^n states
makeListOfAllStates = method()
makeListOfAllStates (ZZ,ZZ) := List => (n,p) -> (
  if n === 0 then {{}}
  else ( 
    x := makeListOfAllStates(n-1, p);
    setJoined := {};
    scan( 0..p-1, i-> (
      set1 := apply(x, x -> prepend(i, x));
      setJoined = join(  setJoined, set1)
    ) );
    setJoined
  )
)

-- find a control sequence for the system F and compute the trajectory
-- F a PDS
-- 
findControl = method()
findControl (Matrix, List, List, List) := List => (F, initialState, finalState, u) -> (
  R = ring F;
  n := numgens ring F;
  numberOfControls = (#first u);
  cost := 0;
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
    while ( potentialNewState := flatten entries sub( F, matrix( R, {flatten append(x, bestControl)}));
      member( potentialNewState, VS) ) do (
      remove( H, bestControl );
      if ( #H == 0 ) then ( -- the last element has been removed
        print "No control sequence found";
        return {}
      );
      bestControl = first minInHash H;
      --print ("Trying control ", bestControl, " to ", x )
    );
    x = potentialNewState;
    print( "Add state " | toString x | " to trajectory with control " | toString bestControl);
    cost = cost + costOf bestControl;
    VS = VS | {x} ; -- add state x to list of visited states
    U = U | {bestControl}
  );
  print ( "Found control sequence of cost " | toString cost );
  {VS, U}
)

findControl (Matrix, List, List) := List => (F, initialState, finalState) -> (
  n := #initialState;
  u := numgens ring F - n;
  uu := makeListOfAllStates (u, char ring F);
  findControl(F,initialState, finalState, uu)
)

-- compute the cost of a given control, assume uniform cost
costOf = method()
costOf List := ZZ => u -> (
  sum apply(u, ui-> lift(ui, ZZ)) 
)

beginDocumentation()

doc ///
Key
  Controller
Headline
  Find an optimal or heuristic controller for a controlled PDS
Description
  Text
    Find an optimal or heuristic controller for a controlled PDS
  Example
SeeAlso
///

doc ///
Key
  (findControl, Matrix, List, List, List) 
  (findControl, Matrix, List, List) 
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
    findControl( F, initialState, finalState) 
  Code
  Pre
Caveat
SeeAlso
  makeControlRing
  findOptimalControl
  distance
///

doc ///
Key
  (findOptimalControl, Matrix, List, List, List) 
  (findOptimalControl, Matrix, List, List) 
  findOptimalControl
Headline
  Find optimal control from initial to final state for system F
Usage
  findOptimalControl( F, initialState, finalState, u)
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
    Finds the optimal trajectory from the initial to the final state using
    Dijkstra algorithm
  Example
    R = makeControlRing( 4, 0, 2);
    F := matrix{ {x1+x2+x4, x1*x3, x2*x4} };
    u := {{0},{1}}; -- list of possible controls
    initialState := {1_R,1_R,1_R};
    finalState := {0_R,0_R,0_R};
    findOptimalControl( F, initialState, finalState, u)
    findOptimalControl( F, {1,1,0}, {0,0,1}, {{0}, {1}})
  Example
    R = makeControlRing( 2, 2, 2);
    F = matrix{ {x1+x2+u1, u2} };
    initialState = {0,0};
    finalState = {1,0};
    u = {{0,0}, {0,1}, {1,0},{1,1}}; -- list of possible controls
    findOptimalControl( F, initialState, finalState, u) 
  Code
  Pre
Caveat
SeeAlso
  findControl
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
  (makeListOfAllStates,ZZ,ZZ)
  makeListOfAllStates
Headline
  Return a list of all p^n states
Usage
  makeListOfAllStates(n,p)
Inputs
  n:ZZ
    number of variables
  p:ZZ
    characteristic of the ring
Outputs
  l:List
    list of all p^n states
Consequences
Description
  Example
    makeListOfAllStates(2,3)
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
  R = makeControlRing( 3, 1, 2)
  F := matrix{ {x1+x2+u1, x1*x3, x2*u1} }
  initialState := {1,0,1};
  finalState := {1,0,0};
  u := {{0},{1}}; -- list of possible controls
  assert( findOptimalControl(F, initialState, finalState, u) ==  {{{1, 0, 1},
  {1, 1, 0}, {0, 0, 0}, {1, 0, 0}}, {{0}, {0}, {1}}})
  assert( findOptimalControl(F, initialState, {0,0,0}, u) == {{{1, 0, 1}, {1,
  1, 0}, {0, 0, 0}}, {{0}, {0}}})
  findOptimalControl(F, initialState, {0,0,0}, u)
///

TEST /// -- more than 1 control variable
  R = makeControlRing( 2, 2, 2)
  F := matrix{ {x1+x2+u1, u2} }
  initialState := {0,0}
  finalState := {1,0}
  u := {{0,0}, {0,1}, {1,0},{1,1}}; -- list of possible controls
  assert( findOptimalControl( F, initialState, finalState ) == {{{0, 0}, {1, 0}}, {{1, 0}}} );
  assert( findOptimalControl( F, {1,1}, finalState ) == {{{1, 1}, {1, 0}}, {{1, 0}}} )
  u = {{0,0}, {0,1}}
  assert( findOptimalControl( F, {1,1}, finalState, u ) == {{{1, 1}, {0, 1}, {1, 0}}, {{0, 1}, {0, 0}}})
  assert( findOptimalControl( F, {1,1}, {1,1}, u ) == {{{1, 1}}, {}})

  u = makeListOfAllStates(2, 2);
  apply( makeListOfAllStates( 2,2 ), xi -> ( 
    assert( findOptimalControl(F, {0,0}, xi) == findOptimalControl(F, {0,0}, xi, u))
  ))
///

TEST /// -- more than 1 control variable
  R = makeControlRing( 2, 2, 2)
  F := matrix{ {x1+x2+u1, u2} }
  initialState := {0,0}
  finalState := {1,0}
  u := {{0,0}, {0,1}, {1,0},{1,1}}; -- list of possible controls
  assert( findControl( F, initialState, finalState, u) == {{{0, 0}, {1, 0}}, {{1, 0}}})
  assert( findControl( F, initialState, finalState ) == {{{0, 0}, {1, 0}}, {{1, 0}}})
///

TEST /// -- more than 1 control variable
  H := new MutableHashTable;
  H#{0,0,0} = 1;
  m := minInHash H;
  assert( m === ({0, 0, 0}, 1) );
  H#{0,1,1} = 0;
  m = minInHash H;
  assert( m === ({0,1,1},0));
  H#{0,0,1} = 0;
  m = minInHash H;
  assert( m === ({0,0,1},0));
  H#{1,0,1} = 2;
  m = minInHash H;
  assert( m === ({0,0,1},0));
///

TEST ///
  assert( makeListOfAllStates(1,3) ==  {{0}, {1}, {2}} )
  assert( makeListOfAllStates(2,2) == {{0, 0}, {0, 1}, {1, 0}, {1, 1}} )
  assert( makeListOfAllStates(3,2) == {{0, 0, 0}, {0, 0, 1}, {0, 1, 0}, {0, 1, 1}, {1, 0, 0}, {1, 0, 1}, {1, 1, 0}, {1, 1, 1}})
  assert( makeListOfAllStates(2,3) == {{0, 0}, {0, 1}, {0, 2}, {1, 0}, {1, 1}, {1, 2}, {2, 0}, {2, 1}, {2, 2}})
///

end
--

restart
installPackage "Controller"
check "Controller"
viewHelp Controller
