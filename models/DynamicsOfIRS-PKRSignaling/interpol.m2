
--L = {"x3", "x1"}
--p = 2
--vals = {0,1,0,1}
interpolate = method()
interpolate (List, ZZ, List) := (L, p, vals) -> (
  --params := select( vals, l -> ( class value toString l ) === Symbol );
  --R := ZZ/p[params / value][L / value ];
  R := ZZ/p[L];
  n := #L;
  QR := R / ideal apply( gens R, x -> x^p-x) ;
  vals = apply(vals, l -> value toString l );
  X := set (0..p-1);
  inputs := sort toList X^**n;
  --print toString L;
  --print toString vals;
  --print toString inputs;

  pol := sum ( inputs, vals, (source, t) -> t* product( source, gens QR, (i, xi) -> 1 - (xi-i)^(p-1) ) )
  --print toString pol
)


-- make the ordered truth table, assuming all inputs are activators
makeTar = method()
makeTar Ring := R -> (
  QR = R / ideal apply( gens R, x -> x^3-x); 
  X = set{ 0, 1, 2};
  rows = sort toList X^**(numgens QR);
  vals = apply( rows, row  -> ( 
    tar := last row;
    ins := apply( #row - 1, i-> row_i);
    m := max ins;
    if m == 0 then 
      if tar != 0 then 
        tar = tar - 1;
    if m == 2 then 
      if tar != 2 then 
        tar = tar + 1;
    tar 
  ) )
)

-- make the ordered truth table, assuming first input is inhibitor, second
-- activator, third target
makeTarFirstInh = method()
makeTarFirstInh Ring := R -> (
  QR = R / ideal apply( gens R, x -> x^3-x); 
  X = set{ 0, 1, 2};
  rows = sort toList X^**(numgens QR);
  vals = apply( rows, row  -> ( 
    tar := last row;
    inh := first row;
    act := row_1;
    if act == 0 then 
      if tar != 0 then 
        tar = tar - 1;
    if act == 1 and inh == 2 then 
      if tar != 0 then 
        tar = tar - 1;
     if act == 2 and inh != 2 then 
      if tar != 2 then 
        tar = tar + 1;
    tar 
  ) )
)


end

restart 
load "interpol.m2"

-- ERK JNK S6K PKC mTOR IKK IRSS  IRSS
-- x7  x13 x19 x20 x21  x22 x14   x14

-- Insuling -> IR
R = ZZ/3[x1, x2];
f = interpolate( gens R, char R, makeTar R);
toString f

-- IR -> ShGS
R = ZZ/3[x2, x3];
f = interpolate( gens R, char R, makeTar R);
toString f

-- ShGS -> Ras
R = ZZ/3[x3, x4];
f = interpolate( gens R, char R, makeTar R);
toString f

-- Ras -> Raf
R = ZZ/3[x4, x5]; f = interpolate( gens R, char R, makeTar R);
toString f

-- Raf, MEKK -> MEK
R = ZZ/3[x5, x12, x6]; f = interpolate( gens R, char R, makeTar R);
toString f

-- MEK, PKR -> ERK
R = ZZ/3[x6, x18, x7]; f = interpolate( gens R, char R, makeTar R);
toString f

-- IRST -> PI3K
R = ZZ/3[x8, x9]; f = interpolate( gens R, char R, makeTar R);
toString f

-- PI3K -> PIP3
R = ZZ/3[x9, x10]; f = interpolate( gens R, char R, makeTar R);
toString f

-- Ras, PIP3 -> Rac
R = ZZ/3[x4, x10, x11]; f = interpolate( gens R, char R, makeTar R);
toString f

-- Rac -> MEKK
R = ZZ/3[x11, x12]; f = interpolate( gens R, char R, makeTar R);
toString f

-- MEKK, PKR -> JNK
R = ZZ/3[x12, x18, x13]; f = interpolate( gens R, char R, makeTar R);
toString f

-- Ras -> Raf
R = ZZ/3[x4, x5]; f = interpolate( gens R, char R, makeTar R);
toString f

-- IRSS
R = ZZ/3[x7, x13, x19, x20, x21, x22, x14]
f = interpolate( gens R, char R, makeTar R) 
ff = openOut "IRSS.txt"
ff << toString f
close ff

-- PIP3 -> PDK
R = ZZ/3[x10, x15]; f = interpolate( gens R, char R, makeTar R);
toString f

-- AKT -> PP1
R = ZZ/3[x16, x17]; f = interpolate( gens R, char R, makeTar R);
toString f

-- PDK, mTOR -> S6K
R = ZZ/3[x15, x21, x19]; f = interpolate( gens R, char R, makeTar R);
toString f

-- AKT -> mTOR
R = ZZ/3[x16, x21]; f = interpolate( gens R, char R, makeTar R);
toString f

-- PKR -> IKK
R = ZZ/3[x18, x22]; f = interpolate( gens R, char R, makeTar R);
toString f

-- PKR -> PP2A 
R = ZZ/3[x18, x23]; f = interpolate( gens R, char R, makeTar R);
toString f

---- Inhibitors
-- IR -> IRST, IRSS -| IRST
-- IRSS, IR, IRST
R = ZZ/3[x14, x2, x8]; 
vals = makeTarFirstInh R
f = interpolate( gens R, char R, makeTar R);
toString f

