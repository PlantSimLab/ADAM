restart
loadPackage ("testOptions3",  Reload => true)
outfile := "benchmarkAverageInDegree.txt";
fout := openOut outfile;
setOutFile outfile;
fout << "starting to write..." << endl;
fout << "Benchmark test for networks that have average in-degree 1.5" << endl << close;
--testNetworks (Sequence, Sequence, ZZ, List) := (nint, valence, runs, gbOptstrings) -> (
gbOptstrings := { Algorithm => Sugarless };
--gbOptstrings = { Algorithm => Sugarless, Algorithm => Sugarless };
valence := (2,6);
valence = (2,2);
time scan( 100, i -> (testNetworks( (50,150), valence, gbOptstrings); print i) );



numvariables := { 10, 20, 30, 40, 50};
runs := {50, 10, 5, 5};
apply( length runs, i -> (
  scan( runs#i, j-> (
     nint := ( numvariables#i, numvariables#(i+1) ); 
     testPowerNetworks(nint, valence, (1, 3), gbOptstrings);
--     testNetworks(nint, valence, gbOptstrings);
--     testMonomialNetworks(nint, valence, runs#i, gbOptstrings);
  ) )
) )     


fout = openOutAppend outfile; 
fout << "done appending. closing file..." << endl << close;

end

restart
load "benchmarks.m2"
