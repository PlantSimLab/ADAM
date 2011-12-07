# Author(s): David Murrugarra & Seda Arat
# Name: Having all the subroutines needed for Stochastic Discrete Dynamical Systems
# Revision Date: 11/28/2011

package Subroutines4sdds;

use strict;
use warnings;

#use Data::Dumper;
use List::Util qw [min];
use State4sdds;
use Class::Struct

(
 flag4tm => '$',
 flag4ss => '$',

 max_num_interestingNodes => '$',
 max_num_reachableStates => '$',
 max_num_nodes => '$',
 max_num_states => '$',
 max_element_stateSpace => '$',

 num_nodes => '$',
 num_states => '$',
 num_steps => '$',
 num_simulations => '$',

 initialState => '@',
 interestingNodes => '@',

 propensityMatrix => '%',
 transitionTable =>'%',

 allStates => '%',
 transitionProbabilityArray => '@',
 steadyStates => '%',
 allTrajectories => '%',
 reachableStates => '%',
 percentageVector => '@',
 averageTrajectory => '@',
);

=pod

$sdds = get_initialstate($initialstate);

Reads and stores the initial state in an array.

=cut

sub get_initialstate {
  my $sdds = shift;
  my $initialstate = shift;
  
  # Error message for $num_states, $num_steps, $num_simulations
  
  if (isnot_number($sdds->num_states()) || $sdds->num_states() < 2 || $sdds->num_states() > $sdds->max_num_states()) {
    print ("<br>ERROR: The number of states must be a number between 2 and ", $sdds->max_num_states(), " . <br>");
    exit;
  }
  else {
    @{$sdds->initialState()} = split(/\s+/, $initialstate);
    $sdds->num_nodes(scalar @{$sdds->initialState()});

    foreach my $value (@{$sdds->initialState()}) {
      if ($value >= $sdds->num_states()) {
	print ("<br>ERROR: Since the number of states is " , $sdds->num_states(), " , the initial state, @{$sdds->initialState()}, must consist of the numbers which are at most " , $sdds->num_states() - 1 , " . Please check the initial state and/or the number of states. <br>");
	exit;
      }
    }
  }
}

############################################################

=pod

$sdds = get_interestingnodes($interestingnodes);

Reads and stores the nodes of interests in an array.

=cut

sub get_interestingnodes {
  my $sdds = shift;
  my $interestingnodes = shift;

  my @temp = split (/\,/, $interestingnodes);
  my $temp = join (' ', @temp);
  @{$sdds->interestingNodes()} = split(/\s+/, $temp);
  my $num_interestingnodes = @{$sdds->interestingNodes()};
  my $min_value = min $sdds->max_num_interestingNodes, $sdds->num_nodes();
  
  #Error checking 
  if (($num_interestingnodes > $min_value) || ($num_interestingnodes < 1)) {
    print ("<br>ERROR: The number of nodes of interest must be at most $min_value. Please check the nodes of interest and/or the initial state. <br>");
    exit;
  }
  foreach my $value (@{$sdds->interestingNodes()}) {
    if ((isnot_number($value)) || ($value < 1) || ($value > $sdds->num_nodes())) {
      print ("<br>ERROR: The nodes of interest, @{$sdds->interestingNodes()}, must consist of the numbers which are at most the number of variables. Please check the nodes of interest and/or the initial state. <br>");
      exit;
    }
  }
}

############################################################

=pod

$sdds = get_propensitymatrix($matrix);

Reads and stores the propensity matrix in a hash if the user uploaded one. 
The keys of the hash are the column numbers and the values are arrays having 
the probability of activation and degradation. If the used did not upload one, 
all probabilities are 0.5 as a default.

=cut

sub get_propensitymatrix {
  my $sdds = shift;
  my $matrix = shift;
  my ($i, @activation, @degradation, $activation, $degradation, $j, $n, $str, $m);

  if ($matrix) {
    $i = 0;
    
    open (OUTPUT, "< $matrix") or die("<br>ERROR: Cannot open $matrix for reading! <br>");
    while (my $line = <OUTPUT>) {
      chomp($line);
      
      my $temp = $line;
      $temp =~ s/\s*//g;
      
      # skip empty lines
      unless ($temp) {
	next;
      }
      

      if ($i == 0) {
	@activation = split(/\s+/, $line);
	$n = scalar @activation;
	if ($n != $sdds->num_nodes()) {
	  print ("<br>ERROR: The number of columns in first row (activation) in the propensity matrix must match with the number of variables in the system. Please check the propensity matrix and/or the initial state. <br>");
	  exit;
	}
	$i++;
      }
      elsif ($i == 1) {
	@degradation = split(/\s+/, $line);
	$n = scalar @degradation;
	if ($n != $sdds->num_nodes()) {
	  print ("<br>ERROR: The number of columns in second row (degradation) in the propensity matrix must match with the number of variables in the system. Please check the propensity matrix and/or the initial state. <br>");
	  exit;
	}
	$i++;
      }
      else {
	last;
      }
    }

    close(OUTPUT) or die("<br>ERROR: Cannot close $matrix for reading! <br>");
    
    # Error checking on the entries of the propensity matrix.
    for ($i = 0; $i < $n; $i++) {
      
      if ((isnot_float($activation[$i])) || ($activation[$i] < 0) || ($activation[$i] > 1)) {
	print ("<br>ERROR: \" $activation[$i] \" in the propensity matrix must be a number between 0 and 1. <br>");
	exit;
      }

      if ((isnot_float($degradation[$i])) || ($degradation[$i] < 0) || ($degradation[$i] > 1)) {
	print ("<br>ERROR: \" $degradation[$i] \" in the propensity matrix must be a number between 0 and 1. <br>");
	exit;
      }
    }
    
    for ($j = 0; $j < $n; $j++) {
      my @temp = ($activation[$j], $degradation[$j]);
      $sdds->propensityMatrix($j, \@temp);
    }
  }
  else {
    for ($j = 0; $j < $sdds->num_nodes(); $j++) {
      my @temp = (0.5, 0.5);
      $sdds->propensityMatrix($j, \@temp);
    }
  }
}


############################################################

=pod

$sdds = get_transitiontable_and_allstates($transitiontable);

Reads and stores the transition table in a hash table whose keys are 
the decimal representation of the states and values are the next state 
and stored as references.

Stores all states in a hash table whose keys are the decimal representation 
of the states and values are the state objects.

=cut

sub get_transitiontable_and_allstates {
  my $sdds = shift;
  my $transitiontable = shift;
  my ($inputs, $outputs, $s, $total_num_states, $size_tt, $i);
  
  open(OUTPUT,"<",$transitiontable) or die("<br>ERROR: Cannot open $transitiontable for reading! <br>");
  while (<OUTPUT>) {
    chomp;
    my ($inputs,$outputs) = split(/\-.*>/);

    # removes the white spaces from the beginning and the end of $inputs and $outputs
    $inputs =~ s/^\s+//;
    $inputs =~ s/\s+$//;

    $outputs =~ s/^\s+//;
    $outputs =~ s/\s+$//;

    if ($inputs && $outputs) {
      my @is = split(/\s+/,$inputs);
      my @ns = split(/\s+/, $outputs);

      my $size_of_is = scalar @is;
      if ($size_of_is != $sdds->num_nodes()) {
	print ("<br>ERROR: The length of the states in the transition table must match with the number of variables in the system. Please revise the transition table and/or the initial state. <br>");
	exit;
      }
      
      my $size_of_ns = scalar @ns;
      if ($size_of_ns != $sdds->num_nodes()) {
	print ("<br>ERROR: The length of the states in the transition table must match with the length of the initial state. Please revise the transition table and/or the initial state. <br>");
	exit;
      }
      
      for ($i = 0; $i < $size_of_is; $i++) {

	if ((isnot_number($is[$i])) || (isnot_number($ns[$i])) || ($is[$i] >= $sdds->num_states()) || ($ns[$i] >= $sdds->num_states())) {
	  print ("<br>ERROR: The states must consist of the numbers which are at most ", $sdds->num_states() - 1, " in the transition table. Please revise the transition table and/or the number of states. <br>");
	  exit;
	}
      }
      
      # Creates a 'state' object.
      my ($state);
      $state = State::new();
      $state->get_value_and_strState(\@is);
      $state->decimal_rep($sdds->convert_to_decimal(\@is));    
      
      my $key = $state->decimal_rep();
      
      if (!defined($sdds->transitionTable($key))) {
	$sdds->transitionTable($key, \@ns);
      }
      else {
	print ("<br>ERROR: The transition table must not include the state, @ns ,  more than once. Please revise the transition table. <br>");
	exit;
      }
      $state->get_nextstate_tt($sdds->transitionTable());
      $sdds->allStates($key,$state);
   }
    # end of while loop 
  }
  close(OUTPUT) or die("<br>ERROR: Cannot close $transitiontable for reading! <br>");
  
  $total_num_states = $sdds->num_states()**$sdds->num_nodes();
  $size_tt = keys (%{$sdds->transitionTable()});
  
  if ($size_tt < $total_num_states) {
    print ("<br>ERROR: The transition table must include all possible states. Please revise the transition table and/or the number of states. <br>");
    exit;
  }
}

############################################################

=pod

$sdds = get_alltrajectories_and_reachablestates();

Stores all trajectories as a hash table whose keys are the order of 
the trajectories and the values are the trajectories whose starting 
points are the initial state and length is num_steps+1.

Stores the reachable states in all trajectories as a hash table whose 
keys are the decimal rep. of the states and values are the 
percentages of that state. 

=cut

sub get_alltrajectories_and_reachablestates {
  my $sdds = shift;
  my ($i, $j, $n);
  
  $n = $sdds->num_simulations() * $sdds->num_steps();

  for ($i = 0; $i < $sdds->num_simulations(); $i++) {
    my @temp = ();  # stores a single trajectory each time 
    my $is = $sdds->initialState();
    push (@temp, $sdds->convert_to_decimal($is));
    
    for ($j = 1; $j <= $sdds->num_steps(); $j++) {
      my @ns = $sdds->get_nextstate_pm($is, $sdds->propensityMatrix());
      my $value = 0;

      if (!defined($sdds->reachableStates($sdds->convert_to_decimal(\@ns)))) {
	$value = 100 / $n;
	$sdds->reachableStates($sdds->convert_to_decimal(\@ns), $value);
      }
      else {
	$value = $sdds->reachableStates($sdds->convert_to_decimal(\@ns));
	$value += 100 / $n;
	$sdds->reachableStates($sdds->convert_to_decimal(\@ns), $value);
      }
      push (@temp, $sdds->convert_to_decimal(\@ns));
      $is = \@ns;
    } # end of for loop $j

    $sdds->allTrajectories($i, \@temp);
  } # end of for loop $i
}

############################################################

=pod

$sdds = get_average_trajectory();

Stores the averageTrajectory of all trajectories in an array

=cut

sub get_average_trajectory {
  my $sdds = shift;
  my ($total_num_states, $i, $j, $k, $r);
  
  $total_num_states = $sdds->num_states()**$sdds->num_nodes();

  # Initial state must be the first state in averageTrajectory.
  push (@{$sdds->averageTrajectory()},@{$sdds->initialState()});

  for ($i = 1; $i <= $sdds->num_steps(); $i++) {
    my @temp = ();  # keeps the values of i-th states in trajectories
    for ($j = 0; $j < $sdds->num_simulations(); $j++) {
      my @traj = @{$sdds->allTrajectories($j)};
      my $temp_state = $sdds->allStates($traj[$i]);
      my @value = @{$temp_state->value()};
      push (@temp, @value);
    }

    my @sum = ();
    for ($k = 0; $k < $sdds->num_nodes(); $k++) {
      for ($r = 0; $r < $sdds->num_simulations(); $r++) {
	my $w = ($r * $sdds->num_nodes()) + $k;
	$sum[$k] += $temp[$w];
      } 
      push (@{$sdds->averageTrajectory()}, $sum[$k] / $sdds->num_simulations());
    }
  }
}

############################################################

=pod

$sdds = get_transitionprobabilityarray_and_steadystates();

Stores the transition probability array as an array whose elements 
are the references of hashes whose keys are decimal representation 
of the states and values are (nonzero) probabilities.

Stores the steady states in a hash table if the system has any.
Its keys are 1, 2, ... and values are the decimal rep. of the 
steady states.

=cut

sub get_transitionprobabilityarray_and_steadystates {
  my $sdds = shift;
  my ($total_num_states, $key, $i, $j, $k, $num_steadystates);
  
  $total_num_states = $sdds->num_states()**$sdds->num_nodes();
  $key = 1;

  if ($total_num_states > $sdds->max_element_stateSpace()) {
     print ("<br>FYI: Since the number of elements in the state space is too large, transition matrix will not be provided. <br>");
     $sdds->flag4tm(0);
  }

  if ($sdds->flag4tm()) {
    for ($i = 0; $i < $total_num_states; $i++) {
      my %temp = ();
      my $state = $sdds->allStates($i + 1);
      my @x = @{$state->value()};
      my @z = @{$state->nextstate_tt()};
      
      for ($j = 0; $j < $total_num_states; $j++) {
	my $p = 1;
	my $total_p = 0;
	my $state1 = $sdds->allStates($j + 1);
	my @y = @{$state1->value()};
	
	for ($k = 0; $k < $sdds->num_nodes(); $k++) {
	  my $c = 0;
	  my @array = @{${$sdds->propensityMatrix}{$k}};
	  if ($x[$k] < $z[$k]) {
	    if ($y[$k] == $z[$k]) {
	      $c = $array[0];
	    }
	    if ($y[$k] == $x[$k]) {
	      $c = 1 - $array[0];
	    }
	  }
	  elsif ($x[$k] > $z[$k]) {
	    if ($y[$k] == $z[$k]) {
	      $c = $array[1];
	    }
	    if ($y[$k] == $x[$k]) {
	      $c = 1 - $array[1];
	    }
	  }
	  else { # $x[$k] = $z[$k]
	    if ($y[$k] == $x[$k]) {
	      $c = 1;
	    }
	  }

	  if ($c == 0) {
	    $p = 0;
	    last;
	  }
	  $p = $p * $c;
	} # end of for loop $k
	
	# Stores the steady states in a hash table if the flag is on.
	if ($sdds->flag4ss() && $i == $j && $p == 1) {
	  my $state = $sdds->allStates($i + 1);
	  $sdds->steadyStates($key, $state->decimal_rep());
	  $key++;
	}
	
	# Stores the nonzero probabilities in a temp hash as a value
	if ($p) {
	  $temp{$j} = $p;
	}

	# Checks if total_p reaches 1. If so, no need to do more calculations.
	$total_p += $p;
	if ($total_p == 1) {
	  last;
	}

      } # end of for loop $j
      
      # Stores all the probabilities in the transition probability array as a hash table.
      @{$sdds->transitionProbabilityArray}[$i] = \%temp; 
    } # end of for loop $i
  }
  elsif ($sdds->flag4ss()) {
    for ($i = 1; $i <= $total_num_states; $i++) {
      my $state = $sdds->allStates($i);
      my @x = @{$state->value()};
      my @z = @{$state->nextstate_tt()};
      my $x = join ('', @x);
      my $z = join ('', @z);
      if ($x eq $z) {
	$sdds->steadyStates($key, $i);
	$key++;
      }
    }
  }
  else {};
  
  # Prints out the steady states if the system has any and the user wants.
  
  if ($sdds->flag4ss()) {
    $num_steadystates = keys (%{$sdds->steadyStates()});
    if ($num_steadystates == 0) {
      print ("<br>There is not any steady state in this system. <br>"); 
    }
    elsif ($num_steadystates == 1) {
      print ("<br>There is only 1 steady state in this system, which is @{$sdds->allStates($sdds->steadyStates(1))->value()} . <br>");
    }
    else {
      print ("<br>There are $num_steadystates steady states in this system, which are: <br>");
      foreach my $a (sort values %{$sdds->steadyStates()}) {
	print ("@{$sdds->allStates($a)->value()} <br>");
      }
    }
  }
}

############################################################

=pod

$sdds = convert_to_decimal($node);

Converts the given state to its decimal representation and adds 1 for convenience.

=cut

sub convert_to_decimal {
  my $sdds = shift;
  my $node = shift;
  my($i, $result);

  for ($i = 0; $i < $sdds->num_nodes(); $i++){
    $result += $$node[$sdds->num_nodes() - 1 - $i] * ($sdds->num_states() ** $i);
  }
  $result++;
  return $result;
}

############################################################

=pod

$sdds = get_nextstate_pm($node, $matrix);

Returns the next state (as an array) depending on the initial state and 
its corresponding probabilities in the propensity matrix.

=cut

sub get_nextstate_pm {
  my $sdds = shift;
  my $node = shift;
  my $matrix = shift;
  my (@x, $state, @z, $r, $n, @next_state, $j);

  @x = @$node;
  $state = $sdds->allStates($sdds->convert_to_decimal($node));
  @z = @{$state->nextstate_tt()};
  $r = rand;

  for ($j = 0; $j < $sdds->num_nodes(); $j++) {
    my @temp = @{$$matrix{$j}};

    if ($x[$j] < $z[$j]) {
      if ($r < $temp[0]) {
	$next_state[$j] = $z[$j];
      }
      else{
	$next_state[$j] = $x[$j];
      }
    }
    elsif ($x[$j] > $z[$j]) {
      if ($r < $temp[1]) {
	$next_state[$j] = $z[$j];
      }
      else{
	$next_state[$j] = $x[$j];
      }
    }
    else {
      $next_state[$j] = $x[$j];
    }
  }
  return (@next_state);
}

############################################################

# Returns true if the input is not a number, false otherwise.

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

# Returns true if the input is not a floating number 
# (between 0 and 1), false otherwise.

sub isnot_float {
  my ($f) = @_;
  if ($f =~ /[^\d\.]/) {
    return 1;
  }
  else {
    return 0;
  }
}

############################################################

1;
