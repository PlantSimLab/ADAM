--Finds cycles of length 2-10 for the files that only have fixed points so far
load "convertToPDS.m2"
needsPackage "solvebyGB"
files := {"GinSimFiles/APBoundary.ginml", "GinSimFiles/SP1.ginml", "GinSimFiles/SP6.ginml", "GinSimFiles/THDifferentiation.ginml", 
           "GinSimFiles/Th_17.ginml", "GinSimFiles/boolean_cell_cycle.ginml", "GinSimFiles/drosophila.ginml", "GinSimFiles/erbb2.ginml", "GinSimFiles/pairRule.ginml",
	    "GinSimFiles/yeastIrons.ginml", "GinSimFiles/yeastLi.ginml", "GinSimFiles/dv_boundary_wing_disk_model.ginml"}

g := openOut "Results210.txt"
-- prints header row in excel sheet
g << "Filename\tNumber of Nodes\tNumber of States\tNumber of FP\tFPs\tRuntime FP\t Number of 2\t2 cycles\tRuntime 2cycle\t Number of 3\t3 cycles\tRuntime 3cycle\t Number of 4\t4 cycles\tRuntime 4cycle\t URL\n

";

scan( files, f-> (
  print f;
  g << f;
  g << "\t";
  (geneList, F) := converter f;
  R = ring F;
  n := numgens R;
  g << n;
  g << "\t";
  
  p := char R;
  g << p;
  g << "\t";

  print( "Number of states for each gene (p-value): " | p );
  print( "Number of nodes: " | n);
 

    scan( 2..10, i -> (
      print ("cycles of length " | toString i);
      tt := timing gbSolver(F, i);
      mytime := first tt;
      solutions := last tt;
      print ("Number of "| toString i | " cycles is " | toString (#solutions));
      print solutions;
      g << #solutions;
      g << "\t";
      g << toString solutions;
      g << "\t";
      g << mytime;
      g << "\t"
    ));
    g << "\n"
))



end
restart
load "analyzeNetworks.m2"
get "!cat results.txt"
