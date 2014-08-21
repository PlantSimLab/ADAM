# Authors: Seda Arat & David Murrugarra
# Name: Script for Stochastic Discrete Dynamical Systems (SDDS)
# Revision Date: August 19, 2014

#!/usr/bin/perl

use strict;
use warnings;

############################################################
###### REQUIRED PERL MODULES before running the code #######
############################################################

use Getopt::Euclid;
use JSON::Parse;
use JSON;
# use Data::Dumper;

############################################################

=head1 NAME

perl SDDS.pl - Simulate a stochastic model from a possible initialization.

=head1 USAGE

perl SDDS.pl -m <model-file> -s <simulation-file> -o <output-file>

=head1 SYNOPSIS

perl SDDS.pl -m <model-file> -s <simulation-file> -o <output-file>

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

=item -o[utput-file] <output-file>

The JSON file containing the average trajectories of all variables.

=for Euclid:

file.type: writable

=back

=head1 AUTHOR

Seda Arat

=cut

# it is for random number generator
srand ();

# inputs
my $modelFile = $ARGV{'-m'};
my $simulationFile = $ARGV{'-s'};

# output(s)
my $outputFile = $ARGV{'-o'};

# upper limits
my $max_num_simulations = 10**6;
my $max_num_interestingVariables = 10;
my $max_num_steps = 100;

# converts Model.json to Perl format
my $model = JSON::Parse::json_file_to_perl ($modelFile);

# converts Simulation.json to Perl format
my $simulation = JSON::Parse::json_file_to_perl ($simulationFile);

# sets the update rules/functions (hash)
my $updateFunctions = $model->{'model'}->{'updateRules'};
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
my $initialState = $simulation->{'simulation'}->{'initialState'};

# sets the variables of interest that the user has specified for plots (array)
my $interestingVariables = $simulation->{'simulation'}->{'variablesofInterest'};
my $num_interestingVariables = scalar @$interestingVariables;

# sets the propensities (hash);
my $propensities = $simulation->{'simulation'}->{'propensities'};
my $num_propensities = scalar values %$propensities;

error_checking ();

my $allTrajectories = get_allTrajectories ();
my $averageTrajectories = get_averageTrajectories ();

# print Dumper ($allTrajectories);
# print ("\n*********************************\n");
# print Dumper ($averageTrajectories);

my $json = JSON->new->indent ();

open (OUT," > $outputFile") or die ("<br>ERROR: Cannot open the file for output. <br>");
print OUT $json->encode ($averageTrajectories);
close (OUT) or die ("<br>ERROR: Cannot close the file for output. <br>");

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

  unless ($num_variables == scalar @$initialState) {
     print ("<br>ERROR: There must be $num_variables variables in the initial state. Please check the initial state entry. <br>");
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
    unless (($v->{"activation"} >= 0) && ($v->{"activation"} <= 1)) {
      print ("<br>ERROR: The activation propensities for stochastic simulations must be a number between 0 and 1. <br>");
      exit;
    }
    unless (($v->{"degradation"} >= 0) && ($v->{"degradation"} <= 1)) {
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
  my $n = shift;

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
    my %table = ();
    my @is = @$initialState;

    for (my $k = 1; $k <= $num_variables; $k++) {
      push (@{$table{"x$k"}}, $is[$k - 1]);
    }
    
    for (my $j = 1; $j <= $num_steps; $j++) {
      my @ns = @{get_nextstate_stoch (\@is)};
      
      for (my $r = 1; $r <= $num_variables; $r++) {
	push (@{$table{"x$r"}}, $ns[$r - 1]);
      }
      @is = @ns;
    }
    $alltrajectories{$i} = \%table;
  }
  return \%alltrajectories;
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

  my @nextsstateStoch;
  
  for (my $j = 0; $j < $num_variables; $j++) {
    my $r = rand ();
    my $i = $j + 1;
    my $prop = $propensities->{"x$i"};
    
    if ($state->[$j] < $z->[$j]) {
      if ($r < $prop->{"activation"}) {
 	$nextsstateStoch[$j] = $z->[$j];
      }
      else{
 	$nextsstateStoch[$j] = $state->[$j];
      }
    }
    elsif ($state->[$j] > $z->[$j]) {
      if ($r < $prop->{"degradation"}) {
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

=pod

get_averageTrajectories ();

Stores average trajectories of all variables into a hash.
Returns a reference of average trajectory hash.

=cut

sub get_averageTrajectories {
  my %averagetrajectories = ();

  for (my $v = 1; $v <= $num_variables; $v++) {
    for (my $t = 0; $t <= $num_steps; $t++) {
      my $sum = 0;
      
      for (my $s = 1; $s <= $num_simulations; $s++) {
	$sum += $allTrajectories->{$s}->{"x$v"}->[$t];
      }
      $averagetrajectories{"x$v"}[$t] = $sum / $num_simulations;
    }
  }
  
  return \%averagetrajectories;
}

############################################################
