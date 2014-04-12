restart
installPackage "Controller"
load "/Users/franzi/network.git/M2code/GSTOPDS.m2"
installPackage "Controller"
gfile := "modelRep/Th_17.ginml"
genList := getListOfGenes gfile
(PDS,R) := fromGStoPDS gfile;
R;
PDS = apply(PDS, p -> promote(p,R));
print ("Number of variables: "| (numgens R));
scan( 1..#PDS, i-> print ("f"|i|" = "| (toString PDS_(i-1))) );

-- find the functions that are constant
constants = select( 0..(numgens R-1), i -> # (support PDS_i) == 0 )
S := makeControlRing( numgens R, #constants, char R)
g := gens S
cPDS := PDS
-- make constant functions into uis and the other ring variables to consecutively
scan( (0..#constants-1), i -> (
  ind := constants_i;
  cPDS = apply(cPDS, p -> sub( sub(p,S), {g_ind => value ("u"|(i+1))}) )
) )
cPDS 
-- 5,7,10
scan( 1..#constants, i-> (
  o := apply( toList (constants_(i-1)..(numgens R-1-i)), j -> g_(j+1)=>g_j );
  cPDS = apply(cPDS, p-> sub( p, o) )
) )
cPDS

-- move to smaller ring without extra xi
S = makeControlRing( numgens R - #constants, #constants, char R)
cPDS = apply(cPDS, p-> sub(p,S))
cPDS = apply(toList set (0..numgens S-1) - set constants, i -> cPDS#i)
print ("\nNumber of variables: "| (numgens S) | " and " | #constants | " controls.");
scan( 1..#cPDS, i-> print ("f"|i|" = "| (toString cPDS_(i-1))) )

end

load "MakecontrolledPDS.m2"



f1 = x4^2*x10^2*x13^2-x4*x10^2*x13^2-x4^2*x13^2+x10^2*x13^2+x13^2+x4
f2 = x1^2*x5^2-x1*x5^2+x1
f3 = -x2^2*x7^2+x7^2+x2
f4 = -x3^2*x4^2*x17^2+x3^2*x4*x17^2-x3*x4^2*x17^2+x3^2*x4^2+x3^2*x4+x3*x4^2-x3*x17^2-x4*x17^2-x3*x4+x3+x4
f5 = -x3^2*x4^2+x3^2+x4^2
f6 = 0
f7 = u1^2
f8 = 0
f9 = -x8^2*x16^2+x8^2
f10 = x9^2
f11 = 0
f12 = -x11^2*x16^2+x11^2
f13 = -x12^2*x17^2+x12^2
f14 = -x3^2*x17^2+x17^2
f15 = -x5^2*x14^2+x14^2
f16 = x15^2
f17 = -x4^2*x16^2+x16^2

x6 = u1

g = gens R
o = apply( 6..16, i-> g_(i-1)=>g_i)

x1 = IFNg
x2 = IFNgR
x3 = STAT1
x4 = Tbet
x5 = SOCS1
x6 = IFNb
x7 = IFNbR
x8 = IL18
x9 = IL18R
x10 = IRAK
x11 = IL12
x12 = IL12R
x13 = STAT4
x14 = IL4
x15 = IL4R
x16 = STAT6
x17 = GATA3


 POLY

restart
load "/Users/franzi/network.git/M2code/GSTOPDS.m2"
gfile = "modelRep/Th_17.ginml"
fromGStoTT gfile;

