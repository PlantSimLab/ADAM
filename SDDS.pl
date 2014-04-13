# Authors: David Murrugarra & Seda Arat
# Name: Script for Stochastic Discrete Dynamical Systems (SDDS)
# Revision Date: April 13, 2014

#!/usr/bin/perl

use strict;
use warnings;

# necessary modules to be installed before running the code
use Getopt::Euclid;
use JSON::Parse;
use Data::Dumper;

=head1 NAME

perl SDDS.pl - Simulate a stochastic model from a possible initialization.

=head1 USAGE

perl SDDS.pl -m <model-file> -s <simulation-file> -p <plot-matrix> -h <histogram-matrix> -t <transitionProbability-matrix>

=head1 SYNOPSIS

perl SDDS.pl -m <model-file> -s <simulation-file> -p <plot-matrix> -h <histogram-matrix> -t <transitionProbability-matrix>

=head1 DESCRIPTION

SDDS.pl - Simulate a stochastic model from a possible initialization.

=head1 REQUIRED ARGUMENTS

=over

=item -m[odel-file] <model-file>

The JSON file containing the model information (.json). 

=for Euclid:

network-file.type: readable

=item -s[imulation-file] <simulation-file>

The JSON file containing the simulation information that the user has been specified (.json). 

=for Euclid:

network-file.type: readable

=back

=head1 OPTIONS

=over

=item -p[lot-matrix] <plot-matrix>

The tab delimited file containing the trajectories for each simulation (.txt).

=for Euclid:

file.type: writable

=item -h[istogram-matrix] <histogram-matrix>

The tab delimited file containing the distribution of states that the initial state can reach (.txt).

=for Euclid:

file.type: writable

=item -t[transitionProbability-matrix] <transitionProbability-matrix>

The tab delimited file containing the probabilities that each state transition to another (.txt).

=for Euclid:

file.type: writable

=back

=head1 AUTHOR

Seda Arat & David Murrugarra

=cut


# inputs
my $modelFile = $ARGV{'-m'};
my $simulationFile = $ARGV{'-s'};

# outputs
my $plotMatrix = $ARGV{'-p'};
my $histogramMatrix = $ARGV{'-h'};
my $transitionProbabilityMatrix = $ARGV{'-t'};

# upper limits
my $max_num_simulations = 10**6;
my $max_num_interestingVariables = 10;
my $max_num_steps = 100;

# converts Model.json to Perl format
my $model = JSON::Parse::json_file_to_perl ($modelFile);

# converts Simulation.json to Perl format
my $simulation = JSON::Parse::json_file_to_perl ($simulationFile);

# sets the update rules/functions (array)
my $updateFunctions = $model->{'model'}->{'updateRules'};

# sets the number of variables in the model (array)
my $variables = $model->{'model'}->{'variables'};
my $num_variables = scalar @$variables;

# sets the unified (maximum prime) number that each state can take values up to
my $num_states = $simulation->{'simulation'}->{'numberofStates'};

# sets the number of simulations that the user has specified
my $num_simulations = $simulation->{'simulation'}->{'numberofSimulations'};

# sets the number of steps that the user has specified
my $num_steps = $simulation->{'simulation'}->{'numberofTimeSteps'};

# sets the initial states that the user has specified for simulations (array)
my $initialStates = $simulation->{'simulation'}->{'initialStates'};

# sets the variables of interest that the user has specified for plots (array)
my $interestingVariables = $simulation->{'simulation'}->{'VariablesofInterest'};
my $num_interestingVariables = scalar @$interestingVariables;

print "$num_variables \t $num_states \t $num_simulations \t $num_steps \t $initialStates \t $interestingVariables \t $num_interestingVariables \t @var_names \n";

error_checking ();

# print ref $model , "\n";
# print Dumper ($model);
# print Dumper ($simulation);

# it is for random number generator
#srand (time | $$);


# my $allTrajectories = get_alltrajectories ();
# my $averageTrajectories = get_averagetrajectories ();

# my ($i, @x_axis4plotting, %y_axis4plotting, @legend_keys);

# # Gets the averageTrajectories of interesting variables for plotting

# for ($i = 0; $i < $num_interestingVariables; $i++) {
#   my $t = $interestingVariables->[$i] - 1;

#   for (my $j = 0; $j <= $num_steps; $j++) {
#     if ($i == 0) {
#       $x_axis4plotting[$j] = $j;
#     }
#     my $r = $j * $num_variables + $t;
#     push (@{$y_axis4plotting{$i + 1}}, $averageTrajectories->[$r]);
#   }
# }

exit;

############################################################

############################################################
####################### SUBROUTINES ########################
############################################################

=pod

error_checking ();

Checks if the user enters the options/parameters correctly

=cut

sub error_checking {

  # num_simulations
  if (isnot_number ($num_simulations) || $num_simulations < 1 || $num_simulations > $max_num_simulations) {
    print ("<br>ERROR: The number of simulations must be a number between 1 and $max_num_simulations. <br>");
    exit;
  }

  # num_steps
  if (isnot_number ($num_steps) || $num_steps < 1 || $num_steps > $max_num_steps) {
    print ("<br>ERROR: The number of steps must be a number between 1 and $max_num_steps. <br>");
    exit;
  }

  # initialStates
  # foreach my $s (@{$interestingVariables}) {
  #   if ((isnot_number ($s)) || ($s < 1)) {
  #     print ("<br>ERROR: The nodes of interest must consist of the numbers which are at most the number of variables. Please check the nodes of interest and/or the initial state. <br>");
  #     exit;
  #   }
  # }

  # interestingVariables
  if ($num_interestingVariables < 1 || $num_interestingVariables > $max_num_interestingVariables) {
    print ("<br>ERROR: The number of variables of interest must be between 1 and $max_num_interestingVariables. <br>");
    exit;
  }
  foreach my $int_var (@$interestingVariables) {
    my $flag = 0;
    foreach my $name (@var_names) {
      if ($int_var eq $name) {
	$flag = 1;
	last;
      }
    }
    unless ($flag) {
      print ();
      exit;
    }
  }

}

# sub get_initialstate {
#   my $initialState = shift;

#   my @initState = split (/\s+/, $initialState);
#   my $num_variables = scalar @initState;

#   #error checking

#   for (my $i = 0; $i < $num_variables; $i++) {
#     if ($initState[$i] < 0 || $initState[$i] > $num_states - 1) {
#       my $max_limit = $num_states - 1;
#       print ("\n ERROR: The numbers in the initial state must be between 0 and $max_limit. Please revise the initial state. \n");
#       exit;
#     }
#   }

#   return (\@initState, $num_variables);
# }

# ############################################################

# =pod

# get_interestingvariables ($interestingvariables);

# Reads and stores the variables of interests in an array. 
# Returns a reference of the interesting variables array and a number indicating the number of interesting variables.

# =cut

# sub get_interestingvariables {
#   my $interestingvariables = shift;
#   $interestingvariables =~ s/\s//g; #remove all spaces
#   my @interestingvariables = split (/\,/, $interestingvariables);
#   my $num_interestingvariables = scalar @interestingvariables;


#   #error checking

#   for (my $i = 0; $i < $num_interestingvariables; $i++) {
#     if ($interestingvariables[$i] < 1 || $interestingvariables[$i] > $num_variables) {
#       print ("\n ERROR: Interesting variables must be between 1 and $num_variables. Please revise the interesting variables. \n");
#       exit;
#     }
#   }
  
#   if ($num_interestingvariables > $max_num_interestingVariables) {
#     print ("\n ERROR: The number of interesting variables must be at most 5. Please revise the interesting variables. \n");
#     exit;
#   }

#   return (\@interestingvariables, $num_interestingvariables);
# }

# ############################################################

# =pod

# get_externalparameters ($ext_param);

# Reads and stores the external parameters into a hash. 
# Returns a reference of the external parameters hash.

# =cut

# sub get_externalparameters {
#   my $ext_param = shift;

#   $ext_param =~ s/\s//g; #remove all spaces
#   my @param = split (/\,/, $ext_param);

#   my %externalParameters;
  
#   for (my $i = 0; $i < @param; $i++) {
#     my @temp = split (/=/, $param[$i]);
#     $externalParameters{$temp[0]} = $temp[1];
#   }

#   return \%externalParameters;
# }

# ############################################################

# =pod

# $sdds = get_propensities ($propensitiesfile);

# Reads and stores the propensity parameters in a hash. 
# The keys are the row numbers and the values are references of arrays consisting of 
# activation and degradation propensities. 
# The first element is the activation propensity and the second element is the 
# degradation propensity in the array.
# Returns a reference of the propensities hash.

# =cut

# sub get_propensities {
#   my $propfile = shift;
#   my %propensities;
#   my $i = 1;
 
#   open (OUTPUT, "< $propfile") or die("\n ERROR: Cannot open the propensities file for reading! \n");
#   while (my $line = <OUTPUT>) {
#     chomp($line);
    
#     # skip empty lines
#     if ($line =~ /^\s*$/) {
#       next;
#     }
#     else {
#       my @array = split (/\s+/, $line);      
#       $propensities{$i} = \@array;
#       $i++;
#     }
#   }
  
#   close(OUTPUT) or die("\n ERROR: Cannot close the propensities file! \n");

#   #error checking

#   unless (%propensities) {
#     print ("\n ERROR: The propensity matrix is empty. \n");
#     exit;
#   }

#   $i--;
#   if ($i != $num_variables) {
#     print ("\n ERROR: The number of rows must be equal to the number of variables in the system. Please revise the propensities file and/or the initial state. \n");
#     exit;
#   }

#   return \%propensities;
# }

# ############################################################

# =pod

# get_updatefunctions ($functionsfile);

# Reads and stores the functions file into an array.
# The n-th element of the functions array is the update function 
# of the n-th variable.
# Returns a reference of the functions array.

# =cut

# sub get_updatefunctions {
#   my $functionsfile = shift;
#   my @functions = ();

#   open (FILE, "< $functionsfile") or die ("\n ERROR: Cannot open the functions-file for reading! \n");
#   while (my $line = <FILE>) {
#     chomp ($line);
    
#     # skip empty lines
#     if ($line =~ /^\s*$/) {
#       next;
#     }
    
#     if ($line =~ /(f|=|x)/) {
     
#       foreach my $key (keys %$externalParameters) {
# 	my $value = $externalParameters->{$key};
# 	$line =~ s/$key/$value/g;
#       }

#      # $line =~ s/\s//g; # remove all spaces
#       $line =~ s/\^/\*\*/g; # replace carret with double stars
#       $line =~ s/x(\d+)/\$x\[$1\]/g; #for evaluation
      
#       my $f;
      
#       unless ($line =~ /^f/) {
# 	my $temp = pop (@functions);
# 	$f = $temp . $line;
#       }
#       else {
# 	(my $a, $f) = split (/=/,$line);
#       }

#       push (@functions, $f);
#     }
#     else {
#       print ("\n ERROR: Please revise the format of the functions file. \n");
#       exit;
#     }
#   }
  
#   close (FILE) or die ("\n ERROR: Cannot close the functions file! \n");
  

#   # Error checking

#   unless ($num_variables == scalar @functions) {
#       print ("\n ERROR: The number of functions in the file must be equal to the number of variables. Please revise the functions file and/or the initial state. \n");
#       exit;
#   }

#   return \@functions;
# }

# ############################################################

# =pod

# $sdds = get_alltrajectories ();

# Stores all trajectories into a hash table whose keys are the order of 
# the trajectories and the values are the trajectories at the initial state 
# and length is num_steps+1.
# Returns a reference of the all trajectories hash.

# =cut

# sub get_alltrajectories {

#   my %alltrajectories = ();
  
#   my $n = $num_simulations * $num_steps;

#   for (my $i = 1; $i <= $num_simulations; $i++) {

#     unless ($i % 100) {
#       print "index_sim = $i \n";
#     }

#     my @temp = ();  # stores a single trajectory each time 
#     my $is = $initialState;

#     push (@temp, convert_from_state_to_decimal ($is));
    
#     for (my $j = 1; $j <= $num_steps; $j++) {
#       my $ns = get_nextstate_propensities ($is);
#       push (@temp, convert_from_state_to_decimal ($ns));
#       $is = $ns;
#     }

#     $alltrajectories{$i} = \@temp;
#   } # end of for loop $i

#   return \%alltrajectories;
# }

# ############################################################

# =pod

# get_averagetrajectories();

# Stores average trajectories of all variables into an array.
# The n-th element of the array is the average trajectory of the n-th variable.
# Returns a reference of average trajectories array.

# =cut

# sub get_averagetrajectories {

#   my @averagetrajectories = ();

#   my $total_num_states = $num_states ** $num_variables;
  
#   for (my $i = 1; $i <= $num_steps + 1; $i++) {
#     my @temp = ();  # keeps the values of i-th states in trajectories
    
#     for (my $j = 1; $j <= $num_simulations; $j++) {
      
#       my @traj = @{$allTrajectories->{$j}};
#       my @value = convert_from_decimal_to_state ($traj[$i - 1]);
#       push (@temp, @value);
#     }
    
#     my @sum = ();
#     for (my $k = 0; $k < $num_variables; $k++) {
#       for (my $r = 0; $r < $num_simulations; $r++) {
# 	my $w = ($r * $num_variables) + $k;
# 	$sum[$k] += $temp[$w];
#       } 
      
#       push (@averagetrajectories, $sum[$k] / $num_simulations);
#     }
#     print "index_timeSteps = $i \n";
#   }
  
#   return \@averagetrajectories;
# }

# ############################################################

# =pod

# convert_from_state_to_decimal ($state);

# Converts a given state to its base-10 representation and adds 1 for convenience.
# The input is a reference of a state array.
# Returns a number, which is the base-10 representation of the state array.

# =cut

# sub convert_from_state_to_decimal {
#   my $state = shift;
#   my $decimal_rep = 1;

#   for (my $i = 0; $i < $num_variables; $i++) {
#     $decimal_rep += $$state[$num_variables - $i - 1] * ($num_states ** $i);
#   }
#   return $decimal_rep;
# }

# ############################################################

# =pod

# convert_from_decimal_to_state ($n);

# Converts the base-10 representation of a state to state itself.
# The input is a number.
# Returns a reference of state array.

# =cut

# sub convert_from_decimal_to_state {
#   my $n = shift;
#   my ($quotient, $remainder);
#   my @state = ();
#   $n--;

#   do {
#     $quotient = int $n / $num_states;
#     $remainder = $n % $num_states;
#     push (@state, $remainder);
#     $n = $quotient;
#   } until ($quotient == 0);

#   my $dif = $num_variables - (scalar @state);

#   if ($dif) {
#     for (my $i = 0; $i < $dif; $i++) {
#       push (@state, 0);
#     }
#   }

#   @state = reverse @state;
#   return @state;
# }

# ###########################################################################

# =pod

# get_nextstate_propensityparameter ($state);

# Returns the next state (as a reference of an array) of a given state 
# (as a reference of an array) using @updateFunctions and propensity parameters.

# =cut

# sub get_nextstate_propensities {
#   my $state = shift;

#   my $z = get_nextstate ($state);
#   my @nextsstatepropensities;

#   for (my $j = 0; $j < $num_variables; $j++) {
#     my $r = rand;
#     my @prop = @{$propensities->{$j + 1}};

#     # $prop[0] is the activation propensity
#     # $prop[1] is the degradation propensity

#     if ($state->[$j] < $z->[$j]) {
#       if ($r < $prop[0]) {
# 	$nextsstatepropensities[$j] = $z->[$j];
#       }
#       else{
# 	$nextsstatepropensities[$j] = $state->[$j];
#       }
#     }
#     elsif ($state->[$j] > $z->[$j]) {
#       if ($r < $prop[1]) {
# 	$nextsstatepropensities[$j] = $z->[$j];
#       }
#       else{
# 	$nextsstatepropensities[$j] = $state->[$j];
#       }
#     }
#     else {
#       $nextsstatepropensities[$j] = $state->[$j];
#     }
#   }
#   return \@nextsstatepropensities;
# }

# ############################################################

# =pod

# get_nextstate ($state);

# Returns the next state (as a reference of an array) of a given state using @updateFunctions

# =cut

# sub get_nextstate {
#   my $state = shift;
#   my @x = @$state;
#   my @nextState;

#   my @temp = @$updateFunctions;
  
#   for (my $i = 0; $i < @temp; $i++) {
#     for (my $j = 0; $j < @x; $j++) {
#       my $k = $j + 1;
#       $temp[$i] =~ s/\$x\[$k\]/\($x[$j]\)/g;
#     }
    
#     $nextState[$i] = eval ($temp[$i]) % $num_states;
#   }
  
#   return \@nextState;
# }

############################################################

=pod

isnot_number ($n);

Returns true if the input is not a number, false otherwise

=cut

sub isnot_number {
  my ($n) = @_;

  if ($n =~ m/\D/) {
    return 1;
  }
  else {
    return 0;
  }
}

############################################################

=pod

isnot_float ($n);

Returns true if the input is not a floating number (between 0 and 1), false otherwise.

=cut

sub isnot_float {
  my ($f) = @_;
  if ($f =~ /[^\d\.]/) {
    return 1;
  }
  else {
    return 0;
  }
}
