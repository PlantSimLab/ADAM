#!/usr/bin/perl

## Hussein Vastani 
## Franziska Hinkelmann
## Bonbons
## June 2010

## Visualizer for controlled Polynomial Dynamical Systems

use CGI qw( :standard );
use Fcntl qw( :flock );

`mkdir -p ../../htdocs/no-ssl`;
`touch ../../htdocs/no-ssl/accessControl`;
#get the clients ip address
$clientip = $ENV{'REMOTE_ADDR'};
$clientip =~ s/\./\-/g;
($sec,$min,$hr) = localtime();
$clientip = $clientip.'-'.$sec.'-'.$min.'-'.$hr;
$clientip = '../../htdocs/no-ssl/files/'. $clientip;

#$clientip = $sec.'-'.$min.'-'.$hr;


print header, start_html( -title=>'Visualizer of Controlled Polynomial Dynamical Systems Web Interface', -script=>{-language=>'JavaScript',-src=>'/fnct2.js'});
print "<center><img src=\"vbi-logo.png\"></center>";
print start_multipart_form(-name=>'form1', -method =>"POST", -onSubmit=>"return validate()");
print "<div style=\"font-family:Verdana,Arial\"><div id=\"tipDiv\" style=\"position:absolute\; visibility:hidden\; z-index:100\"></div>";
print "<table background=\"http://dvd.vbi.vt.edu/gradient.gif\" width=\"100%\"  border=\"0\" cellpadding=\"0\" cellspacing=\"10\">";
print "<tr><td align=\"center\" colspan=\"2\"><b><font size=\"5\">Visualizer of Controlled Polynomial Dynamical Systems v0.9 </font></b><br>";
print "<font size=2><a href=\"http://www.math.vt.edu/people/fhinkel/\">Franziska Hinkelmann</a></font><p>";
print "You can visualize a controlled Polynomial dynamical system. This is experimental, please be patient with us. Thank you for trying it out! If you have any questions or comments, <a href=\"mailto:fhinkel@vt.edu\">please email us</a>!</td></tr>";

## This is the box around Network Description
print "<tr><td><table width=\"90%\" align=\"center\" border=\"0\" bgcolor=\"#ABABAB\"  cellpadding=\"1\" cellspacing=\"0\"><tr><td>";
##
print "<table border=\"0\" bgcolor=\"#FFFFCC\" width=\"100%\" cellspacing=\"0\" cellpadding=\"1\"><tr valign=\"top\"><td bgcolor=\"#666666\" nowrap>";
print "<strong><font color=\"#FFFFFF\">Network Description</font></strong></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";

## number of state variables
print "<tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\"><br>Enter number of state variables: </font>",
  textfield(-name=>'n_nodes', -size=>2, -maxlength=>2, -default=>4),
  "<font size=2> (For more than 10 variables, no graph is generated)</font>";
print "<br>";
print "<br>";

## number of control variables
print "</td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\"><br>Enter number of control variables: </font>",
  textfield(-name=>'u_nodes', -size=>2, -maxlength=>2, -default=>2);
print "<br>";
print "<br>";

## p value
print "</td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr><tr valign=\"top\"><td nowrap><font size=\"2\"><br>Enter number of states per node: </font>";
print textfield(-name=>'p_value',-size=>2,-maxlength=>2, default=>2),
  "<font size=2> (Must be a prime number)</font>";
print "<br>";
print "<br>";

## Explainations
print "</td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr><tr valign=\"top\"><td wrap><font size=\"2\">";
print "<br>";
print "A controlled polynomial dynamical system has a number of state variables x1, ... xn <br>"; 
print "and a number of control variables u1, ..., um. The idea is, that the system evoles according <br>";
print "to certain rules, this corresponds to a regular PDS, but the control variables can be <br> externally controlled. Therefore ";
print "the state space of a controlled PDS looks slighlty different <br>than that of a regular PDS: ";
print "There are p^n states where each state has out-degree at <br>most 2^u. Every edge in the graph is ";
print "labeled with the control that has been applied at this transition. <br>";
print "<br>";

print "</td></tr>";
print "</table>";
print "<tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print "</td></tr></table>";

# Input Functions Block
print "<td><table width=\"90%\" cellSpacing=\"0\" cellPadding=\"1\" align=\"center\" bgColor=\"#ababab\" border=\"0\"><tr><td><table cellSpacing=\"0\" cellPadding=\"1\" width=\"100%\" bgColor=\"#ffffcc\" border=\"0\">";

print "<tr valign=\"top\"><TD nowrap bgColor=\"#666666\"><strong><font
color=\"#ffffff\">Input Functions</font></strong></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";

#print "<tr valign=\"top\"><td nowrap><font size=\"2\">Select function file (not functional!): </font>",filefield(-name=>'upload_file');
#print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#F\" onmouseover=\"doTooltip(event,2)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a>";
#

#print "</td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
#print "<tr><td><div align=\"center\"><b>OR</b> <font size=\"2\" color=\"#006C00\">(Edit functions below)</font></div></td></tr>";
print "<tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr><tr valign=\"top\"><td nowrap><div align=\"center\">";
print textarea(-name=>'edit_functions',
               -default=>
'f1 = x1 + x2 + u1
f2 = u2 + x1 * x3
f3 = x2 * u1 
f4 = x1 + u1 + u2
',
			   -rows=>8,
			   -columns=>50);
print "</div></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";

# Initial and final states
print "<tr valign=\"top\"><td nowrap><font size=\"2\">";
print checkbox(-name =>'findControl', -value=>'1', -label=>'Use heuristic controller to find control sequence', -checked=>1 );
print "<br>";
print "Enter initial state, separated by spaces: ", textfield( -name=>'initialState', -size=>20, -default=>'1 0 1 1');
print "<br>";
print "<br>";
print "Enter final state, separated by spaces: &nbsp   ", textfield( -name=>'finalState', -size=>20, -default=>'0 0 1 1');
print "<br>";
print "<br>";
print "A heuristic algorithm will try to find the cheapest trajectory from the initial to the <br>";
print "final state. Cheap means with the cheapest possible control. As this is an experimental <br>";
print "version, we consider uniform cost for every control variable that is set, i.e., not 0.<br>";
print "If a sequence of control inputs is found, that drives the system from the initial state <br>";
print "to the final state, this trajectory is highlighted in the state space graph in green. If <br>";
print "no sequence can be found, no trajectory will be highlighted in the phase space. <br>";
print "<br>";

print "</div></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print "</table></td></tr></table></td></tr>";

## State Space Specification
#print"<tr><td><table width=\"90%\" align=\"center\" border=\"0\" bgcolor=\"#ABABAB\"  cellpadding=\"1\" cellspacing=\"0\"><tr><td>";
#print"<table border=\"0\" bgcolor=\"#FFFFCC\" width=\"100%\" cellspacing=\"0\" cellpadding=\"1\"><tr valign=\"top\"><td bgcolor=\"#666666\" nowrap>";
#print"<strong><font color=\"#FFFFFF\">State Space Specification (not functional)</font></strong></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
#print"<tr valign=\"top\"><td nowrap><font size=\"2\">Generate state space of";
#print"&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#S\" onmouseover=\"doTooltip(event,5)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
#print radio_group(-name=>'option_box', -values=>['All trajectories from all possible initial states', 'One trajectory starting at an initial state'], -default=>'All trajectories from all possible initial states', -linebreak=>'true',); 
#print "&nbsp\;&nbsp\;&nbsp\;&nbsp\;- Enter initialization separated by spaces: ",textfield(-name=>'trajectory_value', -size=>20);
#print"</font></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr></table></td></tr></table></td><td>";

### Additional Output Specification
#print"<table width=\"90%\" align=\"center\" border=\"0\" bgcolor=\"#ABABAB\" cellpadding=\"1\" cellspacing=\"0\"><tr><td>";
#print"<table border=\"0\" bgcolor=\"#FFFFCC\" width=\"100%\" cellspacing=\"0\" cellpadding=\"1\"><tr valign=\"top\">";
#print"<td bgcolor=\"#666666\" nowrap><b><font color=\"#FFFFFF\">Additional Output Specification (not functional) &nbsp\;<span style=\"background-color:#808080\">(optional)</span></font></b>";
#print"&nbsp\;&nbsp\;&nbsp\;</td>";
#print"</tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr><tr valign=\"top\"><td nowrap><font size=\"2\">View";
#print"&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#G\" onmouseover=\"doTooltip(event,6)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
#print"<font color=\"#006C00\"><i>Select graph(s) to view and image 
#format.</i></font><br>";
#print checkbox_group(-name=>'statespace', -value=>'State space graph', -label=>'State space graph'),"&nbsp\;&nbsp\;&nbsp\;", popup_menu(-name=>'SSformat',-values=>['*.gif','*.jpg','*.png','*.ps']), "&nbsp\;&nbsp\;&nbsp\;", checkbox_group(-name =>'stochastic', -value=>'Print probabilities', -label=>'Print probabilities', -checked),"<br>";
#print checkbox_group(-name=>'depgraph', -value=>'Dependency graph',
#-label=>'Dependency graph'), "&nbsp\;&nbsp\;&nbsp\;", popup_menu(-name=>'DGformat',-values=>['*.gif','*.jpg','*.png','*.ps']);
#print"</font></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr></table></td></tr></table></td></tr>";
print "<tr>";
print "<br>";
print"<td align=\"center\" colspan=\"2\">",submit('button_name','Generate')," <br><font color=\"#006C00\"><br><i>Results will be displayed below.</i></font></td></tr></table></div>"; 

##Google Analytics, Franzi's Account
#print <<ENDHTML;
#<script type="text/javascript">
#var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
#document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
#</script>
#<script type="text/javascript">
#try {
#var pageTracker = _gat._getTracker("UA-11219893-5");
#pageTracker._trackPageview();
#} catch(err) {}</script>
#ENDHTML

print end_form;

open(ACCESS, ">>../../htdocs/no-ssl/accessControl") or die("Failed to open file for writing");
flock(ACCESS, LOCK_EX) or die ("Could not get exclusive lock $!");
print ACCESS ($ENV{REMOTE_ADDR});
system("date >>../../htdocs/no-ssl/accessControl");
flock(ACCESS, LOCK_UN) or die ("Could not unlock file $!");
close(ACCESS);

$p_value = param('p_value');
$n_nodes = param('n_nodes');
$u_nodes = param('u_nodes');
$functions = param('edit_functions');

$heuristicControl = param('findControl');
$initialState = param( 'initialState');
$finalState = param( 'finalState');



$DEBUG = 0;

print "access was ok <br>" if ($DEBUG);
print "client ip is $clientip <br>" if ($DEBUG);
print "$n_nodes<br>" if ($DEBUG);
print "$u_nodes<br>" if ($DEBUG);
print "$p_value<br>" if ($DEBUG);
print "$functions<br>" if ($DEBUG);


print "$initialState<br>" if ($DEBUG);
print "$finalState<br>" if ($DEBUG);
print "$heuristicControl<br>" if ($DEBUG);

if ($heuristicControl eq "1") {
  if ($initialState ne null) {
    $initialState = &cleanUpState( $initialState );
  }
  if ($finalState ne null) {
    $finalState = &cleanUpState( $finalState );
  }
  print "<font color=blue><b>Finding heuristic controller from $initialState to $finalState:</b></font><br>";
} else {
  $initialState = "";
  $finalState = "";
}


$DEBUG = 1;

$DEBUG = 0;

$ret = system("ruby control_runner.rb $n_nodes $u_nodes $p_value \"$functions\" $clientip.out.gif $initialState $finalState");


if ( $ret == 0 ) {
  print "everything ok" if ($DEBUG);
  if (-e "$clientip.out.gif") {
    print  "<A href=\"$clientip.out.gif\" target=\"_blank\"> <font color=red><i>Click to view the state space graph of your controlled polynomial dynamical system.</i></font></A><br>";
  }
} else {
  print "<br><font color=red>Sorry. Something went wrong.</font><br>";
  die("Program quitting. Unknown error");
}


print end_html();

sub cleanUpState() {
  ($s) = @_;
  $s =~ s/^\s+|\s+$//g; #remove all leading and trailing white spaces
  $s =~  s/(\d+)(\s+|,+)+/$1 /g; # remove extra spaces in between the numbers
  $s =~ s/ /_/g;
  $s;
}



