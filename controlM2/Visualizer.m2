--load "Controller.m2"

newPackage(
    "Visualizer",
    Version => "0.1", 
    Date => "July, 8, 2010",
    Authors => {{Name => "Franziska Hinkelmann", 
    Email => "fhinkel@vt.edu", 
    HomePage => "http://www.math.vt.edu/people/fhinkel/"}, 
    {Name => "Reinhard Laubenbacher"}},
    Headline => "Visualize a network with different control inputs",
    PackageExports => {"Controller"},
    DebuggingMode => true
    )

--needsPackage "Controller"

export {generateTransitions, makeDotFile, visualizePhaseSpace, visualizeTrajectory }


-- generate the transitions for all states
-- return a hashtable T of the transitions
-- T{ a, b} = u
generateTransitions = method()
generateTransitions (Matrix, List) := MutableHashTable =>  (F, u) -> (
  T := new MutableHashTable; 
  --print ("The list of controls is " | toString u);
  -- key { {from}, {to} } a pair of two states
  -- value { {ui}, {uj} } a list of all controls
  R := ring F;
  n := numgens R - #(first u);
  assert (n<11);
  l := makeListOfAllStates (n, char R );
  scan( l, state -> (
    state = flatten entries matrix(R, {state});
    apply( u, ui -> (
      toState := flatten entries sub( F, matrix(R, { flatten append( state, ui)}));
      if T#?{state, toState} then 
        T # {state, toState} = T # {state, toState} |  {ui}
      else 
        T # {state, toState} = {ui}
    ) )
  ));
  --print peek T;
  T
)

-- generate trajectory from an initial state, applying the controls in the list u repeatedly 
-- matrix F: PDS
-- List initialState: {0,1,0,0...}
-- List u: list of controls that are being applied in order { {0,0}, {0,1}}
-- returns a list of all the nodes visited, starting with initialState, ending with the repeated state
generateTransitions (Matrix, List, List) := MutableHashTable =>  (F, initialState, u) -> (
  T := new MutableHashTable; 
  -- key { {from}, {to} } a pair of two states
  -- value { {ui}, {uj} } a list of all controls
  R := ring F;
  VS := new MutableList; -- states visited
  x := flatten entries matrix(R, {initialState});
  VS##VS = x;
  i := 0; -- iterator to go through list of controls
  toState := {};
  allControlsHaveBeenApplied := false;
  while ( toState = flatten entries sub( F, matrix(R, { flatten append( x, u#i)})); 
    not member( toState, toList VS) or not allControlsHaveBeenApplied) do (
    print (toString x | " -> " | toString toState );
    if T #?{x, toState} then
      T # {x, toState} = T # {x, toState} | u#i
    else
      T # {x, toState} = u#i;
    x = toState;
    VS##VS = x;  -- add visited state to list
    i = i + 1;
    if i == #u then (
      i = 0;
      allControlsHaveBeenApplied = true
    )
  );
  print (toString x | " -> " | toString toState );
  T # {x, toState} = u#i;
  VS##VS = toState;
  T 
)
    
-- visualize the control previously found 
-- F a controlled PDS, matrix
-- u all possible controls
-- a trajectory to highlight
visualizePhaseSpace = method()

visualizePhaseSpace( Matrix, List, List) := String => (F, u, traj) -> (
  n := numgens ring F - (# first u);
  assert( n < 11 );
  --print ( "The number of state variables is " | n );
  transitions := generateTransitions(F, u);
  s := makeDotFile( transitions, traj);
  print s;
  s
)

visualizePhaseSpace( Matrix, ZZ, List) := String => (F, u, traj) -> (
  uu := makeListOfAllStates(u, char ring F);
  visualizePhaseSpace(F, uu, traj)
)

visualizePhaseSpace( Matrix, ZZ) := String => (F, u) -> (
  uu := makeListOfAllStates(u, char ring F);
  visualizePhaseSpace(F, uu, {})
)

visualizePhaseSpace( Matrix, List) := String => (F, u) -> (
  visualizePhaseSpace(F, u, {})
)

visualizeTrajectory = method()
visualizeTrajectory (Matrix, List, List) := (F, initialState, u ) -> (
  T := generateTransitions(F, initialState, u);
  s := makeDotFile T;
  print s;
  s
)

-- print a list {a,b,c} as "abc" as needed in dotfile
-- used in the dot file to label nodes
printList = l -> (
  s := "";
  scan(l, i -> s = s | toString i);
  s
)

-- control sequence is a list of states
makeDotFile = method()
makeDotFile (MutableHashTable, List) := (T, controlSequence) -> ( 
  s := "digraph G {\n";
  if ( #controlSequence != 0 ) then (
    states := controlSequence;
    scan( states, ss -> (s = s | "\t" | printList ss | " [color=green, style=bold]\n")); 
    ss := apply( #states-1, i -> {states#i, states#(i+1)} )
  ) ;
  scan( pairs T, (k,v)  -> (
    fromS := first k;
    toS := last k;
    u := apply( v, ui -> printList ui); -- still a list
    attr := "[label=\"" ;
    scan( u, ui-> (attr = attr | "u=" | ui | "\\n") );
    attr = attr |  "\"" ;
    if (#controlSequence != 0 and member( k, ss ) ) then 
      attr = attr | ", color=green, style=bold";
    attr = attr |  "]" | "\n" ;

    s = s | "\t\"" | printList fromS | "\" -> \"" | printList toS | "\" " | attr | "\n" 
    )
  ); 
  s = s | "}\n"
)
-- make dot file for a trajectory from a HashTable
makeDotFile HashTable := T -> ( 
  s := "digraph G {\n";
  scan( pairs T, (k,v)  -> (
    fromS := first k;
    toS := last k;
    attr := "[label=\"u=" | printList v | "\"]\n" ;
    s = s | "\t\"" | printList fromS | "\" -> \"" | printList toS | "\" " | attr | "\n" 
    )
  ); 
  s = s | "}\n"
)

beginDocumentation()

doc ///
Key
  Visualizer 
Headline
  Visualize a controlled PDS
Description
  Text
    Visualizes the phase space of a controlled Polynomial Dynamical System. 
SeeAlso
  "Controller"
///



doc ///
Key
  (visualizeTrajectory, Matrix, List, List)
  visualizeTrajectory
Headline
  Visualize a trajectory
Usage
  visualizeTrajectory(F, initialState, u)
Inputs
  F:Matrix
    the controlled PDS
  initialState:List 
    an initial state
  u:List
    List of controls to be applied in order
Outputs
  l:String
    string of the content of a dot file of the trajectory
Consequences
Description
  Text
    This function generates the graph of a trajectory. The controls u are
    applied to the initial state and the following states, until all controls
    have been applied at least once and a steady state (either fixed point or
    limit cycle) are reached. 
  Example
    R = makeControlRing( 3, 2, 2)
    F := matrix{ {x1+x2+u1, u2+x1*x3, x2*u1} }
    initialState := {1_R,1_R,1_R}
    u := {{0,1},{1,1}}; -- list of possible controls
    s := visualizeTrajectory(F, initialState, u);
  Code
  Pre
Caveat
  The output needs to be translated into a dot file: 
  g = openOut "testfile.dot"
  g << s;
  close g;
  get "!dot -Tgif testfile.dot -o test.gif"
  get "! open test.gif"
SeeAlso
  visualizePhaseSpace
  findControl
  findOptimalControl
  makeDotFile
  generateTransitions
///
doc ///
Key
  (visualizePhaseSpace, Matrix, ZZ, List)
  (visualizePhaseSpace, Matrix, List, List)
  (visualizePhaseSpace, Matrix, List)
  (visualizePhaseSpace, Matrix, ZZ)
  visualizePhaseSpace
Headline
  Simulate the phase space and highlight the given control
Usage
  visualizePhaseSpace(F, u, traj)
Inputs
  F:Matrix
    the PDS
  u:ZZ
    number of control variables 
  traj:List
    a list of states to highlight
Outputs
  l:String
    string of the content of a dot file with the phase space and highlighted
    trajectory
Consequences
Description
  Text
    This function generates a graph of the complete phase space.  
    Since this function visualizes the whole ($2^p$ states) phase space, it is only feseable for small systems. 
    If traj is the empty list, then the phase space of the controlled PDS is
    generated without any highlighted trajectory. 
  Example
    R = makeControlRing( 3, 1, 2)
    F := matrix{ {x1+x2+u1, x1*x3, x2*u1} }
    initialState := {1_R,1_R,1_R}
    finalState := {0_R,0_R,0_R}
    u := {{0_R},{1_R}}; -- list of possible controls
    traj := first findControl(F, initialState, finalState, u);
    traj := first findOptimalControl(F, initialState, finalState, u);
    s := visualizePhaseSpace(F, 1, traj);
  Code
  Pre
Caveat
  The output needs to be translated into a dot file: 
  g = openOut "testfile.dot"
  g << s;
  close g;
  get "!dot -Tgif testfile.dot -o test.gif"
  get "! open test.gif"
SeeAlso
  visualizeTrajectory
  findControl
  findOptimalControl
  makeDotFile
  generateTransitions
///


TEST /// -- distance
///

TEST ///
R = makeControlRing( 3, 1, 2)
F := matrix{ {x1+x2+u1, x1*x3, x2*u1} }
u := {{0_R},{1_R}}; -- list of possible controls
generateTransitions( F, u)
///

TEST ///
R = makeControlRing( 3, 1, 2)
F := matrix{ {x1+x2+u1, x1*x3, x2*u1} }
u := {{0_R},{1_R}}; -- list of possible controls
initialState := {1_R,1_R,1_R}
finalState := {0_R,0_R,0_R}
traj = first  findControl(F, initialState, finalState, u);
s = visualizePhaseSpace(F, 1, traj)
g = openOut "testfile.dot"
g << s;
close g;
get "!dot -Tgif testfile.dot -o test.gif"
--get "! open test.gif"
///

TEST ///
R = makeControlRing( 3, 1, 2)
F := matrix{ {x1+x2+u1, x1*x3, x2*u1} }
u := {{0_R},{1_R}}; -- list of possible controls
s = visualizePhaseSpace(F, 1, {})
ss = visualizePhaseSpace(F, 1)
assert (ss == s)
g = openOut "testfile.dot"
g << s;
close g;
get "!dot -Tgif testfile.dot -o test.gif"
--get "! open test.gif"
///

TEST ///
  QR = makeControlRing(2, 2, 2);
  F =  matrix(QR, {{ x1+x2*u1, x2+u1}});
  F =  matrix {{ x1+x2*u1, x2+u1}};
  s = visualizePhaseSpace( F, 2)
  g = openOut "testfile.dot"
  g << s;
  close g;
  get "!dot -Tgif testfile.dot -o test.gif"
  --get "! open test.gif"
///

TEST ///
R = makeControlRing(2,2,2)
F := matrix{ {x1+x2+u1, u2 } }
s := visualizePhaseSpace( F, 2 )
u := {{0_R, 0},{0,1}, {1,0}, {1,1_R}}; -- list of possible controls
transitions = generateTransitions(F,u)
ss = makeDotFile (transitions, {} )
assert(ss == s)
g = openOut "testfile.dot"
g << s;
close g;
get "!dot -Tgif testfile.dot -o test.gif"
get "! cat testfile.dot" 
--get "! open test.gif"
///

TEST ///
R = makeControlRing(3,1,2)
F := matrix{ {x1+x2, x1*x3, x2} }
u := {{0_R},{1_R}}; -- list of possible controls
transitions = generateTransitions(F,u)
s = makeDotFile (transitions, {} )
g = openOut "testfile.dot"
g << s;
close g;
get "!dot -Tgif testfile.dot -o test.gif"
get "! cat testfile.dot" 
--get "! open test.gif"
///

TEST ///
R = makeControlRing( 3, 1, 2)
F := matrix{ {x1+x2+u1, x1*x3, x2*u1} }
initialState := {1_R,1_R,1_R}
finalState := {0_R,0_R,0_R}
u := {{0_R},{1_R}}; -- list of possible controls
traj = first findControl(F, initialState, finalState, u);
s = visualizePhaseSpace(F, 1, traj)
g = openOut "testfile.dot"
g << s;
close g;
get "!dot -Tgif testfile.dot -o test.gif"
--get "! open test.gif"
///

TEST ///
R = makeControlRing( 3, 1, 2)
F := matrix{ {x1+x2+u1, x1*x3, x2*u1} }
initialState := {1_R,1_R,1_R}
finalState := {0_R,0_R,0_R}
u := {{0_R},{1_R}}; -- list of possible controls
traj = first findOptimalControl(F, initialState, finalState, u);
s = visualizePhaseSpace(F, 1, traj)
g = openOut "testfile.dot"
g << s;
close g;
get "!dot -Tgif testfile.dot -o test.gif"
--get "! open test.gif"
///

TEST ///
R = makeControlRing( 3, 1, 2)
F := matrix{ {x1+x2, x1*x3, x2} }
initialState := {1_R,1_R,1_R}
finalState := {0_R,0_R,0_R}
u := {{0_R},{1_R}}; -- list of possible controls
controlSequence = findControl(F, initialState, finalState, u)
s = visualizePhaseSpace(F, 1, first controlSequence)
g = openOut "testfile.dot"
g << s;
close g;
--get "!dot -Tgif testfile.dot -o test.gif"
///

TEST ///
  i=4;
  R = makeControlRing( 4, 2, 2);
  F := matrix{ {x1+x2+u1, u2+ x1*x3, x2*u1, x1+u1+u2} };
  initialState := {0,0,1_R,1};
  finalState := {1,0,1,0};
  u := makeListOfAllStates(2,char R); 
  traj = first findControl(F, initialState, finalState, u);
  s = visualizePhaseSpace(F, 2, traj);
  g = openOut ("testfile"|i|".dot");
  g << s;
  close g;
  get ("!dot -Tgif testfile"|i|".dot -o test"|i|".gif");
  --get ("!open test"|i|".gif");
///

TEST ///
  i=5;
  R = makeControlRing( 4, 2, 2);
  F := matrix{ {x1+x2+u1, u2+ x1*x3, x2*u1, x1+u1+u2} };
  initialState := {0,0,1_R,1};
  finalState := {1,0,1,0};
  u := makeListOfAllStates(2,char R); 
  traj = first findOptimalControl(F, initialState, finalState, u);
  traj = first findOptimalControl(F, initialState, finalState);
  s = visualizePhaseSpace(F, 2, traj);
  g = openOut ("testfile"|i|".dot");
  g << s;
  close g;
  get ("!dot -Tgif testfile"|i|".dot -o test"|i|".gif");
  --get ("!open test"|i|".gif");
///

TEST ///
  R = makeControlRing( 4, 2, 2);
  F := matrix{ {x1+x2+u1, u2+ x1*x3, x2*u1, x1+u1+u2} };
  initialState := {0,0,1,1};
  u := {{0,0}, {0,1}};
  s = visualizeTrajectory(F, initialState, u);
  g = openOut ("testfile.dot");
  g << s;
  close g;
  get ("!dot -Tgif testfile.dot -o test.gif");
  --get ("!open test.gif");
///

TEST ///
  R = makeControlRing( 2, 1, 5);
  F := matrix{ {x1+x2+u1, u1+x1}};
  initialState := {1,1};
  u := {{1}, {0}};
  s = visualizeTrajectory(F, initialState, u);
  g = openOut ("testfile.dot");
  g << s;
  close g;
  get ("!dot -Tgif testfile.dot -o test.gif");
  --get ("!open test.gif");
///

TEST ///
  R = makeControlRing( 4, 2, 2);
  F := matrix{ {x1 + x2 + u1, 
    u2 + x1 * x3,
    x2 * u1, 
    x1 + u1 + u2}};
  initialState := {1,0,1,1};
  u := {{0, 0}, {1, 0}, {0, 0}, {1, 1}};
  s = visualizeTrajectory(F, initialState, u);
  g = openOut ("testfile.dot");
  g << s;
  close g;
  get ("!dot -Tgif testfile.dot -o test.gif");
  --get ("!open test.gif");
///

TEST ///
  R = makeControlRing( 4, 2, 2);
  F := matrix{ {x1+x2+u1, u2+ x1*x3, x2*u1, x1+u1+u2} };
  generateTransitions(F, {0,0,0,0}, { {0,0}})
  generateTransitions(F, {1,1,1,1}, {{0,0}})
  generateTransitions(F, {1,1,1,1}, {{0,0}, {1,0}})
///

--
end

restart
installPackage "Visualizer"
check "Visualizer"


restart
installPackage ("Visualizer", DebuggingMode => true)
  QR = makeControlRing(2, 2, 2);
  F =  matrix(QR, {{ x1+x2*u1, x2+u1}});
  F =  matrix {{ x1+x2*u1, x2+u1}};
  s = visualizePhaseSpace( F, 2);
  g = openOut "testfile.dot"
  g << s;
  close g;
  get "!dot -Tgif testfile.dot -o test.gif"
  get "! open test.gif"
