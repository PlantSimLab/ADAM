
-- indicator function for xi between a and b, in Fp
indicatorF= method()
indicatorF(ZZ,ZZ,ZZ,ZZ) := (a, b, i, p) -> (
  R = ZZ/p[ value concatenate( "x", toString i) ];
  QR = R / ideal apply(gens R, x -> x^p - x);
  x := first gens R;
  f := sum( (a..b), r -> (1 - (x - r)^(p-1)));
  print toString f
)

-- 
simplify = method()
--simplify (String, ZZ, ZZ) := (input, p, n) -> (
--  R = ZZ/p[ apply( (1..n), i -> value concatenate( "x", toString i)) ];
--  QR = R / ideal apply(gens R, x -> x^p - x);
--  pol := value input;
--  print toString pol
--)
simplify (List, ZZ, ZZ) := (functionList, p, n) -> (
  --print "calling simplify on List";
  R = ZZ/p[ apply( (1..n), i -> value concatenate( "x", toString i)) ];
  QR = R / ideal apply(gens R, x -> x^p - x);
  scan( functionList, input -> (
    pol := value input;
    print toString pol
  ))
)

--L = {"x3", "x1"}
--p = 2
--vals = {0,1,0,1}
interpolate = method()
interpolate (List, ZZ, List) := (L, p, vals) -> (
  params := select( vals, l -> ( class value toString l ) === Symbol );
  R := ZZ/p[params / value][L / value ];
  --R := ZZ/p[L];
  n := #L;
  QR := R / ideal apply( gens R, x -> x^p-x) ;
  vals = apply(vals, l -> value toString l );
  X := set (0..p-1);
  inputs := toList X^**n;
  --print toString L;
  --print toString vals;

  pol := sum ( inputs, vals, (source, t) -> t* product( source, gens QR, (i, xi) -> 1 - (xi-i)^(p-1) ) );
  print toString pol
)


end


p = 3
n = 3
  R = ZZ/p[ apply( (1..n), i -> value concatenate( "x", toString i)) ];
  QR = R / ideal apply(gens R, x -> x^p - x);
c = -x2^2*x3^2+x2^2*x3
f1 = x1 + c;
f2 = x2 - c;
f3 = x3 - 2*c;

print toString f1
print toString f2
print toString f3
