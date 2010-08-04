#!/usr/bin/perl

## Hussein Vastani 
## Franziska Hinkelmann
## Bonbons
## July 2010

## ADAM0.3 with support for large networks and conjunctive 
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

print header, start_html( -title=>'Analysis of Discrete Algebraic Models', -script=>{-language=>'JavaScript',-src=>'/adamv2.js'}, ,-onLoad=>'change()', -style=>{-src=>'/adam_stylev2.css'});
print start_multipart_form(-name=>'form1', -method =>"POST", -onSubmit=>"return validate()");
print "<div id=\"wrap\">";
print "<div id=\"tipDiv\" style=\"position:absolute\; visibility:hidden\; z-index:100\"></div>";

#Div Box: ADAM Title :: Header
print "<div id=\"header\">";
print "<table><tr>";
print "<td align=\"right\"><img src=\"http://dvd.vbi.vt.edu/vbi-logo.png\"></td>";
print "<td align=\"left\"><b><font size=\"5\">Analysis of Discrete Algebraic Models (ADAM) v0.3 </font></b></td></tr></table>";
print "</div>";

#Div Box :: Main
print "<div id = \"main\">";

#Div Box: Text Explanation :: Nav
print "<div id=\"nav\"><p>";
print "ADAM uses a combination of simulation and algorithms to analyze the dynamics of
discrete biological systems. It can analyze <b>Logical Models</b> (in <a href= \"http://gin.univ-mrs.fr/\">GINSim</a> format), <b>Polynomial Dynamical 
Systems (PDS)</b>, and <b>Probabilistic Boolean (or multistate) Networks</b>. For small enough networks (deterministic or probabilistic), ADAM simulates the 
complete state space of the model and finds all attractors (steady states and limit cycles) together with statistics about the size of components. For larger networks, 
ADAM computes fixed points for both deterministic and probabilistic networks, and limit cycle of the length specified by the user for deterministic networks. 
You can follow our <a href=\"/steptutorial.htm\">step-by-step tutorial</a> or read the <a href=\"/ADAM_tut.html\" target=\"_blank\">user guide</a>. It is important 
that you follow the format specified in the guide. Make your selections and provide inputs (if any) in the form below and click 
<i>Analyze</i> to run the software. To generate a model from experimental time course data, you can use <a href=\"http://polymath.vbi.vt.edu/polynome\">Polynome</a>.";
print "</div>";


#Table Box 1: Input Functions Network Description
print "<table>";
# Header
print "<tr valign=\"top\"><td class=\"titleBox\" colspan=\"2\">";
print "<strong><font color=\"black\">1)</font></strong>";
print "</td></tr>";

print "<tr class=\"lines\"><td colspan=\"2\"></td></tr>";

# Input Functions
print "<tr valign=\"top\"><td><font size=\"2\"><b>Model Type:</b>";
%labels = ('GINsim'=>'Logical Model (GINsim file)',
'PDS'=>'PDS',
'PBN'=>'Probabilistic Network');
print radio_group(-name=>'format_box', -values=>['GINsim', 'PDS', 'PBN'], -labels=>\%labels, -default=>'PDS', -onChange=>'formatChange()');
print "</font></td>";
# Explanatory Text
print "<td rowspan=\"3\" id=\"explainInput\" class=\"explain\"></td>";
print "</tr>";

print "<tr valign=\"top\"><td><font size=\"2\" id=\"stateInput\">Enter number of states per node: </font>";
print textfield(-name=>'p_value',-size=>2, -maxlength=>2, -default=>3, -onChange=>'pChange()');
print "&nbsp\;&nbsp\;&nbsp\;", popup_menu(-name=>'translate_box',-values=>['Polynomial','Boolean'], -disabled), "<br>";
print "</td></tr>";
print "</table>";

print "<table>";
print "<tr valign=\"top\"><td>";
print "<font size=\"2\"><strong>Model Input: </strong><br></font>";
print "</td></tr>";

print "<tr><td><div align=\"center\">", filefield(-name=>'upload_file');
print "<font id=\"fileInput\"></font>";
print "</div></td></tr>";
print "<tr valign=\"top\"><td><div align=\"center\"><font size=\"2\">or</font></div></td></tr>";
print "<tr valign=\"top\"><td><div align=\"center\">";
print textarea(-name=>'edit_functions',
               -default=>'',
               -rows=>8,
               -columns=>50);
print "</div></td></tr>";
print "</table>";

print "<br>";

#Network Options
print "<table>";
print "<tr valign=\"top\"><td class=\"titleBox\" colspan=\"2\">";
print "<strong><font color=\"#black\">2) Analysis Options</font></strong></td></tr>";
print "<tr class=\"lines\"><td colspan=\"2\"></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\">";
print "Select the type of network: <br>";
print radio_group(-name=>'special_networks', -values=>['Conjunctive/Disjunctive (Boolean rings only)', 'Simulation (suggested for nodes <=11)', 'Algorithms (suggested for nodes > 11)'], -default=>'Simulation (suggested for nodes <=11)', -linebreak=>'true', -onChange=>'networkChange()');
print "</td>";
print "<td id=\"explainNetwork\" class=\"explain\"></td>";
print "</tr>";
print "</table>";

#Additional Options
print "<table>";
print "<tr valign=\"top\"><td class=\"titleBox\">";
print "<strong><font color=\"black\">Additional Options</font></strong>";
print "</td></tr>";

print "<tr class=\"lines\"><td></td></tr>";

print "<tr valign=\"top\"><td nowrap>";
print "<font size=\"2\">";
print checkbox_group(-name=>'depgraph', -value=>'Dependency graph',
-label=>'Dependency graph', -checked), "&nbsp\;&nbsp\;&nbsp\;", popup_menu(-name=>'DGformat',-values=>['*.gif','*.jpg','*.png','*.ps']);
print "&nbsp\;&nbsp\;&nbsp\;", checkbox_group(-name =>'stochastic', -value=>'Print probabilities', -label=>'Print probabilities', -checked);
print "&nbsp\;&nbsp\;&nbsp\;";
print checkbox_group(-name=>'statespace', -value=>'State space graph', -label=>'State space graph', -checked),"&nbsp\;&nbsp\;&nbsp\;", popup_menu(-name=>'SSformat',-values=>['*.gif','*.jpg','*.png','*.ps']), "<br>";
print "</font>";
print "</td></tr>";

print "<tr class=\"lines\"><td></td></tr>";

print "<tr><td id=\"netOpts\" style=\"font-size:12px\">";
print "</table><br>";

print "<center>", submit('button_name','Analyze')," <br><font color=\"#006C00\"><br><i>Results will be displayed below.</i></font></td></tr>";
print "</center>";

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
$upload_file = upload('upload_file');
$option_box = param('option_box');
$format_box = param('format_box');
$translate_box = param('translate_box');
$special_networks = param('special_networks');
$limCyc_length = param('limCyc_length');
$update_box = param('update_box');
$update_schedule = param('update_schedule');
$trajectory_box = param('trajectory_box');
$trajectory_value = param('trajectory_value');
$statespace = param('statespace');
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
print "$format_box <br>" if ($DEBUG);
print "$translate_box <br>" if ($DEBUG);
print "$special_networks <br>" if ($DEBUG);

#make input functions - gives p_value and n_nodes
create_input_function();

# Set flag for creating the dependency graph
($depgraph eq "Dependency graph") ? {$depgraph = 1} : {$depgraph = 0};

if ( $special_networks eq "Conjunctive/Disjunctive (Boolean rings only)" ) {
    # dynamics depend on the dependency graph, need to generate it 
    system("perl regulatory.pl $filename $n_nodes $clientip $DGformat") == 0
      or die("regulatory.pl died");
    $dpGraph = "$clientip.out1";

    # Give link to dependency graph if checked
    if ($depgraph = 1) {
	print  "<br><A href=\"$dpGraph.$DGformat\" target=\"_blank\"><font color=red><i>Click to view the dependency graph.</i></font></A><br>";
    }

    #BLAHBLAH i'm sad ._.
    system("ruby adam_conjunctive.rb $n_nodes $p_value $dpGraph.dot");
} elsif ( $special_networks eq "Algorithms (suggested for nodes > 11)" ) {
    if(($limCyc_length eq null) || ($limCyc_length eq "")){
	print "<font color=red>Sorry. Can't accept null input for limit cycle length.</font>";
	die("Program quitting. Empty field entered for limit cycle length in large networks.");
    }

    # Give link to dependency graph if checked
    if ($depgraph = 1) {
	system("perl regulatory.pl $filename $n_nodes $clientip $DGformat") == 0
	    or die("regulatory.pl died");
	print  "<br><A href=\"$clientip.out1.$DGformat\" target=\"_blank\"><font color=red><i>Click to view the dependency graph.</i></font></A><br>";
    }

    # Analysis
    print "<font color=blue><b>Calculating fixed points for a large network, other analysis of dynamics not possible for now.</b></font><br>";
    print "<font color=blue><b>This is a very experimental feature, therefore there is no error checking. Use at your own risk.</b></font><br>";
    set_update_type();
    system("ruby adam_largeNetwork.rb $n_nodes $p_value $filename $limCyc_length");
} elsif ( $p_value && $n_nodes ) {
    print "Executing simulation<br>";
    print "hello<br>" if ($DEBUG);
    #if($p_value**$n_nodes >= 7000000000000)
    if($n_nodes > 21 || $p_value**$n_nodes > 2**21) {
        print "<font color=red><i>Sorry. Unable to compute statistics for very large networks. It is suggested you use the large networks option.</i></font><br>";
        die("Program quitting. Too many nodes");
    }
   
    print "hello set_update_type<br>" if ($DEBUG);
    set_update_type();

    print $option_box if ($DEBUG);
    if($option_box eq "All trajectories from all possible initial states") {
      print "<font color=blue><b>ANALYSIS OF THE STATE SPACE</b></font>"." [m = ".$p_value.", n = ".$n_nodes;
      if($fileuploaded == 1) {
        print ", file path = ". $upload_file;
      }
      print "] <br>";

      # Calling the wrapper script dvd_stochastic_runner.pl, which in
      # turn calls DVDCore routines

      # Set flag for whether to print probabilities in state space
      ($stochastic eq "Print probabilities") ? {$stochastic = 1} : {$stochastic = 0 };

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
print "(Bonny Guang, Madison Brandon, Rustin McNeill, Franziska Hinkelmann)";
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
      if($format_box eq "GINsim"){
	  # Make sure extension is correct
	  $extension = substr $upload_file, -5;
	  if($extension ne "ginml"){
	      print "<font color=red>Error: Must give GINsim file</font>";
	      die("Program quitting. Extension not ginml");
	  }
	  # Write functions to ginml file on server for ruby script
	  open (GINOUTFILE, ">$clientip.ginsim.ginml");
	  flock(GINOUTFILE, LOCK_EX) or die ("Could not get exclusive lock $!");
	  while($bytesread=read($upload_file, $buffer, 1024)) { print GINOUTFILE $buffer; }
	  flock(GINOUTFILE, LOCK_UN) or die ("Could not unlock file $!");
	  close $upload_file;

	  $pFile = "$clientip.pVal.txt";
	  $nFile = "$clientip.nVal.txt";
	  # Convert GINsim file and get p_value and n_nodes
	  system("ruby ginSim-converter.rb $clientip");
	  close GINOUTFILE;
	  
          # Set p_value and n_nodes
	  open (MYFILE, $pFile) || die("Could not open file!");
	  while (<MYFILE>) { chomp; $p_value = $_; }
	  close (MYFILE); 
	  open (MYFILE, $nFile) || die("Could not open file!");
	  while (<MYFILE>) { chomp; $n_nodes = $_; }
	  close (MYFILE); 
      } else {
          # Make sure extension is correct
	  $extension = substr $upload_file, -3;
	  if($extension ne "txt"){
	      print "<font color=red>Error: Must give .txt file</font>";
	      die("Program quitting. Extension not txt");
	  }

	  # Get contents of file and n_nodes
	  flock(OUTFILE, LOCK_EX) or die ("Could not get exclusive lock $!");	  
	  $n_nodes = 0;
	  while($bytesread=read($upload_file, $buffer, 1024)) {
	      print OUTFILE $buffer;
	      while($buffer =~ m/f(\d+)/g) {
		  if ($1 > $n_nodes) { print "$1<br>";$n_nodes = $1; }
	      }
	  }
      }
      flock(OUTFILE, LOCK_UN) or die ("Could not unlock file $!");
      close $upload_file;
    } elsif ($edit_functions) { # Otherwise parse functions from textarea value (no file uploaded)
	print OUTFILE $edit_functions;
	$n_nodes = 0;
	while($edit_functions =~ m/f(\d+)/g) {
	    if ($1 > $n_nodes) { $n_nodes = $1; }
	}
	flock(OUTFILE, LOCK_UN) or die("Could not unlock file $!");
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
