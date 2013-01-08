# Author(s): David Murrugarra & Seda Arat
# Name: Generating the plot, histogram and transition probability matrix for SDDS
# Revision Date: January 2013

#!/usr/bin/perl

use strict;
use warnings;

use Subroutines4sdds;
use Getopt::Euclid;
use GD::Graph;
use GD::Graph::linespoints;
#use GD::Graph::colour;
use GD::Graph::bars;

=head1 NAME

SDDS.pl - Simulate a stochastic model from a possible initialization.

=head1 USAGE

SDDS.pl -f <functions_or_transitiontable-file> -p <propensitymatrix-file> -i <initial-state> -n <interesting-nodes> -s <number-states> -e <number-steps> -m <number-simulations> - a <flag-steadystates> -b <flag-transitionmatrix> -g <plot-file> -h <histogram-file> -t <tm-file> -o <output-file>

=head1 SYNOPSIS

SDDS.pl -f <functions_or_transitiontable-file> -p <propensitymatrix-file> -i <initial-state> -n <interesting-nodes> -s <number-states> -e <number-steps> -m <number-simulations> -a <flag-steadystates> -b <flag-transitionmatrix> -g <plot-file> -h <histogram-file> -t <tm-file> -o <output-file>

=head1 DESCRIPTION

SDDS.pl - Simulate a stochastic model from a possible initialization.

=head1 REQUIRED ARGUMENTS

=over

=item -f[unctions_or_transitiontable-file] <functions_or_transitiontable-file>

The name of the file containing the functions or transition table for the finite dynamical system (.txt). 

=for Euclid:

network-file.type: readable

=item -p[ropensitymatrix-file] <pp-file>

The name of the file containing the propensity probabilities for the system.

=for Euclid:

network-file.type: readable

=item -i[nitial-state] <initial-state>

The string containing the initial state.

=item -n <interesting-nodes>

The string containing the nodes of interest.

=item -s <number-states>

The number of states.

=item -e <number-steps>

The number of states.

=item -m <number-simulations>

The number of states.

=item -a <flag-steadystates>

The number indicating if the steadystates will be shown

=item -b <flag-transitionmatrix>

The number indicating if the transitionmatrix will be shown

=item -g <plot-file>

The name of the file to plot the average trajectory.

=for Euclid:

file.type: writeable

=item -h[istogram-file] <histogram-file>

The name of the file to get the histogram of the percentage vector.

=for Euclid:

file.type: writeable

=back

=head1 OPTIONS

=over

=item -t[transitionmatrix-file] <tm-file>

The name of the file to get the whole transition matrix.

=for Euclid:

file.type: writeable

=item -o[utput-file] <output-file>

The name of the file to print the results.

=for Euclid:

file.type: writeable

=back

=head1 AUTHOR

David Murrugarra & Seda Arat

=cut

my ($func_or_tt_file, $propensitymatrix_file, $initialstate, $interestingnodes, $num_states, $num_steps, $num_simulations, $flag4ss, $flag4tm, $plot_file, $histogram_file, $tm_file, $output_file);

$func_or_tt_file = $ARGV{'-f'};
$propensitymatrix_file = $ARGV{'-p'};
$initialstate = $ARGV{'-i'};
$interestingnodes = $ARGV{'-n'};
$num_states = $ARGV{'-s'};
$num_steps = $ARGV{'-e'};
$num_simulations = $ARGV{'-m'};
$flag4ss = $ARGV{'-a'};
$flag4tm = $ARGV{'-b'};
$plot_file = $ARGV{'-g'};
$histogram_file = $ARGV{'-h'};
$tm_file = $ARGV{'-t'};
$output_file = $ARGV{'-o'};

#print ("<br>---$func_or_tt_file---$propensitymatrix_file---$initialstate---$interestingnodes---$num_states---$num_steps---$num_simulations---$flag4ss---$flag4tm---$plot_file---$histogram_file---$tm_file---<br>");

# it is for random number generator
srand (time | $$);

my ($sdds);

$sdds = Subroutines4sdds::new();

$sdds->max_num_interestingNodes(5);
$sdds->max_num_nodes(20);
$sdds->max_num_states(20);
$sdds->max_num_steps(10**3);
$sdds->max_num_simulations(10**6);
$sdds->max_element_stateSpace(10**3);

$sdds->num_states($num_states);
$sdds->num_steps($num_steps);
$sdds->num_simulations($num_simulations);

$sdds->get_initialstate($initialstate);
$sdds->get_interestingnodes($interestingnodes);

$sdds->flag4ss($flag4ss);
$sdds->flag4tm($flag4tm);

$sdds->get_propensitymatrix($propensitymatrix_file);
$sdds->get_functions_or_transitiontable($func_or_tt_file);

$sdds->get_alltrajectories_and_reachablestates();
$sdds->get_average_trajectory();
$sdds->get_transitionMatrix_and_steadystates($tm_file);

# it is for not showing the states whose percentage is below the threshold in histogram
my $threshold4histogram = 1;
my $max_num_histogramStates = 20;

my ($i, $j, @x_axis4plotting, %y_axis4plotting, @legend_keys, @x_axis4histogram, @y_axis4histogram);

# Gets the data for plotting according to averageTrajectory

my $num_interesting_nodes = scalar @{$sdds->interestingNodes()};

for ($i = 0; $i < $num_interesting_nodes; $i++) {
  my $t = ${$sdds->interestingNodes()}[$i] - 1;

  for ($j = 0; $j <= $sdds->num_steps(); $j++) {
    if ($i == 0) {
      $x_axis4plotting[$j] = $j;
    }
    my $r = $j * $sdds->num_nodes() + $t;
    push (@{$y_axis4plotting{$i + 1}}, @{$sdds->averageTrajectory()}[$r]);
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
$graph -> set_legend(@legend_keys);
$graph -> set (
	       x_label => 'Time Steps',
	       y_label => "Average Expression Level",
	       title => 'Cell Population Simulation',
	       x_min_value => 0,
	       x_label_position => 1/2,
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


open (IMG," > $plot_file.png") or die("<br>ERROR: Cannot open the file for plotting! <br>");
binmode IMG;
print IMG $graph->plot(\@data_plotting)->png;
close (IMG) or die ("<br>ERROR: Cannot close the file for plotting! <br>");


# Gets the histogram according to percentage vector

my $s = 0;
foreach my $keyy (keys %{$sdds->reachableStates()}) {
  if ($sdds->reachableStates($keyy) > $threshold4histogram) {
    my @array = $sdds->convert_from_decimal_to_state($keyy);
    
    $x_axis4histogram[$s] = $keyy;
    $y_axis4histogram[$s] = $sdds->reachableStates($keyy);
    $s++;
  }

  if ($s > $max_num_histogramStates) {
    print ("<br>FYI: Since the number of states for histogram, $s, exceeds $max_num_histogramStates, Probability Distribution will not be shown. <br>");
    $s = 0;
    last;
  } 
}

if ($s) {
  
  my $histogram = GD::Graph::bars->new(900, 500);
  $histogram -> set (
		     x_label => 'States',
		     y_label => 'Percentages',
		     title => 'Probability Distribution',
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
  
  open (IMG," > $histogram_file.png") or die("<br>ERROR: Cannot open the file for histogram! <br>");
  binmode IMG;
  print IMG $histogram->plot(\@data_histogram)->png;
  close (IMG) or die ("<br>ERROR: Cannot close the file for histogram! <br>");
}

exit;
