#!/usr/bin/perl -w 

## Hussein Vastani
## Franziska Hinkelmann
## Bonbons
## November 2011

use v5.10;
use CGI qw/:standard/;    # load CGI routines
use Fcntl qw( :flock );
print header;             # create the HTTP header

#say "<pre>";
#say param;
#say "</pre>";
#say  param('upload_file');
#exit 1;



$p_value          = param('p_value');
$k_value          = param('k_bound');
$upload_file      = param('upload_file');
$option_box       = "";
$choice_box       = param('choice_box');         # build, analyze, control
$format_box       = param('inputType');
$continuous       = param('continuous');
$anaysis_method = param('anaysis_method');
$limCyc_length    = "1";                         #param('limCyc_length');
$update_box       = "0";                         #param('update_box');
$update_schedule  = "0";                         #param('update_schedule');
$trajectory_box   = "0";                         #param('trajectory_box');
$trajectory_value = "0";                         #param('trajectory_value');
$statespace       = param('statespace');
$depgraph         = param('depgraph');
$feedback         = param('feedback');
$edit_functions   = param('edit_functions');
$SSformat         = param('SSformat');
$DGformat         = param('DGformat');
$stochastic
    = param('probabilities'); # if set, probabilities are drawn in state space
$updstoch_flag = "0";
$updsequ_flag  = "0";
$weights       = param('weights');
$dreamss       = param('dreamss');


# Declaration and initialization of (extra) parameters for SDDS
$upload_file_pm = param('upload_file_pm');
$initialState = "\"" . param('initialState') . "\"";
$interestingNodes = "\"" . param('interestingNodes') . "\"";
$num_states = param('num_states');
$steadyStates = param('SteadyStates');
$transitionMatrix = param('TransitionMatrix');
$flag4ss = 0;
$flag4tm = 0;


if ($choice_box eq "") {
	say '<a href="http://adam.vbi.vt.edu"/>ADAM has moved.</a> Please update your bookmarks';
	exit 1;
}

# this function reads input functions from file or text area and writes the input functions into $clientip.functionfile.txt
sub create_input_function {

  # assures that the program will do nothing for SDDS and continue the algorithm
  if ($format_box eq 'SDDS') {
    return 0;
  }

    #$DEBUG=1;
    print "Clientip $clientip \n<br>" if ($DEBUG);
    use Cwd;
    $cwd = getcwd();
    `mkdir -p $cwd/../../htdocs/no-ssl/files`;
    $filename = "$clientip.functionfile.txt";

    say "--" . $upload_file . "--" if ($DEBUG);
    if ($upload_file) {

        #system("ls");
        say "cp ../../htdocs/no-ssl/files/$upload_file $filename <br>	"
            if ($DEBUG);
        system("cp ../../htdocs/no-ssl/files/$upload_file $filename");
        if ($choice_box eq 'analyze'
            && (   $format_box eq 'PDS'
                || $format_box eq 'pPDS'
                || $format_box eq 'BN'
                || $format_box eq 'PBN' )
            )
        {
			open FILE, "<", $filename or die $!;
            while ( $bytesread = read( FILE, $buffer, 1024 ) ) {
				say "reading ..." if ($DEBUG);
                while ( $buffer =~ m/f(\d+)/g ) {
                    if ( $1 > $n_nodes ) {

                        say "$1<br>" if ($DEBUG);
                        $n_nodes = $1;
                    }
                }
            }
			close(FILE);
        }
    }
    elsif ($edit_functions)
    {    # Otherwise parse functions from textarea value (no file uploaded)
        open( OUTFILE, ">$filename" );
        print "open ok \n<br>" if ($DEBUG);
        print OUTFILE $edit_functions;
        $n_nodes = 0;
        while ( $edit_functions =~ m/f(\d+)/g ) {
            if ( $1 > $n_nodes ) { $n_nodes = $1; }
        }
        flock( OUTFILE, LOCK_UN )
            or die("Could not unlock file $!");
        close(OUTFILE);
    }
    else {
        print
            "<font color=red>No input functions! Please upload a file or enter the functions.</font>";
        die("Program quitting. No input functions");
    }

    #say "$edit_functions";
    #say "The number of nodes is $n_nodes.";
    #remove any ^M characters
    `perl -pi -e 's/\r//g' "$clientip.functionfile.txt"`;
    $buffer = "";
}

# Take the Functions in functionfile.txt, translate them, and save the result back into functionfile.txt
sub translate_functions {
    print "translate_functions<br>" if ($DEBUG);
    system(
        "/usr/bin/perl translator.pl $clientip.functionfile.txt $clientip.trfunctionfile.txt $n_nodes"
    );
    $filename = "$clientip.trfunctionfile.txt";
    if ( -e "$clientip.trfunctionfile.txt" ) {
        print
            "<A href=\"$clientip.trfunctionfile.txt\" target=\"_blank\"><font color=green><i>Translation from Boolean functions to Polynomial was successful.</i></font></A><br><br>";
    }
    else {
        print
            "<font color=red>Translation from Boolean functions to polynomial was unsuccessful</font><br>";
        `rm -f $clientip.functionfile.txt`;
        die("Translation unsuccessful");
    }
}

sub set_update_type() {
    return 0;    # not implemented yet
    $update_box_param = "";
    if ( $update_box eq 'Update_stochastic' ) {

        #print "Update Stochastic<br>";
        $update_box_param = "updstoch";
        $updstoch_flag    = "1";
        $update_schedule  = "0";
    }
    if ( $update_box eq 'Sequential' ) {

        #print "$update_box<br>";
        $update_box_param = "async";
        $updsequ_flag     = "1";
        if (   ( $update_schedule ne null )
            && ( $update_schedule ne "" ) )
        {
            $update_schedule =~ s/^\s+|\s+$//g
                ;    #remove all leading and trailing white spaces
            $update_schedule =~ s/(\d+)\s+/$1 /g
                ;    # remove extra spaces in between the numbers
            $update_schedule =~ s/ /_/g;

            #print "$update_schedule";
        }
        else {
            print
                "<br><font color=red>Please enter an update schedule or select <i>Synchronous</i>.</font><br>";
            die("Program quitting. Empty value for update schedule field");
        }
    }
    else {
        $update_box_param = "parallel";
        $update_schedule  = "0";
    }
}


# Does error checking and sets the flags in SDDS
sub SDDSerrorchecking_and_set_flags {

  # error checking

  if ($initialState eq "\"\"") {
    print "<br> ERROR: The initial state must be specified for the system. Please check the initial state. <br>";
    exit;
  }
  if ($interestingNodes eq "\"\"") {
    print "<br> ERROR: The nodes of interest must be specified for the system. Please check the nodes of interest. <br>";
    exit;
  }
  if ($num_states eq "") {
    print "<br> ERROR: The number of states must be specified for the system. Please check the number of states. <br>";
    exit;
  }

  # set flags

  if ($steadyStates eq "Print Steady States") {
    $flag4ss = 1;
  }
  if ($transitionMatrix eq "Print Transition Matrix") {
    $flag4tm = 1;
  }
}


`mkdir -p ../../htdocs/no-ssl`;
`touch ../../htdocs/no-ssl/access`;

#get the clients ip address
$clientip = $ENV{'REMOTE_ADDR'};
$clientip =~ s/\./\-/g;
( $sec, $min, $hr ) = localtime();
$clientip = $clientip . '-' . $sec . '-' . $min . '-' . $hr;
$clientip = '../../htdocs/no-ssl/files/' . $clientip;

#$clientip = $sec.'-'.$min.'-'.$hr;

#open(ACCESS, ">>../../htdocs/no-ssl/access") or die("Failed to open file for writing");
#flock(ACCESS, LOCK_EX) or die ("Could not get exclusive lock $!");
#print ACCESS ($ENV{REMOTE_ADDR});
#system("date >>../../htdocs/no-ssl/access");
#flock(ACCESS, LOCK_UN) or die ("Could not unlock file $!");
#close(ACCESS);

my $bytesread = "";
my $buffer    = "";

$DEBUG = 0;

$fileuploaded = 0;
$SSformat =~ s/\*\.//;
$DGformat =~ s/\*\.//;
print "access was ok <br>"     if ($DEBUG);
print "$option_box <br>"       if ($DEBUG);
print "$format_box <br>"       if ($DEBUG);
print "$translate_box <br>"    if ($DEBUG);
print "$anaysis_method <br>" if ($DEBUG);

#make input functions - gives p_value and n_nodes
create_input_function();

#print "p_value: " . $p_value ."<br>";
#print "n_nodes: " . $n_nodes ."<br>";
#print $edit_functions . "\n";

#print $choice_box . "<br>";
#print $continuous . "<br>";

given ($choice_box) {
    when (/control/) {
        print "We are implementing Hueristic $format_box <br>"
            if ($DEBUG);
        system('ruby parseGA.rb "$p_value" "$weights" "$dreamss" "$filename"')
            ; #"ruby parseGA.rb \"$p_value\" \"$weights\" \"$dreamss\" \"$filename\""
    }
    when (/build/) {

        #$DEBUG =1;
        print "We are working with transition tables $format_box <br>"
            if ($DEBUG);
        print "p $p_value <br>" if ($DEBUG);
        if ( $continuous eq 'continuous' ) {
            print "We are working with continuous models: $continuous <br>"
                if ($DEBUG);
            system("ruby transitionTablesContinuous.rb $p_value $filename");
        }
        else {
            print "We are not working with continuous models $continuous <br>"
                if ($DEBUG);
            system("ruby transitionTables.rb $p_value $filename");
        }
    }
    when (/analyze/) {
        print $format_box . "<br>" if $DEBUG;
        given ($format_box) {
            when (/Petrinet/) {
                say "cp $filename $clientip.spped" if $DEBUG;
                system("cp $filename $clientip.spped");
                system("ruby petri-converter.rb $clientip $k_value");
            }
            when (/GINsim/) {
                say "cp $filename $clientip.ginsim.ginml" if $DEBUG;
                system("cp $filename $clientip.ginsim.ginml");

                # Convert GINsim file and get p_value and n_nodes
                #The ruby script is supposed to write the p value into a file
                system("ruby ginSim-converter.rb $clientip");
                $pFile = "$clientip.pVal.txt";
                $nFile = "$clientip.nVal.txt";

                # Set p_value and n_nodes
                open( MYFILE, $pFile ) || die("Could not open file!");
                while (<MYFILE>) { chomp; $p_value = $_; }
                close(MYFILE);
                open( MYFILE, $nFile ) || die("Could not open file!");
                while (<MYFILE>) { chomp; $n_nodes = $_; }
                close(MYFILE);
            }
            when (/(BN)|(PBN)/) {
                translate_functions();
            }
            when (/(PDS)|(pPDS)/) {

            }

	    when (/(SDDS)/){
	      SDDSerrorchecking_and_set_flags();  
	      use Cwd;
	      $cwd_sdds = getcwd();
	      `mkdir -p $cwd_sdds/../../htdocs/no-ssl/files`;
	      
	      # checks if a file was uploaded for transition table
	      if ($upload_file) {
		$filename_tt = "$clientip.tt.txt";
		system("cp ../../htdocs/no-ssl/files/$upload_file $filename_tt");
		`perl -pi -e 's/\r//g' "$clientip.tt.txt"`;
	      }
	      else {
		print "<br>ERROR: There must be a file uploaded for a (complete) transition table. <br>";
		exit;
	      }
	      
	      # checks if a file was uploaded for propensity matrix 
	      if ($upload_file_pm) {
		$filename_pm = "$clientip.pm.txt";
		system("cp ../../htdocs/no-ssl/files/$upload_file_pm $filename_pm");
		`perl -pi -e 's/\r//g' "$clientip.pm.txt"`;
	      }
	      else {
		print "<br>FYI: No file was uploaded for the propensity matrix, so uniform distribution will be used. <br>";
	      }
	      
	      $plot_file = "$clientip.plot";
	      $histogram_file = "$clientip.histogram";
	      $tm_file = "$clientip.tm";
	      
	      if ($upload_file_pm) {
		system ("perl SDDS.pl -t $filename_tt -p $filename_pm -i $initialState -n $interestingNodes -s $num_states -f $flag4ss -m $flag4tm -g $plot_file -h $histogram_file -x $tm_file");
	      }
	      else {
		system ("perl SDDS.pl -t $filename_tt -i $initialState -n $interestingNodes -s $num_states -f $flag4ss -m $flag4tm -g $plot_file -h $histogram_file -x $tm_file");
	      }
	    } # end of /SDDS/

            default {
                say 'Invalid choice of model, there was an error.'
            }
        }
    }
    default {
        say 'Invalid choice of input, there was an error.'
    }
}

$useRegulatory = 0;

# Set flag for creating the dependency graph
if ( $depgraph eq "Dependency graph" ) {
    if ( $choice_box eq "analyze" ) {
        if (   ( $format_box eq "PDS" )
            || ( $format_box eq "BN" )
            || ( $format_box eq "GINsim" ) )
        {
            $useRegulatory = 1;
        }
    }

    $depgraph = 1;
}
else {
    $depgraph = 0;
}

( $feedback eq "Feedback Circuit" )
    ? { $feedback = 1 }
    : { $feedback = 0 };

# Give link to functional circuits if checked
if ( $feedback == 1 ) {
    $circuits = "$clientip.circuits.html";
    open FILE, ">$circuits" or die $!;
    print FILE "<html><body>";
    close FILE;
    system("ruby circuits.rb $n_nodes $p_value $filename $circuits");
    open FILE, ">>$circuits" or die $!;
    print FILE "</body></html>";
    close FILE;
    print
        "<a href=\"$circuits\" target=\"_blank\"><font color=\"#226677\"<i>Click to view the functional circuits.</i></font></a><br>";
}

if ( $anaysis_method eq "Conjunctive" ) {

    # dynamics depend on the dependency graph, need to generate it
    system("perl regulatory.pl $filename $n_nodes $clientip $DGformat") == 0
        or die("regulatory.pl died");
    $dpGraph = "$clientip.out1";

    # Give link to dependency graph if checked
    if ( $depgraph == 1 ) {
        print
            "<br><A href=\"$dpGraph.$DGformat\" target=\"_blank\"><font color=\"#226677\"><i>Click to view the dependency graph.</i></font></A><br>";
    }

    #print "ruby adam_conjunctive.rb $n_nodes $p_value $dpGraph.dot<br>" ;
    system("ruby adam_conjunctive.rb $n_nodes $p_value $dpGraph.dot");
}
elsif ( $anaysis_method eq "Algorithms" ) {
    $limCyc_length = 1;
    if ( ( $limCyc_length eq null ) || ( $limCyc_length eq "" ) ) {
        print
            "<font color=red>Please enter a length of the limit cycle you wish to compute. Enter 1 for fixed points</font>";
        die("Program quitting. Empty field entered for limit cycle length in large networks."
        );
    }

    # Give link to dependency graph if checked
    if ( $useRegulatory == 1 ) {
        system("perl regulatory.pl $filename $n_nodes $clientip $DGformat")
            == 0
            or die("regulatory.pl died");
        print
            "<br><A href=\"$clientip.out1.$DGformat\" target=\"_blank\"><font color=\"#226677\"><i>Click to view the dependency graph.</i></font></A><br>";
    }
    set_update_type();
    system(
        "ruby adam_largeNetwork.rb $n_nodes $p_value $filename $limCyc_length"
    );
}
elsif ( $format_box eq "Control" ) {

    # we do nothing
}
elsif ( $anaysis_method eq "Simulation" ) {

    #$DEBUG =1;
    if ( $p_value && $n_nodes ) {
        print "Executing simulation<br>";
        print "hello<br>" if ($DEBUG);
        if ( $n_nodes > 30 || $p_value**$n_nodes > 2**30 ) {
            print
                "<font color=red>Simulation for large networks is not possible. Please chose <i>Algorithms</i> as <b>Analysis</b> option. </font><br>";
            die("Program quitting. Too many nodes");
        }

        print "hello set_update_type<br>" if ($DEBUG);
        set_update_type();

        print $option_box if ($DEBUG);

     # for more than 1000 nodes don't produce a graph, use C++ program instead

        # Set flag for whether to print probabilities in state space
        ( $probabilities eq "probabilities" )
            ? { $stochastic = 1 }
            : { $stochastic = 0 };
        $option_box = "All trajectories from all possible initial states";
        if ( $option_box eq
            "All trajectories from all possible initial states" )
        {    # complete state space
            print $format_box if ($DEBUG);
            if (   $p_value**$n_nodes > 1000
                && $format_box eq "PDS" )
            {
                print
                    "Calculating fixed points and limit cycles, not generating a graph of the state space.<BR>\n";
                print(
                    "./Analysis/analysis $p_value ${clientip}.functionfile  <BR>"
                ) if ($DEBUG);
                print("<pre>");
                system(
                    "./Analysis/analysis $p_value ${clientip}.functionfile");
                print("</pre>");
                print("Done.<br>");
            }
            else {    #analysis through simulation with graph
                if ( $p_value**$n_nodes > 1000 ) {
                    print
                        "<font color=red>Simulation for large stochastic networks is not possible. Please chose <i>Algorithms</i> as <b>Analysis</b> option. </font><br>";
                    die("Program quitting. Too many nodes");
                }
                print
                    "<font color=blue><b>Analysis of the state space</b></font> <br>";
                print(
                    "perl dvd_stochastic_runner.pl  $n_nodes $p_value 1 $updstoch_flag $clientip $SSformat $depgraph $updsequ_flag $update_schedule $stochastic 1 0 $filename\n<br> "
                ) if ($DEBUG);
                system(
                    "/usr/bin/perl dvd_stochastic_runner.pl  $n_nodes $p_value 1 $updstoch_flag $clientip $SSformat $depgraph $updsequ_flag $update_schedule $stochastic 1 0 $filename"
                );
            }
        }
        else {    # trajectory
            print
                "<font color=blue><b>Computing Trajectory of the given initialization</b></font> <br>";
            if (   ( $trajectory_value ne null )
                && ( $trajectory_value ne "" ) )
            {
                $trajectory_value =~ s/^\s+|\s+$//g;
                ;    #remove all leading and trailing white spaces
                $trajectory_value =~ s/(\d+)\s+/$1 /g
                    ;    #remove extra white space between the numbers
                $trajectory_value =~ s/ /_/g;
                print "trajectory_value: $trajectory_value<br>"
                    if $DEBUG;

                system(
                    "/usr/bin/perl dvd_stochastic_runner.pl  $n_nodes $p_value 1 $updstoch_flag $clientip $SSformat $depgraph $updsequ_flag $update_schedule $stochastic 0 $trajectory_value $filename"
                );
                print
                    "/usr/bin/perl dvd_stochastic_runner.pl  $n_nodes $p_value 1 $updstoch_flag $clientip $SSformat $depgraph $updsequ_flag $update_schedule $stochastic 0 $trajectory_value $filename<br>"
                    if $DEBUG;
            }
            else {
                print
                    "<br><font color=red>Please enter an initial state or select <i>Complete State Space</i></font><br>";
                die( "Program quitting. Empty value for initialization field"
                );
            }
        }
        if (   $statespace eq "State space graph"
            && $option_box eq
            "All trajectories from all possible initial states" )
        {
            if ( -e "$clientip.out.$SSformat" ) {
                print "<A href=\"$clientip.out.$SSformat\"
            target=\"_blank\"><font color=\"#226677\"><i>Click to view the state space
            graph.</i></font></A><br>"
            }
        }
        else {
            if ( -e "$clientip.graph.$SSformat" ) {
                print
                    "<A href=\"$clientip.graph.$SSformat\" target=\"_blank\"><font
            color=\"#226677\"><i>Click to view the trajectory.</i></font></A><br>"
            }
        }

        #if(-e "$clientip.out1.$DGformat")
        if ( -e "$clientip.out1.$SSformat" ) {
            print
                "<A href=\"$clientip.out1.$DGformat\" target=\"_blank\"><font
        color=\"#226677\"><i>Click to view the dependency graph.</i></font></A><br>";

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
}

elsif ( $anaysis_method eq "sdds_graph" ) {

  if (-e "$clientip.plot.png"){ 
    print "<br><A href=\"$clientip.plot.png\" target=\"_blank\"><font color=\"#226677\"><i>Click here to see the plot of cell population simulation.</i></font></A><br>";
  }
  if (-e "$clientip.histogram.png") {
    print "<br><A href=\"$clientip.histogram.png\" target=\"_blank\"><font color=\"#226677\"><i>Click here to see the histogram for probability distribution.</i></font></A><br>";
  }
  if (-e "$clientip.tm.txt") {
    print "<br><A href=\"$clientip.tm.txt\" target=\"_blank\"><font color=\"#226677\"><i>Click here to see the probability transition matrix of the system.</i></font></A><br>";
  }
}

else {
    print "there was an error." . "\n";
}

#print $anaysis_method . "<br>\n";
#print $conjunctive . "<br>\n";
exit 1;

