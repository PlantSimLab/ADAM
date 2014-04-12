restart
xx = apply( (1..36), i -> "x" | i )
R = ZZ/2[xx, MonomialOrder => Lex ]
FP = ideal apply(gens R, x-> x^2-x);
QR = R/FP;

f1 = x1
f2 = x1
f3 = x1
f4 = x4
f5 = x4
f6 = x6
f7 = x7
f8 = x7
f9 = x9
f10 = x4
f11 = x4
f12 = x12
f13 = x13
f14 = x7
f15 = x7
f16 = x16
f17 = x28
f18 = x18
f19 = x19*x34 + x19 + x34
f20 = x20*x21 + x20 + x21
f21 = x26*x36
f22 = x22
f23 = x14 + x36
f24 = x13*x25
f25 = x24*x25 + x24 + x25
f26 = x7*x26 + x26
f27 = x27
f28 = x28
f29 = x29
f30 = x30
f31 = x18 + x22
f32 = x33
f33 = x33
f34 = x34
f35 = x35
f36 = x36



F = matrix(QR, { toList apply( 1..36, i -> value ("f"|i))})
polys = apply( flatten entries F, gens QR, (f,x) -> f - x)
time pols = flatten entries  gens gb ideal polys


G = F;

F = G;
polys = apply( polys, p-> lift(p,R));
loadPackage "RationalPoints"
--pols = flatten entries  gens gb (ideal FP + (ideal polys), Algorithm=>Sugarless)
time pols = flatten entries  gens gb (FP + (ideal polys));

restart
xx = apply( (1..60), i -> "x" | i )
R = ZZ/2[xx]
FP = ideal apply(gens R, x-> x^2+x);
QR = R/FP;
load "~/network.git/Paper/raw-polys.txt"
--load "~/network.git/Paper/raw-polys_inst.txt"
F = matrix(QR, { toList apply( 1..60, i -> value ("f"|i))})
fn = "simplified_polys.txt"
scan( flatten entries F, (1..60), (f, i) -> fn << toString ("f"|i | " = " | toString f | "\n") )
fn << close
get fn
--scan( flatten entries F, (1..60), (f, i) -> print ("f"|i | " = " | toString f) )
G = F;

initialState = {
0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0,
1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 
1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0}

-- 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 
-- 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0
-- 1 0 0 0 0 0 0 1 0 0 0 1 0 0 0 
-- 1 1 0 0 0 0 0 1 0 0 0 1 0 0 0

sourceState = matrix(QR, {initialState} );
while ( targetState = sub( G, sourceState ); sourceState != targetState ) do (
  print flatten entries targetState;
  sourceState = targetState);


targetState = sub( G, sourceState )
scan( ({0..14}, {15..29}, {30..44}, {45..59}), ind -> print (flatten entries targetState)_ind )
sourceState = targetState


(flatten entries targetState)_{0..14}
(flatten entries targetState)_{15..29}
(flatten entries targetState)_{30..44}
(flatten entries targetState)_{45..59}

{1,2,3,4}_{1,3}
(flatten entries targetState) _ (toList (0..4))
scan( (0..14), i -> print toString flatten entries targetState_i )
targetState_(0..14)
targetState_14)
scan( (0..3), i -> (
  scan( (0..14), j -> print toString( targetState_(i*15 + j )) )
) )



a = 1
while ( a != 5) do (
  print a;
  a = a + 1
  )
;

a
newState = sub( G, matrix(QR, {initialState}) )

for i from 1 to 3 do 
  time G = sub(G,F); --compose once
  
F = G;
polys = apply( flatten entries F, gens R, (f,x) -> f - x);
polys = apply( polys, p-> lift(p,R));
loadPackage "RationalPoints"
--pols = flatten entries  gens gb (ideal FP + (ideal polys), Algorithm=>Sugarless)
time pols = flatten entries  gens gb (FP + (ideal polys));
sols = rationalPoints ideal pols;
#sols
scan( sols, targetState -> (print "\n"; scan( ({0..14}, {15..29}, {30..44}, {45..59}), ind -> print (targetState)_ind )))

fns = "solution.txt"
scan( sols, targetState -> (fns << endl; scan( ({0..14}, {15..29}, {30..44}, {45..59}), ind -> fns << toString (targetState)_ind << endl)))
fns << close

-- 
end
load "get_sols.m2"
restart


-olynomial form 
--f2 = x14*x1*(1+x15) OR (x2*(x14 OR x1)*(1+x15))
--f2 = x14*x1*(1+x15) OR x2*x14*x1 + x14 + x1)*(1+x15)
g1 = x14*x1*(1+x15)
g2 = x2*(x14*x1 + x14 + x1)*(1+x15)
ff2 = g1*g2+g1+g2
f2
-- ff8 =  ((x14 * (~x5)) * (~x15)
ff8 =  ((x14 * (1+x5)) * (1+x15))
f8

A OR B = A*B + A + B




finalState = { {0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0},
{1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1},
{1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0} }
finalState = flatten finalState

polys = apply( flatten entries F, finalState, (f,x) -> f-x)     -- f(x) = finalState
polys = apply( polys, p-> lift(p,R));
loadPackage "RationalPoints"
--pols = flatten entries  gens gb (ideal FP + (ideal polys), Algorithm=>Sugarless)
time pols = flatten entries  gens gb (FP + (ideal polys));
newPols = {x60, x59+1, x58+1, x57+1, x54+1, x53+1, x52, x51, x50, x49, x47+1, x43+1, x42+1, x41, x39+1, x36, x35, x34, x33, x32, x31+1, x30, x29+1, x28+1, x27+1, x24+1, x23+1, x22, x21, x20, x19, x17, x16, x15, x13, x12, x9, x8, x6+1, x5+1, x4+1, x3, x2, x1, x56^2+x56, x55^2+x55, x48^2+x48, x18*x48+x18+x48+1, x46^2+x46, x45^2+x45, x44*x45+x44, x44^2+x44, x40^2+x40, x38^2+x38, x37^2+x37, x7*x37+x7+x37+1, x26^2+x26, x25^2+x25, x18^2+x18, x14^2+x14, x11^2+x11, x10^2+x10, x7^2+x7}
newPols = {x60, x59+1, x58+1, x57+1, x54+1, x53+1, x52, x51, x50, x49, x47+1,
x43+1, x42+1, x41, x39+1, x36, x35, x34, x33, x32, x31+1, x30, x29+1, x28+1,
x27+1, x24+1, x23+1, x22, x21, x20, x19, x17, x16, x15, x13, x12, x9, x8,
x6+1, x5+1, x4+1, x3, x2, x1, x18*x48+x18+x48+1, x44*x45+x44, x7*x37+x7+x37+1}
polys = apply( newPols, p-> lift(p,R));
  sols = rationalPoints ideal pols;
#sols
  scan( sols, targetState -> (print "\n"; scan( ({0..14}, {15..29}, {30..44}, {45..59}), ind -> print (targetState)_ind )))









