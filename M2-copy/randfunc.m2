newPackage(
     "randfunc",
     Version => "1.0",
     Date => "June 17, 2010",
     Authors => {
	  {Name => "Bonny Guang, Madison Brandon, Rustin McNeill, Franziska Hinkelmann" 
	       }},    
     Headline => "generates random networks over boolen ring")

export{booleanRing, makeBooleanNetwork, makeMonomialNetwork}
exportMutable {}

-- generate quotient ring with n variables
booleanRing = method()
booleanRing ZZ := (nvars) -> (
     ll := apply( (1..nvars), i -> value concatenate("x",toString i));
     R1 := ZZ/2[ll];
     --R1 := ZZ/2[vars(0..nvars-1), MonomialOrder=>Lex];
     L := ideal apply(gens R1, x -> x^2+x);
     R1/L
)

-- randomly generate n functions with up to nterms, where each function involves up to valence variables
makeBooleanNetwork = (R, valence, nterms) -> (
    -- R should be a boolean ring
    -- output: a random finite dynamical system
    -- where each var has random 'valence'
    -- number of inputs
    choices := subsets(gens R, valence);
    for x in gens R list (
      r := random (#choices);
      inputs := choices#r;
      allelems := subsets inputs;
      allelems = allelems/product; 
      nt := 1 + random(nterms);
      sum for i from 1 to nt list allelems#(random (#allelems))
	  )
)


-- randomly generate n functions with only 1 term, where each function involves up to valence variables
makeMonomialNetwork = (R, valence) -> (
    -- R should be a boolean ring
    -- output: a random finite dynamical system
    -- where each var has random 'valence'
    -- number of inputs
    choices := subsets(gens R, valence);
    for x in gens R list (
      r := random (#choices);
      inputs := choices#r;
      allelems := subsets inputs;
      allelems = allelems/product; --this one includes a 1
      allelems = delete(1,allelems);
      nt := 1;
      sum for i from 1 to nt list allelems#(random (#allelems))
	  )
)

TEST ///
  R = booleanRing 8;
///

end

restart
loadPackage "randfunc"
installPackage "randfunc"
