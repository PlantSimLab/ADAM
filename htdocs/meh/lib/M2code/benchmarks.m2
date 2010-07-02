restart
loadPackage "testOptions3"
outfile := "benchmarkPowerOfF.txt";
fout := openOut outfile;
setOutFile outfile;
fout << "starting to write..." << endl;
fout << "Benchmark test for monomial networks" << endl << close;

--gbOptstrings = {Algorithm => Inhomogeneous, Algorithm => Sugarless, Strategy => LongPolynomial, Strategy => Sort, Strategy => UseSyzygies};

--testNetworks (Sequence, Sequence, ZZ, List) := (nint, valence, runs, gbOptstrings) -> (
--testNetworks( (3,5), (2,4), 1, gbOptstrings)
--testNetworks( (10, 20), (2,4), 20, gbOptstrings)

gbOptstrings := { Algorithm => Sugarless };
valence := (2,6);
--     valence := (10,15)   --to test high valence

scan( 50, i -> testPowerNetworks( (5,10), valence, (1, 5), gbOptstrings) );


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


