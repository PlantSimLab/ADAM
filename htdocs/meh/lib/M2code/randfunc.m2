newPackage(
     "randfunc",
     Version => "1.0",
     Date => "June 17, 2010",
     Authors => {
	  {Name => "Bonny Guang, Madison Brandon, Rustin McNeill, Franziska Hinkelmann" 
	       }},    
     Headline => "generates random networks over boolen ring")

export{makeRing, makeBooleanNetwork, makeMonomialNetwork}
exportMutable {}

-- generate quotient ring with n variables
makeRing = method()
makeRing (ZZ,ZZ) := (nvars,c) -> (
     ll := apply( (1..nvars), i -> value concatenate("x",toString i));
     R1 :=ZZ/c[ll];
     --R1 := ZZ/2[vars(0..nvars-1), MonomialOrder=>Lex];
     L := ideal apply(gens R1, x -> x^2+x);
     R1/L
)



-- randomly generate n functions with up to nterms, where each function involves up to valence variables
makeBooleanNetwork = method()
makeBooleanNetwork (QuotientRing, ZZ, ZZ) := Matrix => (R, valence, nterms) -> (
    -- R should be a boolean ring
    -- output: a random finite dynamical system
    -- where each var has random 'valence'
    -- number of inputs
    choices := subsets(gens R, valence);
    ll := for x in gens R list (
      r := random (#choices);
      inputs := choices#r;
      allelems := subsets inputs;
      allelems = allelems/product; 
      nt := 1 + random(nterms);
      -- random( allelems ) might pick the same monomial twice 
      -- TODO fix that!
      sum for i from 1 to nt list allelems#(random (#allelems))
	  );
    matrix(R, {ll})
)


-- randomly generate n functions with only 1 term, where each function involves up to valence variables
makeMonomialNetwork = (R, valence) -> makeBooleanNetwork( R, valence, 1)
  

doc ///
  Key
    (randfunc)
    randfunc
  Headline
    Generate random networks
  Description
    Text
      Generates a random network for benchmaking
///

doc ///
  Key
    (makeBooleanNetwork, QuotientRing, ZZ, ZZ)
    makeBooleanNetwork
  Headline
    generate a random boolean network 
  Usage
    QR = makeRing(4, 5);
    makeBooleanNetwork(QR, 4,10)
  Inputs
    QR:QuotientRing
    valence:ZZ
      number of variables per function
    nterms: ZZ
      upper bound of number of terms
  Outputs
    I:Matrix 
      $1 \times numgens QR$ matrix in QR with random polynomials
  Description
    Text
      Generates a random network with {\tt valence} variables per function,
      consisting of up to {\tt nterms} terms. 
    Example
      QR = makeRing(4, 5);
      makeBooleanNetwork(QR, 4,10)
///


doc ///
  Key
    (makeRing, ZZ, ZZ)
    makeRing
  Headline
    generate quotient ring for boolean polynomials
  Usage
    makeRing(n,c)
  Inputs
    n:ZZ
      number of variables
    c:ZZ
      characteristic of the field
  Outputs
    QR:QuotientRing
  Description
    Text
      Generates $ZZ/2[x_1, \ldots, x_n]/ <x_1^2 +x_1, \ldots, x_n^2 + x_n
      >$. 
    Example
      makeRing(4, 5);
///

TEST ///
  QR = makeRing (8,2);
  makeBooleanNetwork( QR, 4, 10)
  makeMonomialNetwork( QR, 4)

///

end


  QR = booleanRing 8;
  makeBooleanNetwork( QR, 4, 10)

  matrix(QR, { makeMonomialNetwork( QR, 4) })


restart
loadPackage "randfunc"
installPackage "randfunc"
