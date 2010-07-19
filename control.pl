#!/usr/bin/perl

## Colors are extracted from VBI logo: 
# #009977 green
# #226677 blue

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


print header, start_html( -title=>'Visualizer of Controlled Polynomial Dynamical Systems Web Interface', 
                -script=>{-language=>'JavaScript',-src=>'/fnct2.js'},
                -head=>[Link({-rel=>'icon',-type=>'image/png',-href=>'https://www.vbi.vt.edu/images/favicon.ico'}),]);
#print "<body background=\"https://www.vbi.vt.edu/templates/vbi/images/background-body-vbi.png\" link=\"#009977\" vlink=\"#226677\">";
#print "<body background=\"http://dvd.vbi.vt.edu/gradient.gif\" link=\"#009977\" vlink=\"#226677\">";
print start_multipart_form(-name=>'form1', -method =>"POST", -onSubmit=>"return validate()");
print "<div style=\"font-family:Verdana,Arial\"><div id=\"tipDiv\" style=\"position:absolute\; visibility:hidden\; z-index:100\"></div><br>";

print "<table width=\"100%\"  border=\"0\" cellpadding=\"10\" cellspacing=\"5\">";
print "<tr><td width=\"7%\"></td> <td align=right><img src=\"http://dvd.vbi.vt.edu/vbi-logo.png\"></td> <td align=left> <b><font size=\"5\">Visualizer of Controlled Polynomial Dynamical Systems v0.9 </font></b><br>";
#print "<font size=2><a href=\"http://www.math.vt.edu/people/fhinkel/\">Franziska Hinkelmann</a></font><p> 
print "</td></tr>";
print "<tr><td colspan=3 align=center>";
print "You can visualize a controlled Polynomial dynamical system. This is experimental, please be patient with us. Thank you for trying it out! <br>
If you have any questions or comments, <a href=\"mailto:fhinkel\@vt.edu\">please email Franziska Hinkelmann</a>! </td></tr></table>";
#print "<table background=\"http://dvd.vbi.vt.edu/gradient.gif\" width=\"100%\"  border=\"0\" cellpadding=\"0\" cellspacing=\"10\">";

print "<table width=\"100%\"  border=\"0\" cellpadding=\"30\" cellspacing=\"10\">";

## This is the box around Network Description
print "<tr valign=top><td width=50%>";
print "<table width=\"100%\" cellSpacing=\"0\" cellPadding=\"1\" align=\"center\" bgColor=\"#ababab\" border=\"0\"><tr><td>";
print "<table border=\"0\" bgcolor=\"#FFFFCC\" width=\"100%\" cellspacing=\"0\" cellpadding=\"1\"><tr><td bgcolor=\"#666666\" nowrap>";
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
print "</td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"> </td></tr>
<tr valign=\"top\"><td nowrap><font size=\"2\"><br>Enter number of states per node: </font>";
print textfield(-name=>'p_value',-size=>2,-maxlength=>2, default=>2),
  "<font size=2> (Must be a prime number)</font>";
print "<br>";
print "<br>";

## Explainations
print "</td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr><tr valign=\"top\"><td wrap><font size=\"2\">";
print "<br>";
print "A controlled polynomial dynamical system has a number of state variables x1, ... xn <br>"; 
print "and a number of control variables u1, ..., um. The idea is, that the
system evolves according <br>";
print "to certain rules, this corresponds to a regular PDS, but the control variables can be <br> externally controlled. Therefore ";
print "the state space of a controlled PDS looks slightly different <br>than that of a regular PDS: ";
print "There are p^n states where each state has out-degree at <br>most 2^u. Every edge in the graph is ";
print "labeled with the control that has been applied at this transition. <br>";
print "<br>";

print "</td></tr>";

# Input Functions Block
print "<tr><td nowrap bgColor=\"#666666\"><strong><font
color=\"#ffffff\">Input Functions</font></strong></td></tr>
<tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";

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
print "</table>";
print "</td></tr>";
print "</table>";

# control Options
# controlGroup  
#  - nothing
#  - given
#  - heuristic
#  - best

print "
<td width=50%>
<table width=\"100%\" cellSpacing=\"0\" cellPadding=\"1\" align=\"center\" bgColor=\"#ababab\" border=\"0\">
<tr>
  <td>
    <table cellSpacing=\"0\" cellPadding=\"1\" width=\"100%\" bgColor=\"#ffffcc\" border=\"0\">
      <tr><td nowrap bgColor=\"#666666\"><strong><font color=\"#ffffff\">
        Controller</font></strong></td>
      </tr>
      <tr>
        <td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\">
        </td>
      </tr>
      <tr>
        <td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\">
        </td>
      </tr>
      <tr valign=\"top\">
        <td nowrap><div align=\"center\">
<tr valign=\"top\"><td nowrap><font size=\"2\">
<table width=100% border=0>
<tr>
  <td colspan=3>
    <label>
      <input type=\"radio\" name=\"controlGroup\" value=\"nothing\" checked=\"checked\" >
      Do not search for a control sequence, just compute the complete phase space.
    </label>
  </td>
</tr>
<tr><td colspan=3 BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\" width=100%></td></tr>
<tr>
  <td colspan=3>
    Enter initial state, separated by spaces: ", textfield( -name=>'initialState', -size=>20, -default=>'1 0 1 1'), "
  </td>
</tr>
<tr>
  <td width5%>
  </td>
  <td colspan=2>
    <label>
      <input type=\"radio\" name=\"controlGroup\" value=\"given\">
      Apply a given control sequence repeatedly
    </label>
  </td>
</tr>
<tr>
  <td width=5%>
  </td>
  <td colspan=2>
    Enter a control sequence, the sequence will be repeatedly applied until a repeated node is found.<br>",
      textarea(-name=>'given_control',
               -default=>
'0 0
1 0
',
               -rows=>6,
               -columns=>15), "
  </td>
</tr>
<tr>
  <td>
  </td>
  <td colspan=2 BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\" width=100%>
  </td>
</tr>
<tr>
  <td>
  </td>
  <td colspan=2>
     Enter final state, separated by spaces: &nbsp   ", textfield( -name=>'finalState', -size=>20, -default=>'0 0 1 1'),"
  </td>
</tr>
<tr>
  <td width=5%>
  </td>
  <td width=5%>
  </td>
  <td>
    <label>
      <input type=\"radio\" name=\"controlGroup\" value=\"heuristic\">
      Use heuristic controller to find control sequence
    </label>
  </td>
</tr>
<tr>
  <td>
  </td>
  <td>
  </td>
  <td>
   A heuristic algorithm will try to find the cheapest trajectory from the initial to the <br>
   final state. Cheap means with the cheapest possible control. As this is an experimental <br>
   version, we consider uniform cost for every control variable that is set, i.e., not 0.<br>
   If a sequence of control inputs is found, that drives the system from the initial state <br>
   to the final state, this trajectory is highlighted in the state space graph in green. If <br>
   no sequence can be found, no trajectory will be highlighted in the phase space. <br>
   <br>
  </td>
</tr>
<tr>
  <td>
  </td>
  <td>
  </td>
  <td>
    <label>
      <input type=\"radio\" name=\"controlGroup\" value=\"best\">
      Find the true optimal controller
    </label>
  </td>
</tr>
<tr>
  <td>
  </td>
  <td>
  </td>
  <td>
   Find a truly optimal controller from the initial to the final state. <br> 
   This is done by enumeration. <br><br>
  </td>
</tr>

<tr>
  <td colspan=3 nowrap bgColor=\"#666666\"><strong><font color=\"#ffffff\" size=3>
    Cost Function</font></strong>
  </td>
</tr>
<tr valign=\"top\"><td></td><td></td>
  <td wrap><font size=2>
    The algorithms find a control sequence that is best with respect to a cost<br>
    function. Please enter your cost function here:
    ",
    textfield(-name=>'costFunction', -size=>20, -default=>'u1+u2'),
    "<br>The control variables are referred to as u = {u1, u2, ...,  um},<br>
    where m is the number of control variables. The total cost for a<br>
    trajectory is the sum of the cost of the controls applied. For example, if<br>
    you applied the controls {0,1}, {2,1}, {0,0}, {1,1}, then the cost is<br>
    c({0,1}) + c({2,1}) + c({0,0}) + c({1,1}).  <b>Please note, for now, only the<br>
    default cost is possible, changing this field is not working yet</b>.</font>
  </td>
</tr> ";

print "</table></div></td></tr><tr><td colspan=3 BGCOLOR=\"#DCDCDC\"
HEIGHT=\"1\"></td></tr>";
print "</table></td></tr></table></td></tr>";

print "<tr>";
print "<br>";
print "<td align=\"center\" colspan=\"2\">", 
  submit('generateButton', 'Generate'),
  "<br><font style=bold color=\"#009977\"><br><i>Results will be displayed below.</i></font></td></tr>";
print end_form;

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

$controlType = param( 'controlGroup' );
$initialState = param( 'initialState' );
$finalState = param( 'finalState');
$givenControl = param( 'given_control');

$generateButton = param('generateButton');


print "<tr>";
print "<br>";
print "<td align=\"left\" colspan=\"2\">";


$DEBUG = 0;
print "access was ok <br>" if ($DEBUG);
print "client ip is $clientip <br>" if ($DEBUG);
print "$n_nodes<br>" if ($DEBUG);
print "$u_nodes<br>" if ($DEBUG);
print "$p_value<br>" if ($DEBUG);
print "$functions<br>" if ($DEBUG);


print "$initialState<br>" if ($DEBUG);
print "$finalState<br>" if ($DEBUG);
print "generate button: $generateButton<br>" if $DEBUG;
print "controlType is $controlType, <br>
  initialState $initialState, <br>
  finalState $finalState<br>" if $DEBUG;

if (param) {
  if ($initialState ne null) {
    $initialState = &cleanUpState( $initialState );
  }
  if ($finalState ne null) {
    $finalState = &cleanUpState( $finalState );
  }

  if ($controlType eq "nothing") {
    print "No control<br>" if $DEBUG;
    $ret = system("ruby control_runner.rb $n_nodes $u_nodes $p_value \"$functions\" $clientip.out.gif $controlType ");
  } elsif ($controlType eq "given") {
    print "given control <br>" if $DEBUG;
    print "<font color=\"#226677\"><b>Finding trajectory from $initialState
    for given control $givenControl:</b></font><br>" if $DEBUG;
    if ($givenControl eq null) {
      print "<br><font color=red>Sorry. You have to specify a control sequence if you want chose given control.</font><br>";
      die("Program quitting.");
    }
    print ("ruby control_runner.rb $n_nodes $u_nodes $p_value \"$functions\" $clientip.out.gif $controlType $initialState \"$givenControl\" <br>") if $DEBUG;
    $ret = system("ruby control_runner.rb $n_nodes $u_nodes $p_value \"$functions\" $clientip.out.gif $controlType $initialState \"$givenControl\"");
  } elsif ($controlType eq "heuristic" or $controlType eq "best") {
    print "heuristic or best <br>" if $DEBUG;
    print "<font color=\"#226677\"><b>Finding $controlType controller from $initialState to $finalState:</b></font><br>";
    print ("ruby control_runner.rb $n_nodes $u_nodes $p_value \"$functions\" $clientip.out.gif $controlType $initialState $finalState") if $DEBUG;
    $ret = system("ruby control_runner.rb $n_nodes $u_nodes $p_value \"$functions\" $clientip.out.gif $controlType $initialState $finalState");
  } else {
    print "<br><font color=red>Sorry. Something went wrong.</font><br>";
    die("Program quitting. Unknown error");
    exit 1;
  }


  if ( $ret == 0 ) {
    print "everything ok<br>" if ($DEBUG);
    if (-e "$clientip.out.gif") {
      print  "<A href=\"$clientip.out.gif\" target=\"_blank\"> <font color=\"#226677\"><i>Click to view the state space graph of your controlled polynomial dynamical system.</i></font></A><br>";
    }
  } else {
    print "<br><font color=red>Sorry. Something went wrong.</font><br>";
    die("Program quitting. Unknown error");
  }
}

print "</td></tr>";
print "</table></div>"; 

print end_html;

sub cleanUpState() {
  ($s) = @_;
  $s =~ s/^\s+|\s+$//g; #remove all leading and trailing white spaces
  $s =~  s/(\d+)(\s+|,+)+/$1 /g; # remove extra spaces in between the numbers
  $s =~ s/ /_/g;
  $s;
}



