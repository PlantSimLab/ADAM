-- -*- coding: utf-8 -*-
--load "randfunc.m2"
--load "gbHelper.m2"

newPackage(
     "testOptions3",
     Version => "1.0",
     Date => "June 17, 2010",
     Authors => {
	  {Name => "Bonny Guang, Madison Brandon, Rustin McNeill, Franziska Hinkelmann" }},    
     Headline => "Run and time different Groebner basis algorithms to generate benachmarks")

needsPackage "randfunc"
needsPackage "gbHelper"

export{ getGB, getGBBoolean, setOutFile, testNetworks, testMonomialNetworks, testPowerNetworks}
exportMutable {}

-- use this as default output file
outfile = "testOutput.txt"

-- overwrite default output file
setOutFile = method()
setOutFile String := f -> outfile = f

-- compute groebner basis for F with all different algorithms in Optstrings
getGB = method()
getGB( List, List) := (F, gbOptstrings) -> (
    basesList := {};
    apply( gbOptstrings, opt -> ( 
      fout := openOutAppend outfile;
      fout << "running getGB on F with option " << opt << endl;
      t1 := cpuTime();
      G := flatten entries gens gb (ideal F, opt);
      t2 := cpuTime();
      T := (t2-t1)/60;
      fout << "Groebner basis is: " << endl << G << endl << "Cpu time: " << T << " minutes" << endl;
      fout << close;
      basesList = append(basesList, G);
    ));
    basesList
)

-- compute groebner basis for F using gbBoolean (available when M2 is build from source 
getGBBoolean = method()
getGBBoolean List := F -> (
    basesList := {};
    fout := openOutAppend outfile;
    fout << "running getGBBoolean on F" << endl;
    t1 := cpuTime();
    G := gens gb ideal F;
    --G := gbBoolean ideal F;
    t2 := cpuTime();
    T := (t2-t1)/60;
    fout << "Groebner basis is: " << endl << G << endl << "Cpu time: " << T << " minutes" << endl;
    fout << close;
    basesList = append(basesList, G);
    basesList
)

-- compute basis for a bunch of random networks
-- nint: lower and upper bound for number of variables 
-- valence: lower and upper bound of number of variables per functions
-- gbOptstrings: List of options for gb
testNetworks = method ()
testNetworks (Sequence, Sequence, List) := (nint, valence, gbOptstrings) -> (
    assert( length nint == 2 );
    assert( length valence == 2 );
    n := random nint; 
    valence = (first valence, min(last valence, n)); 
    v := random valence;
    QR := makeRing( n,2);
    nterms := 1 + random(10);
    nterms = min(nterms, n^v);
--      nterms = max(1,random(n^v));    --to test with a lot of terms
    F := makeBooleanNetwork( QR, v, nterms);

    fout := openOutAppend outfile;
    fout << endl;
    fout << "number of variables = " << n << endl;
    fout << "number of terms = " << nterms << endl;
    fout << "max number of variables per term = " << v << endl;
    fout << "random functions generated are: " << endl << toString flatten entries F << endl << close;
    --fout << "random functions generated are: " << endl << F << endl << close;
        
    F = apply( flatten entries F, gens QR, (f,x) -> f - x );
    getGB ( F, gbOptstrings);
--      getGBBoolean F;
)

-- compute basis for a bunch of random networks
-- nint: lower and upper bound for number of variables 
-- valence: lower and upper bound of number of variables per functions
-- powers: take network to these powers, Sequence( ZZ, ZZ )
-- gbOptstrings: List of options for gb
testPowerNetworks = method ()
testPowerNetworks (Sequence, Sequence, Sequence, List) := (nint, valence, powers, gbOptstrings) -> (
    assert( length nint == 2 );
    assert( length valence == 2 );
    assert( length powers == 2 );
    n := random nint; 
    valence = (first valence, min(last valence, n)); 
    --v := random valence;
    v := first random {2,3,2,2,3,2,2}; -- ugly hack to get 1.66 
    QR := makeRing( n, 2);
    nterms := 1 + random(10);
    nterms = min(nterms, n^v);
--      nterms = max(1,random(n^v));    --to test with a lot of terms
    F := makeBooleanNetwork( QR, v, nterms);

    fout := openOutAppend outfile;
    fout << endl;
    fout << "number of variables = " << n << endl;
    fout << "number of terms = " << nterms << endl;
    fout << "max number of variables per term = " << v << endl;
    fout << "random functions generated are: " << endl << flatten entries F << endl << close;
    
    scan( first powers .. last powers, p -> (
      fout = openOutAppend outfile;
      fout << "States of periodicity " << p << endl;
      fout << close;
      FF := composeSystem(F, p);
      FF = apply( flatten entries FF, gens QR, (f,x) -> f - x );
      fout = openOutAppend outfile;
      fout << "Solve the system " << FF << endl;
      fout << close;
      getGB (FF, gbOptstrings);
    ))
)

testMonomialNetworks = method ()
testMonomialNetworks (Sequence, Sequence, ZZ, List) := (nint, valence, runs, gbOptstrings) -> (
    apply( runs, i -> (
      assert( length nint == 2 );
      assert( length valence == 2 );
      n := random nint; 
      valence = (first valence, min(last valence, n)); 
      v := random valence;
      QR := makeRing( n, 2);
      F := makeMonomialNetwork( QR, v);

      fout := openOutAppend outfile;
      fout << endl;
      fout << "number of variables = " << n << endl;
      fout << "number of terms = 1" << endl;
      fout << "max number of variables per term = " << v << endl;
      fout << "random functions generated are: " << endl << F << endl << close;

--     k := 0;  -- f^2
--     k := 3;  -- f^5
--     k := 8;  -- f^10
     -- solve a system of the form (f_i)^(k+2) = x_i
--     for i to k do  (
--          F = apply(F, p -> sub(p, matrix{toList(F)}));
--     )	   
      
      -- solve a system of the form f_i = x_i
      F = apply( F, gens QR, (f,x) -> f - x );
      getGB (flatten entries F, gbOptstrings);
    ) )
)


TEST ///

    -- hard to tes,t random functions, so only use 1 variable
    R = makeRing( 1,2 )
    assert( makeBooleanNetwork(R,0,1) - matrix{{1}} == 0 )

///

TEST ///
    n := 3;
    R = makeRing( n, 2);
    G := matrix{{x1, x1 + 1, x1*x2 + x1 + x2 + 1}}
    s := {Algorithm => Sugarless, Algorithm => Inhomogeneous }
    assert( getGB( flatten entries G, s) == {{1}, {1}} )

///

end

TEST ///
n:= 3
R = makeRing( n, 2)
G := makeBooleanNetwork(R, 2, 4)
G = {a, a + 1, a*b + a + b + 1}
getGBBoolean flatten entries G
////

TEST /// 
  testPowerNetworks( (3,5), (2,3), (1,3), {Algorithm => Sugarless, Algorithm => Inhomogeneous })
  testNetworks( (3,5), (2,3), {Algorithm => Sugarless, Algorithm => Inhomogeneous })
///

s := {Algorithm => Sugarless}
getGB( G, s)

restart 
installPackage "testOptions3"
check "testOptions3"

load "benchmarks.m2"
