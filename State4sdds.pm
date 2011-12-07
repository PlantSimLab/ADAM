# Author(s): David Murrugarra & Seda Arat
# Name: Having all properties needed for a state in SDDS
# Revision Date: 11/28/2011

package State4sdds;

#use Data::Dumper;
use strict;
use warnings;

use Class::Struct

(
 value => '@',
 decimal_rep => '$',
 str_state => '$',
 nextstate_tt => '@',
);

=pod

$state = get_value_and_strState($node);

Gets the array value of the given state.

=cut

sub get_value_and_strState {
  my $state = shift;
  my $node = shift;
  @{$state->value()} = @$node;
  $state->str_state(join (' ', @{$state->value()}));
}

############################################################

=pod

$state = get_nextstate_tt($table);

Returns the next state of the given state in the truth table.

=cut

sub get_nextstate_tt
{
  my $state = shift;
  my $table = shift;
  my ($key);
  $key = $state->decimal_rep();
  @{$state->nextstate_tt()} = @{$$table{$key}};
}

############################################################


1;
