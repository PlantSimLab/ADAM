-- need to fix this to load makeRing from gbHelper
newPackage(
     "randfunc",
     Version => "1.0",
     Date => "June 17, 2010",
     Authors => {
      {Name => "Bonny Guang, Madison Brandon, Rustin McNeill, Franziska Hinkelmann" }
      },    
     Headline => "generates random networks over boolen ring")

needsPackage "gbHelper"

export{ makeBooleanNetwork, makeMonomialNetwork}
exportMutable {}


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
      p := 0_R;
       while (p == 0_R or p == 1_R) do  (
        --print "0";
         p = sum for i from 1 to nt list allelems#(1+ random (#allelems-1))
         );
         p

	  );
    matrix(R, {ll})
)


-- randomly generate n functions with only 1 term, where each function involves up to valence variables
makeMonomialNetwork = method()
makeMonomialNetwork (QuotientRing, ZZ) := (R, valence) -> makeBooleanNetwork( R, valence, 1)


beginDocumentation()

--doc ///
--  Key
--    (randfunc)
--    randfunc
--  Headline
--    Generate random networks
--  Description
--    Text
--      Generates a random network for benchmaking
--///

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
      loadPackage "gbHelper" ;
      QR = makeRing(4, 5);
      makeBooleanNetwork(QR, 4,10)
///




TEST ///
  QR = makeRing (8,2);
  makeBooleanNetwork( QR, 4, 10)
  makeMonomialNetwork( QR, 4)

///

end


QR = makeRing 8;
makeBooleanNetwork( QR, 4, 10)

matrix(QR, { makeMonomialNetwork( QR, 4) })


restart
load "randfunc.m2"
loadPackage "gbHelper" 
loadPackage "randfunc"
installPackage "randfunc"
installPackage "gbHelper"
check "randfunc"
