#!/usr/bin/perl
print "Content-type: text/html\n\n";
print <<ENDHTML;
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>
			ADAM User Guide
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
		<div id="main">
			<div id="nav">
ENDHTML

$navigation = &Constant_HTML('navigation.html');
print $navigation;
print <<ENDHTML;
				<h1>
					<font face="Verdana, Arial, Helvetica, sans-serif">Analysis of Discrete Algebraic Models User Guide</font>
				</h1>
				<p>
					<a name="top" id="top"></a>
				</p>
				<ul>
					<li>
						<a href="#Overview"><font face="Verdana, Arial, Helvetica, sans-serif">Overview</font></a>
					</li>
					<li>
						<a href="#LM"><font face="Verdana, Arial, Helvetica, sans-serif">How to Analyze a Logical Model (generated with GINsim)</font></a>
					</li>
					<li>
						<a href="#PDS"><font face="Verdana, Arial, Helvetica, sans-serif">How to Analyze a Polynomial Dynamical System (PDS)</font></a>
					</li>
					<li>
						<a href="#PBN"><font face="Verdana, Arial, Helvetica, sans-serif">How to Analyze a Probabilistic Network</font></a>
					</li>
					<li>
						<a href="#ModelType"><font face="Verdana, Arial, Helvetica, sans-serif">What is the <i>Model Type</i>?</font></a>
					</li>
					<li>
						<a href="#ModelInput"><font face="Verdana, Arial, Helvetica, sans-serif">What is the <i>Model Input</i>?</font></a>
					</li>
					<li>
						<a href="#Analysis"><font face="Verdana, Arial, Helvetica, sans-serif">What are the different <i>Analysis</i> Options?</font></a>
					</li>
					<li>
						<a href="#numStates"><font face="Verdana, Arial, Helvetica, sans-serif">What is the <i>number of states per node</i>?</font></a>
					</li>
					<li>
						<a href="#DG"><font face="Verdana, Arial, Helvetica, sans-serif">What is the <i>Dependency Graph</i>?</font></a>
					</li>
					<li>
						<a href="#PrintProb"><font face="Verdana, Arial, Helvetica, sans-serif">What is <i>Print Probabilities</i>?</font></a>
					</li>
					<li>
						<a href="#SS"><font face="Verdana, Arial, Helvetica, sans-serif">What is the <i>State Space Graph</i>?</font></a>
					</li>
					<li>
						<a href="#update"><font face="Verdana, Arial, Helvetica, sans-serif">What is the <i>Updating Scheme</i>?</font></a>
					</li>
					<li>
						<a href="#sim"><font face="Verdana, Arial, Helvetica, sans-serif">What is the <i>Simulation Option</i>?</font></a>
					</li>
					<li>
						<a href="#length"><font face="Verdana, Arial, Helvetica, sans-serif">What is <i>Limit Cycle Length</i></font></a>
					</li>
					<li>
						<a href="#circ"><font face="Verdana, Arial, Helvetica, sans-serif">What is <i>Feedback Circuit</i> output option?</font></a>
					</li><!-- <li>
						<a href="#O"><font face="Verdana, Arial, Helvetica, sans-serif">What is <i>Signed Edges</i> output option?</font></a>
					</li> -->
					<li>
						<a href="#boolean"><font face="Verdana, Arial, Helvetica, sans-serif">What is Boolean Input Format?</font></a>
					</li>
					<li>
						<a href="#how"><font face="Verdana, Arial, Helvetica, sans-serif">How is the Analysis without Simulation implemented?</font></a>
					</li>
					<li>
						<a href="#slow"><font face="Verdana, Arial, Helvetica, sans-serif">What if the Analysis is too Slow?</font></a>
					</li>
					<li>
						<a href="#src"><font face="Verdana, Arial, Helvetica, sans-serif">Where can I get the source code?</font></a>
					</li>
					<li>
						<a href="#authors"><font face="Verdana, Arial, Helvetica, sans-serif">Who contributes to ADAM?</font></a>
					</li>
					<li>
						<a href="#Ref"><font face="Verdana, Arial, Helvetica, sans-serif">References</font></a>
					</li>
				</ul>
				<hr>
				<h3>
					<a name="Overview" id="Overview">Overview</a>
				</h3>
				<p>
					ADAM is a web-based tool for the analysis and visualization of the dynamics of multi-state, discrete models of biological networks. Multi-state discrete models are characterized by a collection of functions. For a network of <i>n</i> nodes, the corresponding discrete model will have <i>n</i> functions, where the <i>i</i>-th function describes the state transitions of the <i>i</i>-th node in the network. The user may select one of three inputs: a GINsim file, a PDS (polynomial dynamical system), or a PBN (probabilistic Boolean network). The user may upload a file or enter functions into the text box. Based upon which input type the user selects, other input options may appear. The user is guided through additional input/output options. ADAM can calculate fixed points and limit cycles of a specified length, produce the dependency graph for all networks and the state space for networks which are simulated, the graph of trajectories starting from a given initial state, and identify functional circuits along with their signed edges. ADAM analyzes dynamics using a combination of simulation and abstract algebra techniques. The method of computation and the output will depend on options selected by the user.
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="LM" id="LM">How to Analyze a Logical Model (generated with GINsim)</a>
				</h3>
				<p>
					<img src="/UserGuide_files/phageLambda.png" alt="Logical Model of Phage Lambda" align="left">ADAM can analyze Logical Models generated with <a href="http://gin.univ-mrs.fr/">GINsim</a>. GINsim is a program to build a logical model for a biological system such as a gene regulatory network. Internally, ADAM converts a logical model to a polynomial dynamical system (PDS) via the method described in Veliz-Cuba et al., 2010<sup>1</sup> and then uses techniques from abstract algebra to analyze the PDS for key dynamics. ADAM will assign <i>x1</i> to <i>xn</i> to the variables used in the logical model, and states of the dynamic model are represented as vectors, where the first entry corresponds to the variable assigned to x1, and so on. For example, the logical model of <a href="http://gin.univ-mrs.fr/GINsim/model_repository/MICROBIOLOGICAL%20REGULATORY%20NETWORKS/Phage%20Lambda/PhageLambda/description.html">Phage Lambda</a> (left) is converted to the following PDS. ADAM determines the number of states per variable from the logical model, in this example, there are 5 different states per variable.<br>
				</p>
				<center>
					<img src="/UserGuide_files/phageLambdaPDS.png" alt="PDS of Phage Lambda" style="border:1px solid black;"><br>
				</center><br>
				The Logical Model can be analyzed (using <i>Algorithms</i> or <i>Simulation</i>). This Phage Lambda model has one fixed point or steady state, represented as <i>(2 0 0 0)</i>. This means, that C1 is 2, a medium concentration, because the first (<i>x<b>1</b></i> = C1) entry is 2, and the other three variables are 0, i.e., not expressed at all.<br>
				<br>
				Note: Currently ADAM is only compatible with GINsim 2.3. Please use GINsim version 2.3 to generate your models in order to analyze them with ADAM.
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="PDS" id="PDS">How to Analyze a Polynomial Dynamical System (PDS)</a>
				</h3>
				<p>
					The user can upload a text file (.txt) or directly enter the functions of a PDS. The <i>number of states per node</i> must be specified. It denotes the cardinality of the state set of the user's discrete network. Note that this must be a prime number. The software accepts positive prime integers up to 99. This value gives the total number of states that a node in the network can have. For example, if <i>number of states per node</i> = 3, then the possible states for any node are 0, 1, and 2. If the system is <b>Boolean</b>, i.e., the number of states per node is 2, then ADAM accepts functions in polynomial form, or in Boolean form (see <a href="#boolean">Boolean Input Format</a>).
				</p>
				<p>
					Each node of the user's network is represented by a variable. Variable names are <i>x1</i>, <i>x2</i>, etc. Function names are <i>f1</i>, <i>f2</i>, etc. The convention is that <i>fk</i> is the function which describes the state transitions of the node represented by <i>xk</i>. ADAM will use the functions from the input text box only when the user DOES NOT select a file to upload. The functions should follow the following formatting rules:
				</p>
				<ul>
					<li>The functions should begin with <i>f</i> followed by an integer, example <i>f1</i>, <i>f2</i>, <i>f3</i>,...,<i>fn</i>, where <i>n</i> is the number of variables
					</li>
					<li>Use * for multiplication, + for additions and ^ for exponents.
					</li>
					<li>The variables should begin with <i>x</i> followed by an integer, example <i>x1</i>, <i>x2</i>, <i>x3</i>,...,<i>xn</i>, where <i>n</i> is the number of states
					</li>
				</ul>
				<p>
					The PDS can be analyzed (using <i>Algorithms</i> or <i>Simulation</i>). For small networks (less than 10 nodes), the complete state space can be simulated and all attractors (fixed points and limit cycles) are found. In addition to that, the size of each component, i.e., the basin of attraction, are determined. For larger networks, a simulation of the complete state space is not possible. Instead, ADAM uses tools from computational algebra, to find all fixed points or limit cycles of a given length. The algorithms that ADAM uses are fast for sparse systems, a structure maintained by most biological systems. ADAM can easily compute fixed points for systems with 50 or 100 nodes, as long as every node has only a few neighbors in the wiring diagram, i.e., only a few variables appear in each function.
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="PBN" id="PBN">How to Analyze a Probabilistic Network</a>
				</h3>
				<p>
					<img src="/UserGuide_files/PBN_SS.gif" width="350" alt="sample probabilistic network" align="left">ADAM can visualize the state space of a (small) probabilistic network. In the state space of a probabilistic network, all possible transitions from one state to the next are drawn, together with their probability, if <i>Print Probabilities</i> is checked. The <i>number of states per node</i> must be specified. It denotes the cardinality of the state set of the user's discrete network. Note that this must be a prime number. The software accepts positive prime integers up to 99. This value gives the total number of states that a node in the network can have. For example, if <i>number of states per node</i> = 3, then the possible states for any node are 0, 1, and 2. If the system is Boolean, i.e., the number of states per node is 2, then ADAM accepts functions in polynomial form, or in Boolean form (see <a href="#boolean">Boolean Input Format</a>).<br>
					<br>
					Probabilistic Networks can be entered by using <b>{</b> and <b>}</b> around several possible functions for one variable. If not specified, the functions have uniform probability, if the user wants to impose a distribution on the functions, the probability can be specified behind the function, separated with the pound symbol, <b>#</b>.<br>
				</p>
				<center>
					<img src="/UserGuide_files/PBN.png" alt="sample probabilistic network"><br>
				</center>In probabilistic networks, fixed points are defined as state that <i>could</i> remain the same when updated. The <i>stability</i> of a fixed point is its probability to not change in the next iteration. Fixed points with stability 1 are <b>true fixed points</b>, as they can never transition to another state. ADAM determines true fixed points of probabilistic networks by simulation for smaller networks, or by using algorithms from computational algebra for systems too complex for simulation. Bounded Petri Nets can be represented as probabilistic networks<sup>1</sup>. In the terminology of petri nets, fixed points with stability one are <b>deadlocks</b>.
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="ModelType" id="ModelType">What is the <i>Model Type</i>?</a>
				</h3>
				<p>
					ADAM can analyze a logical Model (.ginml file generated with <a href="http://gin.univ-mrs.fr/">GINsim</a>), a polynomial dynamical system (PDS), or a probabilistic network.
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="ModelInput" id="ModelInput">What is the <i>Model Input</i>?</a>
				</h3>
				<p>
					The user can upload the model as a file, or, for PBS or PN, enter it directly. Logical Models must be provided as <i>.ginml</i> files, PBS and PN as <i>.txt</i> files.
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="Analysis" id="Analysis">What are the different <i>Analysis</i> Options?</a>
				</h3>
				<p>
					ADAM will simulate dynamics for the <i>Simulation</i> option (11 nodes or less), meaning it computes the transition states from all possible initializations. When simulating, ADAM will output the analysis results as well as the graph of the state space. For <i>Algorithms</i> ADAM uses algebra to solve for fixed points and limit cycles of a specified length. ADAM uses a separate algorithm to compute dynamics in the case of <i>Conjunctive/Disjunctive</i> Networks. Conjunctive Boolean networks consist of functions containing only one monomial term, i.e. the functions use only the AND operator. Conversely, Disjunctive Boolean networks consist of functions which use only the OR operator. Note that the <i>Conjunctive/Disjunctive</i> option only works for functions defined in a Boolean ring, i.e. there can be only two states per node. (see <a href="#numStates">What is the <i>number of states per node</i>?</a>) Furthermore, <i>Conjunctive/Disjunctive</i> networks currently works only for strongly connected graphs. When input is analyzed with either the <i>Algorithms</i> or <i>Conjunctive/Disjunctive network</i> option, ADAM displays the fixed points and limit cycles in a table.
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="numStates" id="numStates">What is the <i>number of states per node</i>?</a>
				</h3>
				<p>
					The states, or varying levels of concentration a protein may have or gene expression levels. If the number of states per node of a model is 2, then it is a Boolean model, with genes being either on, 0, or off, 1. In a model with 3 states, 0 can represent the state in which a gene is not expressed, 1 a gene with a medium expression level, and 2 a high leve. 
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="DG" id="DG">What is the <i>Dependency Graph</i>?</a>
				</h3>
				<p>
					The <b>dependency graph</b> or <b>wiring diagram</b> shows the static relationship between the nodes by directed edges. A directed edge from variable <i>xi</i> to <i>xj</i> means that <i>xi</i> affects the state of <i>xj</i>. In ADAM, all edges in the dependency graph are functional.
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="PrintProb" id="PrintProb">What is <i>Print Probabilities</i>?</a>
				</h3>
				<p>
					For probabilistic networks, ADAM can print the probability for each transition in the state space. See <a href="#PBN">Probabilistic Networks</a>.
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="SS" id="SS">What is the <i>State Space Graph</i>?</a>
				</h3>
				<p>
					The state space is a graph where the nodes are the states of the system, and the arrows indicate, how the state dynamically change with each iteration.
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="update" id="update">What is the <i>Updating Scheme</i>?</a>
				</h3>
				<p>
					This will determine the order in which to evaluate the functions.<br>
				</p>
				<ul>
					<li>
						<b>Synchronous</b>: all functions get evaluated at the same time
					</li>
					<li>
						<b>Sequential</b>: the functions are evaluated in some specified order. The function indices must be entered in the input box provided with each index used exactly once and should be in the range 1 to n (number of nodes)
					</li>
					<li style="list-style: none">For all polynomial dynamical systems asynchronous/synchronous updating yields the same fixed points. This is particularly helpful for the logical modeling community because most of their updating is done asynchronously. Note that this option applies only to <i>PDS</i>.
					</li>
				</ul>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="sim" id="sim">What is the <i>Simulation Option</i>?</a>
				</h3>
				<p>
					If the user selects the option to view the <i>Complete State Space</i>, the software computes the number of connected components in the state space, as well as some statistics of the components. It displays the number of states in a component and the length of the cycle. (Since these discrete models are finite, each component necessarily has a cycle. Because the models are deterministic - they are characterized by a set of rules, given by functions - there is only one cycle per component.) If there are fixed points (i.e., cycles of length 1), then it prints the state, along with the size of its component. If the user selects the option to view the graphs, the corresponding links will be displayed which will show the graph.
				</p>
				<p>
					<img src="/UserGuide_files/traj.gif" align="left" alt="Visualization of a trajectory"> The user can view the trajectory of one initialization only, if he selects that option. The input text box next to the option is where the user needs to provide the initialization. The states in the initialization should be separated by spaces. For example 1 0 0 0 1 , 2 0 3 2 1 or 11 12 10 0 1. It is important to separate the states by spaces in order for the software to distinguish between the different states. On clicking <i>Analyze</i>, the trajectory will be printed in a vertical fashion (one on each line) and will stop once it finds a repeated pattern. If the user has selected the option to view the state space graph, a link will be displayed which will show the graph and the cycle will be colored. The initial states provided by the user will be in the box shaped node. Below is a snapshot of the trajectory generated using example functions from Figure a with initialization 2 0 1. Single trajectories can be computed and visualized, when the network is too complex to generate the complete state space.<br>
					<br>
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="length" id="length">What is <i>Limit Cycle Length</i>?</a>
				</h3>
				<p>
					For large networks, the user has to specify the length of limit cycles that ADAM is computing. Limit cycles of length 1 are the same as fixed points.
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="circ" id="circ">What is <i>Feedback Circuit</i> output option?</a>
				</h3>
				<p>
					ADAM can analyze the model for feedback circuits. It will list all functional circuits.
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div><!-- <h3>
									<a name="signed" id="signed">What is <i>Signed Edges</i> output option?</a>
								</h3>
								<p>
									TODO
								</p>
								<div align="right">
									<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
								</div> -->
				<h3>
					<a name="boolean" id="boolean">What is Boolean Input Format?</a>
				</h3>
				<p>
					ADAM provides the user withs the option to specify how the operations in the function file should be interpreted. For example, 'x1*x2' could be interpreted as polynomial multiplication of variables or as the Boolean AND operation. If the user provides functions that are in the Boolean format, ADAM will convert the Boolean functions to polynomial functions to do the computations. This only works, when <i>number of states per node</i> is 2. The Boolean function file must adhere to the following format:<br>
					<br>
				</p>
				<center>
					<table border="1" cellpadding="10" cellspacing="0" summary="Boolean input">
						<tr>
							<td>
								<b>Boolean operator</b>
							</td>
							<td>
								<b>Written as</b>
							</td>
						</tr>
						<tr>
							<td>
								<center>
									AND
								</center>
							</td>
							<td>
								<center>
									*
								</center>
							</td>
						</tr>
						<tr>
							<td>
								<center>
									OR
								</center>
							</td>
							<td>
								<center>
									+
								</center>
							</td>
						</tr>
						<tr>
							<td>
								<center>
									NOT
								</center>
							</td>
							<td>
								<center>
									~
								</center>
							</td>
						</tr>
					</table>
				</center>
				<p>
					<br>
					The Boolean functions should also be <u>fully bracketed infix expressions</u>. For example, the Boolean function<br>
					<br>
				</p>
				<center>
					x1 OR x3 OR (x2 AND NOT x3)
				</center>
				<p>
					<br>
					should be entered as<br>
					<br>
				</p>
				<center>
					((x1+x3)+(x2*(~x3)))
				</center>
				<p>
					<br>
					or<br>
					<br>
				</p>
				<center>
					(x1+(x3+(x2*(~x3))).
				</center>
				<p>
					<br>
					In particular, please do <b>not</b> use unnecessary parenthesis. For example, the following is interpreted wrongly because of the extra parenthesis around x1:<br>
					<br>
				</p>
				<center>
					(x1*((x1)+x2)).
				</center>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="how" id="how">How is the Analysis without Simulation implemented?</a>
				</h3>
				<p>
					There are two options for analysis without simulation. The first is specifically for conjunctive/disjunctive networks. If the user has a Boolean network consisting solely of AND operators (conjunctive) or solely of OR operators (disjunctive), then ADAM will compute the number of fixed points and limit cycles according to algorithms from Salam Jarrah et al.<sup>2</sup>. It will also output what the fixed points and limit cycles are using Gröbner basis computations.
				</p>
				<p>
					The second option is for general networks. For networks that are too large to analyze with simulation, we use Gröbner bases. The user specifies a limit cycle length they would like to find, and our algorithm finds all limit cycles of that length.
				</p>
				<p>
					In the worst case, computing Gröbner bases for a polynomial system has a complexity of doubly exponential in the number of solutions to the system. However, in practice Gröbner bases are computable in a reasonable time. Furthermore, for sparse systems in a finite field it is actually fairly quick. It has been shown that computing Gröbner bases in modular form is much faster in general. <sup>3</sup> In addition, sparse polynomials mean that simpler S-polynomials, usually of comparable length, will be added to the basis, which means less computation is involved. In short, the sparse structure of biological systems is preserved by Gröbner bases, causing our algorithms to be both efficient and fast.
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="slow" id="slow">What if the Analysis is too Slow?</a>
				</h3>
				<p>
					If the analysis is too slow, it is probably due to a combination of: having too many nodes in the network, having functions that are too dense, and searching for limit cycle lengths that are too long. Finding a limit cycle of length <i>n</i> involves composing the system of equations <i>n</i> times - this means functions become more dense as <i>n</i> increases. As explained in <a href="#how">How is the Analysis without Simulation implemented?</a>, the Gröbner basis algorithm is faster for sparse polynomials.
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="src" id="src">Where can I get the source code?</a>
				</h3>
				<p>
					The source code is not on a public repository at the moment. If you would like a copy of it, please e-mail <a href="mailto:fhinkel@vt.edu">Franziska Hinkelmann</a> for now.
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="authors" id="authors">Who contributes to ADAM?</a>
				</h3>
				<p>
					<a href="mailto:fhinkel@vt.edu">Please email us if you have any problems!</a><br>
					<font face="Verdana, Arial, Helvetica, sans-serif">Madison Brandon<br>
					Nick Eriksson<br>
					Bonny Guang<br>
					Abdul Jarrah<br>
					Franziska Hinkelmann<br>
					Reinhard Laubenbacher<br>
					Rustin McNeill<br>
					Brandilyn Stigler<br>
					Hussein Vastani<br>
					<a href="http://img10.imageshack.us/img10/9024/p7080016crop.png">Chuck</a><br></font>
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h3>
					<a name="Ref" id="Ref">References</a>
				</h3>
				<p>
					<sup>1</sup>Veliz-Cube A., Salam Jarrah A., Laubenbacher R., (2010) Polynomial Algebra of Discrete Models in Systems Biology.<br>
					<sup>2</sup>Salam Jarrah A., Laubenbacher R., Veliz-Cuba A., (2008) The Dynamics of Conjunctive and Disjunctive Boolean Network Models. <i>Bioinformatics</i><br>
					<sup>3</sup>Brown W.S. (1971) On Euclid's Algorithm and the Computation of Polynomial Greatest Common Divisors. <i>Journal of the ACM</i>.
				</p>
				<div align="right">
					<a href="#top"><font size="-1" color="#FF0000">Return to the top</font></a>
				</div>
				<h2>
					<a href="/cgi-bin/git/adam.pl">Back to ADAM</a>&nbsp;&nbsp;&nbsp; <a href="/steptutorial.htm">Step-by-step tutorial</a>
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
