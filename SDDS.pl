# Authors: David Murrugarra & Seda Arat
# Name: Script for Stochastic Discrete Dynamical Systems (SDDS)
# Revision Date: July 20, 2014

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

perl SDDS.pl -m <model-file> -s <simulation-file> -o <output-matrix>

=head1 SYNOPSIS

perl SDDS.pl -m <model-file> -s <simulation-file> -o <output-matrix>

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

=item -o[utput-matrix] <output-matrix>

The tab delimited file containing the average trajectories of all variable (.txt).

=for Euclid:

file.type: writable

=back

=head1 AUTHOR

Seda Arat & David Murrugarra

=cut

# it is for random number generator
srand ();

# inputs
my $modelFile = $ARGV{'-m'};
my $simulationFile = $ARGV{'-s'};

# outputs
my $outputMatrix = $ARGV{'-o'};

# it is for random number generator
srand (time | $$);

# upper limits
my $max_num_simulations = 10**6;
my $max_num_interestingVariables = 10;
my $max_num_steps = 100;

# converts Model.json to Perl format
my $model = JSON::Parse::json_file_to_perl ($modelFile);

# converts Simulation.json to Perl format
my $simulation = JSON::Parse::json_file_to_perl ($simulationFile);

# sets the update rules/functions (hash)
my $updateFunctions = $model->{'model'}->{'updateRules'}->[0];
my $num_functions = scalar values %$updateFunctions;

# sets the number of variables in the model (array)
my $variables = $model->{'model'}->{'variables'};
my $num_variables = scalar @$variables;

# sets the unified (maximum prime) number that each state can take values up to (scalar)
my $num_states = $simulation->{'simulation'}->{'numberofStates'};

# sets the number of simulations that the user has specified (scalar)
my $num_simulations = $simulation->{'simulation'}->{'numberofSimulations'};

# sets the number of steps that the user has specified (scalar)
my $num_steps = $simulation->{'simulation'}->{'numberofTimeSteps'};

# sets the initial states that the user has specified for simulations (array)
my $initialStates = $simulation->{'simulation'}->{'initialStates'};
my @initialState = split (/\s/, $initialStates->[0]);

# print "@initialState \n";

# sets the variables of interest that the user has specified for plots (array)
my $interestingVariables = $simulation->{'simulation'}->{'variablesofInterest'};
my $num_interestingVariables = scalar @$interestingVariables;

# sets the propensities (hash);
my $propensities = $simulation->{'simulation'}->{'propensities'};
my $num_propensities = scalar values %$propensities;

error_checking ();
my $allTrajectories = get_allTrajectories ();
print Dumper ($allTrajectories);

# TO_DO:
# my $averageTrajectories = get_averagetrajectories ();
# print_outputmatrix ();

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
  
  # num_functions, num_variables and num_propensities
  unless ($num_functions == $num_variables) {
    print ("<br>INTERNAL ERROR: The number of variables, $num_variables, must be equal to the number of update rules, $num_functions. <br>");
    exit;
  }

  unless ($num_variables == $num_propensities) {
    print ("<br>ERROR: There must be propensity entries for $num_variables variables. It seems there are propensity entries for $num_propensities variables. <br>");
    exit;
  }

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

  # propensities
  foreach my $v (values %$propensities) {

    unless (($v->[0] >= 0) && ($v->[0] <= 1)) {
      print ("<br>ERROR: The activation propensities for stochastic simulations must be a number between 0 and 1. <br>");
      exit;
    }
    
    unless (($v->[1] >= 0) && ($v->[1] <= 1)) {
      print ("<br>ERROR: The degradation propensities for stochastic simulations must be a number between 0 and 1. <br>");
      exit;
    }
  }

}

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

get_allTrajectories ();

Stores all trajectories into a hash table whose keys are the order of 
the trajectories and the values are the trajectories at the initial state 
and length is num_steps+1.
Returns a reference of the all trajectories hash.

=cut

sub get_allTrajectories {

  my %alltrajectories = ();

  for (my $i = 1; $i <= $num_simulations; $i++) {

    my @temp = ();  # stores a single trajectory each time 
    my $is = \@initialState;

    push (@temp, convert_from_state_to_decimal ($is));
    
    for (my $j = 1; $j <= $num_steps; $j++) {
      my $ns = get_nextstate_stoch ($is);
      push (@temp, convert_from_state_to_decimal ($ns));
      $is = $ns;
    }

    $alltrajectories{$i} = \@temp;
  }

  return \%alltrajectories;
}

############################################################

=pod

convert_from_state_to_decimal ($state);

Converts a given state to its base-10 representation and adds 1 for convenience.
The input is a reference of a state array.
Returns a number, which is the base-10 representation of the state array.

=cut

sub convert_from_state_to_decimal {
  my $state = shift;
  my $decimal_rep = 1;
  
  for (my $i = 0; $i < $num_variables; $i++) {
    $decimal_rep += $$state[$num_variables - $i - 1] * ($num_states ** $i);
  }
  return $decimal_rep;
}

############################################################

=pod

get_nextstate_stoch ($state);

Returns the next state (as a reference of an array) of a given state 
(as a reference of an array) using update functions and propensity parameters.

=cut

sub get_nextstate_stoch {
  my $state = shift;
  my $z = get_nextstate_det ($state);

  print "state = @$state \t nextstate_det = @$z \n";

  my @nextsstateStoch;
  
  for (my $j = 0; $j < $num_variables; $j++) {
    my $r = rand ();
    my $i = $j + 1;
    my $prop = $propensities->{"x$i"};
    
    # $prop->[0] is the activation propensity
    # $prop->[1] is the degradation propensity
    
    if ($state->[$j] < $z->[$j]) {
      if ($r < $prop->[0]) {
 	$nextsstateStoch[$j] = $z->[$j];
      }
      else{
 	$nextsstateStoch[$j] = $state->[$j];
      }
    }
    elsif ($state->[$j] > $z->[$j]) {
      if ($r < $prop->[1]) {
 	$nextsstateStoch[$j] = $z->[$j];
      }
      else{
 	$nextsstateStoch[$j] = $state->[$j];
      }
    }
    else {
      $nextsstateStoch[$j] = $state->[$j];
    }
  }

  print "state = @$state \t nextstate_stoch = @nextsstateStoch \n";

  return \@nextsstateStoch;
 }

############################################################

=pod

get_nextstate_det ($state);

Returns the next state (as a reference of an array) of a given state using 
update functions.

=cut

sub get_nextstate_det {
  my $state = shift;
  my @nextState;
  
  for (my $i = 1; $i <= @$state; $i++) {
    my $func = $updateFunctions->{"x$i"}->{"polynomialFunction"};

    for (my $j = 1; $j <= @$state; $j++) {
      $func =~ s/x[$j]/\($state->[$j - 1]\)/g;
    }
    
    $nextState[$i - 1] = eval ($func) % $num_states;
   }
  
  return \@nextState;
}

############################################################

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

############################################################

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
  
 #  @state = reverse @state;
#   return @state;
# }

############################################################
