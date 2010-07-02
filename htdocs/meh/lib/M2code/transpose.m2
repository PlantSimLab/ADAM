newPackage(
     "transposer",
     Version => "1.0",
     Date => "June 15, 2010",
     Authors => {
	  {Name => "Bonny Guang, Madison Brandon, Rustin McNeill" 
	       }},    
     Headline => "transpose a system of equations")

export{randfunc, getgb, transposer}
exportMutable {}

--generate and list of m functions in n variables
randfunc = method ()
randfunc (ZZ,ZZ) := List => (n,m) -> ( 
     R := ZZ/2[vars (0..n-1), MonomialOrder => Lex];
     l := apply(gens R, x -> x^2+x);
     QR := R/l;
     L = for i to m-1 list random(-n,-1);
     H = random(QR^1, QR^L);
     H0 := entries H;
     flatten H0
)

--getgb
getgb = method()
getgb List := List => G -> (
     L = entries gens gb ideal G;
     flatten L
     )

--transpoeses system
transposer = method()

end

restart
loadPackage "transposer"

elimfunc1 = a^2+b*a+a
elimfunc2 = b^2+d*a+e
I = ideal(elimfunc1, elimfunc2)
gens gb I
transpose oo
