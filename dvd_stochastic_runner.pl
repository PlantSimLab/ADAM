#!/usr/bin/perl

## Franziska Hinkelmann

## dvd_stochasitic_runner.pl
## Multi-function, stochastic DVD Processing
## This script takes a number of nodes, the number of states, and the filename for the input file
## Functions can be read from the input file with the possiblity for more than one function per node
## Authored by Jonte Craighead and Franziska Hinkelmann
#
# Use: perl dvd_stochasitic_runner.pl #nodes #states all_trajectories_flag
# update_stochastic_flag outputfilename graph_format dependencygraph_flag
# update_sequential_flag update_schedule inputfile.txt
# 
# If this script is run, Stochastic is hard coded to 1, so we always get a
# probabilities in the graph (maybe this should be changed?)
#
# The all_trajectories_flag set means all possible arrows are drawn in one
# graph, without this option, one update is choosen at random for every
# variables - the program should always be run with the flag turned on, since
# this produces the phase space, the other option produces one possible
# trajectory for each state but not a simulation starting from one state
# 
# update_stochastic_flag set means that we treat the system as an update
# stochastic systems (the udpate schedule is random). This is simulated by
# using a function stochastic system where each function set has two members:
# the local update function and the identity. The probabilities are set such
# that (nodes-1) functions are delayed and only one function is updated. If
# the user gives a family of update functions for one node, an error is
# returned, because a function and update stochastic system is not
# allowed. 

# Need this so I can have access from a different folder - needs to be changed
# for polymath
#use lib '/Users/fhinkel/Sites';
use lib './';

use DVDCore qw($Clientip $Function_data $Function_file &error_check @Output_array $Pwd &dvd_session &_log $Stochastic);
use Cwd;
use Getopt::Std;
getopts('vh');

#set non-zero to get too much information
$DEBUG=$opt_v;

print "Begin of computation\n<br>" if ($DEBUG);

die "Usage: dvd_stochasitic_runner.pl [-vh] #nodes #states
all_trajectories_flag update_stochastic_flag outputfilename graph_format
dependencygraph_flag update_sequential_flag update_schedule
Probabilities_in_graph_flag trajectory_flag trajectory_value inputfile.txt \n\t-v  verbose \n\t-h  this help\n"
if ($opt_h || $#ARGV != 12);

$n_nodes = $ARGV[0]; #number of variables
$p_value = $ARGV[1]; #number of states
$all_trajectories_flag= $ARGV[2];  # This flag set means all possible arrows are drawn in one
# graph, without this option, one update is choosen at random for every
# variables
$update_stochastic_flag=$ARGV[3]; 	#if set, an update stochastic system is simulated using
#random delays
$clientip = $ARGV[4]; #outputfiles
$ss_format = $ARGV[5]; #graph format
$regulatory = $ARGV[6]; #on if dependency graph should be graphed

# $passes = 1;
$translate = 0; #translate_box (whether Boolean or polynomial; at the moment
# translation is done in the new_dvd2.pl program
$update_sequential_flag = $ARGV[7]; #1 if sequential update
$update_schedule = $ARGV[8]; #update_schedule
$statespace = 1; #statespace 1 means create picture
$dg_format = $ss_format; 
$Stochastic = $ARGV[9]; 	# if set to one, probabilities are included in graph
$trajectory_flag = $ARGV[10]; # 1 if all trajectories, 0 for a single trajetory form intitial state trajectory_value
$trajectory_value = $ARGV[11]; # initial state

$stochastic_input_file = $ARGV[-1]; 

open($function_file, $stochastic_input_file);
_log("Attempted to read from '$stochastic_input_file'");

$Pwd = getcwd();

@response = dvd_session($n_nodes, $p_value, $clientip, $translate,
$update_sequential_flag, $update_schedule, $all_trajectories_flag,
$statespace, $ss_format, $regulatory, $dg_format,
$trajectory_flag, $trajectory_value, $update_stochastic_flag, $DEBUG,
$function_file);

if($response[0] == 1) { # a response code should always be returned by the main DVDCore functions
    _log($_) foreach(@Output_array);
    if ($trajectory_flag) {
        print "Number of components $Output_array[2]<br>";
        print "Number of fixed points $Output_array[3]<br>";
        print "$Output_array[5]<br>";
    }
} 
else {
    print $_."\n" foreach(@response);
#	print "<br>Use<br>\nperl dvd_stochasitic_runner.pl n_nodes p_value all_trajectories_flag update_stochastic_flag clientip ss_format dependencygraph update_sequential_flag update_schedule inputfile<br>\n";
}
