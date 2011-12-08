# Author(s): David Murrugarra & Seda Arat
# Name: Generating the plot, histogram and transition matrix for SDDS
# Revision Date: 12/7/2011

#!/usr/bin/perl

print "---I am in SDDS.pl! <br>";

exit;


use strict;
use warnings;

use Subroutines4sdds;
#use Data::Dumper;
#use Getopt::Euclid;
use GD::Graph;
use GD::Graph::linespoints;
use GD::Graph::colour;
use GD::Graph::bars;

print "I am in SDDS.pl---! <br>";


my ($transitiontable, $propensitymatrix, $initialstate, $interestingnodes, $number_of_states, $flag4ss, $flag4tm, $plot_file, $histogram_file, $tm_file, $output_file);

$transitiontable = $ARGV[0];
$initialstate = $ARGV[1];
$interestingnodes = $ARGV[2];
$number_of_states = $ARGV[3];
$flag4ss = $ARGV[4];
$flag4tm = $ARGV[5];
$plot_file = $ARGV[6];
$histogram_file = $ARGV[7];

if ($ARGV[8]) { $tm_file = $ARGV[8];}
if ($ARGV[9]) { $propensitymatrix = $ARGV[9];}
if ($ARGV[10]) { $output_file = $ARGV[10];}

# it is for random number generator
srand(time | $$);

my ($sdds);

$sdds = Subroutines4sdds::new();

$sdds->max_num_interestingNodes(5);
$sdds->max_num_reachableStates(20);
$sdds->max_num_nodes(20);
$sdds->max_num_states(20);
$sdds->num_steps(50);
$sdds->num_simulations(100);
$sdds->max_element_stateSpace(10**3);

$sdds->num_states($number_of_states);

$sdds->get_initialstate($initialstate);
$sdds->get_interestingnodes($interestingnodes);

$sdds->flag4ss($flag4ss);
$sdds->flag4tm($flag4tm);

$sdds->get_propensitymatrix($propensitymatrix);
$sdds->get_transitiontable_and_allstates($transitiontable);

$sdds->get_alltrajectories_and_reachablestates();
$sdds->get_average_trajectory();
$sdds->get_transitionprobabilityarray_and_steadystates();

# it is for not to show the states whose percentage is below the threshold in histogram
my $threshold4histogram = 1;


my ($total_num_states, $num_interestingnodes, $i, $j, @x_axis4plotting, %y_axis4plotting, @legend_keys, $k, $r, $key, @x_axis4histogram, @y_axis4histogram);


#Prints out the transition matrix if the user wants  

if ($sdds->flag4tm()) {
  $total_num_states = $sdds->num_states()**$sdds->num_nodes();
  open(TM," > $tm_file.txt") or die("<br>ERROR: Cannot open $tm_file for transition matrix! <br>");
  for ($k = 0; $k < $total_num_states; $k++) {
    
    my $state1 = $sdds->allStates($k+1);
    my $str1 = $state1->str_state();
    
    my %temp = %{${$sdds->transitionProbabilityArray}[$k]};
    
    foreach my $key ( sort {$a <=> $b} keys %temp) {
      my $state2 =$sdds->allStates($key+1);
      my $str2 = $state2->str_state();
      
      print TM ("Pb (", $str1, " -> ", $str2, ") = ", $temp{$key}, "\n");
    }
    print TM "_________________________________________________\n\n";
  }
  close (TM) or die("<br>ERROR: Cannot close $tm_file for writing! <br>");
}


# Gets the data for plotting according to averageTrajectory

my $num_interesting_nodes = scalar @{$sdds->interestingNodes()};

for ($i = 0; $i < $num_interesting_nodes; $i++) {
  for ($j = 0; $j <= $sdds->num_steps(); $j++) {
    if ($i == 0) {
      $x_axis4plotting[$j] = $j;
    }
    my $t = ${$sdds->interestingNodes()}[$i] - 1;
    my $k = $j * $sdds->num_nodes() + $t;
    push (@{$y_axis4plotting{$i + 1}}, @{$sdds->averageTrajectory()}[$k]);
  }
}

while ($i < $sdds->max_num_interestingNodes) {
  push (@{$y_axis4plotting{$i + 1}}, ());
  $i++;
}

# @legend_keys depends on $max_num_interestingNodes.

for (my $a = 0; $a < $sdds->max_num_interestingNodes(); $a++) {
  if (!$sdds->interestingNodes($a) eq '') {
    push (@legend_keys, 'Node # ' . $sdds->interestingNodes($a)),
  }
}

my $graph = GD::Graph::linespoints->new(900, 500);
$graph->set_legend(@legend_keys);
$graph -> set (
	       x_label => 'Time Steps',
	       y_label => "Average Expression Level",
	       title => 'Cell Population Simulation (# of simulations = 100)',
	       x_min_value => 0,
	       x_label_position => 1/2,
	      # x_labels_vertical => 1,
	       y_min_value => 0,
	       y_max_value => $sdds->num_states() - 1,
	       y_tick_number => 5 * ($sdds->num_states() - 1),
	       dclrs => [qw (red blue yellow gray dpink)],
	       line_types => [1, 2, 3, 4, 1],
	       markers => [1, 7, 5, 2, 8],
	       marker_size => 3,
	       legend_placement => 'RT',
	      ) or die $graph->error;

# @data_plotting depends on $max_num_interestingNodes.

my @data_plotting = (
		     \@x_axis4plotting,
		     $y_axis4plotting{1},
		     $y_axis4plotting{2},
		     $y_axis4plotting{3},
		     $y_axis4plotting{4},
		     $y_axis4plotting{5},
		    );


open(IMG," > $plot_file.png") or die("<br>ERROR: Cannot open $plot_file for plotting! <br>");
binmode IMG;
print IMG $graph->plot(\@data_plotting)->png;
close (IMG) or die ("<br>ERROR: Cannot close $plot_file for writing! <br>");


# Gets the histogram according to percentage vector

my $s = 0;
foreach $key (keys %{$sdds->reachableStates()}) {
  if ($sdds->reachableStates($key) > $threshold4histogram) {
    my $state = $sdds->allStates($key);
    
    $x_axis4histogram[$s] = $state->str_state();
    $y_axis4histogram[$s] = $sdds->reachableStates($key);
    $s++;
  }
}

if ($s > $sdds->max_num_reachableStates()) {
  print ("<br>FYI: Since the number of states for histogram, $s, exceeds ", $sdds->max_num_reachableStates(), ", Probability Distribution will not be shown. <br>");
}
else {
  
  my $histogram = GD::Graph::bars->new(900, 500);
  $histogram -> set (
		     x_label => 'States',
		     y_label => 'Percentages',
		     title => 'Probability Distribution (# of simulations = 100)',
		     x_label_position => 1/2,
		     y_min_value => 0,
		     y_max_value => 100,
		     y_tick_number => 10,
		     show_values => 1,
		     bar_spacing => 5,
		     dclrs => [qw (lblue)],
		    ) or die $histogram->error;
  
  my @data_histogram = (
			\@x_axis4histogram,		
			\@y_axis4histogram,
		       );
  
  open(IMG," > $histogram_file.png") or die("<br>ERROR: Cannot open $histogram_file for histogram! <br>");
  binmode IMG;
  print IMG $histogram->plot(\@data_histogram)->png;
  close (IMG) or die ("<br>ERROR: Cannot close $histogram_file for writing! <br>");
}

exit;
