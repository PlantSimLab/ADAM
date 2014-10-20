# Author: Seda Arat
# Name: Basin of Attractors for Large Systems using Random Sampling Synch Update
# Revision Date: October 2014

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

RandomSampling.pl - Find the basin of attractors of a given discrete system with a large state space using random sampling and a synchronous update schedule.

=head1 USAGE

RandomSampling.pl -m <model-file> -s <sampling-file> -o <output-file>

=head1 SYNOPSIS

RandomSampling.pl -m <model-file> -s <sampling-file> -o <output-fiel>

=head1 DESCRIPTION

RandomSampling.pl - Find the basin of attractors of a given discrete system with a large state space using random sampling and a synchronous update schedule.

=head1 REQUIRED ARGUMENTS

=over

=item -m[odel-file] <model-file>

The JSON file containing the model information (.json). 

=for Euclid:

network-file.type: readable

=item -s[ampling-file] <sampling-file>

The JSON file containing the sampling information that the user has been specified (.json). 

=for Euclid:

network-file.type: readable

=item -o[utput-file] <output-file>

The JSON file containing the basin of attractions of the system.

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
my $samplingFile = $ARGV{'-s'};

# output(s)
my $outputFile = $ARGV{'-o'};

# converts Model.json to Perl format
my $model = JSON::Parse::json_file_to_perl ($modelFile);

# converts Simulation.json to Perl format
my $sampling = JSON::Parse::json_file_to_perl ($samplingFile);

# sets the update rules/functions (hash)
my $updateFunctions = $model->{'model'}->{'updateRules'};
my $num_functions = scalar values %$updateFunctions;

# sets the number of variables in the model (array)
my $variables = $model->{'model'}->{'variables'};
my $num_variables = scalar @$variables;

# sets the unified (maximum prime) number that each state can take values up to (scalar)
my $num_states = $sampling->{'sampling'}->{'numberofStates'};

# sets the sampling size
my $samplingSize = $sampling->{'sampling'}->{'samplingSize'};

error_checking ();

my $stateSpaceSize = $num_states ** $num_functions;
my $length = 5;
my %state_attractor_table;
my %attractor_table;

for (my $index = 1; $index <= $samplingSize; $index++) {
  my $is = 1 + int (rand ($stateSpaceSize + 1));

  if (exists $state_attractor_table{$is}) {
    next;
  }

  my @array = ($is);
  
  attr: while (1) {
    for (my $n = 1; $n <= $length; $n++) {
      push (@array, get_nextstate ($array[-1]));
    }

    my $arraysize = scalar @array;
    
    for (my $j = 0; $j < $arraysize - 1; $j++) {
      for (my $k = $j + 1; $k < $arraysize; $k++) {
	if ($array[$j] == $array[$k]) {

	  my @sub_array = @array[$j ... $k - 1];
	  my $sortedAttractor = join (' , ', sort {$a <=> $b} @sub_array);

	  unless (exists $attractor_table{$sortedAttractor} ) {
	    my $attractor = join (' -> ', @sub_array);
	    $attractor_table{$sortedAttractor} = [$attractor, 0];
	  }

	  for (my $s = 0; $s < $k; $s++) {
	    my $a = $array[$s];
	    unless (exists $state_attractor_table{$a}) {
	      $state_attractor_table{$a} = $sortedAttractor;
	      ${$attractor_table{$sortedAttractor}}[1]++;
	    }
	  }
	  last attr;
	}
      }
    }

    push (@array, get_nextstate ($array[-1]));

  } # end of while loop

} # end of for loop

my $attractorTable = format_attractors (\%attractor_table);
my $json = JSON->new->indent ();

open (OUT," > $outputFile") or die ("<br>ERROR: Cannot open the file for output. <br>");
print OUT $json->encode ($attractorTable);
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
  
  # num_functions and num_variables
  unless ($num_functions == $num_variables) {
    print ("<br>INTERNAL ERROR: The number of variables, $num_variables, must be equal to the number of update rules, $num_functions. <br>");
    exit;
  }

  # samplingSize
  if (isnot_number ($samplingSize) || ($samplingSize <= 0)) {
    print ("<br>ERROR: The sampling size must be a positive number. <br>");
    exit;
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

# Returns the next state (as an integer) of a given state (as an integer)

sub get_nextstate {
  my $state = shift;
  my @currentState = convert_from_integer_to_state ($state);
  my @nextState;
  
  for (my $i = 1; $i <= $num_variables; $i++) {
    my $func = $updateFunctions->{"x$i"}->{"polynomialFunction"};

    for (my $j = 1; $j <= $num_variables; $j++) {
      $func =~ s/x[$j]/\($currentState[$j - 1]\)/g;
    }
    
    $nextState[$i - 1] = eval ($func) % $num_states;
   }

  my $nextState = convert_from_state_to_integer (\@nextState);
  return $nextState;
}

################################################################################

# Converts a given state (as a ref of array) to its integer representation and adds 1 for convenience

sub convert_from_state_to_integer {
  my $state = shift;
  my $int_rep = 1;

  for (my $i = 0; $i < $num_variables; $i++) {
    $int_rep += $state->[$num_variables - $i - 1] * ($num_states ** $i);
  }
  return $int_rep;
}

################################################################################

# Converts the integer representation of a state to state itself (as an array)

sub convert_from_integer_to_state {
  my $n = shift;

  my ($quotient, $remainder);
  my @state = ();
  $n--;

  do {
    $quotient = int $n / $num_states;
    $remainder = $n % $num_states;
    push (@state, $remainder);
    $n = $quotient;
  } until ($quotient == 0);

  my $dif = $num_variables - (scalar @state);

  if ($dif) {
    for (my $i = 0; $i < $dif; $i++) {
      push (@state, 0);
    }
  }

  @state = reverse @state;
  return @state;
}

################################################################################

# Format the attractors

sub format_attractors {
  my $table = shift;
  my %formattedTable;

  foreach my $value (values %$table) {
    my @array1 = split (' -> ', $value->[0]);
    my @array2 = ();

    for (my $i = 0; $i < scalar @array1; $i++) {
      $array2[$i] = join (' ', convert_from_integer_to_state ($array1[$i]));
    }
    
    my $attractor = join (' -> ', @array2);
    $formattedTable{$attractor} = $value->[1];
  }

  return \%formattedTable;
}

################################################################################
