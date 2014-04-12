
--- take a file that resulted in running benchmarks and extract the original system of equations
-- then calculate the average in-degree

restart
content := lines get "benchmarkAverageInDegree.txt"
RRR = QQ[apply(151, i -> ("x" | toString i ))]
--RRR = QQ[vars(0..151)]
posOfRandom = select( #content, i -> match( ///^random///, content_i ) )
systems := apply( posOfRandom, i -> content_(i+1) )    
total := sum(systems, system-> (
  supportSum := sum( flatten entries matrix(RRR, {value system}), poly -> #(support poly) );
  --supportSum := sum( flatten entries matrix(RRR, {value system}), poly -> #(support poly) );
  numberOfEquation := #(value system);
  av := supportSum / numberOfEquation;
  print toString promote(av, RR);
  print numberOfEquation;
	supportSum / numberOfEquation
))
total / (#systems)
promote(oo, RR)
  

