# Author(s): David Murrugarra & Seda Arat
# Name: Having all the subroutines needed for Stochastic Discrete Dynamical Systems
# Revision Date: 1/25/2012

package Subroutines4sdds;

use strict;
use warnings;

use List::Util qw [min];
use Class::Struct

(
 max_num_interestingNodes => '$',
 max_num_nodes => '$',
 max_num_states => '$',
 num_steps => '$',
 num_simulations => '$',
 max_element_stateSpace => '$',
 flag4ss => '$',
 flag4tm => '$',
 flag4func => '$',
 num_states => '$',
 initialState => '@',
 interestingNodes => '@',
 num_nodes => '$',
 propensityMatrix => '%',
 functions =>'@',
 transitionTable => '%',
 allTrajectories => '%',
 reachableStates => '%',
 averageTrajectory => '@',
 transitionProbabilityArray => '@',
 steadyStates => '%',
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
      if ((isnot_number($value)) || ($value >= $sdds->num_states())) {
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

Reads and stores the propensity matrix in a hash. 
The keys of the hash are the column numbers and the values are arrays having 
the probability of activation and degradation.

=cut

sub get_propensitymatrix {
  my $sdds = shift;
  my $matrix = shift;
  my (@activation, @degradation, $n);
  my $i = 0;
    
  open (OUTPUT, "< $matrix") or die("<br>ERROR: Cannot open the propensity matrix file for reading! <br>");
  while (my $line = <OUTPUT>) {
    chomp($line);
    
    # skip empty lines
    if ($line =~ /^\s*$/) {
      next;
    }
    
    if ($i == 0) {
      @activation = split(/\s+/, $line);
      $n = scalar @activation;
      if ($n != $sdds->num_nodes()) {
	print ("<br>ERROR: The number of columns in first row (activation) in the propensity matrix must match with the number of variables in the system. Please check the propensity matrix file and/or the initial state. <br>");
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
      print ("<br>FYI: The number of rows must be exactly 2 in the propensity matrix, so other than the first 2 rows were not considered. <br>");
      last;
    }
  }
  
  close(OUTPUT) or die("<br>ERROR: Cannot close the propensity matrix file! <br>");
  
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
  
  for (my $j = 0; $j < $n; $j++) {
    my @temp = ($activation[$j], $degradation[$j]);
    $sdds->propensityMatrix($j, \@temp);
  }
}

############################################################

=pod

$sdds = get_functions_or_transitiontable($file);

Either gets the functions or transition table depending on the user's 
preference.

=cut

sub get_functions_or_transitiontable {
  my $sdds = shift;
  my $file = shift;

  open (FILE, "< $file") or die ("<br>ERROR: Cannot open the transition table / functions file for reading! <br>");
  while (my $line = <FILE>) {
    chomp ($line);
    
    # skip empty lines
    if ($line =~ /^\s*$/) {
      next;
    }

    if ($line =~ /(f|x|=)/) {
      close (FILE) or die ("<br>ERROR: Cannot close the transition table / functions file! <br>");
      $sdds->flag4func(1);
      $sdds->get_functions ($file);
      last;
    }
    elsif ($line =~ /-.*>/) {
      close (FILE) or die ("<br>ERROR: Cannot close the transition table / functions file! <br>");
      $sdds->flag4func(0);
      $sdds->get_tt ($file);
      last;
    }
    else {
      print ("<br>ERROR: Please revise the format of the transition table / functions file. <br>");
      exit;
    }
  }
}

############################################################

=pod

$sdds = get_functions ($file);

Reads and stores the functions in an array. The first entry is the updating
function of the first node, the second entry is the updating function of the
second node, so on...

=cut

sub get_functions {
  my $sdds = shift;
  my $file = shift;
  my $f;
  my $flag = 0;

  open (FILE, "< $file") or die ("<br>ERROR: Cannot open the functions file for reading! <br>");
  while (my $line = <FILE>) {
    chomp ($line);
    
    # skip empty lines
    if ($line =~ /^\s*$/) {
      next;
    }

    # checks if the line is a new function or a sequent line 
    # of the previous function
    if ($line =~ /^(f|F)/) {
      
      if ($flag) {
	push(@{$sdds->functions()}, $f);
      }
      
      $flag = 1;
      (my $a, $f) = split(/=/,$line);
    }
    else {
      if ($flag) {
	$f .= $line;
      }
      else {
	print "<br> ERROR: The format of the functions file is wrong. Please revise it. <br>";
	exit;
      }
    }
    
    $f =~ s/\^/\*\*/g; # replace carret with double stars
    $f =~ s/x(\d+)/\$x\[$1\]/g; #for evaluation
  }
  
  push(@{$sdds->functions()}, $f);
  
  close (FILE) or die ("<br>ERROR: Cannot close the functions file! <br>");
  
  # Error checking
  my $size_func = scalar @{$sdds->functions()};
  unless ($size_func == $sdds->num_nodes()) {
    print ("<br>ERROR: The number of functions in the file must be equal to the number of nodes. Please revise the functions file and/or the initial state. <br>");
    exit;
  }
}

############################################################

=pod

$sdds = get_tt ($file);

Reads and stores the transition table in a hash table whose keys are 
the decimal representation of the states and values are the decimal 
representation of their next state.

=cut

sub get_tt {
  my $sdds = shift;
  my $file = shift;

  open (FILE, "< $file") or die ("<br>ERROR: Cannot open the transition table file for reading! <br>");
  while (my $line = <FILE>) {
    chomp ($line);
    
    # skip empty lines
    if ($line =~ /^\s*$/) {
      next;
    }
    
    my ($inputs,$outputs) = split(/\-.*>/, $line);
    
    # removes the white spaces from the beginning and the end of $inputs and $outputs
    $inputs =~ s/^\s+//;
    $inputs =~ s/\s+$//;
    
    $outputs =~ s/^\s+//;
    $outputs =~ s/\s+$//;
    
    if ($inputs && $outputs) {
      my @is = split(/\s+/,$inputs);
      my @ns = split(/\s+/, $outputs);
      
      my $size_of_is = scalar @is;
      
      unless ($size_of_is == $sdds->num_nodes()) {
	print ("<br>ERROR: The length of the states in the transition table must match with the number of variables in the system. Please revise the transition table file and/or the initial state. <br>");
	exit;
      }
      
      my $size_of_ns = scalar @ns;
      
      unless ($size_of_ns == $sdds->num_nodes()) {
	print ("<br>ERROR: The length of the states in the transition table must match with the length of the initial state. Please revise the transition table file and/or the initial state. <br>");
	exit;
      }
      
      for (my $i = 0; $i < $size_of_is; $i++) {
	
	if ((isnot_number($is[$i])) || (isnot_number($ns[$i])) || ($is[$i] >= $sdds->num_states()) || ($ns[$i] >= $sdds->num_states())) {
	  print ("<br>ERROR: The states must consist of the numbers which are at most ", $sdds->num_states() - 1, " in the transition table. Please revise the transition table file and/or the number of states. <br>");
	  exit;
	}
      }    
      
      my $idec = $sdds->convert_from_state_to_decimal(\@is);
      
      if (!defined($sdds->transitionTable($idec))) {
	my $ndec = $sdds->convert_from_state_to_decimal(\@ns);
	$sdds->transitionTable($idec, $ndec);
      }
      else {
	print ("<br>ERROR: The transition table can not include the state, @ns , more than once. Please revise the transition table file. <br>");
	exit;
      }
    }
  }

  close (FILE) or die ("<br>ERROR: Cannot close the transition table file! <br>");
  
  # Error checking
  my $total_num_states = $sdds->num_states()**$sdds->num_nodes();
  my $size_tt = keys (%{$sdds->transitionTable()});
  
  unless ($size_tt == $total_num_states) {
    print ("<br>ERROR: The transition table must include all possible states. Please revise the transition table file and/or the number of states. <br>");
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
keys are the string rep. of the states and values are the 
percentages of these states.

=cut

sub get_alltrajectories_and_reachablestates {
  my $sdds = shift;
  
  my $n = $sdds->num_simulations() * $sdds->num_steps();

  for (my $i = 1; $i <= $sdds->num_simulations(); $i++) {
    my @temp = ();  # stores a single trajectory each time 
    my $is = $sdds->initialState();
    push (@temp, $sdds->convert_from_state_to_decimal($is));
    
    for (my $j = 1; $j <= $sdds->num_steps(); $j++) {

      my @ns = $sdds->get_nextstate_pm($is);
      my $dec = $sdds->convert_from_state_to_decimal(\@ns);
      my $str = join (' ', @ns);
      my $value = 0;

      if (!defined ($sdds->reachableStates($str))) {
	$value = 100 / $n;
      }
      else {
	$value = $sdds->reachableStates($str);
	$value += 100 / $n;
      }
      $sdds->reachableStates($str, $value);
      push (@temp, $dec);
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
  
  my $total_num_states = $sdds->num_states()**$sdds->num_nodes();

  # Initial state must be the first state in averageTrajectory.
  push (@{$sdds->averageTrajectory()},@{$sdds->initialState()});

  for (my $i = 1; $i <= $sdds->num_steps(); $i++) {
    my @temp = ();  # keeps the values of i-th states in trajectories

    for (my $j = 1; $j <= $sdds->num_simulations(); $j++) {
      my @traj = @{$sdds->allTrajectories($j)};
      my @value = $sdds->convert_from_decimal_to_state($traj[$i - 1]);
      push (@temp, @value);
    }

    my @sum = ();
    for (my $k = 0; $k < $sdds->num_nodes(); $k++) {
      for (my $r = 0; $r < $sdds->num_simulations(); $r++) {
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
  
  my $total_num_states = $sdds->num_states()**$sdds->num_nodes();
  my $key = 1;

  if ($total_num_states > $sdds->max_element_stateSpace()) {
     print ("<br>FYI: Since the number of elements in the state space is too large, transition matrix will not be provided. <br>");
     $sdds->flag4tm(0);
  }

  if ($sdds->flag4tm()) {
    for (my $i = 1; $i <= $total_num_states; $i++) {
      my %temp = ();
      my @x = $sdds->convert_from_decimal_to_state($i);
      my @z = $sdds->get_nextstate(\@x);
      
      for (my $j = 1; $j <= $total_num_states; $j++) {
	my $p = 1;
	my $total_p = 0;
	my @y = $sdds->convert_from_decimal_to_state($j);
	
	for (my $k = 0; $k < $sdds->num_nodes(); $k++) {
	  my $c = 0;
	  my @array = @{${$sdds->propensityMatrix()}{$k}};
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
	  my $str = join (' ', @x);
	  $sdds->steadyStates($key, $str);
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
      ${$sdds->transitionProbabilityArray()}[$i - 1] = \%temp; 
      
    } # end of for loop $i
  }
  elsif ($sdds->flag4ss()) {
    for (my $i = 1; $i <= $total_num_states; $i++) {
      my @x = $sdds->convert_from_decimal_to_state($i);
      my @z = $sdds->get_nextstate(\@x);
      my $x = join (' ', @x);
      my $z = join (' ', @z);
      if ($x eq $z) {
	$sdds->steadyStates($key, $x);
	$key++;
      }
    }
  }
  else {};
  
  # Prints out the steady states if the system has any and the user wants.
  
  if ($sdds->flag4ss()) {
    $key--;
    if ($key == 0) {
      print ("<br>There is not any steady state in this system. <br>"); 
    }
    elsif ($key == 1) {
      print ("<br>There is only 1 steady state in this system, which is: ", $sdds->steadyStates(1), ". <br>");
    }
    else {
      print ("<br>There are $key steady states in this system, which are: <br>");
      foreach my $key ( sort {$a <=> $b} keys %{$sdds->steadyStates()}) {
	print ($sdds->steadyStates($key), "<br>");
      }
    }
  }
}

############################################################

=pod

$sdds = convert_from_state_to_decimal ($state);

Converts a given state to its decimal representation and adds 1 for convenience.

=cut

sub convert_from_state_to_decimal {
  my $sdds = shift;
  my $state = shift;
  my $decimal_rep = 1;

  for (my $i = 0; $i < $sdds->num_nodes(); $i++) {
    $decimal_rep += $$state[$sdds->num_nodes() - $i - 1] * ($sdds->num_states() ** $i);
  }
  return $decimal_rep;
}

############################################################

=pod

$sdds = convert_from_decimal_to_state ($n);

Converts the decimal representation of a state to state itself.

=cut

sub convert_from_decimal_to_state {
  my $sdds = shift;
  my $n = shift;
  my ($quotient, $remainder);
  my @state = ();
  $n--;

  do {
    $quotient = int $n / $sdds->num_states();
    $remainder = $n % $sdds->num_states();
    push (@state, $remainder);
    $n = $quotient;
  } until ($quotient == 0);

  my $dif = $sdds->num_nodes() - (scalar @state);

  if ($dif) {
    for (my $i = 0; $i < $dif; $i++) {
      push (@state, 0);
    }
  }

  @state = reverse @state;
  return @state;
}

###########################################################################

=pod

$sdds = get_nextstate($state);

Returns the next state (as an array) depending on the initial state 
via @functions or %transitionTable

=cut

sub get_nextstate {
  my $sdds = shift;
  my $state = shift;
  my @x = @$state;
  my @nextState = ();

  if ($sdds->flag4func()) {
    my @temp = @{$sdds->functions()};
    
    for (my $i = 0; $i < @temp; $i++) {
      for (my $j = 0; $j < @x; $j++) {
	my $k = $j + 1;
	$temp[$i] =~ s/\$x\[$k\]/\($x[$j]\)/g;
      }
      
      $nextState[$i] = eval($temp[$i]) % $sdds->num_states();
    }
  }
  else {
     my $dec = $sdds->convert_from_state_to_decimal(\@x);
     $dec = $sdds->transitionTable($dec);
     @nextState = $sdds->convert_from_decimal_to_state($dec);
  }
  return @nextState;
}

###########################################################################

=pod

$sdds = get_nextstate_pm($state);

Returns the next state (as an array) depending on the initial state and 
its corresponding probabilities in the propensity matrix.

=cut

sub get_nextstate_pm {
  my $sdds = shift;
  my $state = shift;

  my @x = @$state;
  my @z = $sdds->get_nextstate(\@x);
  my @next_statePM;

  for (my $j = 0; $j < $sdds->num_nodes(); $j++) {
    my $r = rand;
    my @temp = @{$sdds->propensityMatrix($j)};

    if ($x[$j] < $z[$j]) {
      if ($r < $temp[0]) {
	$next_statePM[$j] = $z[$j];
      }
      else{
	$next_statePM[$j] = $x[$j];
      }
    }
    elsif ($x[$j] > $z[$j]) {
      if ($r < $temp[1]) {
	$next_statePM[$j] = $z[$j];
      }
      else{
	$next_statePM[$j] = $x[$j];
      }
    }
    else {
      $next_statePM[$j] = $x[$j];
    }
  }
  return @next_statePM;
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
