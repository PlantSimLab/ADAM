restart
R = ZZ/2[x_1, x_2, x_3]
f1 = x_1*x_2*x_3+x_1*x_2+x_2*x_3+x_2 
f2 = x_1*x_2*x_3+x_1*x_2+x_1*x_3+x_1+x_2 
f3 = x_1*x_2*x_3+x_1*x_3+x_2*x_3+x_1+x_2
loadPackage "RationalPoints"
rationalPoints ideal( f1 -x_1, f2 - x_2, f3 - x_3)
f = (f1, f2, f3)
g = flatten entries sub( matrix(R, {{f}}), matrix(R, {{f}}) )
rationalPoints ideal( g_0 -x_1, g_1 - x_2, g_2 - x_3)
g = flatten entries sub( matrix(R, {g}), matrix(R, {{f}}) )
rationalPoints ideal( g_0 -x_1, g_1 - x_2, g_2 - x_3)
QR = R / ideal apply (gens R, x -> x^2 -x ) 
apply( g, gi -> sub(gi, QR) ) 


