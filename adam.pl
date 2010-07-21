#!/usr/bin/perl

## Hussein Vastani 
## Franziska Hinkelmann
## Bonbons
## July 2010

## ADAM0.1 with support for large networks and conjunctive 
## networks using M2 instead of perl enumeration

use CGI qw( :standard );
use Fcntl qw( :flock );

`mkdir -p ../../htdocs/no-ssl`;
`touch ../../htdocs/no-ssl/access`;
#get the clients ip address
$clientip = $ENV{'REMOTE_ADDR'};
$clientip =~ s/\./\-/g;
($sec,$min,$hr) = localtime();
$clientip = $clientip.'-'.$sec.'-'.$min.'-'.$hr;
$clientip = '../../htdocs/no-ssl/files/'. $clientip;

#$clientip = $sec.'-'.$min.'-'.$hr;

print header, start_html( -title=>'Analysis of Discrete Algebraic Models', -script=>{-language=>'JavaScript',-src=>'/fnct2.js'}, -style=>{-src=>'/adam_style.css'});
print start_multipart_form(-name=>'form1', -method =>"POST", -onSubmit=>"return validate()");
print "<div id=\"wrap\">";
print "<div id=\"tipDiv\" style=\"position:absolute\; visibility:hidden\; z-index:100\"></div>";

#Div Box: ADAM Title :: Header
print "<div id=\"header\">";
print "<table><tr>";
print "<td align=\"right\"><img src=\"http://dvd.vbi.vt.edu/vbi-logo.png\"></td>";
print "<td align=\"left\"><b><font size=\"5\">Analysis of Discrete Algebraic Models (ADAM) v0.1 </font></b></td></tr></table>";
print "</div>";

#Div Box: Text Explanation :: Nav
print "<div id=\"nav\"><p>";
print "ADAM uses a combination of simulation and algorithms to analyze the dynamics of ";
print "discrete systems. <br>If this is your first time, please read the <a href=\"http://dvd.vbi.vt.edu/VADD_tut.html\" target=\"_blank\">tutorial</a>. It is important ";
print "that you follow the format specified in the tutorial.<br>Make your selections and provide inputs (if any) in the form below and click ";
print "Generate to run the software.<br> Note: The computation may take some time.";
print "</div>";

#Div Box: Input Functions, Number of Nodes, Number of States :: Main
print "<div id = \"main\">";

#Table Box 1: Network Description
print "<table>";
print "<tr valign=\"top\"><td class=\"titleBox\">";
print "<strong><font color=\"black\">Network Description</font></strong>";
print "</td></tr>";
print "<tr class=\"lines\"><td></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\">Enter number of nodes: </font>",
  textfield(-name=>'n_nodes', -size=>2, -maxlength=>2, -default=>3),
  "&nbsp &nbsp &nbsp";
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#N\" onmouseover=\"doTooltip(event,0)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a></td></tr>";
print "<tr class=\"lines\"><td></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\">Enter number of states per node: </font>";
print textfield(-name=>'p_value',-size=>2,-maxlength=>2, default=>3);
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#P\" onmouseover=\"doTooltip(event,1)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a>";
print "</td></tr>";
print "</table>";

# Input Functions Block
print "<table>";
print "<tr vAlign=top><td class=\"titleBox\"><strong><font
color=\"black\">(Stochastic) Input Functions</font></strong></td></tr>";
print "<tr class = \"lines\"><td></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\">Select format of input functions:";
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#F\" onmouseover=\"doTooltip(event,3)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
print radio_group(-name=>'translate_box', -values=>['Polynomial','Boolean'], -default=>'Polynomial', -linebreak=>'true');
print "</font></td></tr>";
print "</td></tr><tr class=\"lines\"><td></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\">Select function file: </font>",filefield(-name=>'upload_file');
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#F\" onmouseover=\"doTooltip(event,2)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a>";
print "</td></tr><tr class=\"lines\"><td></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\">", checkbox_group(-name=>'ginSim', -value=>'GINsim File', -label=>'GINsim File'), "&nbsp &nbsp &nbsp";
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#N\" onmouseover=\"doTooltip(event,8)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a>";
print "<tr class=\"lines\"><td></td></tr>";
print "<tr><td><div align=\"center\"><b>OR</b> <font size=\"2\" color=\"#006C00\">(Edit functions below)</font></div></td></tr>";
print "<tr class=\"lines\"><td></td></tr><tr valign=\"top\"><td nowrap><div align=\"center\">";
print textarea(-name=>'edit_functions',
               -default=>'f1 = {
x1+x2   #.9
x1      #.1
}
f2 = x1*x2*x3
f3 = {
x1*x2+x3^2
x2
}' ,
			   -rows=>8,
			   -columns=>50);
print "</div></td></tr>";
print "<tr class = \"lines\"><td></td></tr>";
print "<tr><td align=\"center\" colspan=\"2\">",submit('button_name','Generate')," <br><font color=\"#006C00\"><br><i>Results will be displayed below.</i></font></td></tr>";
print "</table>";
print "</div>";

#Div Box: Network Options/Other Options :: Sidebar
print "<div id=\"sidebar\">";

#Network Options
print "<table>";
print "<tr valign=\"top\"><td class=\"titleBox\">";
print "<strong><font color=\"#black\">Network Options</font></strong></td></tr>";
print "<tr class=\"lines\"><td></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\">";
print "Select the type of network:";
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#N\" onmouseover=\"doTooltip(event,7)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
print radio_group(-name=>'special_networks', -values=>['Conjunctive/Disjunctive (Boolean rings only)', 'Small Network (nodes <= 10)', 'Large Network (nodes > 10)'], -default=>'Small Network (nodes <= 10)', -linebreak=>'true');
print "&nbsp\;&nbsp\;&nbsp\;&nbsp\;- Limit cycle length to search for: <br>";
print "<center>", textfield(-name=>'limCyc_length', -size=>2), "</center></font>";
print "</td></tr>";
print "</table>";

#Small Network Options
#Input Functions
print "<table>";
print "<tr valign=\"top\"><td class=\"titleBox\">";
print "<strong><font color=\"black\">Options for Small Networks</font></strong>";
print "</td></tr>";
print "<tr class=\"lines\"><td></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\">Select the updating scheme for the functions:";
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#U\" onmouseover=\"doTooltip(event,4)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
print radio_group(-name=>'update_box', -values=>['Synchronous',
'Update_stochastic', 'Sequential'], -default=>'Synchronous', -linebreak=>'true');
print "&nbsp\;&nbsp\;&nbsp\;&nbsp\;- Enter update schedule separated by spaces: <br>";
print "<center>", textfield(-name=>'update_schedule', -size=>24), "</center>";
print "</font></td></tr>";

#State Space Specifications
print "<tr class=\"lines\"><td></td></tr>";
print"<tr valign=\"top\"><td nowrap><font size=\"2\">Generate state space of";
print"&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#S\" onmouseover=\"doTooltip(event,5)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
print radio_group(-name=>'option_box', -values=>['All trajectories from all possible initial states', 'One trajectory starting at an initial state'], -default=>'All trajectories from all possible initial states', -linebreak=>'true',); 
print "&nbsp\;&nbsp\;&nbsp\;&nbsp\;- Enter initialization separated by spaces: <br><center>",textfield(-name=>'trajectory_value', -size=>20), "</center>";
print"</font></td></tr>";

#BLOCK 3: Additional Output Specifications
print "<tr><td>";
print"<tr class=\"lines\"><td></td></tr><tr valign=\"top\"><td nowrap><font size=\"2\">View";
print"&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#G\" onmouseover=\"doTooltip(event,6)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
print"<font color=\"#006C00\"><i>Select graph(s) to view and image 
format.</i></font><br>";
print checkbox_group(-name=>'statespace', -value=>'State space graph', -label=>'State space graph'),"&nbsp\;&nbsp\;&nbsp\;", popup_menu(-name=>'SSformat',-values=>['*.gif','*.jpg','*.png','*.ps']), "&nbsp\;&nbsp\;&nbsp\;", checkbox_group(-name =>'stochastic', -value=>'Print probabilities', -label=>'Print probabilities', -checked),"<br>";
print checkbox_group(-name=>'depgraph', -value=>'Dependency graph',
-label=>'Dependency graph'), "&nbsp\;&nbsp\;&nbsp\;", popup_menu(-name=>'DGformat',-values=>['*.gif','*.jpg','*.png','*.ps']);
print"</font></td></tr><tr class=\"lines\"><td></td></tr></table></td></tr></table></td></tr>";
print "</table>";
print "</div>";

print "<div id =\"computation\">";
#Google Analytics, Franzi's Account
print <<ENDHTML;
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-11219893-5");
pageTracker._trackPageview();
} catch(err) {}</script>
ENDHTML

print end_form;

open(ACCESS, ">>../../htdocs/no-ssl/access") or die("Failed to open file for writing");
flock(ACCESS, LOCK_EX) or die ("Could not get exclusive lock $!");
print ACCESS ($ENV{REMOTE_ADDR});
system("date >>../../htdocs/no-ssl/access");
flock(ACCESS, LOCK_UN) or die ("Could not unlock file $!");
close(ACCESS);

$p_value = param('p_value');
$n_nodes = param('n_nodes');
$upload_file = upload('upload_file');
$option_box = param('option_box');
$translate_box = param('translate_box');
$special_networks = param('special_networks');
$limCyc_length = param('limCyc_length');
$update_box = param('update_box');
$update_schedule = param('update_schedule');
$trajectory_box = param('trajectory_box');
$trajectory_value = param('trajectory_value');
$statespace = param('statespace');
$ginSim = param('ginSim');
$depgraph = param('depgraph');
$edit_functions = param('edit_functions');
$SSformat = param('SSformat');
$DGformat = param('DGformat');
$stochastic =param('stochastic'); 	# if set, probabilities are drawn in state space
$updstoch_flag = "0";
$updsequ_flag= "0";
my $bytesread = "";
my $buffer = "";
 
$DEBUG = 0;

$fileuploaded = 0;
$SSformat =~ s/\*\.//;
$DGformat =~ s/\*\.//;
print "access was ok <br>" if ($DEBUG);
print "$option_box <br>" if ($DEBUG);
print "$translate_box <br>" if ($DEBUG);
print "$special_networks <br>" if ($DEBUG);

if ( $special_networks eq "Conjunctive/Disjunctive (Boolean rings only)" ) {
  # conj/disj networks dynamics depend on the dependency graph, we need to
  # generate it 
  create_input_function();
  system("perl regulatory.pl $filename $n_nodes $clientip $DGformat") == 0
      or die("regulatory.pl died");
  $dpGraph = "$clientip.out1";
  print  "<br><A href=\"$dpGraph.$DGformat\" target=\"_blank\"><font
  color=red><i>Click to view the dependency graph.</i></font></A><br>";
  #BLAHBLAH i'm sad ._.
  system("ruby adam_conjunctive.rb $n_nodes $p_value $dpGraph.dot");
}
elsif ( $special_networks eq "Large Network (nodes > 10)" ) {
  if(($limCyc_length eq null) || ($limCyc_length eq "")){
      print "<font color=red>Sorry. Can't accept null input for limit cycle length.</font>";
      die("Program quitting. Empty field entered for limit cycle length in large networks.");
  }
  print "<font color=blue><b>Calculating fixed points for a large network,
  other analysis of dynamics not possible for now.</b></font><br>";
  print "<font color=blue><b>This is a very experimental feature, therefore
  there is no error checking. Use at your own risk.</b></font><br>";
  create_input_function();
  system("ruby adam_largeNetwork.rb $n_nodes $p_value $filename $limCyc_length");
} elsif ( $p_value && $n_nodes )
{
    print "hello<br>" if ($DEBUG);
    #if($p_value**$n_nodes >= 7000000000000)
    if($n_nodes > 21 || $p_value**$n_nodes > 2**21) {
        print "<font color=red><i>Sorry. Unable to compute statistics for very large networks. It is suggested you use the large networks option.</i></font><br>";
        die("Program quitting. Too many nodes");
    }
   
    create_input_function();
    set_update_type();
    
    # Set flag for creating the dependency graph and whether to print
    # the probabilities in the phase space
    ($depgraph eq "Dependency graph") ? {$depgraph = 1} : {$depgraph=0};
    ($stochastic eq "Print probabilities") ? {$stochastic = 1} : {$stochastic = 0 };

    print $option_box if ($DEBUG);
    if($option_box eq "All trajectories from all possible initial states") {
      print "<font color=blue><b>ANALYSIS OF THE STATE SPACE</b></font>"." [m = ".$p_value.", n = ".$n_nodes;
      if($fileuploaded == 1) {
        print ", file path = ". $upload_file;
      }
      print "] <br>";

      # Calling the wrapper script dvd_stochastic_runner.pl, which in
      # turn calls DVDCore routines
      print ("perl dvd_stochastic_runner.pl  $n_nodes $p_value 1 $updstoch_flag $clientip $SSformat $depgraph $updsequ_flag $update_schedule $stochastic 1 0 $filename\n<br> ") if ($DEBUG); 		
      system("/usr/bin/perl dvd_stochastic_runner.pl  $n_nodes $p_value 1 $updstoch_flag $clientip $SSformat $depgraph $updsequ_flag $update_schedule $stochastic 1 0 $filename"); 		
    } else {
       print "<font color=blue><b>Computing Trajectory of the given initialization</b></font>"." [m = ".$p_value.", n = ".$n_nodes."] <br>";
       if( ($trajectory_value ne null) &&( $trajectory_value ne "") ) {
          $trajectory_value =~ s/^\s+|\s+$//g;; #remove all leading and trailing white spaces
          $trajectory_value =~  s/(\d+)\s+/$1 /g; #remove extra white space between the numbers
          $trajectory_value =~ s/ /_/g;
          
          system("/usr/bin/perl dvd_stochastic_runner.pl  $n_nodes $p_value 1 $updstoch_flag $clientip $SSformat $depgraph $updsequ_flag $update_schedule $stochastic 0 $trajectory_value $filename"); 		
      } else {
        print "<br><font color=red>Sorry. Cannot accept null input for initialization field iii</font><br>";
        die("Program quitting. Empty value for initialization field");
      }
    }
    if($statespace eq "State space graph" && $option_box eq "All trajectories from all possible initial states") {
        if(-e "$clientip.out.$SSformat") {
            print  "<A href=\"$clientip.out.$SSformat\"
            target=\"_blank\"><font color=red><i>Click to view the state space
            graph.</i></font></A><br>"
        }
    } else {
        if(-e "$clientip.graph.$SSformat") {
            print  "<A href=\"$clientip.graph.$SSformat\" target=\"_blank\"><font
            color=red><i>Click to view the trajectory.</i></font></A><br>"
        }
    }
    #if(-e "$clientip.out1.$DGformat")
    if(-e "$clientip.out1.$SSformat") {
        print  "<A href=\"$clientip.out1.$DGformat\" target=\"_blank\"><font
        color=red><i>Click to view the dependency graph.</i></font></A><br>";

    }
    
#    `rm -f -R $clientip`;
#    `rm -f $clientip.out.dot`;
#    `rm -f $clientip.graph.dot`;
#
#    `rm -f $clientip.out1.dot`;
#    `rm -f $clientip.out2.dot`;
#    
#    `rm -f $clientip.functionfile.txt`;
#    `rm -f $clientip.trfunctionfile.txt`;

}
print "</div>";

#Box: Comments/Questions/Bugs Link :: Footer
print "<div id=\"footer\">";
print "ADAM is currently still under development; if you ";
print "spot any bugs or have any questions/comments, please <a href=\"mailto:mbrando1@utk.edu\">";
print "e-mail us</a>. ";
print "(Bonny Guang, Madison Brandon, Rustin McNeill)";
print "</td></tr>";
print "</div>";

print "</div>";

print end_html();






# this function reads input functions from file or text area and writes the input functions into $clientip.functionfile.txt
sub create_input_function() {
    print "Clientip $clientip \n<br>" if ($DEBUG);
    use Cwd;
    $cwd = getcwd();
    `mkdir -p $cwd/../../htdocs/no-ssl/files`; 
    open (OUTFILE, ">$clientip.functionfile.txt");
    print "open ok \n<br>" if ($DEBUG);
    $filename = "$clientip.functionfile.txt";
    if($upload_file) {
      $fileuploaded = 1;
      if($ginSim eq "GINsim File"){
	  $extension = substr $upload_file, -5;
	  if($extension ne "ginml"){
	      print "<font color=red>Error: Must give GINsim file</font>";
	      die("Program quitting. Extension not ginml");
	  }
        open (GINOUTFILE, ">$clientip.ginsim.ginml");
        flock(GINOUTFILE, LOCK_EX) or die ("Could not get exclusive lock $!");
        while($bytesread=read($upload_file, $buffer, 1024)) {
            print GINOUTFILE $buffer;
        }
        flock(GINOUTFILE, LOCK_UN) or die ("Could not unlock file $!");
        close $upload_file;
        system("ruby ginSim-converter.rb $clientip.ginsim.ginml $filename");
      } else {
      flock(OUTFILE, LOCK_EX) or die ("Could not get exclusive lock $!");
      while($bytesread=read($upload_file, $buffer, 1024)) {
            print OUTFILE $buffer;
      }}
      flock(OUTFILE, LOCK_UN) or die ("Could not unlock file $!");
      close $upload_file;
    } else { # user has not uploaded any file. so use the textarea value
      if($edit_functions) {
        #read value from editfunctions and print it to outfile
        #flock(OUTFILE, LOCK_EX) or die ("Could not get exclusive lock $!");
        print OUTFILE $edit_functions;
        flock(OUTFILE, LOCK_UN) or die ("Could not unlock file $!");
      } else { # no functions provided
        print "<font color=\"red\">Error: No functions provided. Please upload a
        function file or type in your functions in the edit box</font><br>";
        close(OUTFILE);
        die("No function file provided by user");
	    }
    }	
    close(OUTFILE);

    #remove any ^M characters
    `perl -pi -e 's/\r//g' "$clientip.functionfile.txt"`;
    $buffer = "";  

    if($translate_box eq "Boolean") {
      translate_functions();
    }
}


sub translate_functions() {
    print "translate_functions<br>" if ($DEBUG);
    system("/usr/bin/perl translator.pl $clientip.functionfile.txt $clientip.trfunctionfile.txt $n_nodes");
    $filename = "$clientip.trfunctionfile.txt";
    if(-e "$clientip.trfunctionfile.txt") {
      print  "<A href=\"$clientip.trfunctionfile.txt\" target=\"_blank\"><font color=green><i>Translation from Boolean functions to Polynomial was successful.</i></font></A><br><br>";
    } else {
      print "<font color=red>Translation from Boolean functions to polynomial was unsuccessful</font><br>";
      `rm -f $clientip.functionfile.txt`;
      die("Translation unsuccessful");
    }
}

sub set_update_type() {
	$update_box_param = "";
	if($update_box eq 'Update_stochastic') {
		 #print "Update Stochastic<br>";
	   $update_box_param = "updstoch";
	   $updstoch_flag = "1";
	   $update_schedule = "0";
	}
	if($update_box eq 'Sequential') {
		#print "$update_box<br>";
	   $update_box_param = "async";
	   $updsequ_flag = "1";
	   if( ($update_schedule ne null) &&( $update_schedule ne "") ) {
		   $update_schedule =~ s/^\s+|\s+$//g; #remove all leading and trailing white spaces
		   $update_schedule =~  s/(\d+)\s+/$1 /g; # remove extra spaces in between the numbers
		   $update_schedule =~ s/ /_/g;
		   #print "$update_schedule";
	   } else {
       print "<br><font color=red>Sorry. Cannot accept null input for update schedule field</font><br>";
       die("Program quitting. Empty value for update schedule field");
	   }
	} else {
		$update_box_param = "parallel";
		$update_schedule = "0";
	}
}
