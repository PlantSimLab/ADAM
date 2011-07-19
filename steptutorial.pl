#!/usr/bin/perl
print "Content-type: text/html\n\n";
print <<ENDHTML;
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
	<head>
		<title>
			ADAM Step-by-step tutorial
		</title>
		<link rel="stylesheet" type="text/css" href="/adam_style.css">
	</head>
	<body>
		<div id="header">
ENDHTML

$header = &Constant_HTML('header.html');
print $header;
print <<ENDHTML;
		</div>
		<div id="main" >
			<div id="nav">
ENDHTML

$navigation = &Constant_HTML('navigation.html');
print $navigation;
print <<ENDHTML;
			<h1>
				Detailed examples of how to use ADAM
			</h1>
			<p><font size="2">
				<a href="#GS">Logical Model (GINsim)</a> &nbsp;&nbsp;&nbsp; <a href="#PDS">Polynomial Dynamical System</a> &nbsp;&nbsp;&nbsp; <a href="#PBN">Probabilistic Boolean Network</a> &nbsp;&nbsp;&nbsp; <a href="#LN">Large Network</a> &nbsp;&nbsp;&nbsp; <a href="#conj">Conjunctive Network</a></font>
			</p>
			<h2>
				<a name="GS" id="GS">How to use a Logical Model (GINsim file) as an input</a>
			</h2>
			<p>
				Select <b>Logical Model</b> as the format of the input functions
			</p>
			<p>
				Note that input for number of states per node is not allowed as it is not needed. Adam pulls this information from the GINsim file.
			</p>
			<p>
				Upload the 4 node Lambda Phage model named regulatoryGraph.ginml (inside the zipped folder phage4.zginml available <a href="http://gin.univ-mrs.fr/GINsim/model_repository/MICROBIOLOGICAL%20REGULATORY%20NETWORKS/Phage%20Lambda/PhageLambda/description.html">here</a>)
			</p>
			<p>
				Select Simulation (as the model is small enough with only four nodes)
			</p>
			<p>
				<img border="0" width="434" height="347" src="steptutorial_files/image002.png">
			</p>
			<p>
				Click <i>Analyze</i> to view the outputs
			</p>
			<p>
				<img border="0" width="434" height="111" src="steptutorial_files/image004.png">
			</p>
			<h2>
				<a name="PDS" id="PDS">How to enter a Polynomial Dynamical System</a>
			</h2>
			<p>
				Select <b>PDS</b> as the format for input functions
			</p>
			<p>
				Enter the number of states each node may have. For this example, enter 3. This indicates each node may be 0, 1 or 2
			</p>
			<p>
				Enter the functions in the text box below. For this example we will have 2 functions. Enter
			</p>
			<p>
				f1 = x1*x2
			</p>
			<p>
				f2 = x1+x2
			</p>
			<p>
				Under network options, select simulation, as there are only 2 nodes. Leave synchronous selected for the updating scheme to have the states updated synchronously, and leave all trajectories selected to view the entire state space.
			</p>
			<p>
				<img border="0" width="434" height="183" src="steptutorial_files/image006.png">
			</p>
			<p>
				<img border="0" width="434" height="181" src="steptutorial_files/image008.png">
			</p>
			<p>
				Click <i>Analyze</i> to view the results.
			</p>
			<p>
				<img border="0" width="314" height="128" src="steptutorial_files/image010.png">
			</p>
			<h2>
				<a name="PBN" id="PBN">How to Enter a Probabilistic Boolean Network</a>
			</h2>
			<p>
				Select <b>PBN</b> as the format for function input.
			</p>
			<p>
				The number of states per node must now be set to 2 and the drop-box to the right must be changed from polynomial to boolean.
			</p>
			<p>
				For this example, enter the following for the functions:
			</p>
			<p>
				f1 = (x1*x2)
			</p>
			<p>
				f2 = (x1+x3)
			</p>
			<p>
				f3 = (~(x1+x2))
			</p>
			<p>
				This is read as f1 equals x1 AND x2, f2 equals x1 OR x3, f3 equals NOT (x1 OR x2). Note that each operation must have a set of parenthesis that correspond to it. It is important not to place extra sets of parenthesis in any of the equations. Note that changing f3 to (~((x1)+x2)) gives a different, incorrect output as there is an unnecessary set of parenthesis around x1.
			</p>
			<p>
				Under network options, select simulation, as there are only 3 nodes. Leave synchronous selected for the updating scheme to have the states updated synchronously, and leave all trajectories selected to view the entire state space.
			</p>
			<p>
				<img border="0" width="434" height="128" src="steptutorial_files/image012.png">
			</p>
			<p>
				<img border="0" width="434" height="171" src="steptutorial_files/image014.png">
			</p>
			<p>
				Click Analyze to view the ouput, which should be as follows:
			</p>
			<p>
				<img border="0" width="414" height="130" src="steptutorial_files/image016.png">
			</p>
			<h2>
				<a name="LN" id="LN">How to Enter a Large Network (number of nodes &gt; 11)</a>
			</h2>
			<p>
				Select GINsim as the format of the input functions.
			</p>
			<p>
				Note that input for number of states per node is not allowed as it is not needed. Adam pulls this information from the GINsim file.
			</p>
			<p>
				Upload the TCR model named TCRsig40.ginml(inside the zipped folder phage4.zginml available <a href="http://gin.univ-mrs.fr/GINsim/model_repository/MAMMALIAN%20REGULATORY%20NETWORKS/T%20lymphocytes/TCR_sig/description.html">here</a>).
			</p>
			<p>
				Select Algorithms (as the model has 40 nodes and its state space is too large to be simulated), and enter 7 for the limit cycle length to view all 7-cycles.
			</p>
			<p>
				<img border="0" width="434" height="233" src="steptutorial_files/image018.png">
			</p>
			<p>
				Click <i>Analyze</i> to view the results. There is one 7-cycle.
			</p>
			<p>
				<img border="0" width="434" height="39" src="steptutorial_files/image020.png">
			</p>
			<h2>
				<a name="conj" id="conj">How to Enter a Conjunctive Network</a>
			</h2>
			<p>
				Select <b>PBN</b> the format of input functions for this example (either PDS or PBN may be used).
			</p>
			<p>
				The number of states per node must be set to two. Select Boolean as we are entering a PBN, but for a PDS select Polynomial.
			</p>
			<p>
				In the function box enter
			</p>
			<p>
				f1 = (x1*x3)
			</p>
			<p>
				f2 = (x2*x1)
			</p>
			<p>
				f3 = (x2*x3)
			</p>
			<p>
				The functions must only use either the AND operator or the OR operator. Additionally, the dependency graph formed from these functions must be strongly connected.
			</p>
			<p>
				<img border="0" width="434" height="128" src="steptutorial_files/image022.png">
			</p>
			<p>
				Select Conjunctive network.
			</p>
			<p>
				Leave synchronous selected for the updating scheme to have the states updated synchronously, and leave all trajectories selected to view the entire state space.
			</p>
			<p>
				<img border="0" width="434" height="181" src="steptutorial_files/image024.png">
			</p>
			<p>
				Click <i>Analyze</i> to view the results
			</p>
			<p>
				<img border="0" width="434" height="49" src="steptutorial_files/image026.png">
			</p>
		</div>
		<div id="nav">
			<h2>
				<a href="/cgi-bin/git/adam.pl">Back to ADAM</a>&nbsp;&nbsp;&nbsp; <a href="/userGuide.html">User Guide</a>
			</h2>
		</div>
		</div>
	</body>
</html>

ENDHTML

# read in a file to include it
sub Constant_HTML {
  local(*FILE); # filehandle
  local($file); # file path
  local($HTML); # HTML data

  $file = $_[0] || die "There was no file specified!\n";

  open(FILE, "<$file") || die "Couldn't open $file!\n";
  $HTML = do { local $/; <FILE> }; #read whole file in through slurp #mode (by setting $/ to undef)
  close(FILE);

  return $HTML;
}
