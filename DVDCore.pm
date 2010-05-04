#!/usr/bin/perl

## Franziska Hinkelmann

# This module must be symlinked to /etc/perl/DVDCore.pm
package DVDCore;
use Cwd;

BEGIN {
    use Exporter ();
    our ( $VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS );
    @ISA         = qw(Exporter);
    @EXPORT      = qw(&dvd_session $Use_log);
    %EXPORT_TAGS = ();

    $VERSION = "0.12.1";

    @EXPORT_OK
        = qw(&translator &count_comps_final &sim, &regulatory $N_nodes $P_value $Clientip $Function_data $Function_file $Pwd @Output_array &error_check &_log $Polynome $Stochastic);

# functions that the user may want to include in their namespace, but only if they don't want to use the
# dvd_session method (i.e. they want to manually input/keep track of their variables)
}

our @EXPORT_OK;

# exportable variables
our $N_nodes;
our $P_value;
our $Adj;
our $Clientip;
our @Function_data;
our $Function_file;
our $All_trajectories_flag;
our $Update_stochastic;
our $Update_sequential;
our $Update_schedule;
our $All_trajectories;
our $Initial_state;

# package/module exclusive globals
our @Output_array;
our $Last_status;
our $Current_program;
our $Session_on;

# this is an object that is accessed in nearly every script
our @Functions;

# $Pwd is set by user to define the current working directory
our $Pwd;
our $Polynome;
our $Stochastic;
our $Use_log;

#our $Use_log=1;
our $dot_filename;

# This is a double arraw #prob[i][i] with the probability for the jth function in the ith
# set.
our $prob;

# more localized variables
# none

# private variables
# none

# private functions
# none

# functions

sub dvd_session                           { }
sub translator                            { }
sub count_comps_final                     { }
sub count_comps_final_single_trajectories { }
sub count_comps_final_all_trajectories    { }
sub sim                                   { }
sub regulatory                            { }
sub recu                                  { }
sub create_output { }    # this collects information from the .dot file

END { }

## main code entry

# dvd_session serves as a wrapper for the DVD interface (think new_dvd11.pl), providing a
# single method for specifying all of the needed runtime variables
sub dvd_session {
	

    #set path for graphviz for the server to use, this is necessary, because
    # PATH variable on polymath does not include /usr
    $ENV{'PATH'}            = '/usr/local/bin:/bin:/etc:/usr/bin';
    $ENV{'LD_LIBRARY_PATH'} = '/usr/local/lib/graphviz';

    # eventually serialize a hash
    # count the arguments
    $count = scalar(@_);
    my ($n_nodes,               $p_value,           $clientip,
        $translate,             $update_sequential, $update_schedule,
        $all_trajectories_flag, $statespace,        $ss_format,
        $regulatory,            $dg_format,         $all_trajectories,
        $initial_state,         $update_stochastic, $debug
    ) = @_[ 0 .. 14 ];
    $Use_log         = $debug;
    $Current_program = "dvd_session";

    #print "\$regulatory $regulatory,";
    print "\n<br>" if ($DEBUG);
    _log("all trajectories: $All_trajectories");
    _log( "Argument length: " . $count );
    _log( "Arguments: " . join( ", ", @_[ 0 .. 13 ] ) );
    @Output_array  = [];
    $Function_file = $_[-1];
    $Clientip      = $clientip;
    _log( "Clientip is " . $Clientip );
    $N_nodes               = $n_nodes;
    $P_value               = $p_value;
    $All_trajectories_flag = $all_trajectories_flag
        ;    #plot phase space, not just trajectory for one state
    $Update_stochastic = $update_stochastic
        ;    # 1 if update stochastic (faked with random delays)
    $Update_sequential
        = $update_sequential;    # 1 if we want update sequential system
    $Update_schedule = $update_schedule;    # update order with _ between

    $All_trajectories = $all_trajectories
        ;    #on for all trajectories, off for traj of one initial state
    $Initial_state = $initial_state;

    _log("\$Update_stochastic: $Update_stochastic");
    $Session_on = 1;

    # begin evaluation of input
    if ( ( !$p_value ) & ( !$n_nodes ) ) {
        return _package_error(
            "Empty values for nodes and/or states. $n_nodes, $p_value");

    # _error_and_exit("Empty values for nodes and/or states.", "dvd_session");
    # return $Output_array;
    }

# we need to define a vector for the function file data. It's probably best to get the data and keep it in memory, despite the load, and pass it through the functions. In order to keep from creating extra copies all the time, each function will reference the global memory allocation.
    if ( !@Function_data && ( !defined($Function_file) ) && ($Clientip) ) {
        $function_file_location
            = _get_filelocation("$Clientip.functionfile.txt");
        if ( $Clientip && -e $function_file_location ) {

       # file handle should be <OPEN>
       # my($file_location) = _get_filelocation("$Clientip.functionfile.txt");
            open( $Function_file, $function_file_location );
        }
        else {
            return _package_error(
                "Please ensure that your clientip, $Clientip, corresponds to a file located in $function_file_location."
            );
        }
    }
    if ( $Function_file && scalar(@Function_data) == 0 ) {
        _load_function_data($Function_file);
        _log("Loaded functionfile.");
    }

    @response = error_check();
    return _package_error( $response[1] ) unless ( $response[0] );

    if ( $translate == 1 ) {
        my ( $success, $message ) = dvd_translator();
        return ( _package_error($message) ) unless ($success);
        $Current_program = "dvd_session";
    }

    # we need to clean the file formats
    if ($ss_format) {
        $ss_format =~ s/\*\.//;
    }
    if ($dg_format) {
        $dg_format =~ s/\*\.//;
    }

    $Current_program = "dvd_session";
    if ( $regulatory == 1 ) {

        #print "In regulatory \$dg_format $dg_format<br>";
        my ( $success, $message )
            = regulatory($dg_format);    #create dependency graph
        return _package_error($message) unless ($success);
    }
    if ( $update_stochastic == 1 ) {
        _set_update_stochastic();
    }
    if ( $update_sequential == 1 ) {
        unless ( update_schedule != "" ) {
            $update_schedule = _sanitize_input($update_schedule);
            _log("Update Schedule: $update_schedule");
            my ( $success, $message )
                = _check_and_set_update_schedule($update_schedule);
            if ( $success == 0 ) {
                return _package_error($message);
            }
            else {
                $update_schedule = $success;
            }
        }
        else {
            return _package_error("Empty update schedule.");
        }
    }

    if ( $All_trajectories == 1 ) {
        $mode = 0
            ; # mode refers to the computation mode-- statespace, or initialization
        my ( $success, $message )
            = count_comps_final( $statespace, $ss_format );
        return _package_error($message) unless ($success);
    }
    else {
        $mode = 1;
        unless ( $initial_state eq "" ) {
            $initial_state = _sanitize_input($initial_state);
            _log("initial $initial_state");
        }
        else {
            _log("Initial state: $initial_state.");
            return _package_error("Empty initial state.");
        }
        my ( $success, $message )
            = sim( $initial_state, $update_sequential, $update_schedule,
            $statespace, $ss_format );
        return _package_error($message) unless ($success);
    }
    $Output_array[1] = $mode;

    # cleanup globals
    @Function_data = ();
    $Function_file = "";

    return 1;    # user should then read $Output_array...
}

#identity has to be added to simulate a delay and the probabilites
#have to be set
sub _set_update_stochastic() {
    $Current_program = "_set_update_stochastic";
    for ( my $count = 1; $count <= $n_nodes; $count++ ) {
        _log("Function @{ $Functions[$count-1] }");
        my $identity = "\$x[" . $count . "]";
        _log("\$identity $identity");
        push( @{ $Functions[ $count - 1 ] }, $identity );
        _log( "Increased number of elements in xFunctions[$count] to "
                . scalar( @{ $Functions[ $count - 1 ] } ) );
        _log("Adjusting \$prob[$count-1][_]");

        # probability for using update function on node $count, should be
        # 1/n_nodes
        $prob[ $count - 1 ][0] = 1 / $n_nodes;

        # all the other times delays should be used
        $prob[ $count - 1 ][1] = 1 - $prob[ $count - 1 ][0];
    }
}

# checks update schedule and sets @Functions to new functions
# So far this only works for a deterministic network - does it even make sense
# for a function stochastic network?
#
# common to both sim.pl and count_comps_final
# this function should be called after error_check (@Functions must be set)
#
# @Functions is changed, such that later a regular synchronuous
# update can be made, for example f1=x1+x2, f2=x1, 1_2 turns into
#($x[1])+($x[2])
#(($x[1])+($x[2]))
sub _check_and_set_update_schedule {
    my ( $update_schedule, $n_nodes );
    if ( $Session_on == 1 ) {
        $update_schedule = $_[0];
        $n_nodes         = $N_nodes;
    }
    else {
        ( $update_schedule, $n_nodes ) = @_;
    }
    _log("Update Schedule: $update_schedule");
    $update_schedule =~ s/_/ /g;    #remove the underscores
    my @prefArr = split( /\s+/, $update_schedule );
    if (   ( scalar(@prefArr) != $n_nodes )
        || ( $update_schedule =~ m/[^(\d)(\s*)]/g ) )
    {
        return _package_error(
            "Make sure the indices are non negative numbers separated by spaces and equal to the number of nodes."
        );
    }
    for ( my $h = 0; $h < $n_nodes; $h++ ) {
        if ( $prefArr[$h] > $n_nodes ) {
            return _package_error(
                "Make sure the range of each index of the update schedule is between 1 and number of nodes."
            );
        }
    }
    ## Todo: check that numbers in update schedule are unique, or at least put
    ## it in tutorial
    for ( my $i = 1; $i <= $n_nodes; $i++ ) {
        push( @variables, "\$y[$i]" );
    }

    for ( my $curr = 0; $curr < $n_nodes; $curr++ ) {
        my $varToUpdate = $prefArr[$curr];    #get the order number
        for ( my $i = 1; $i <= $n_nodes; $i++ ) {
            $Functions[ $varToUpdate - 1 ][0]
                =~ s/\$x\[$i\]/\($variables[$i-1]\)/g;
        }
        $variables[ $varToUpdate - 1 ]
            = $Functions[ $varToUpdate - 1 ][0];    # get the function
        $Functions[ $varToUpdate - 1 ][0] =~ s/y/x/g;  #replace ys back to x's
    }
    return 1;
}

sub _sanitize_input {
    $value = $_[0];
    $value =~ s/^\s+|\s+$//g;    #remove all leading and trailing white spaces
    $value =~ s/(\d+)\s+/$1 /g;  # remove extra spaces in between the numbers
    $value =~ s/ /_/g;
    _log("_sanitize_input: $value");
    return $value;
}

# deprecated, use return _package_error($error_message)
sub _error_and_exit {
    my ( $error_message, $function ) = @_;

    foreach (@Output_array) {
        print $_ . "\n";
    }
    exit;
}

# should this be private? we're expecting @Function_data
# if exported, recognize that there are three modes-- $Session_on, $Session_on
# = 0, and the mode that should be defined when it is called from outside a
# particular function
# in the $Session_on == 0 inline function call, we want it to load the
# $Output_array, but return just 0 (we have a hanging or
sub error_check {
    $Current_program = "error_check";
    if ( $Session_on == 1 ) {
        _log("<br>Session_on = 1");
        $mode = 1;
        ( $n_nodes, $function_data ) = ( $N_nodes, \@Function_data );
    }
    else {
        _log("<br>Session_on = 0");
        my ( $n_nodes, $function_data ) = ( $_[0], \$_[ 1 .. -1 ] );
        if ( $Current_program != "" ) {
            $mode = 0;
        }
        else {
            $mode = -1;
        }
    }
    _log( "num_nodes: " . $n_nodes . ", global: " . $N_nodes );
    @Functions = ()
        ; # make sure that this is +only+ run from dvd_session or to validate the function data
    $found  = 0;
    $n      = 1;
    $fcount = 1;
    _log( "Length of \@\$function_data in error_check: " . scalar(@$function_data) );
    if ($Polynome) {
        open( $poly_fix_file, ">poly_fix.txt" );
    }
    foreach (@$function_data) {
        $fn  = 0;
        $max = 1;
        _log("<BR><BR>$_<BR>");
        $tmp1 = scalar($_);
        _log("tmp1 $tmp1<BR>");
        $tmp2 = scalar( @{$_} );
        _log("tmp2 $tmp2<BR>");
        if ( scalar($_) =~ /ARRAY/ ) {
            $max = scalar( @{$_} );
            _log( "Attempting to read from an array... (matching) 'ARRAY:' "
                    . scalar($_)
                    . "With length: $max" );
        }
        until ( $fn == $max ) {
            if ( $max > 1 ) {    #function stochastic
                _log("<BR>Function stochastic<BR>");
                _log("$fn<BR>");
                $line =  @{$_}[$fn];
                #$line = ${ @{$_} }[$fn];
                $n    = ${ @{ $Function_lines[ $fcount - 1 ] } }[$fn];
                _log("<br>Reading fn $fn, function: $line");
                _log("@{$_}[0]");
                _log("{@{$_}}[0]");
                _log("<br>This is called when having multiple functions");
            }
            else {               #not function stochastic
                $line = $_;
                $n = $Function_lines[ $fcount - 1 ] || $n;
                _log("Reading function: $line");
                _log("<br>This is called when having one function");
            }

            #remove newline character
            chomp($line);

            #remove all spaces

            # split into function and probability
            ( my $temp, my $f_prob ) = split( /#/, $line );

            #remove blanks
            $f_prob =~ s/\s*//g;
            chomp($f_prob);

            #_log("\$f_prob: $f_prob after prob");
            # Check whether probability matches 1.0 or 0.23432
            if ( $f_prob =~ m/^((1(\.0+)?)|(0?\.\d+))$/ ) {

                #_log("\$prob[$fcount-1][$fn]= $f_prob");
                $prob[ $fcount - 1 ][$fn] = $f_prob;
            }
            else {    #if no probability was given, assume equal distribution
                $prob[ $fcount - 1 ][$fn] = 1 / $max;
            }

            # assign function to line
            $line = $temp;
            $line =~ s/\s*//g;

            #remove repetitions of equals
            $line =~ s/=+/=/g;
            $count = 0;

            _log(
                "Starting check of function $fcount, which has $max
                function(s)... f$fcount, $line<br>"
            );
            
            #line starts with fi=
            _log("passes f check") if ( $line =~ m/^f$fcount=/i ); 
            
            if (   ( ( $line ne "" ) && ( $line ne null ) )
                && ( $line =~ m/f$fcount=/i || $Polynome || $max => 1 ) )
            {    ## && (@Functions  < $n_nodes))
                $func = ( split( /=/, $line ) )[-1];  # just read the function
                _log( "Length of function:" . length($func) );
                _log("<br>Function $func");
                if ($Polynome) {
                    _log("Hola!");
                    @a_z{ 'a' .. 'z' } = ( 1 .. 26 );

# _log("Before translation, the function looks like this: $func") if (length($func) == 1);
                    _log( "Length of function:" . length($func) );
                    if ( $func =~ /[a-z][^\d]/ ) {
                        _log("Had to rewrite function.");
                        $func
                            =~ s/([a-z][^\d]|[a-z]$)/"x"."$a_z{substr($&, 0, 1)}".substr($&, 1)/ge;
                    }
                    ### print $poly_fix_file $func, "\n";
             # _log("After translation, the function looks like this: $func");
                }
                if ( length($func) == 0 ) {
                    _log("faili empy function");
                    $errString = "ERROR: Empty function no $fcount.";
                    $found     = 1;
                    last;
                }
                if ( $func =~ m/[^(x)(\d)(\()(\))(\+)(\-)(\*)(\^)]/g ) {
                    _log("fail 1");
                    $func =~ s/[^(x)(\d)(\()(\))(\+)(\-)(\*)(\^)]/+/g;
                    _log( length($func) );
                    _log($func);
                    $errString
                        = "ERROR: Found unacceptable character(s) in line $n.";
                    $found = 1;
                    last;
                }

   # check to see if there are equal number of opening and closing paranthesis
                if ( tr/\(/\(/ != tr/\)/\)/ ) {
                    _log("fail 2");
                    $errString = "ERROR: Missing paranthesis in line $n.";
                    $found     = 1;
                    last;
                }

                #check to see if the index of x is acceptable
                $err = 0;
                while ( $func =~ m/x(\d+)/g ) {
                    if ( ( $1 > $n_nodes ) || ( $1 < 1 ) ) {
                        _log("fail 3");
                        $errString
                            = "ERROR: Index of x out of range in line $n.";
                        $err = 1;
                        last;
                    }
                }

                #check to see if there was any error in the above while loop
                if ( $err == 1 ) {
                    _log("fail: $errString");
                    $found = 1;
                    last;
                }

                #Check to see if function is starting properly
                if ( $func =~ m/^[\)\*\^]/ ) {
                    _log("fail 4");
                    $errString
                        = "ERROR: Incorrect syntax in line $n. Inappropriate char at start of function.";
                    $found = 1;
                    last;
                }

                #Check to see if function is ending properly
                if ( $func =~ m/[^\)\d]$/ ) {
                    _log("fail 5");
                    $errString
                        = "ERROR: Incorrect syntax in line $n. Inappropriate char at end of function.";
                    $found = 1;
                    last;
                }

                #check to see if x always has an index
                if ( $func =~ m/x\D/g ) {
                    _log("fail");
                    $errString
                        = "ERROR: Incorrect syntax in line $n. Check x variable.";
                    $found = 1;
                    last;
                }

                #check to see if ^ always has a number following
                if ( $func =~ m/\^\D/g ) {
                    _log("fail");
                    $errString
                        = "ERROR: Incorrect syntax in line $n. Check exponent value.";
                    $found = 1;
                    last;
                }
                if (   ( $func =~ m/[\+\-\*\(][\)\+\-\*\^]/g )
                    || ( $func =~ m/\)[\(\d x]/g )
                    || ( $func =~ m/\d[\( x]/g ) )
                {
                    _log("fail");
                    $errString
                        = "ERROR: Incorrect syntax in line $n. Read the tutorial for correct formatting rules.";
                    $found = 1;
                    last;
                }
                if ( $found == 0 ) {
                    _log("Line is good.");
                    $func =~ s/\^/\*\*/g;   # replace carret with double stars
                    $func =~ s/x(\d+)/\$x\[$1\]/g;    #for evaluation
                    _log("\$func: $func");
                    ## Franziska made a change here, if a stochastic=1, and f_i has only
                    ## one update function, then the indexing later of @functions is
                    ##off, So I think this works, but I don't guarantee
                    #     if ($max > 1)
                    if ( $max > 0 ) {
                        unless ( $Functions[$fcount] ) {
                            $Functions[$fcount] = [$func];
                        }
                        else {
                            push( @{ $Functions[$fcount] }, $func );
                        }
                        _log(
                            "Increased number of elements in xFunctions[x$fcount] to "
                                . scalar( @{ $Functions[$fcount] } ) );
                    }
                    else {   ##Franziska: with the change we don't end up here
                        _log(
                            "NOT Increased number of elements in xFunctions[xn] to "
                                . scalar( @{ $Functions[$fcount] } ) );
                        push( @Functions, $func );
                    }
                }
            }
            else {
                if ( ( $line ne "" ) && ( $line ne null ) ) {
                    _log("fail 0");
                    $errString
                        = "ERROR: Incorrect start of function declaration in line $n.";
                    $found = 1;
                    last;
                }
            }
            $fn++;
        }
        last if ( $found == 1 );    # Errors found
        if ($Update_stochastic) {
            if ( scalar( @{ $Functions[$fcount] } > 1 ) ) {
                _log(
                    "ERROR, Update stochastic but more than one function for f_$fcount."
                );
                $errString
                    = "ERROR: Update stochastic but more than one function for f_$fcount.";
                $found = 1;
                last;
            }
        }
        last if ( $found == 1 );    # Errors found
        if ($Update_sequential) {
            if ( scalar( @{ $Functions[$fcount] } > 1 ) ) {
                _log(
                    "ERROR, Update sequential but more than one function for f_$fcount."
                );
                $errString
                    = "ERROR: Update sequential but more than one function for f_$fcount.";
                $found = 1;
                last;
            }
        }
        last if ( $found == 1 );    # Errors found
        if ( !$All_trajectories ) {
            _log("blaall_trajectories $All_trajectories");
            if ( scalar( @{ $Functions[$fcount] } > 1 ) ) {
                _log(
                    "ERROR, Trajectory from a single initial state but more than one function for f_$fcount."
                );
                $errString
                    = "ERROR, Trajectory from a single initial state but more than one function for f_$fcount.";
                $found = 1;
                last;
            }
        }
        last if ( $found == 1 );    # Errors found
        $fcount++;
        $n++
            ; # only works if the line number matches up (perhaps use a conversion table to get line #?)
    }

    if ( $found == 0 && ( $fcount - 1 ) < $N_nodes ) {
        _log("fail 1");
        $errString
            = "ERROR: Insufficient number of functions in the input provided. Check your number of nodes field.";
        $found = 1;
    }

    #  if ($Stochastic) {
    #    shift(@Functions);
    #  }
### I changed the indexing above, therefore there should always be a shift
    shift(@Functions);
    _log( "Length of \@Functions: " . scalar(@Functions) );
    foreach (@Functions) {
        if ( scalar($_) =~ /ARRAY/ ) {
            _log("{");
            foreach ( @{$_} ) { _log($_) }
            _log("}");
        }
        else {
            _log($_);
        }
    }
    if ( $found == 1 ) {
        _log("Errors found with function file.");
        if ( $mode == 1 || $mode == 0 ) {
            return _package_error($errString);
        }
        return 0;
    }
    elsif ( $found == 0 ) {
        _log("No errors found with function file.");
        return 1;
    }
}

# this function has been deprecated in favor of &dvd_session
sub new_dvd11 { }

# derived from translator.pl, renamed so as not to cause a name collision. Error checking has already been performed on the input file, significantly shortening the file.
# The functions referenced in evalutateInfix, and the function itself, are defined below the function regulatory

sub dvd_translator {
    $Current_program = "dvd_translator";
    if ( $Session_on == 1 ) {
        _log("Session_on = 1");
        my ( $n_nodes, $clientip ) = ( $N_nodes, $Clientip );
        $function_data = \@Function_data;
    }
    else {
        _log("<br>Session_on = 0");
        my ($n_nodes) = $_[0];
        $function_data = \@_[ 1 .. -1 ];
    }
    $found             = 0;
    @new_function_data = ();
    foreach (@$function_data) {
        $line = $_;

        #remove newline character
        chomp($line);
        $func = ( split( /=/, $line ) )[1];
        if ( $found == 0 ) {
            @express = ();
            @testarr = split( /([\(\)\*\+\~ ])/, $func );
            for ( $i = 0; $i < scalar(@testarr); $i++ ) {
                if ( $testarr[$i] ne "" && $testarr[$i] ne " " ) {
                    push( @express, $testarr[$i] );
                }
            }
            push( @new_function_data,
                "f$fcount = " . evaluateInfix(@express) . "\n" );
            $fcount++;
        }
    }
    if ($Session_on) {
        @Function_data = @new_function_data;
        return 1;
    }
    else {
        return ( 1, @new_function_data );
    }
}

# derived from count_comps_final.pl.
# This wrapper picks either the method that does creates the phase space that
# has all possible connections in it or a graph that shows one possible update
# for each function
sub count_comps_final {
    _log("In Count rapper: $All_trajectories_flag");
    if ($All_trajectories_flag) {
        count_comps_final_all_trajectories(@_);
        create_output();
    }
    else {    #deprecated
        count_comps_final_single_trajectories(@_);
    }
}

# This function carries out the evaluation of networks that calculate the entire state space.
# rewritten by Franziska to include all possible connections instead of a
# random instance of the phase space in one graph
sub count_comps_final_all_trajectories {
    $Current_program = "count_comps_final_all_trajectories";

    #print "<br> $Current_program <br>";
    $combi = 1;    # all combinations of functions
    $i     = 0;
    $k     = 1;
    foreach (@Functions) {
        $l = scalar( @{$_} );
        _log("SCALAR in loop $l");
        for ( $j = 0; $j < $l; $j++ ) {
            ## The probablities has to be read in!
            #$prob[$i][$j] = 1/$k;
            $k += 1;
            _log("prob SCALAR prob[$i][$j] = $prob[$i][$j]");
        }
        $i += 1;
        $combi *= $l;
    }

    #		$l = scalar( @{ $Functions[$my_N]} );
    #		_log("SCALAR combinations $combi");
    if ( $Session_on == 1 ) {
        ( $clientip, $n_nodes, $p_value ) = ( $Clientip, $N_nodes, $P_value );
        _log("session variables = $clientip $n_nodes, $p_value");
        ( $statespace, $ss_format ) = @_;
    }
    else {
        my ( $clientip, $n_nodes, $p_value, $update_sequential,
            $update_schedule, $statespace, $ss_format )
            = @_[ 0 .. -2 ];
        _load_function_data( \$_[-1] );
        my ( $success, $message ) = error_check(@Function_data);
        return _package_error($message) unless ($success);

# error_check(@Function_data)[0] or return $Output_array; # WHERE $Output_array is set by _package_error
    }
    _log("Got clientip as $clientip WHERE Session_on = $Session_on");
    _log("session variables = $clientip, $n_nodes, $p_value");

    #now for the main loop.
    #we create a file ip.out.dot describing the state space

    ########### what to do here?
    $dot_filename = _get_filelocation("$clientip.out.dot");

  #print ("Got dot_filename as $dot_filename WHERE Session_on = $Session_on");
    open( $Dot_file, ">$dot_filename" )
        or return print("Could not open $dot_filename.");

#open($Dot_file, ">$dot_filename") or return _package_error("Could not open $dot_filename.");
    print $Dot_file "digraph test {\n";

    #we count both by $i and by @y which encodes $i in base $p_value
    #first initialize @y, probably not needed
    $y[$_] = 0 foreach ( 0 .. $n_nodes - 1 );
    _log("starting loop");
    @fixed_points = [];

    # Iterate through all combinations of update functions by using recursive
    # function
    recu( 0, 1 );
    _log("Adjacency matrix");
    for ( my $x = 0; $x < $p_value**$n_nodes; $x++ ) {
        for ( my $y = 0; $y < $p_value**$n_nodes; $y++ ) {
            if ( scalar( $Adj[$x][$y] ) > 0 ) {

                #printf "%.2f\t",$Adj[$x][$y];
                if ( $x == $y ) {    #fixed point
                                     # add state number and probability
                    push( @fixed_points, [ $x, $Adj[$x][$y] ] );
                }
                if ( !$Stochastic ) {    #make an edge from @y to @ans
                        # graph with arrows without probablities
                    print $Dot_file "node$x -> node$y\n";
                }
                else {    # graph probablities
                    printf $Dot_file "node$x -> node$y [label= \"%.2f",
                        $Adj[$x][$y];
                    printf $Dot_file "\"];\n";
                }
            }
            else {        #print("0 \t");
            }
        }
        #print("\n");
    }

    shift(@fixed_points);
    _log("ended loop.");

    # terminate and close ip.out.dot
    print $Dot_file "}";
    close($Dot_file);
}

sub create_output {
    $Current_program = "create_output";
    $Output_array[6] = $dot_filename;

    # Initialize client side mapping variables needed for commmand
    # line calls
    my $client_wd = _get_filelocation($clientip);
    $cwd = getcwd();
    `mkdir -p $cwd\/$client_wd`;
    `chmod 777 $client_wd`;
    `mkdir -p $client_wd/tmp`;
    `chmod 777 $client_wd/tmp`;
    `mkdir -p $client_wd/dev` ;
    `chmod 777 $client_wd/dev`;

    #$pres = `pwd`;
    #chomp($pres);
    my $pres = "";

    # dot_filename is .dot file
    # count connected components
    my $s = `gc -c $dot_filename`;
    print "<br><br>s $s\n<br>" if ($DEBUG);
    print "<br>" if ($DEBUG);

    #remove trailing return
    chomp $s;

    #remove white space at beginning (\s+ matchs 1 or more spaces)
    $s =~ s/\s+//;
    _log("Output \$s $s");

    #split off the number
    my @tmp = split( / /, $s );
    my $num_comps = $tmp[0];

    # Get number of fixed points as length of fixed_points array
    my $fp = $#fixed_points + 1;
    _log("There are $num_comps components and $fp fixed point(s)");
    $Output_array[2] = $num_comps;
    $Output_array[3] = $fp;

    # each connected component is written to a separated file (/tmp/component)
    my $cwd = getcwd();  
    print "current dir $cwd\n<br>" if ($DEBUG);
    `ccomps -x -o $client_wd/tmp/component $dot_filename`;
    print "return value of ccomps: $? \n<br>" if ($DEBUG);
    print "ccomps -x -o $client_wd/tmp/component $dot_filename\n<br>" if ($DEBUG);
    print "return value of ccomps: $? \n<br>" if ($DEBUG);

 #store the components in files /tmp/component, /tmp/component_1, etc
 #FIXME: parse output of ccomps -v to get #components, then eliminate gc check
 #above.  Probably only saves a few percent of the time, though, so whatever
 #NOTE:   sccmap picks out the strongly connected component
 #        of a directed graph.  In our case, that's the limit cycle.
 #        But sccmap doesn't consider self loops, so we add the fixed point in

    #first process ./tmp/component (stupid naming scheme by ccomps)
    #FIXME: this really should be broken into a procedure
    $size = `grep label $client_wd/tmp/component | wc -l`;
    print "grep label $client_wd/tmp/component | wc -l\n<br>" if ($DEBUG);	
    print "$size\n<br>" if ($DEBUG);
    $cycle
        = `sccmap $client_wd/tmp/component 2> $client_wd/dev/null | grep label | wc -l`;
        print "sccmap $client_wd/tmp/component 2> $client_wd/dev/null | grep label | wc -l\n" if ($DEBUG);
    chomp $size;
    chomp $cycle;
    $size  =~ s/\s+//;
    $cycle =~ s/\s+//;

    if ( $cycle == 0 ) { $cycle++; }
    ### don't print any compononents and their cycles yet
    #$Output_array[4] = "1 $size $cycle";

    $total_size += $size;

    #if $num_comps > 1 then loop over $clientip/tmp/component_$i

    for ( $i = 1; $i < $num_comps; $i++ ) {
        $size = `grep label $client_wd/tmp/component_$i | wc -l`;
        $cycle
            = `sccmap $client_wd/tmp/component_$i 2> $client_wd/dev/null | grep label |wc -l`;

        chomp $size;
        chomp $cycle;
        $size  =~ s/\s+//;
        $cycle =~ s/\s+//;
        if ( $cycle == 0 ) { $cycle++; }
        $tmp = $i + 1;

        # print "$tmp $size $cycle";
        ### don't print any compononents and their cycles yet
        # $Output_array[4] = $Output_array[4]."|$tmp $size $cycle";
        $total_size += $size;
    }
    if ( $fp > 0 ) {
        for ( $i = 0; $i < scalar(@fixed_points); $i++ ) {
            _log("number of fixed points: $#fixed_points +1");

            # fixed points
            #once again convert base p back to decimal
            #      $num = 0;
            #      for ($j = 0 ; $j < $n_nodes; $j++)
            #      {
            #        $num += $fixed_points[$i][$j]*$p_value**($n_nodes-$j-1);
            #      }
            #fixed_points has fixed point as decimal number
            $num = $fixed_points[$i][0];
            my $prob_f = sprintf( "%.2f", $fixed_points[$i][1] );
            _log("Prob \$fixed_points[$i][1] $fixed_points[$i][1]");
            _log("Prob \$prob_f $prob_f");

            # this computes the connected component of node @fixed_points[$i]
            _log(
                "ccomps -Xnode$num $dot_filename -v > $client_wd/tmp/blah 2> $client_wd/dev/null"
            );
            `ccomps -Xnode$num $dot_filename  > $client_wd/tmp/blah 2> $client_wd/dev/null`;

#`ccomps -Xnode$num $dot_filename -v > $client_wd/tmp/blah 2> $client_wd/dev/null`;
#then we count how many labels (and thus nodes) there are in the file
# don't count lines with -> in them
            $s = `grep label $client_wd/tmp/blah | grep -v ">" | wc -l`;

            #$s = `grep label $client_wd/tmp/blah | wc -l`;
            chomp($s);
            $s =~ s/\s+//;

           # convert decimal number $num into array with base p representation
            my @point;
            my $temp = $num;
            for ( my $j = $N_nodes - 1; $j >= 0; $j-- ) {
                $point[$j] = $temp % $P_value;
                $temp -= $point[$j];
                $temp /= $P_value;
            }
            _log("$num in base $P_value: @point \n");

            if ( !$Output_array[5] ) {

                $Output_array[5]
                    = "Fixed point, component size, stability <br> (@point), $s, $prob_f";

                #$Output_array[5] = "@{$fixed_points[$i]}, $s";
                _log("Added it to the beginning...");
            }
            else {
                $Output_array[5]
                    = $Output_array[5] . " <br> (@point), $s, $prob_f";

             #$Output_array[5] = $Output_array[5]."|@{$fixed_points[$i]}, $s";
                _log("Added it to the end...");
            }
        }

        #print "<br>\$statespace $statespace<br>";
        return _package_response(1) unless ( $statespace == 1 );
    }

    #make the nice picture -- THIS IS SLOW!
    #FIXME:  figure out how to make a pretty .png graph, so
    #the file isn't so huge
    if ( $statespace == 1 ) {

        #    if($total_size <= 2**10)
        #    {
        if ( -e $dot_filename ) {
            $statespace_filename
                = _get_filelocation("$clientip.out.$ss_format");

            _log($statespace_filename);
            _log("dot -T$ss_format -o $statespace_filename $dot_filename");

            `dot -T$ss_format -o $statespace_filename $dot_filename`;

            #  $output_array[0] = 1;
            $Output_array[7] = "$statespace_filename";
            return _package_response(1);
        }
        else {
            return _package_error("Unable to locate $dot_filename.");
        }

#    }
#    else
#    {
#      return _package_error("Unable to draw a graph with more than 1000 nodes in the state space.");
#    }
    }
    else {
        $Output_array[7] = "";
    }
}

# derived from sim.pl. This function does calculations for networks with a specific initialization.
# sim("use_session", $initial_state, $update_sequential, $update_schedule, $statespace, $ss_format);
sub sim {
    $Current_program = "sim";
    if ( $Session_on == 1 ) {
        _log("Seesion == 1");
        ( $clientip, $n_nodes, $p_value ) = ( $Clientip, $N_nodes, $P_value );
        (   $initial_state, $update_sequential, $update_schedule, $statespace,
            $ss_format
        ) = @_;
        foreach (@Function_data) {
            _log($_);
        }
    }
    else {
        _log("Seesion == 0");
        (   $clientip, $n_nodes, $p_value, $initial_state, $update_sequential,
            $update_schedule, $statespace, $ss_format
        ) = @_[ 0 .. -2 ];
        _load_function_data( \$_[-1] );
        error_check(@Function_data)
            or return
            $Output_array
            ;    # WHERE $Output_array has already been set by error_check
        if ( $update_sequential == 1 ) {
            _check_and_set_update_schedule(
                _sanitize_input($update_schedule) )
                or return $Output_array;
        }
    }
    _log("Function @{ $Functions[0]}");
    _log("Function @{ $Functions[1]}");
    _log("Function @{ $Functions[2]}");
    $initial_state = _sanitize_input($initial_state);
    $initial_state =~ s/_/ /g;
    _log("final initial state: '$initial_state'");
    @y = split( /\s+/, $initial_state );
    _log( "length of \@y: " . scalar(@y) );

    if (   ( scalar(@y) != $n_nodes )
        || ( $initial_state =~ m/[^(\d)(\s*)]/g ) )
    {
        return _package_error(
            "ERROR, Make sure the states are separated by spaces and equal to the number of nodes."
        );

#   return _package_error("Make sure the indices are non negative numbers separated by spaces and equal to the number of nodes.");
    }

    $overrange = 0;
    for ( $h = 0; $h < scalar(@y); $h++ ) {
        if ( $y[$h] >= $p_value ) {
            $overrange = 1;
            $y[$h] = $y[$h] % $p_value;
        }
    }

    if ( $overrange == 1 ) {
        $Output_array[2]
            = "The trajectory for " . $initial_state . "(which is @y) ";
    }
    else {
        $Output_array[2] = "The trajectory for " . $initial_state;
    }

    # change the index of the array
    @x = ( 0, @y );
    $frominitial = 1;
    _log("before @_");
    foreach ( 0 .. 1000 ) {
        $i = 1;
        foreach (@Functions) {

            #        _log("Function @{ $Functions[0]}");
            #        _log("Function @{ $Functions[1]}");
            #        _log("Function @{ $Functions[2]}");
            #        _log("functions: $_[0]");
            #        _log("functions: @_");
            if ( scalar($_) =~ /ARRAY/ ) {
                foreach ( @{$_} ) {
                    $f = $_;

                    #$f = $_[int(rand(length(@{ $_ })))];
                }
                _log("in scalar $f");
            }
            else {
                $f = $_;
                _log($f);
            }
            $y[$i] = eval($f) % $p_value;
            _log( $y[$i] );
            $i++;
        }

# so now we have the next state stored in the array y. and initial state is still in array x
        $nextsamestate = 1;

        #compare the state and its next state (i.e compare x and y)
        foreach $index ( 1 .. $n_nodes ) {
            if ( $x[$index] != $y[$index] ) {
                $nextsamestate = 0;
            }
        }

       # if repeated is still 1, it means the states were same.
       # so now check if the state was already in the list of previous states.
        shift(@x);
        $temp_string = join( ' ', @x );
        $found       = 0;
        $repeated    = 0;
        foreach (@states) {
            if ( $_ eq $temp_string ) {
                $repeated = 1;
                $found    = 1;
            }
        }

# if the state did not repeat then print the state and push it on the list of previous states
        $Output_array[3] = "";
        if ( $found == 0 ) {
            push( @states, $temp_string );

            # $Output_array[2] = $Output_array[2]."|".$temp_string;
        }
        else {
            if ( ( $found == 1 ) && ( $frominitial == 0 ) )
            {    # state already occured and its not coming from initalization
                    # $Output_array[2] = $Output_array[2]."|".$temp_string;
            }
        }

        # now make x to hold the next state
        foreach $index ( 1 .. $n_nodes ) {
            $x[$index] = $y[$index];
        }

# if next coming state is the same..fixed point has been reached. make sure pair does not repeat
        if ( ( $nextsamestate == 1 ) && ( $found != 1 ) ) {

            # $Output_array[2] = $Output_array[2]."|".$temp_string;
            $repeated = 1;
        }

        if ( $repeated == 1 ) {
            ### don't print any compononents and their cycles yet
            #$Output_array[4] = 1; #repeated node found
            push( @states, $temp_string );
            last;
        }

        # reset value of from initial
        $frominitial = 0;
    }
    $Output_array[3] = join( "|", @states );
    if ($statespace) {
        $lastval      = $states[$#states];
        $old          = $states[0];
        $total_size   = scalar($states);
        $dot_filename = _get_filelocation("$clientip.graph.dot");
        open( $Dot_file, ">$dot_filename" )
            or return _package_error(
            "Could not open $dot_filename for writing.");
        print $Dot_file "digraph G{ \n";
        if ( $lastval eq $old ) {
            print $Dot_file "node[style=filled, color=cyan]\;\n";
            $found = 1;
        }

        print $Dot_file "n" . _hash($old) . " [label=\"$old\",shape=box]\;\n";
        $found = 0;
        for ( $h = 1; $h < scalar(@states); $h++ ) {
            $state = $states[$h];
            if ( ( $lastval eq $state ) && ( $found == 0 ) ) {
                print $Dot_file "node[style=filled, color=cyan]\;\n";
                $found = 1;
            }

            print $Dot_file "n" . _hash($state) . " [label=\"$state\"]\;\n";
            print $Dot_file "n" . _hash($old) . " [label=\"$old\"\];\n";
            print $Dot_file "n"
                . _hash($old) . " -> n"
                . _hash($state) . ";\n";
            $old = $state;
        }

        print $Dot_file "}\n  ";
        print $Dot_file "}\n  \n";
        close($Dot_file);
        $Output_array[5] = $dot_filename;
        open( STDERR, ">/dev/null" );
        if ( $total_size <= 1000 ) {
            if ( -e $dot_filename ) {
                $statespace_filename
                    = _get_filelocation("$clientip.graph.$ss_format");
                `dot -T$ss_format -o $statespace_filename $dot_filename`;
                $Output_array[6] = $statespace_filename;
            }
        }
        else {
            _package_error(
                "Sorry. Unable to draw the trajectory with more than 1000 nodes."
            );
        }

         #`rm -f $dot_filename`;
    }
    return _package_response(1);

}

# derived from regulatory.pl. This function generates a dependency graph for the network
sub regulatory {
    $Current_program = "regulatory";
    my ( $clientip, $n_nodes, $dg_format );
    if ($Session_on) {

        #print" Session on<br>";
        ( $clientip, $n_nodes ) = ( $Clientip, $N_nodes );
        ($dg_format) = $_[0];
    }
    else {

        #print" Session off<br>";
        my ( $clientip, $n_nodes, $dg_format ) = ( @_[ 0 .. 1 ], $_[-1] );
        _load_function_data( \$_[-2] );
        error_check(@Function_data) or return $Output_array;
    }

    my $dot_filename = _get_filelocation("$clientip.out1.dot");
    open( $Dot_file, ">$dot_filename" )
        or return _package_error("Could not open $dot_filename for writing.");
    print $Dot_file "digraph test {\n";

    for ( my $ind = 1; $ind <= scalar(@Functions); $ind++ ) {

        # print all nodes in the dependency graph file
        print $Dot_file "node$ind [label=\"x$ind\", shape=\"box\"];\n";
    }
    my $ind = 1;
    foreach (@Functions) {
        if ( scalar($_) =~ /ARRAY/ ) {

            #print("{<br>");
            foreach ( @{$_} ) {
                my $node = $_;
                _log("testtest $_ = $node <br>");
                @vars = ();
                while ( $node =~ m/x\[(\d+)\]/g ) {

                    #print "what is this $1<br>";
                    $vars[$1] = $1;
                }
                if ( scalar( @vars > 0 ) ) {
                    for ( my $j = 0; $j < scalar(@vars); $j++ ) {
                        if ( defined( $vars[$j] ) ) {
                            $from = $vars[$j];
                            print $Dot_file "node$from -> node$ind;\n";
                        }
                    }
                }
            }

            #print("}<br>");
        }
        else {
            print "ERROR this should not happen\n<BR>";
            print "Are you maybe using the wrong perl version? Retry with 5.8\n<BR>";

            #print($_);
        }
        $ind++;
    }
    print $Dot_file "}";
    close($Dot_file);

    $dot_filename2 = _get_filelocation("$clientip.out2.dot");
    _log("`sort -u $dot_filename > $dot_filename2`");
    _log("Removing double arrows from $dot_filename2");
    `sort -u $dot_filename > $dot_filename2`;
    #`mv $dot_filename $dot_filename2`;
    `rm -f $dot_filename`;
    $dot_filename = $dot_filename2;

    #	for(my $h = 1; $h <= scalar(@Functions); $h++)
    #  {
    #    my $node = $Functions[$h-1];
    #    my @vars = ();
    #    while( $node =~ m/x\[(\d+)\]/g )
    #    {
    #			print "what is this $1<br>";
    #      $vars[$1] = $1;
    #    }
    #    if(scalar(@vars > 0))
    #    {
    #      for(my $j = 0; $j < scalar(@vars); $j++)
    #      {
    #        if(defined($vars[$j]) )
    #        {
    #            $from = $vars[$j];
    #            print $Dot_file "node$from -> node$h;\n";
    #        }
    #      }
    #    }
    #  }
    print $Dot_file "}";
    _log("here");
    close($Dot_file);

    # make the graph
    if ( -e $dot_filename ) {
        $digraph_filename = _get_filelocation("$clientip.out1.$dg_format");
        _log("dot -T$dg_format -o $digraph_filename $dot_filename");
        `dot -T$dg_format -o $digraph_filename $dot_filename`;

# $Output_array[7] = $digraph_filename; # index(7) is only for count_comps_final
# Add the filename to the end of the list
        push( @Output_array, $digraph_filename );

        #`rm -f $dot_filename`
    }
    else {
        _log("dot_filename does not exist in fs");
    }
    #`rm -f $dot_filename`;
    return _package_response(1);
}

# the following functions were derived from the dvd_translator files
# these are meant to be private functions, but the use is not
# prohibited by perl (_isOperand, _isOperator, _InfixToPostfix,
# _PostfixEval, _joinArr, _evaluateInfix)

sub _isOperand {
    $param = shift;
    if ( ( !_isOperator($param) ) && ( $param ne "(" ) && ( $param ne ")" ) )
    {
        return 1;
    }
    else {
        return;
    }
}

sub _isOperator {
    $param = shift;
    if ( ( $param eq "+" ) || ( $param eq "*" ) || ( $param eq "~" ) ) {
        return 1;
    }
    else {
        return;
    }
}

sub _InfixToPostfix {
    @infixStr   = @_;
    @postfixArr = ();
    @stack      = ();
    for ( $i = 0; $i < scalar(@infixStr); $i++ ) {
        if ( _isOperand( $infixStr[$i] ) )   #if its an operand ( * or + or ~)
        {
            push( @postfixArr, $infixStr[$i] )
                ; # add it to the end of the postfixarray or as say top of stack
        }
        if ( _isOperator( $infixStr[$i] )
            )     #if its an operator (x1, x2, x3 etc)
        {
            push( @stack, $infixStr[$i] );    # add it to the top of stack
        }
        if ( $infixStr[$i] eq ")" )  #this marks the latest closed paranthesis
        {
            push( @postfixArr, pop(@stack) )
                ;    #remove from stack and push it in postFixArray
        }
    }
    return @postfixArr;
}

sub _PostfixEval {
    @postfixArr = @_;
    @stackArr   = ();
    for ( $i = 0; $i < scalar(@postfixArr); $i++ ) {
        if ( _isOperand( $postfixArr[$i] ) ) {
            push( @stackArr, $postfixArr[$i] );
        }
        if ( _isOperator( $postfixArr[$i] ) ) {
            $val = pop(@stackArr);
            if ( $postfixArr[$i] eq "~" ) {
                $val = "(" . $val . "+1)";
                push( @stackArr, $val );
            }
            if ( $postfixArr[$i] eq "+" ) {
                $val2 = pop(@stackArr);
                $val
                    = "((" 
                    . $val . "+" 
                    . $val2 . ")+(" 
                    . $val . "*" 
                    . $val2 . "))";
                push( @stackArr, $val );
            }
            if ( $postfixArr[$i] eq "*" ) {
                $val2 = pop(@stackArr);
                $val  = "(" . $val . "*" . $val2 . ")";
                push( @stackArr, $val );
            }
        }
    }
    return @stackArr;
}

sub _joinArr {
    (@who) = @_;
    $who_len = @who;
    $retVal  = "";
    for ( $i = 0; $i < $who_len; $i++ ) {
        $retVal .= $who[$i];
    }
    return $retVal;
}

sub _evaluateInfix {
    @exp = @_;
    return _joinArr( _PostfixEval( _InfixToPostfix(@exp) ) );
}

# this function was added from sim.pl
sub _hash {
    @elems   = split( / /, $_[0] );
    $n_nodes = scalar(@elems);
    $dec_ans = 0;
    for ( $j = 0; $j < $n_nodes; $j++ ) {
        $dec_ans += $elems[$j] * $p_value**( $n_nodes - $j - 1 );
    }
    @elems = ();
    return $dec_ans;
}

# this function decides what kind of output to render based on a value (meant to be the dvd_session code
sub _package_response {
    my ( $exit_code, @output ) = @_;
    my ($program) = $Current_program;
    _clear_current_program();
    if ($Session_on) {
        if ( $exit_code == 0 ) {
            @Output_array = ( $exit_code, $output[0] );
            _log("ERROR: $output[0] in $program.");
            return ( $exit_code, $output[0] );
        }
        elsif ( $exit_code == 1 ) {

# the program/function should be setting Output_array all along
# a 1 error code means that the program successfully executed and needs no intervention
            $Output_array[0] = 1;
            return 1;
        }
        else {
            if ( $exit_code == 0 ) {
                return ( 0, $output[0] );
            }
            elsif ( $exit_code == 1 ) {

                # again, Output_array should be built all along
                $Output_array[0] = 1;
                return @Output_array;
            }
        }
    }
}

sub _package_error {
    return _package_response( 0, @_ );
}

sub _load_function_data {

 # function data should be passed unaliased, see note for changes to this rule
    if ( scalar(@_) > 1 || ( scalar( $_[0] ) =~ /^\d+$/ ) ) {
        @Function_data = @_;
        _log("Loaded function data from array.");
    }
    else {

        # $file_handle = *$_[0]; # fails syntax checks
        _log("Loaded function data from file.");
        $file_handle = $_[0];

        # _log("does file_handle scalar check? ".scalar($file_handle));
        # @hehe = <$Function_file>;
        # log("what? ".$hehe[0]);
        $Function_lines = [];
        $in_bracket     = 0;
        $fn             = 0;
        $line           = 1;
            _log(" <br>P_value: $P_value");
        foreach (<$file_handle>) {
            # line with opening bracket
            if ( $_ =~ /\{/ ) {
                $in_bracket = 1;
                $line++;
                next;
            }
            # check for x_i or constant input
            elsif ( $in_bracket && ($_ =~ /x\d+/ || $_ =~/\d/) ) {
            #elsif ( $in_bracket && ($_ =~ /x\d+/ || $_ =~/1/ || $_ =~/0/) ) 
                if ( $_ =~ /\s*\}/ ) {
                    $_ =~ s/\s*\}//g;
                    $in_bracket = 0;
                    $fn++;
                }
                if ( $Function_data[$fn] ) {
                    unless ( scalar( @Function_data[$fn] ) =~ /^ARRAY/ ) {
                        $Function_data[$fn] = [ $Function_data[$fn], $_ ];
                        $Function_lines[$fn]
                            = [ $Function_lines[$fn], $line ];
                    }
                    else {
                        push( @{ $Function_data[$fn] },  $_ );
                        _log( "in_bracket push: $_");
                        push( @{ $Function_lines[$fn] }, $line );
                        _log( "in_bracket push: $line");
                    }
                }
                else {
                    push( @Function_data,  $_ );
                    _log( "push 1: $_");
                    push( @Function_lines, $line );
                    _log( "push line: $line");
                }
            }
            # line with closing bracket
            elsif ( $in_bracket && $_ =~ /\}/ ) {
                $in_bracket = 0;
                $fn++;
                $line++;
                next;
            }
            # not function stochastic
            # check for xi or constant function
            elsif ( $_ =~ /x\d+/  || $_ =~ /\d/ ) {
                _log("<br><br>");
                _log("before splitting $_");
                $func = (split( /=/, $_))[-1];
                _log("<br>$func<br>");

                push( @Function_data,  $func );
                push( @Function_lines, $line );
                _log( "Not function stochastic (no brackets) push: $func, $line");
                $fn++;
            }
            $line++;
        }
        _log( "First line is: " . $Function_data[0] );
    }
    _log( "Length of function data: " . scalar(@Function_data) );
}

sub _get_filelocation {
    return $_[0];
    $file_location = $_[0];
    $pwd           = "";
    $pwd           = $Pwd;
    $pwd           = $pwd . "/" unless ( $pwd eq "" || $pwd =~ /\/$/ );
    _log("Pwd: '$Pwd', pwd: '$pwd', file_location: '$file_location'");
    return $pwd . $file_location;
}

sub _clear_current_program {
    $Current_program = "";
    return 1;
}

sub _log {
    if ($Use_log) {
        $Current_program = "" unless ($Current_program);
        print "$_[0] in $Current_program\n";
    }
}
## Recursive routine to go through all $n_nodes sets of local functions,
## creating all possible deterministic update functions
# parameters: listlength, probability, list
# done when listlength = $n_nodes
sub recu {
    $Current_program = "recu";
    $my_N            = shift;    # function family
    my $probability = shift;

    #_log("blabla @_");
    #_log("blabla $probability");
    #_log("blabla in recu $my_N");
    #_log("SCA @{$Functions[$my_N]}");
    #foreach( @{ $Functions[$my_N]} ){ _log($_);}
    #_log(@{ $Functions[$my_N] });
    if ( $my_N < $n_nodes ) {

        #_log("prob setting ii to 0");
        my $ii = 0;              # counter for index function in family
        foreach ( @{ $Functions[$my_N] } ) {    #foreach function in set $my_N
            ### The current probability is multiplied by the probability for this
            ### function and then passed to the recursive sub
            #_log("prob $_");
            push( @_, $_ );
            _log("\$prob[$my_N][$ii] = $prob[$my_N][$ii]");

            #_log("\$probability = $probability");
            my $p_temp = $probability * $prob[$my_N][$ii];
            $my_N += 1;
            recu( $my_N, $p_temp, @_ );

            #_log("prob before pop");
            pop(@_);
            $my_N -= 1;

            #_log("\$prob[$my_N][$ii] = $prob[$my_N][$ii]");
            $ii += 1;
        }
    }
    else
    {    #the list past as 3rd parameter has #n_nodes elements, so we simulate
            #the network
            # Iterate through all states (nodes of the phase space)
        for ( $i = 0; $i < $p_value**$n_nodes; $i++ ) {
            _log( "Running iteration for node" . $i );

            # _log("iteration");
            #  @functions wants a list @x, and it starts indexing from 1
            @x = ( 0, @y );

    #   apply functions, reduce mod p.
    #FIXME:  it would be noticibly faster to reduce during function evaluation
    #instead of after -- to do this you could add a regex to
    #substitute "%$p_value +" for occurances of "+" in @functions, I guess
    #only a problem for larger primes

            #all possible combinations of update functions

            # _log( "Number of Combis $combi");
            #print "@{$Functions[0]}";
            #_log("@{$Functions[0]}");
            #_log("${ @{$Functions[0]} }[0]");
            #_log("${ @{$Functions[0]} }[1]");

            $j = 0;
            foreach (@_) {
                $f = $_;
                _log( "Auto-function $f for node" . $i . "[" . $j . "]" );
                $ans[$j] = eval($f) % $p_value;
                if ( $index >= 0 ) {
                    _log( "choosing F_$j [$index]($i) = "
                            . scalar( $ans[$j] ) );
                }
                $j++;
            }

            #but we have to number the nodes.  remember were looping over $i,
            #so node @y is the $ith, but we have to
            #convert the list @ans to decimal

            $dec_ans = 0;
            for ( $j = 0; $j < $n_nodes; $j++ ) {
                $dec_ans += $ans[$j] * $p_value**( $n_nodes - $j - 1 );
            }

            #check for fixed points
            #theyre stored in an array of arrays @fixed_points
            #						if ($i == $dec_ans) {
            #								push(@fixed_points,[ @y ]);
            #						}

            #here we essentially translate @y and @ans into strings $v, $w
            #to be used for the labels in the graphviz view
            $v = "";
            $w = "";
            for ( $j = 0; $j < $n_nodes; $j++ ) {
                $v = $v . " " . "$y[$j]";
                $w = $w . " " . "$ans[$j]";
            }

            #now we make the ip.out.dot file:
            #declare node$i
            print $Dot_file "node$i [label=\"$v\"];\n";

            #hopefully graphviz doesnt need us to declare every node before
            #using it. If there is an error, uncomment this line at the cost
            #of making the dot.out file larger
            #    print OUTDOT "node$dec_ans [label=\"$w\"];\n";

            #make an edge from @y to @ans
            #print $Dot_file "node$i -> node$dec_ans;\n ";

            # Write adjecancy matrix
            $Adj[$i][$dec_ans] += $probability;
            _log("\$Adj[$i][$dec_ans] = $Adj[$i][$dec_ans] ");

            #$Adj[$i][$dec_ans] +=1/$combi;

            #   end of loop.  Finally increment @y -- a base p counter
            #   $i is incremented by the for loop, so we dont have to worry
            #   about when to stop

            $pos = $n_nodes - 1;
            while ( $pos >= 0 ) {
                if ( $y[$pos] == $p_value - 1 ) {
                    $y[$pos] = 0;
                    $pos--;
                }
                else {
                    $y[$pos]++;
                    last;
                }
            }
        }

        _log("## @_");

        #pop(@bla);
    }

    #pop(@bla);
}
return 1;
