load "Controller.m2"

newPackage(
    "Visualizer",
    Version => "0.1", 
    Date => "July, 8, 2010",
    Authors => {{Name => "Franziska Hinkelmann", 
    Email => "fhinkel@vt.edu", 
    HomePage => "http://www.math.vt.edu/people/fhinkel/"}, 
    {Name => "Reinhard Laubenbacher"}},
    Headline => "Visualize a network with different control inputs", 
    DebuggingMode => true
    )

needsPackage "Controller"

export {generateTransitions, makeDotFile, sub01, visualizeControl }


-- generate the dotfile representing the phase space
generateTransitions = method()
generateTransitions (Matrix, List) := MutableHashTable =>  (F, u) -> (
  T := new MutableHashTable; 
  -- key { {from}, {to} } a pair of two states
  -- value { {ui}, {uj} } a list of all controls
  R = ring F;
  n := numgens R;
  assert( n < 11 );
  l := sub01 (n - #(first u) );
  scan( l, state -> apply( u, ui -> (
    toState := flatten entries sub( F, matrix(R, { flatten append( state, ui)}));
    if T#?{state,toState} then 
      T # {state, toState} = T # {state, toState} |  ui
    else 
      T # {state, toState} = {ui}
    )
  ));
  T
)



-- visualize the Control found with the algorithm 
-- F a controlled PDS, matrix
-- u all possible controls
-- initial and final state
visualizeControl = method()
visualizeControl( Matrix, ZZ, List)  := (F, u, traj)   -> (
  uu := sub01 u;
  if ( traj != {} ) then (
    assert( #traj == 2 );
    initialState := first traj;
    finalState := last traj;
    traj = findControl(F, initialState, finalState, uu);
  ); 
  transitions := generateTransitions(F, uu);
  s = makeDotFile( transitions, traj);
  print s
)


-- print a list {a,b,c} as "abc"
-- used in the dot file to label nodes
printList = l -> (
  s := "";
  scan(l, i -> s = s | toString i);
  s
)

makeDotFile = method()
makeDotFile (MutableHashTable, List) := (T, controlSequence) -> ( 
  s := "digraph G {\n";
  if ( #controlSequence != 0 ) then (
    states := first controlSequence;
    scan( states, ss -> (s = s | "\t" | printList ss | " [color=green, style=bold]\n")); 
    ss := apply( #states-1, i -> {states#i, states#(i+1)} );
    controls := last controlSequence
  ) ;
  scan( pairs T, (k,v)  -> (
    fromS := first k;
    toS := last k;
    u = apply( v, ui -> printList ui); -- still a list
    attr := "[label=\"" ;
    scan( u, ui-> (attr = attr | "u=" | ui | "\\n") );
    attr = attr |  "\"" ;
    if (#controlSequence != 0 and any( ss, s -> k == s ) ) then 
      attr = attr | ", color=green, style=bold";
    attr = attr |  "]" | "\n" ;

    s = s | "\t" | printList fromS | " -> " | printList toS | " " | attr | "\n" 
    --s = s | "\t" | printList fromS | " -> " | printList toS | "[label=\"u=" | printList u | "\"]" | "\n" 
    )
  ); 
  s = s | "}\n"
)

-- make a list with all 2^n Boolean states
sub01 = (n) -> (
  if n === 0 then {{}}
  else (x := sub01 (n-1); set1 := apply(x, x -> prepend(0, x)); set2 := apply(x, x -> prepend(1, x)); join(set1,set2))
)

beginDocumentation()

doc ///
Key
  Visualizer 
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
  (visualizeControl, Matrix, ZZ, List)
  visualizeControl
Headline
  Simulate the phase space and highlight the control
Usage
  visualizeControl(F, u, traj)
Inputs
  F:Matrix
    the PDS
  u:ZZ
    number of control variables 
  traj:List
    list of an initial and a final state
Outputs
  l:String
    string of the content of a dot file with the phase space and highlighted control
Consequences
Description
  Text
    This function calls findControl to find a good control sequence that drives the system
    from the initial state to the final state. A graph of the complete phase space is generated. 
    Since this function visualizes the whole ($2^p$ states) phase space, it is only feseable for small systems. 
    If traj is the empty list, then the phase space of the controlled PDS is generated without any highlighted trajectory. 
  Example
    2+2;
    R = makeControlRing( 3, 1, 2)
    F := matrix{ {x1+x2+u1, x1*x3, x2*u1} }
    initialState := {1_R,1_R,1_R}
    finalState := {0_R,0_R,0_R}
    u := {{0_R},{1_R}}; -- list of possible controls
    s := visualizeControl(F, 1, {initialState, finalState})
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
  findControl
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
s = visualizeControl(F, 1, {initialState, finalState})
g = openOut "testfile.dot"
g << s;
close g;
get "!dot -Tgif testfile.dot -o test.gif"
--get "! open test.gif"
///

TEST ///
R = makeControlRing(2,2,2)
F := matrix{ {x1+x2+u1, u2 } }
u := {{0_R, 0},{0,1}, {1,0}, {1,1_R}}; -- list of possible controls
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
///

TEST ///
R = makeControlRing( 3, 1, 2)
F := matrix{ {x1+x2+u1, x1*x3, x2*u1} }
initialState := {1_R,1_R,1_R}
finalState := {0_R,0_R,0_R}
u := {{0_R},{1_R}}; -- list of possible controls
s = visualizeControl(F, 1,{ initialState, finalState})
g = openOut "testfile.dot"
g << s;
close g;
get "!dot -Tgif testfile.dot -o test.gif"
///

TEST ///
R = makeControlRing( 3, 1, 2)
F := matrix{ {x1+x2, x1*x3, x2} }
initialState := {1_R,1_R,1_R}
finalState := {0_R,0_R,0_R}
u := {{0_R},{1_R}}; -- list of possible controls
controlSequence = findControl(F, initialState, finalState, u)
s = visualizeControl(F, 1, {initialState, finalState})
g = openOut "testfile.dot"
g << s;
close g;
get "!dot -Tgif testfile.dot -o test.gif"
///

TEST ///
  i=4;
  R = makeControlRing( 4, 2, 2);
  F := matrix{ {x1+x2+u1, u2+ x1*x3, x2*u1, x1+u1+u2} };
  initialState := {0,0,1_R,1};
  finalState := {1,0,1,0};
  u := sub01 2; 
  findControl(F, initialState, finalState, u);
  s = visualizeControl(F, 2, {initialState, finalState});
  g = openOut ("testfile"|i|".dot");
  g << s;
  close g;
  get ("!dot -Tgif testfile"|i|".dot -o test"|i|".gif");
  get ("!open test"|i|".gif");
///

--
end

restart
loadPackage "Visualizer"
installPackage ("Visualizer", DebuggingMode => true)
check "Visualizer"

restart
installPackage ("Visualizer", DebuggingMode => true)
  R = makeControlRing( 4, 2, 2);
  F := matrix{ {x1+x2+u1, u2+ x1*x3, x2*u1, x1+u1+u2} };
  visualizeControl( F, 2, {})
  visualizeControl( F, 2, {{1,1,1,1},{0,1,1,1}})
