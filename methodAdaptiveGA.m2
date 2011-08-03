--Atsya Kumano MSSB2011 ak1126jplydon@gmail.com--
--Adaptive GA Macaulay Code used in ADAM Heuristic Control.
clearAll
needsPackage "RationalPoints";

MakeParams = method()
MakeParams(Set,ZZ,ZZ,ZZ) := (noKOset,numpop,n,p) -> (
     parameters := apply(numpop, i-> apply(n, j-> if noKOset #? j then 1 else random p) );
     return parameters;
     );

CalcFit = method()
CalcFit(List) := (listofStuff) -> (
     n := listofStuff#0;
     numfit := listofStuff#1;
     SteadyStates := listofStuff#2;
     cp := listofStuff#3;
     SSreqs := listofStuff#4;
     SSreqindx := listofStuff#5;
     noKOset := listofStuff#6;
     fitlimit := listofStuff#7;
     ParameterWeights := listofStuff#8;
     fitnesslist := apply(numfit, i-> (
	       if #SteadyStates#i == 0 then 0 else if #SteadyStates#i > 1 then floor(10/#SteadyStates#i) else (
		    KOpositions = positions(cp#i, j-> j == 0);
		    KOcheck = set (apply(KOpositions, j-> noKOset #? j) );
		    SScheck = apply(#SSreqindx, j-> (flatten SteadyStates#i)#(SSreqindx#j) == SSreqs#j );
		    SScheck = set(SScheck);
	  	    if #(SteadyStates#i) == 1 and (SScheck #? false) == false and (KOcheck #? true) == false then fitlimit - sum(n, j -> (1 - (cp#i)#j ) * ParameterWeights#j) else 0)
	       )
	  );
     return fitnesslist;
     );

AdaptiveGAwPS = method()
AdaptiveGAwPS(ZZ, ZZ, List, List) := (n, p, pols, GSSandWeights) -> (
     --(# of variables, char, polynomials, Goal SS, Weights)
--GoalSteadyState = {1 for must be on. 0 for must be off. NA for otherwise}
--ParameterWeights = {"no" (string) for cannot be knocked down. Other entries are integers}
if isPrime p == false then error "expected a prime integer";
if n != #pols then error "n and the number of polynomials don't match";
if #GSSandWeights != 2 * n then error "either n or Goal Steady States and Parameter Weights input is incorrect";
GSScheck = apply(n, i-> class (GSSandWeights#i));
GSScheck = set GSScheck;
if GSScheck #? ZZ == false then error "expected at least one goal state";

use ZZ;
NA = p; --replace NA (unspecified) with p (in Fp, steady states doesn't have p as an entry)
GoalSteadyState := value toString (take(GSSandWeights, n));
SSreqindx := positions(GoalSteadyState, i-> i != p);
SSreqs := apply(SSreqindx, i-> GoalSteadyState#i);

ParameterWeights := take(GSSandWeights, -n);
noKO := positions(ParameterWeights, i-> class i === Symbol); --genes that cannot be knocked out
noKOset := set noKO;
no = 0;
ParameterWeights = value toString ParameterWeights;

QRcoef = ZZ/p [u_1..u_n];
QRcoef = QRcoef/ideal(apply(gens QRcoef, i-> i^p -i) );
QR = QRcoef [toList value replace("_","",toString (x_1..x_n) )];
QR = QR/ideal(apply(gens QR, i-> i^p - i) );

pols = pols/value;

apply(n, i-> f_(i+1) = pols#i); --set f_n to fn (user polynomials).
apply(n, i-> f_(i+1) = u_(i+1) * f_(i+1) ); --add parameters u_1..u_n

SSEquations = apply(n, i-> sub(f_(i+1) - value (concatenate("x", toString (i+1) ) ), QR) );
PreSelection = true;

--Restriction of Parameters using necessary condition for the existence of the goal steady state. (This may not work well if there are too many NA's.)
--1. Substitute Goal Steady State (u) into x and f => get information about u.
if PreSelection then (
GoalSSsub = apply(#GoalSteadyState, i-> if GoalSteadyState#i != p then (gens QR)#i => GoalSteadyState#i); --don't set u = NA = 2.
A = positions(GoalSSsub, i-> class i === Option);
GoalSSsub = apply(A, i-> GoalSSsub#i);
ParamCond = apply(#GoalSteadyState, i-> if GoalSteadyState#i != p then sub(SSEquations#i,GoalSSsub) );
B = positions(ParamCond, i-> class i === QR);
ParamCond = apply(B, i-> ParamCond#i);
C = positions(ParamCond, i-> liftable(i,ZZ) == false); --weed out integers
ParamCond = apply(C, i-> ParamCond#i);
D = positions(ParamCond, i-> first degree i == 0); --weed out x's
ParamCond = apply(D, i-> ParamCond#i);
if #ParamCond != 0 then (
R = ZZ/p [value replace("u_","t_", toString (gens QRcoef) )];
ParamCond = value replace("u_","t_", toString ParamCond);
-- if p == 2 then (
--      ParamIdeal = sub(ideal(ParamCond), R);
--      ParamIdeal = gbBoolean(ParamIdeal);
--      PotentialParams = rationalPoints(ParamIdeal, UseGB=>false);
--      ) else ();
     ParamIdeal = sub(ideal(ParamCond), R);
     PotentialParams = rationalPoints(ParamIdeal, UseGB=>true); --List of Parameters that satisfies the necessary condition
     PotentialParams = value toString PotentialParams;
) else PreSelection = false;
) else PreSelection = false;
--print toString (#PotentialParams); --Debug here! (Rational Points cannot find potential parameters)
--- GA ---
np = 20; --the size of population
if PreSelection then cp := apply(np, i-> value toString ( PotentialParams#(random(#PotentialParams) ) ) ) else cp = MakeParams(noKOset,np,n,p);

ngeneration = 40;
Reset = 0;
improvements = 0;
crossoverRate := 0.7; --min: 0%, max: 90%
mutationRate := 0.1; --min: 0%, max: 100%
bestparams := {};
bestparamsfit := {};
RT = ZZ/p [toList value replace("_","",toString (x_1..x_n) )];

scan(ngeneration, generations -> (
use QR;
if generations == 0 or Reset == 1 then numfit = np else numfit = ceiling(np*crossoverRate); --numfit = # of vectors whose fitness is not calculated yet. those vectors are children vectors and are on the top of fitnesslist.

kids = take(cp, numfit);
checkedkids = select(kids, i-> ( --Keep the good ones
	       KOpositions = positions(i, j-> j == 0);
     	       KOcheck = set (apply(KOpositions, j-> noKOset #? j) );
	       KOcheck #? true == false
	       )
     	  );
if #checkedkids == np then cp = checkedkids else cp = MakeParams(noKOset,numfit-#checkedkids,n,p) | checkedkids | apply(np - ceiling(np*crossoverRate) - floor(np/10), i -> clone_i) | apply(floor(np/10), i-> bestcp_i);
SubSSEquations = apply(numfit, i-> ( --only fitness of new children have to be calculated b/c the clones and bests know their fitness already.
     subOptions = apply(n, j-> u_(j+1) => (cp#i)#(j) );
     sub(matrix(QR, {SSEquations}) , subOptions)
     ) 
);
use RT;
--GBBoolean gives ideal 1. somehow
-- if p == 2 then (
--      SteadyStates = apply(numfit, i -> (
-- 	       systemIdeal = sub( ideal(toSequence flatten entries SubSSEquations#i) ,RT);
-- 	       systemIdeal = gbBoolean(systemIdeal);
--        	       rationalPoints(systemIdeal , UseGB => false)
-- 	  )
--      );
-- ) else
SteadyStates = apply(numfit, i -> (
	  systemIdeal = sub( ideal(toSequence flatten entries SubSSEquations#i) ,RT);
	  --try rationalPoints(systemIdeal , UseGB => true) else
	   rationalPoints(systemIdeal, UseGB=>false)
	  )
     );

use ZZ;
fitlimit = n * max(ParameterWeights);
SteadyStates = value toString SteadyStates; --to lift the ring elements from ZZ/2 to ZZ.
if generations == 0 or Reset == 1 then (
     fitnesslist = CalcFit({n,numfit,SteadyStates,cp,SSreqs,SSreqindx,noKOset,fitlimit,ParameterWeights})--Calculate the fitness of vectors (just children or all if after reset)
) else (
     childrenfitnesslist = CalcFit({n,numfit,SteadyStates,cp,SSreqs,SSreqindx,noKOset,fitlimit,ParameterWeights});  -- apply(numfit, i-> (
	  --      if #SteadyStates#i == 0 then 0 else (
	  -- 	    KOpositions = positions(cp#i, j-> j == 0);
	  --      	    KOcheck = set (apply(KOpositions, j-> noKOset #? j) );
	  -- 	    SScheck = apply(#SSreqindx, j-> (flatten SteadyStates#i)#(SSreqindx#j) == SSreqs#j );
	  -- 	    SScheck = set(SScheck);
	  -- 	    if #(SteadyStates#i) == 1 and (SScheck #? false) == false and (KOcheck #? true) == false then fitlimit - sum(n, j -> (1 - (cp#i)#j ) * ParameterWeights#j) else 0)
	  --      )
	  -- ) ;
	  --Calculate the fitness of each vector
     --print concatenate("childrenfitnesslist: ", toString childrenfitnesslist);
     fitnesslist = childrenfitnesslist | clonefitnesslist | bestfitnesslist;
     );
--print concatenate("fitnesslist: ", toString fitnesslist);     
     
-- 1/5 rule (Adaptation of GA)--
use RR;
if Reset == 0 and generations > 0 then (
improvements = 0;
scan(ceiling(np*crossoverRate), i -> if fittestofgeneration_(generations - 1) < fitnesslist#i then improvements = improvements + 1); --compare the fitness of children with the max of previous generation
--print concatenate("improvements =", toString improvements);
if improvements*5 < np*crossoverRate then mutationRate = mutationRate + 0.1; 
if mutationRate > 1 then mutationRate = 1; --less than 1/5 of the new children is better than the fittest of the previous population
if improvements*5 > np*crossoverRate then mutationRate = mutationRate - 0.1;
if mutationRate < 0 then mutationRate = 0;
     );
--Make n*crossover-rate children. Roulette Wheel selection based on fitness.--
wheel = accumulate(plus, fitnesslist);
totalfitness = fold(plus, fitnesslist);
scan(ceiling(np*crossoverRate), k-> (
roulette1 = random(RR)*totalfitness;
roulette2 = random(RR)*totalfitness;
parent1indxcode = concatenate("if 0 <= roulette1 and roulette1 < fitnesslist#0 then 0 else if fitnesslist#0 <= roulette1 and roulette1 < wheel#0 then 1",
     concatenate apply(1..np-3, i -> (
	       replace("j", toString i, " else if wheel#(j-1) <= roulette1 and roulette1 < wheel#j then j+1")
     	       )
	  ), " else " | toString (np-1) );
parent1indx = value(parent1indxcode);
parent2indxcode = replace("roulette1","roulette2", toString parent1indxcode);
parent2indx = value(parent2indxcode);
parent1 = cp#parent1indx;
parent2 = cp#parent2indx;
--make a child
breakpoint = random (n + 1);
child_k = take(parent1, breakpoint) | take(parent2, -(n - breakpoint) ); --create a child by mixing two parents
if random(RR) < mutationRate then child_k = random(child_k);--mutation is random permutation of the list
--print concatenate("child",toString k, "is", toString child_k);
)
);
-- Keep the top 10% --
tempfitnesslist = fitnesslist;
tempcp = cp;
scan(floor(np/10), i-> (
     bestvecindx_i = maxPosition tempfitnesslist;
     bestcp_i = tempcp#(bestvecindx_i);
     --print concatenate("bestcp",toString i, " is ", toString bestcp_i);
     bestfitness_i = tempfitnesslist#(bestvecindx_i);
     bestparams = append(bestparams, bestcp_i); --store this vector of parameters
     bestparamsfit = append(bestparamsfit, bestfitness_i); --store the fitness of this vector
     tempfitnesslist = drop(tempfitnesslist, {bestvecindx_i,bestvecindx_i} );
     tempcp = drop(tempcp, {bestvecindx_i,bestvecindx_i} );
)
); --bestcp's are the top10%.
bestfitnesslist = apply(floor(np/10), i-> bestfitness_i);
--print concatenate("bestfitnesslist: ", toString bestfitnesslist);

--make Clones (no mutation)--
scan(np - ceiling(np*crossoverRate) - floor(np/10), i -> (
     roulette = random(RR) * totalfitness;
     parentindx = value( 
     concatenate("if 0 <= roulette and roulette < fitnesslist#0 then 0 else if fitnesslist#0 <= roulette and roulette < wheel#0 then 1",
     concatenate apply(1..np-3, i -> (
	       replace("j", toString i, " else if wheel#(j-1) <= roulette and roulette < wheel#j then j+1")
     	       )
	  ), " else " | toString (np-1) )
     );
     clone_i = cp#parentindx;
     clonefitness_i = fitnesslist#parentindx;
     --print concatenate("clone",toString i, " is ", toString clone_i);
     )
);
clonefitnesslist = apply(np - ceiling(np*crossoverRate) - floor(np/10), i -> clonefitness_i);
--print concatenate("clonefitnesslist: ", toString clonefitnesslist);
cp = apply(ceiling(np*crossoverRate), i-> child_i) | apply(np - ceiling(np*crossoverRate) - floor(np/10), i -> clone_i) | apply(floor(np/10), i-> bestcp_i) ; --new population (top: children, middle: clone, bottom: best)

fittestofgeneration_generations = bestfitness_0;

--print concatenate("The fittest of the ",toString generations, " th generation is ", toString fittestofgeneration_generations );

-- Reset GA ? --
if PreSelection then (
     if generations != 0 and generations%10 == 0 and fittestofgeneration_(generations) <= fittestofgeneration_(generations - 9) then (
	  cp = apply(np, i-> value toString ( PotentialParams#(random(#PotentialParams) ) ) ); mutationRate = 0.2; Reset = 1;
	  ) else Reset = 0;
     ) else (
     if generations != 0 and generations%10 == 0 and fittestofgeneration_(generations) <= fittestofgeneration_(generations - 9) then (
	  cp = MakeParams(noKOset,np,n,p); mutationRate = 0.2; Reset = 1;
	  ) else Reset = 0; 
     )--check every 10 generations. Reset if the fitness hasn't changed since 10 generation before.
)-- close scan
);

maxfitness := max(bestparamsfit);
finalbestindx := positions(bestparamsfit, i-> i == maxfitness);
finalbestparams := apply(finalbestindx, i-> bestparams#i);
--print concatenate("The set of the best parameters without duplication (fitness = ", toString maxfitness, ") :" );
finalresult := unique finalbestparams;
outputstring := apply(finalresult, i-> toString i | "<br>");
scan(outputstring, i-> print i);

);

end
load "methodAdaptiveGA.m2"
restart

--default input
AdaptiveGAwPS(20, 2, {"f1=x13*x15*x18*x19*x20+x13*x15*x18*x19+x13*x15*x18*x20+x13*x15*x19*x20+x13*x18*x19*x20+x15*x18*x19*x20+x13*x15*x18+x13*x15*x19+x13*x18*x19+x15*x18*x19+x13*x15*x20+x13*x18*x20+x15*x18*x20+x13*x19*x20+x15*x19*x20+x18*x19*x20+x13*x15+x13*x18+x15*x18+x13*x19+x15*x19+x18*x19+x13*x20+x15*x20+x18*x20+x19*x20+x13+x15+x18+x19+x20","f2=x3*x4*x5+x3*x4+x4*x5+x4","f3=x2*x10*x12+x2*x10+x2*x12+x10*x12+x2+x10+x12+1","f4=x1*x9*x10*x12+x1*x9*x12+x9*x10*x12","f5=x2*x6*x10*x12+x2*x6*x10+x2*x6*x12+x2*x10*x12+x6*x10*x12+x2*x6+x2*x10+x6*x10+x2*x12+x6*x12+x10*x12+x2+x6+x10+x12+1","f6=x3*x5*x7+x3*x7+x5*x7+x7","f7=x12","f8=x2*x11","f9=x1*x10+x1+x10","f10=x13*x15*x18*x19*x20+x13*x15*x18*x19+x13*x15*x18*x20+x13*x15*x19*x20+x13*x18*x19*x20+x15*x18*x19*x20+x13*x15*x18+x13*x15*x19+x13*x18*x19+x15*x18*x19+x13*x15*x20+x13*x18*x20+x15*x18*x20+x13*x19*x20+x15*x19*x20+x18*x19*x20+x13*x15+x13*x18+x15*x18+x13*x19+x15*x19+x18*x19+x13*x20+x15*x20+x18*x20+x19*x20+x13+x15+x18+x19+x20","f11=x4","f12=x1*x9*x10+x1*x9+x1*x10+x9*x10+x1+x9+x10","f13=x9*x10*x18+x9*x10+x9*x18+x10*x18+x9+x10","f14=1","f15=x14","f16=x14","f17=x14","f18=x16*x17","f19=x15*x16","f20=x15*x17"}, {NA,NA,NA,NA,NA,NA,NA,0,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,1, 1, 1, 1, 1, 1, 1, no, 1, 1, 1, 1, 1, no, 1, 1, 1, 1, 1, 1} )
--score: 3, 6, 5, 5, 5, 6, 5, 0, 4, 3, 6, 4, 2, 0, 1, 1, 1, 2, 2, 2 maxfit: x9 or x12 or (x13,15,17).

--to Check the answer
p = 2;
n = 20;
parameter ={1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1};
subOptions = apply(n, i-> u_(i+1) => parameter#i );
SubSSEquation = sub(matrix(QR, {SSEquations}) , subOptions);
answer = rationalPoints( sub( ideal(toSequence flatten entries SubSSEquation) ,RT), UseGB => true);
fitness = if #answer == 1 and (flatten answer)#7 == 0  and parameter#7 != 0 and parameter#13 != 0 then 100 - sum(n, j -> (1- parameter#j ) * ParameterWeights#j) else 0
-- bestparamsfit  WHERE FITNESS IS STORED
--to just do rational points
n = 75;
p = 2;
pols = {} --list of polynomials
RT = ZZ/p [toList value replace("_","",toString (x_1..x_n) )];
pols = value toString pols;
apply(n, i-> f_(i+1) = pols#i);
SSEquations = apply(n, i-> f_(i+1) - value (concatenate("x", toString (i+1) ) ) );
systemIdeal = sub( ideal(SSEquations) , RT);
needsPackage "RationalPoints";
time rationalPoints(systemIdeal , UseGB => true)

AdaptiveGAwPS(75, 2, {"f1=x54*x14*1","f2=((x5+x8-x5*x8)+(x72+x73-x72*x73)-(x5+x8-x5*x8)*(x72+x73-x72*x73))*((x54+x64-x54*x64)*(1-(x55*1)))","f3=((x5+x8-x5*x8)+x72-((x5+x8-x5*x8)*x72))*(x54*1)","f4=x54*1","f5=x5+x41-x5*x41","f6=((x72*x54)+x8-(x72*x54)*x8)+(x72*x54*(x41+x42-x41*x42))-((x72*x54)+x8-(x72*x54)*x8)*(x72*x54*(x41+x42-x41*x42))","f7=x54*((x5+x8-x5*x8)+x72-(x5+x8-x5*x8)*x72)","f8=x54*(((((x7*x3)+x9-(x7*x3)*x9)+(x43+(x40*x28)-x43*(x40*x28))-(((x7*x3)+x9-(x7*x3)*x9))*(x43+(x40*x28)-x43*(x40*x28)))+(x5*x32)-(((x7*x3)+x9-(x7*x3)*x9)+(x43+(x40*x28)-x43*(x40*x28))-(((x7*x3)+x9-(x7*x3)*x9))*(x43+(x40*x28)-x43*(x40*x28)))*(x5*x32))+(x33*(((x15+x18-x15*x18)+((x28*x29)+x22-(x28*x29)*x22)-(x15+x18-x15*x18)*((x28*x29)+x22-(x28*x29)*x22))+(x27+x30-x27*x30)-((x15+x18-x15*x18)+((x28*x29)+x22-(x28*x29)*x22)-(x15+x18-x15*x18)*((x28*x29)+x22-(x28*x29)*x22))*(x27+x30-x27*x30)))-((((x7*x3)+x9-(x7*x3)*x9)+(x43+(x40*x28)-x43*(x40*x28))-(((x7*x3)+x9-(x7*x3)*x9))*(x43+(x40*x28)-x43*(x40*x28)))+(x5*x32)-(((x7*x3)+x9-(x7*x3)*x9)+(x43+(x40*x28)-x43*(x40*x28))-(((x7*x3)+x9-(x7*x3)*x9))*(x43+(x40*x28)-x43*(x40*x28)))*(x5*x32))*(x33*(((x15+x18-x15*x18)+((x28*x29)+x22-(x28*x29)*x22)-(x15+x18-x15*x18)*((x28*x29)+x22-(x28*x29)*x22))+(x27+x30-x27*x30)-((x15+x18-x15*x18)+((x28*x29)+x22-(x28*x29)*x22)-(x15+x18-x15*x18)*((x28*x29)+x22-(x28*x29)*x22))*(x27+x30-x27*x30))))","f9=((x8*((x29+x15-x29*x15)+x26-(x29+x15-x29*x15)*x26))+(x7*x2*(1-x55))-(x8*((x29+x15-x29*x15)+x26-(x29+x15-x29*x15)*x26))*(x7*x2*(1-x55)))*((1-((x42+x20-x42*x20)+(x22+x31-x22*x31)-(x42+x20-x42*x20)*(x22+x31-x22*x31)))+1-(1-((x42+x20-x42*x20)+(x22+x31-x22*x31)-(x42+x20-x42*x20)*(x22+x31-x22*x31)))*1)","f10=x8*x9*(1-(((x68+x69-x68*x69)+(x67+x70-x67*x70)-(x68+x69-x68*x69)*(x67+x70-x67*x70))+(x71+x55-x71*x55)-((x68+x69-x68*x69)+(x67+x70-x67*x70)-(x68+x69-x68*x69)*(x67+x70-x67*x70))*(x71+x55-x71*x55)))","f11=x8*x9*(1-x70)","f12=x54*x5*x2","f13=(x54+x64-x54*x64)*x7*((1-(((x55+x57-x55*x57)+x56-(x55+x57-x55*x57)*x56)+(x59+x63-x59*x63)-((x55+x57-x55*x57)+x56-(x55+x57-x55*x57)*x56)*(x59+x63-x59*x63)))+1-((1-(((x55+x57-x55*x57)+x56-(x55+x57-x55*x57)*x56)+(x59+x63-x59*x63)-((x55+x57-x55*x57)+x56-(x55+x57-x55*x57)*x56)*(x59+x63-x59*x63))))*1)","f14=((x5*x13*(1-(((x61+x62-x61*x62)+(x60+x63-x60*x63)-(x61+x62-x61*x62)*(x60+x63-x60*x63))+x66-((x61+x62-x61*x62)+(x60+x63-x60*x63)-(x61+x62-x61*x62)*(x60+x63-x60*x63))*x66)))*1)+(x72*x54)-((x5*x13*(1-(((x61+x62-x61*x62)+(x60+x63-x60*x63)-(x61+x62-x61*x62)*(x60+x63-x60*x63))+x66-((x61+x62-x61*x62)+(x60+x63-x60*x63)-(x61+x62-x61*x62)*(x60+x63-x60*x63))*x66)))*1)*(x72*x54)","f15=((x36+x44-x36*x44)+(x8+(x5*x54)-x8*(x5*x54))-(x36+x44-x36*x44)*(x8+(x5*x54)-x8*(x5*x54)))*(1-((x20+x22-x20*x22)+x31-(x20+x22-x20*x22)*x31))","f16=(x36+x37-x36*x37)+(x44+x6-x44*x6)-(x36+x37-x36*x37)*(x44+x6-x44*x6)","f17=x37+x38-x37*x38","f18=(((x36+x38-x36*x38)+(x44+x45-x44*x45)-(x36+x38-x36*x38)*(x44+x45-x44*x45))+x47-((x36+x38-x36*x38)+(x44+x45-x44*x45)-(x36+x38-x36*x38)*(x44+x45-x44*x45))*x47)*(1-x28)","f19=((x38+x44-x38*x44)+x47-(x38+x44-x38*x44)*x47)*(1-x28)","f20=((x8+x36-x8*x36)+(x6+x44-x6*x44)-(x8+x36-x8*x36)*(x6+x44-x6*x44))+(x47+(x5*x54)-x47*(x5*x54))-((x8+x36-x8*x36)+(x6+x44-x6*x44)-(x8+x36-x8*x36)*(x6+x44-x6*x44))*(x47+(x5*x54)-x47*(x5*x54))","f21=x5*(x54+x56-x54*x56)*x2","f22=((((x38+x36-x38*x36)+(x8+(x6*x55)-x8*(x6*x55))-(x38+x36-x38*x36)*(x8+(x6*x55)-x8*(x6*x55)))+(x5*((x54+x55-x54*x55)+x56-(x54+x55-x54*x55)*x56)))-(((x38+x36-x38*x36)+(x8+(x6*x55)-x8*(x6*x55))-(x38+x36-x38*x36)*(x8+(x6*x55)-x8*(x6*x55)))*(x5*((x54+x55-x54*x55)+x56-(x54+x55-x54*x55)*x56))))*(1-x28)","f23=(x36+(x6*(1-(x55+x56-x55*x56)))-x36*(x6*(1-(x55+x56-x55*x56))))+(x8+(x5*(x54+x60-x54*x60))-x8*(x5*(x54+x60-x54*x60)))-(x36+(x6*(1-(x55+x56-x55*x56)))-x36*(x6*(1-(x55+x56-x55*x56))))*(x8+(x5*(x54+x60-x54*x60))-x8*(x5*(x54+x60-x54*x60)))","f24=x38+x44-x38*x44","f25=(x6+x36-x6*x36)+x8-(x6+x36-x6*x36)*x8","f26=(x8+x36-x8*x36)+(x37+x38-x37*x38)-(x8+x36-x8*x36)*(x37+x38-x37*x38)","f27=x36+x6-x36*x6","f28=((((x36+x37-x36*x37)+(x39+(x40*x1)-x39*(x40*x1))-(x36+x37-x36*x37)*(x39+(x40*x1)-x39*(x40*x1)))+((x6+x8-x6*x8)+((x5*x54)*(1-x55))-(x6+x8-x6*x8)*((x5*x54)*(1-x55)))-((x36+x37-x36*x37)+(x39+(x40*x1)-x39*(x40*x1))-(x36+x37-x36*x37)*(x39+(x40*x1)-x39*(x40*x1)))*((x6+x8-x6*x8)+((x5*x54)*(1-x55))-(x6+x8-x6*x8)*((x5*x54)*(1-x55)))))*(1-(x31*x22))","f29=((((x46+x37-x46*x37)+(x39+x44-x39*x44)-(x46+x37-x46*x37)*(x39+x44-x39*x44))+((x45+x47-x45*x47)+(x36+x8-x36*x8)-(x45+x47-x45*x47)*(x36+x8-x36*x8))-((x46+x37-x46*x37)+(x39+x44-x39*x44)-(x46+x37-x46*x37)*(x39+x44-x39*x44))*((x45+x47-x45*x47)+(x36+x8-x36*x8)-(x45+x47-x45*x47)*(x36+x8-x36*x8)))+(((((x5*x54)+x56-(x5*x54)*x56)+x60-((x5*x54)+x56-(x5*x54)*x56)*x60))*(1-x55))-(((((x5*x54)+x56-(x5*x54)*x56)+x60-((x5*x54)+x56-(x5*x54)*x56)*x60))*(1-x55))*(((x46+x37-x46*x37)+(x39+x44-x39*x44)-(x46+x37-x46*x37)*(x39+x44-x39*x44))+((x45+x47-x45*x47)+(x36+x8-x36*x8)-(x45+x47-x45*x47)*(x36+x8-x36*x8))-((x46+x37-x46*x37)+(x39+x44-x39*x44)-(x46+x37-x46*x37)*(x39+x44-x39*x44))*((x45+x47-x45*x47)+(x36+x8-x36*x8)-(x45+x47-x45*x47)*(x36+x8-x36*x8))))","f30=(x37+x36-x37*x36)+x39-(x37+x36-x37*x36)*x39","f31=((x5*x54)+x8-(x5*x54)*x8)*(x55+x56-x55*x56)","f32=x54*((x5+x74-x5*x74)+x8-(x5+x74-x5*x74)*x8)","f33=x33+(x40*x28)-x33*(x40*x28)","f34=x54*(x6*((x23+x20-x23*x20)+(x25+x28-x25*x28)-(x23+x20-x23*x20)*(x25+x28-x25*x28)))","f35=x75*x54*1","f36=x54*((((x1*x7)+x8-(x1*x7)*x8)+((x6*x34)+(x75*x35)-(x6*x34)*(x75*x35))-((x1*x7)+x8-(x1*x7)*x8)*((x6*x34)+(x75*x35)-(x6*x34)*(x75*x35)))+(((x74*x29)+(x33*(((x16+x18-x16*x18)+(x20+x28-x20*x28)-(x16+x18-x16*x18)*(x20+x28-x20*x28))+x27-((x16+x18-x16*x18)+(x20+x28-x20*x28)-(x16+x18-x16*x18)*(x20+x28-x20*x28))*x27))-(x74*x29)*(x33*(((x16+x18-x16*x18)+(x20+x28-x20*x28)-(x16+x18-x16*x18)*(x20+x28-x20*x28))+x27-((x16+x18-x16*x18)+(x20+x28-x20*x28)-(x16+x18-x16*x18)*(x20+x28-x20*x28))*x27))))-(((x1*x7)+x8-(x1*x7)*x8)+((x6*x34)+(x75*x35)-(x6*x34)*(x75*x35))-((x1*x7)+x8-(x1*x7)*x8)*((x6*x34)+(x75*x35)-(x6*x34)*(x75*x35)))*(((x74*x29)+(x33*(((x16+x18-x16*x18)+(x20+x28-x20*x28)-(x16+x18-x16*x18)*(x20+x28-x20*x28))+x27-((x16+x18-x16*x18)+(x20+x28-x20*x28)-(x16+x18-x16*x18)*(x20+x28-x20*x28))*x27))-(x74*x29)*(x33*(((x16+x18-x16*x18)+(x20+x28-x20*x28)-(x16+x18-x16*x18)*(x20+x28-x20*x28))+x27-((x16+x18-x16*x18)+(x20+x28-x20*x28)-(x16+x18-x16*x18)*(x20+x28-x20*x28))*x27)))))","f37=(x54*(x33*(x23+x25-x23*x25)))+(x5*x32)-(x54*(x33*(x23+x25-x23*x25)))*(x5*x32)","f38=(x54*x33*x18)+(x5*x32)-(x54*x33*x18)*(x5*x32)","f39=x36+x41-x36*x41","f40=x33*x54*1","f41=(x37*x23)*(1-x42)","f42=((x38*x18)*(1-x41))+x47-((x38*x18)*(1-x41))*x47","f43=x39*(x41+(x6*x1)-x41*(x6*x1))","f44=x33*x32*(x17+x26-x17*x26)","f45=x33*x32*((x17+x19-x17*x19)+x26-(x17+x19-x17*x19)*x26)","f46=x74*x54*(x4+(x33*((x18+x21-x18*x21)+(x28+((x29+x30-x29*x30)*x15)-x28*((x29+x30-x29*x30)*x15))-(x18+x21-x18*x21)*(x28+((x29+x30-x29*x30)*x15)-x28*((x29+x30-x29*x30)*x15))))-x4*(x33*((x18+x21-x18*x21)+(x28+((x29+x30-x29*x30)*x15)-x28*((x29+x30-x29*x30)*x15))-(x18+x21-x18*x21)*(x28+((x29+x30-x29*x30)*x15)-x28*((x29+x30-x29*x30)*x15)))))","f47=x73*(((x54+x18-x54*x18)+(x19+x24-x19*x24)-(x54+x18-x54*x18)*(x19+x24-x19*x24))+x2-((x54+x18-x54*x18)+(x19+x24-x19*x24)-(x54+x18-x54*x18)*(x19+x24-x19*x24))*x2)","f48=((x54*x5*x29)*(1-(x22+(x11*x58)-x22*(x11*x58))))+((x50+x49-x50*x49)*(1-(x65+x55-x65*x55)))-((x54*x5*x29)*(1-(x22+(x11*x58)-x22*(x11*x58))))*((x50+x49-x50*x49)*(1-(x65+x55-x65*x55)))","f49=(((x39*((x16*x20)+x15-(x16*x20)*x15))+x40)-((x39*((x16*x20)+x15-(x16*x20)*x15))*x40))*x1","f50=(((x39*(x28+x16-x28*x16))+x40)-((x39*(x28+x16-x28*x16))*x40))*x1","f51=((x44+x45-x44*x45)+x47-(x44+x45-x44*x45)*x47)*(x32+((x21+x17-x21*x17)+(x15+x26-x15*x26)-(x21+x17-x21*x17)*(x15+x26-x15*x26))-x32*((x21+x17-x21*x17)+(x15+x26-x15*x26)-(x21+x17-x21*x17)*(x15+x26-x15*x26)))","f52=x52+(x8*(x29*x15))-x52*(x8*(x29*x15))","f53=x8*((x29*x15)+(x31+x32-x31*x32)-(x29*x15)*(x31+x32-x31*x32))","f54=((x54*(x5+x8-x5*x8))*(1-((x10+x11-x10*x11)+(x12+x51-x12*x51)-(x10+x11-x10*x11)*(x12+x51-x12*x51))))+(x54*(1-(x13+x48-x13*x48)))-((x54*(x5+x8-x5*x8))*(1-((x10+x11-x10*x11)+(x12+x51-x12*x51)-(x10+x11-x10*x11)*(x12+x51-x12*x51))))*(x54*(1-(x13+x48-x13*x48)))","f55=x54*x55","f56=x54*x56","f57=x54*x7","f58=x54*x58","f59=x54*x59","f60=x54*x60","f61=x54*x61","f62=x54*x62","f63=x54*x7","f64=x54*x64","f65=x54*x65","f66=x54*x66","f67=x54*x8","f68=x54*x8","f69=x54*x8","f70=x54*x8","f71=x54*x8","f72=1","f73=1","f74=1","f75=1"}, {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,10,3,2,4,5,6,3,7,8,3,10,3,2,4,5,6,3,7,8,3,10,3,2,4,5,6,3,7,8,3,10,3,2,4,5,6,3,7,8,3,10,3,2,4,5,6,3,7,8,3,10,3,2,4,5,6,3,7,8,3,10,3,2,4,5,6,3,7,8,3,3,4,5,1,6});

--for n = 60, p = 2. One steady state calculation is 42 sec w/o groebner basis, takes for ever with groebner basis
