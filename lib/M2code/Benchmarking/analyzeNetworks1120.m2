--finds cycles of length 11-20 for files that the 1-10 cycles have been found
load "convertToPDS.m2"
needsPackage "solvebyGB"
files := {"GinSimFiles/TCRsig40.ginml", "GinSimFiles/ThBoolean.ginml", "GinSimFiles/ap-1_else-0_wt.ginml", "GinSimFiles/arabidopsis.ginml", 
           "GinSimFiles/gapA.ginml", "GinSimFiles/gapB.ginml", "GinSimFiles/gapC.ginml", "GinSimFiles/gapD.ginml", "GinSimFiles/phage2.ginml",
	    "GinSimFiles/phage4.ginml", "GinSimFiles/trpEcoli.ginml", "GinSimFiles/yeastLiModified.ginml", "GinSimFiles/yeastMCP.ginml", "GinSimFiles/yeastOrlando.ginml"}

g := openOut "longResults1120.txt"
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
 

    scan( 11..20, i -> (
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
