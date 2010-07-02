load "randfunc.m2"
load "limitcycle.m2"
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
needsPackage "limitcycle"

export {testOutFile, getFixedPoints }
exportMutable {}

dataFile = "fixedpointOutput.txt"

testOutFile = method()
testOutFile String := f -> dataFile = f

getFixedPoints = method()
for i from 10 to 20 do(
getFixedPoints (ZZ,ZZ,ZZ):= List=>  (i,valence,nterms) -> (
     QR := booleanRing i;     
     fout = openOutAppend dataFile;
     fout << "Computing fixed points" << endl;
     G:= toSequence makeBooleanNetwork(QR, valence, nterms);
     
    
     t1 := cpuTime();
     FPs := fixedPoints G;
     t2 := cpuTime();
     T := (t2-t1)/60;
     fout << "Fixed points are: " << endl << FPs << endl << "Cpu time: " << T << " minutes" << endl;
     fout << close;))
end

restart
loadPackage "testFP"
installPackage "limitcycle"
getFixedPoints (10,5,5)
