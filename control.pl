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
print start_multipart_form(-name=>'form1', -method =>"POST", -onSubmit=>"return validate()");
print "<div style=\"font-family:Verdana,Arial\"><div id=\"tipDiv\" style=\"position:absolute\; visibility:hidden\; z-index:100\"></div>";
print "<table background=\"http://dvd.vbi.vt.edu/gradient.gif\" width=\"100%\"  border=\"0\" cellpadding=\"0\" cellspacing=\"10\">";
print "<tr><td align=\"center\" colspan=\"2\"><b><font size=\"5\">Visualizer of Controlled Polynomial Dynamical Systems v0.9
</font></b><p>";
print "You can visualize a controlled Polynomial dynamical system. This is experimental, please be patient with us. Thank you for trying it out! If you have any questions or comments, <a href=\"mailto:fhinkel@vt.edu\">feel free to email us</a>.</td></tr>";

## This is the box around Network Description
print "<tr><td><table width=\"90%\" align=\"center\" border=\"0\" bgcolor=\"#ABABAB\"  cellpadding=\"1\" cellspacing=\"0\"><tr><td>";
##
print "<table border=\"0\" bgcolor=\"#FFFFCC\" width=\"100%\" cellspacing=\"0\" cellpadding=\"1\"><tr valign=\"top\"><td bgcolor=\"#FF8000\" nowrap>";
print "<strong><font color=\"#FFFFFF\">Network Description</font></strong></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";

## number of state variables
print "<tr valign=\"top\"><td nowrap><font size=\"2\">Enter number of state variables: </font>",
  textfield(-name=>'n_nodes', -size=>2, -maxlength=>2, -default=>4),
  "&nbsp &nbsp &nbsp";
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#N\" onmouseover=\"doTooltip(event,0)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a>";

## number of control variables
print "</td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\">Enter number of control variables: </font>",
  textfield(-name=>'u_nodes', -size=>2, -maxlength=>2, -default=>2),
  "&nbsp &nbsp &nbsp";
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#N\" onmouseover=\"doTooltip(event,0)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a>";

## p value
print "</td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr><tr valign=\"top\"><td nowrap><font size=\"2\">Enter number of states per node: </font>";
print textfield(-name=>'p_value',-size=>2,-maxlength=>2, default=>2);
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#P\" onmouseover=\"doTooltip(event,1)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a>";

# Input form 
print "</td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\">Select format of input functions (not functional):";
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#F\" onmouseover=\"doTooltip(event,3)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
print radio_group(-name=>'translate_box', -values=>['Polynomial','Boolean'], -default=>'Polynomial', -linebreak=>'true');

# Synchronous or Seqeuential 
print "</font></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr><tr valign=\"top\"><td nowrap><font size=\"2\">Select the updating scheme for the functions (not functional):";
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#U\" onmouseover=\"doTooltip(event,4)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
print radio_group(-name=>'update_box', -values=>['Synchronous',
'Update_stochastic', 'Sequential'], -default=>'Synchronous', -linebreak=>'true');
print "&nbsp\;&nbsp\;&nbsp\;&nbsp\;- Enter update schedule separated by spaces: ",textfield(-name=>'update_schedule', -size=>24);
print "</font></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr></table></td></tr></table></td>";

print "<td><table width=\"90%\" cellSpacing=\"0\" cellPadding=\"1\" align=\"center\" bgColor=\"#ababab\" border=\"0\"><tr><td><table cellSpacing=\"0\" cellPadding=\"1\" width=\"100%\" bgColor=\"#ffffcc\" border=\"0\">";

# Input Functions Block
print "<tr valign=\"top\"><TD nowrap bgColor=\"#ff8000\"><strong><font
color=\"#ffffff\">Input Functions</font></strong></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\">Select function file (not functional!): </font>",filefield(-name=>'upload_file');
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#F\" onmouseover=\"doTooltip(event,2)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a>";


print "</td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print "<tr><td><div align=\"center\"><b>OR</b> <font size=\"2\" color=\"#006C00\">(Edit functions below)</font></div></td></tr>";
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
print "</div></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr></table></td></tr></table></td></tr>";

# State Space Specification
print"<tr><td><table width=\"90%\" align=\"center\" border=\"0\" bgcolor=\"#ABABAB\"  cellpadding=\"1\" cellspacing=\"0\"><tr><td>";
print"<table border=\"0\" bgcolor=\"#FFFFCC\" width=\"100%\" cellspacing=\"0\" cellpadding=\"1\"><tr valign=\"top\"><td bgcolor=\"#FF8000\" nowrap>";
print"<strong><font color=\"#FFFFFF\">State Space Specification (not functional)</font></strong></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print"<tr valign=\"top\"><td nowrap><font size=\"2\">Generate state space of";
print"&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#S\" onmouseover=\"doTooltip(event,5)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
print radio_group(-name=>'option_box', -values=>['All trajectories from all possible initial states', 'One trajectory starting at an initial state'], -default=>'All trajectories from all possible initial states', -linebreak=>'true',); 
print "&nbsp\;&nbsp\;&nbsp\;&nbsp\;- Enter initialization separated by spaces: ",textfield(-name=>'trajectory_value', -size=>20);
print"</font></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr></table></td></tr></table></td><td>";

## Additional Output Specification
print"<table width=\"90%\" align=\"center\" border=\"0\" bgcolor=\"#ABABAB\" cellpadding=\"1\" cellspacing=\"0\"><tr><td>";
print"<table border=\"0\" bgcolor=\"#FFFFCC\" width=\"100%\" cellspacing=\"0\" cellpadding=\"1\"><tr valign=\"top\">";
print"<td bgcolor=\"#FF8000\" nowrap><b><font color=\"#FFFFFF\">Additional Output Specification (not functional) &nbsp\;<span style=\"background-color:#808080\">(optional)</span></font></b>";
print"&nbsp\;&nbsp\;&nbsp\;</td>";
print"</tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr><tr valign=\"top\"><td nowrap><font size=\"2\">View";
print"&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#G\" onmouseover=\"doTooltip(event,6)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
print"<font color=\"#006C00\"><i>Select graph(s) to view and image 
format.</i></font><br>";
print checkbox_group(-name=>'statespace', -value=>'State space graph', -label=>'State space graph'),"&nbsp\;&nbsp\;&nbsp\;", popup_menu(-name=>'SSformat',-values=>['*.gif','*.jpg','*.png','*.ps']), "&nbsp\;&nbsp\;&nbsp\;", checkbox_group(-name =>'stochastic', -value=>'Print probabilities', -label=>'Print probabilities', -checked),"<br>";
print checkbox_group(-name=>'depgraph', -value=>'Dependency graph',
-label=>'Dependency graph'), "&nbsp\;&nbsp\;&nbsp\;", popup_menu(-name=>'DGformat',-values=>['*.gif','*.jpg','*.png','*.ps']);
print"</font></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr></table></td></tr></table></td></tr><tr>";
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



$DEBUG = 0;

print "access was ok <br>" if ($DEBUG);
print "client ip is $clientip <br>" if ($DEBUG);
print "$n_nodes<br>" if ($DEBUG);
print "$u_nodes<br>" if ($DEBUG);
print "$p_value<br>" if ($DEBUG);
print "$functions<br>" if ($DEBUG);


$ret = system("ruby control_runner.rb $n_nodes $u_nodes $p_value \"$functions\" $clientip.out.gif");

if ( 1 || !$ret ) {
  print "everything ok" if ($DEBUG);
  print  "<A href=\"$clientip.out.gif\" target=\"_blank\"> <font color=red><i>Click to view the state space graph of your controlled polynomial dynamical system.</i></font></A><br>";
} else {
  print "<br><font color=red>Sorry. Something went wrong.</font><br>";
  die("Program quitting. Unknown error");
}


print end_html();


