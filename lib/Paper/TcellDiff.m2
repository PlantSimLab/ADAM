

L = {
{{x29, x30, x5, x6},{}},
{{x29, x30, x5, x6},{}},
{{x12, x10},{-x6}},
{{x7, x3, x40,x10,x9},{}},
{{x39},{}},
{{x39},{-x3}},
{{x44},{}},
{{x45},{-x13}},
{{x8},{}},
{{x11, x12},{}},
{{x47},{}},
{{x4},{}},
{{x14},{ -x41}},
{{x29, x30, x5, x6},{}},
{{x48},{}},
{{x15},{}},
{{x26, x23},{}},
{{x24, x25, x17},{-x16}},
{{x18},{}},
{{x17},{}},
{{x36, x20, x19},{}},
{{x21},{}},
{{x50},{}},
{{x50},{}},
{{x50},{}},
{{x50},{}},
{{x49},{}},
{{x27, x35},{ -x12}},
{{x39, x28},{}},
{{x36, x27, x22, x29},{}},
{{x36, x43},{}},
{{x31},{}},
{{x32},{}},
{{x33},{}},
{{x34},{}},
{{x51},{}},
{{x13},{-x16,-x41}},
{{x13},{}},
{{x11, x37,x38},{}},
{{x42, x11},{-x39}},
{{x12, x10, x3},{}},
{{x46},{}},
{{x49},{}},
{{x44},{}},
{{x45},{}},
{{x46},{}},
{{x47},{}},
{{x48},{}},
{{x49},{}},
{{x50},{}},
{{x51},{}}
}

L = {
{{x29, x30, x5, x6},{}},
{{x29, x30, x5, x6},{}},
{{x12, x10},{-x6}},
{{x7, x3, x40,x10,x9},{}},
{{x39},{}},
{{x39},{-x3}},
{{x44},{}},
{{x45},{-x13}},
{{x8},{}},
{{x11, x12},{}},
{{x47},{}},
{{x4},{}},
{{x14},{ -x41}},
{{x29, x30, x5, x6},{}},
{{x48},{}},
{{x15},{}},
{{x26, x23},{}},
{{x24, x25, x17},{-x16}},
{{x18},{}},
{{x17},{}},
{{x36, x20, x19},{}},
{{x21},{}},
{{x50},{}},
{{x50},{}},
{{x50},{}},
{{x50},{}},
{{x49},{}},
{{x27, x35},{ -x12}},
{{x39, x28},{}},
{{x36, x27, x22, x29},{}},
{{x36, x43},{}},
{{x31},{}},
{{x32},{}},
{{x33},{}},
{{x34},{}},
{{x51},{}},
{{x13},{-x16,-x41}},
{{x13},{}},
{{x11, x37,x38},{}},
{{x42, x11},{-x39}},
{{x12, x10, x3},{}},
{{x46},{}},
{{x49},{}},
{{},{}},
{{},{}},
{{},{}},
{{},{}},
{{},{}},
{{},{}},
{{},{}},
{{},{}}
}



mySum = method()
mySum List := L -> ( 
  if #L == 0 then 
    return 0;
  if #L == 1 then 
    return first L;
  if #L == 2 then (
    a := first L;
    b := last L;
    return a*b+a+b
  );
  a = first L;
  b = mySum toList apply( 1..(#L-1), i -> L#i);
  return a*b+a+b
)


end

restart
g := apply( 1..51, i -> ("x" | i) )
R := ZZ/2[g]
load "TcellDiff.m2" 
LL := apply( L, pair -> (
  activators := first pair;
  inhibitors := pair_1;
  pos := mySum activators;
  neg := mySum inhibitors;
  pos*(1+neg)
  )
)


FP := ideal apply( gens R, x -> x^2 -x )
S := ideal apply ( LL, gens R, (f, x) -> f-x )
loadPackage "RationalPoints"
myGb := ideal gens gb( S+FP, Algorithm => Sugarless)
mySS := rationalPoints  myGb

mySS3 := {
{0,0,1,0,1,1,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0},
{1,1,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0},
{1,1,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0}
}
-- Steady states from paper: 
s1 := {}
s2 := {x4, x12, x41, x10, x3} 
s3 := {x6, x1, x14, x13, x2, x29, x37, x38, x5, x30, x39} 

threecycle := {
{ x4, x1, x14, x2, x38, x30, x41}, 
{ x12, x1, x14, x2, x39}, 
{ x6, x13, x29, x5, x41, x10, x3}
}


myS1 := apply( gens R, x -> if member(x, s2) then 1 else 0 )
myS2 := apply( gens R, x -> if member(x, s3) then 1 else 0 )


mythreecycle := apply( threecycle, l -> apply( gens R, x -> if member(x, l)
then 1 else 0 ))

mySS3_0 - mythreecycle_2
mySS3_1 - mythreecycle_1
mySS3_2 - mythreecycle_0

LLL := apply( (1..51), i -> "f" | toString i | " = " | toString LL#(i-1) )
toString LLL

mySum {x1} == x1
mySum {} == 0
mySum {x1, x2} == x1*x2 + x1 + x2
mySum {x1,x2,x3, x4, x5} 
mySum {x1,x2,x3}
mySum {x1*x2 + x1 + x2, x3} 

a := x1*x2 + x1 + x2
b := x3
a*b+a+b

x1*x2*x3 + x1*x2 + x1*x3 + x2*x3 + x1 + x2 + x3

(x10 + x12)*(1+x6)
