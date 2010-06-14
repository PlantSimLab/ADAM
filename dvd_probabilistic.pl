#!/usr/bin/perl

## Hussein Vastani 
## Franziska Hinkelmann

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


print header, start_html( -title=>'Discrete Visualizer of Dynamics Web Interface', -script=>{-language=>'JavaScript',-src=>'/fnct2.js'});
print start_multipart_form(-name=>'form1', -method =>"POST", -onSubmit=>"return validate()");
print "<div style=\"font-family:Verdana,Arial\"><div id=\"tipDiv\" style=\"position:absolute\; visibility:hidden\; z-index:100\"></div>";
print "<table background=\"http://dvd.vbi.vt.edu/gradient.gif\" width=\"100%\"  border=\"0\" cellpadding=\"0\" cellspacing=\"10\">";
print "<tr><td align=\"center\" colspan=\"2\"><b><font size=\"5\">Discrete 
Visualizer of Dynamics (DVD) v2.0 </font></b><p>";
print "If this is your first time, please read the <a href=\"http://dvd.vbi.vt.edu/tutorial.html\" target=\"_blank\">tutorial</a>. It is important ";
print "that you follow the format specified in the tutorial.<br>Make your selections and provide inputs (if any) in the form below and click ";
print "Generate to run the software.<br> Note: The computation may take some time depending on your internet connection.</td></tr>";
print "<tr><td><table align=\"center\" border=\"0\" bgcolor=\"#ABABAB\"  cellpadding=\"1\" cellspacing=\"0\"><tr><td>";
print "<table border=\"0\" bgcolor=\"#FFFFCC\" width=\"100%\" cellspacing=\"0\" cellpadding=\"1\"><tr valign=\"top\"><td bgcolor=\"#FF8000\" nowrap>";
print "<strong><font color=\"#FFFFFF\">Network Description</font></strong></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\">Enter number of nodes: </font>",textfield(-name=>'n_nodes', -size=>2, -maxlength=>2, -default=>3);
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#N\" onmouseover=\"doTooltip(event,0)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a>";
print "</td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr><tr valign=\"top\"><td nowrap><font size=\"2\">Enter number of states per node: </font>";
print textfield(-name=>'p_value',-size=>2,-maxlength=>2, default=>3);
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#P\" onmouseover=\"doTooltip(event,1)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a>";
print "</td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\">Select format of input functions:";
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#F\" onmouseover=\"doTooltip(event,3)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
print radio_group(-name=>'translate_box', -values=>['Polynomial','Boolean'], -default=>'Polynomial', -linebreak=>'true');
print "</font></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr><tr valign=\"top\"><td nowrap><font size=\"2\">Select the updating scheme for the functions:";
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#U\" onmouseover=\"doTooltip(event,4)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
print radio_group(-name=>'update_box', -values=>['Synchronous',
'Update_stochastic', 'Sequential'], -default=>'Synchronous', -linebreak=>'true');
print "&nbsp\;&nbsp\;&nbsp\;&nbsp\;- Enter update schedule separated by spaces: ",textfield(-name=>'update_schedule', -size=>24);
print "</font></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr></table></td></tr></table></td>";
print "<td><table cellSpacing=\"0\" cellPadding=\"1\" align=\"center\" bgColor=\"#ababab\" border=\"0\"><tr><td><table cellSpacing=\"0\" cellPadding=\"1\" width=\"100%\" bgColor=\"#ffffcc\" border=\"0\">";
print "<tr vAlign=top><TD nowrap bgColor=\"#ff8000\"><strong><font
color=\"#ffffff\">(Stochastic) Input Functions</font></strong></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print "<tr valign=\"top\"><td nowrap><font size=\"2\">Select function file: </font>",filefield(-name=>'upload_file');
print "&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#F\" onmouseover=\"doTooltip(event,2)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a>";
print "</td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print "<tr><td><div align=\"center\"><b>OR</b> <font size=\"2\" color=\"#006C00\">(Edit functions below)</font></div></td></tr>";
print "<tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr><tr valign=\"top\"><td nowrap><div align=\"center\">";
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
print "</div></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr></table></td></tr></table></td></tr>";
print"<tr><td><table align=\"center\" border=\"0\" bgcolor=\"#ABABAB\"  cellpadding=\"1\" cellspacing=\"0\"><tr><td>";
print"<table border=\"0\" bgcolor=\"#FFFFCC\" width=\"100%\" cellspacing=\"0\" cellpadding=\"1\"><tr valign=\"top\"><td bgcolor=\"#FF8000\" nowrap>";
print"<strong><font color=\"#FFFFFF\">State Space Specification</font></strong></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr>";
print"<tr valign=\"top\"><td nowrap><font size=\"2\">Generate state space of";
print"&nbsp\;<a href=\"http://dvd.vbi.vt.edu/tutorial.html#S\" onmouseover=\"doTooltip(event,5)\" onmouseout=\"hideTip()\"><font size=\"1\">what is this?</font></a><br>";
print radio_group(-name=>'option_box', -values=>['All trajectories from all possible initial states', 'One trajectory starting at an initial state'], -default=>'All trajectories from all possible initial states', -linebreak=>'true',); 
print "&nbsp\;&nbsp\;&nbsp\;&nbsp\;- Enter initialization separated by spaces: ",textfield(-name=>'trajectory_value', -size=>20);
print"</font></td></tr><tr><td BGCOLOR=\"#DCDCDC\" HEIGHT=\"1\"></td></tr></table></td></tr></table></td><td>";
print"<table align=\"center\" border=\"0\" bgcolor=\"#ABABAB\" cellpadding=\"1\" cellspacing=\"0\"><tr><td>";
print"<table border=\"0\" bgcolor=\"#FFFFCC\" width=\"100%\" cellspacing=\"0\" cellpadding=\"1\"><tr valign=\"top\">";
print"<td bgcolor=\"#FF8000\" nowrap><b><font color=\"#FFFFFF\">Additional Output Specification &nbsp\;<span style=\"background-color:#808080\">(optional)</span></font></b>";
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
if($p_value && $n_nodes)
{
    print "hello<br>" if ($DEBUG);
    #if($p_value**$n_nodes >= 7000000000000)
    if($n_nodes > 21 || $p_value**$n_nodes > 2**21)
    {
        print "<font color=red><i>Sorry. Unable to compute statistics for very large networks. It is suggested you download the standalone version which has no limitations</i></font><br>";
        die("Program quitting. Too many nodes");
    }

	create_input_function();
    print "hello<br>" if ($DEBUG);
	set_update_type();
    print "hello<br>" if ($DEBUG);
    print "hello<br>" if ($DEBUG);
    
    # Set flag for creating the dependency graph and whether to print
    # the probabilities in the phase space
    ($depgraph eq "Dependency graph") ? {$depgraph = 1} : {$depgraph=0};
    ($stochastic eq "Print probabilities") ? {$stochastic = 1} : {$stochastic = 0 };

	if($option_box eq "All trajectories from all possible initial states")
	{
		print "<font color=blue><b>ANALYSIS OF THE STATE SPACE</b></font>"." [m = ".$p_value.", n = ".$n_nodes;
		if($fileuploaded == 1)
		{
			print ", file path = ". $upload_file;
		}
		print "] <br>";

    # Calling the wrapper script dvd_stochastic_runner.pl, which in
    # turn calls DVDCore routines
    print ("perl dvd_stochastic_runner.pl  $n_nodes $p_value 1 $updstoch_flag $clientip $SSformat $depgraph $updsequ_flag $update_schedule $stochastic 1 0 $filename\n<br> ") if ($DEBUG); 		
    system("/usr/bin/perl dvd_stochastic_runner.pl  $n_nodes $p_value 1 $updstoch_flag $clientip $SSformat $depgraph $updsequ_flag $update_schedule $stochastic 1 0 $filename"); 		
	}
	else
	{
	   print "<font color=blue><b>Computing Trajectory of the given initialization</b></font>"." [m = ".$p_value.", n = ".$n_nodes."] <br>";
	   if( ($trajectory_value ne null) &&( $trajectory_value ne "") )
	   {
		    $trajectory_value =~ s/^\s+|\s+$//g;; #remove all leading and trailing white spaces
        $trajectory_value =~  s/(\d+)\s+/$1 /g; #remove extra white space between the numbers
        $trajectory_value =~ s/ /_/g;
        
        system("/usr/bin/perl dvd_stochastic_runner.pl  $n_nodes $p_value 1 $updstoch_flag $clientip $SSformat $depgraph $updsequ_flag $update_schedule $stochastic 0 $trajectory_value $filename"); 		
		}
		else
		{
			print "<br><font color=red>Sorry. Cannot accept null input for initialization field iii</font><br>";
			die("Program quitting. Empty value for initialization field");
		}
	}
    if($statespace eq "State space graph" && $option_box eq "All trajectories from all possible initial states")
    {
        if(-e "$clientip.out.$SSformat")
        {
            print  "<A href=\"$clientip.out.$SSformat\"
            target=\"_blank\"><font color=red><i>Click to view the state space
            graph.</i></font></A><br>"
        }
    }
    else {
        if(-e "$clientip.graph.$SSformat")
        {
            print  "<A href=\"$clientip.graph.$SSformat\" target=\"_blank\"><font
            color=red><i>Click to view the trajectory.</i></font></A><br>"
        }
    }
    #if(-e "$clientip.out1.$DGformat")
    if(-e "$clientip.out1.$SSformat")
    {
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

print end_html();






# this function reads input functions from file or text area and writes the input functions into $clientip.functionfile.txt
sub create_input_function()
{
    print "Clientip $clientip \n<br>" if ($DEBUG);
    use Cwd;
    $cwd = getcwd();
    `mkdir -p $cwd/../../htdocs/no-ssl/files`; 
    open (OUTFILE, ">$clientip.functionfile.txt");
    print "open ok \n<br>" if ($DEBUG);
	if($upload_file)
	{
	  $fileuploaded = 1;
      flock(OUTFILE, LOCK_EX) or die ("Could not get exclusive lock $!");
      while($bytesread=read($upload_file, $buffer, 1024))
      {
            print OUTFILE $buffer;
      }
      flock(OUTFILE, LOCK_UN) or die ("Could not unlock file $!");
	  close $upload_file;
	}
	else  # user has not uploaded any file. so use the textarea value
	{
	  if($edit_functions)
	  {
		#read value from editfunctions and print it to outfile
		#flock(OUTFILE, LOCK_EX) or die ("Could not get exclusive lock $!");
		print OUTFILE $edit_functions;
		flock(OUTFILE, LOCK_UN) or die ("Could not unlock file $!");
	  }
	  else # no functions provided
	   {
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
	$filename = "$clientip.functionfile.txt";

	if($translate_box eq "Boolean")
    {
		translate_functions();
	}
}


sub translate_functions()
{
	print "translate_functions<br>" if ($DEBUG);
	system("/usr/bin/perl translator.pl $clientip.functionfile.txt $clientip.trfunctionfile.txt $n_nodes");
	$filename = "$clientip.trfunctionfile.txt";
	if(-e "$clientip.trfunctionfile.txt")
	{
		print  "<A href=\"$clientip.trfunctionfile.txt\" target=\"_blank\"><font color=green><i>Translation from Boolean functions to Polynomail was successful.</i></font></A><br><br>";
	}
	else
	{
		print "<font color=red>Translation from Boolean functions to polynomail was unsuccessful</font><br>";
		`rm -f $clientip.functionfile.txt`;
		die("Translation unsuccessful");
	}
}

sub set_update_type()
{
	$update_box_param = "";
	if($update_box eq 'Update_stochastic')
	{
		 #print "Update Stochastic<br>";
	   $update_box_param = "updstoch";
	   $updstoch_flag = "1";
	   $update_schedule = "0";
	}
	 if($update_box eq 'Sequential')
	{
		#print "$update_box<br>";
	   $update_box_param = "async";
	   $updsequ_flag = "1";
	   if( ($update_schedule ne null) &&( $update_schedule ne "") )
	   {
		   $update_schedule =~ s/^\s+|\s+$//g; #remove all leading and trailing white spaces
		   $update_schedule =~  s/(\d+)\s+/$1 /g; # remove extra spaces in between the numbers
		   $update_schedule =~ s/ /_/g;
		   #print "$update_schedule";
	   }
	   else
	   {
		 print "<br><font color=red>Sorry. Cannot accept null input for update schedule field</font><br>";
		 die("Program quitting. Empty value for update schedule field");
	   }
	}
	else
	{
		$update_box_param = "parallel";
		$update_schedule = "0";
	}
}
