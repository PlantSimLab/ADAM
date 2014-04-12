newPackage(
	"testFP",
	Version => "1.0",
	Date => "June 23, 2010",
	Authors => {
		{Name => "Bonny Guang, Madison Brandon, Rustin McNeill,
		Franziska Hinkelmann" }},
	Headline => "Test how many fixed points limitcycle.m2 can compute in
	half an hour")


needsPackage "randfunc"
needsPackage "solvebyGB"

export {testOutFile, getFixedPoints }
exportMutable {}

dataFile = "fixedpointOutput.txt"

testOutFile = method()
testOutFile String := f -> dataFile = f

getFixedPoints = method()
for i from 10 to 20 do(
getFixedPoints (ZZ,ZZ,ZZ):= List=>  (i,valence,nterms) -> (
     p := (2,3,5,7);
     QR := makeRing(i,  p_(random (#p)));     
     fout = openOutAppend dataFile;
     fout << "Computing fixed points for " << i << " variables in F_" << char QR << "." << endl;
     G:=  makeBooleanNetwork(QR, valence, nterms);
     
    
     t1 := cpuTime();
     FPs := gbSolver(G, 1); -- only check for fixed points
     t2 := cpuTime();
     T := (t2-t1);
     fout << "Fixed points are: " << endl << FPs << endl << "Cpu time: " << T << " seconds" << endl;
     fout << close;))
end

restart
loadPackage "testFP"
load "../gbHelper.m2"
installPackage "gbHelper"
installPackage "solvebyGB"
installPackage "FP"
load "../solvebyGB.m2"
load "../FP.m2"

restart
loadPackage "testFP"
getFixedPoints (20,3,10)

scan( (1..100), i -> getFixedPoints (10*i,3,10))
