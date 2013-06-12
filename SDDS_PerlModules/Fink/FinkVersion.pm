# -*- mode: Perl; tab-width: 4; -*-
#
# Fink::FinkVersion package
#
# Fink - a package manager that downloads source and installs it
# Copyright (c) 2001 Christoph Pfisterer
# Copyright (c) 2001-2011 The Fink Package Manager Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA.
#

package Fink::FinkVersion;

use strict;
use warnings;

require Exporter;
our @ISA	 = qw(Exporter);
our @EXPORT_OK	 = qw(&fink_version &default_binary_version &max_info_level &get_arch);
our %EXPORT_TAGS = ('ALL' => \@EXPORT_OK);


=head1 NAME

Fink::FinkVersion - Fink version numbers

=head1 SYNOPSIS

  use Fink::FinkVersion qw(:ALL);

  my $fink_version    = fink_version;
  my $arch            = get_arch;
  my $default_version = default_binary_version($distribution);
  my $max_info_level  = max_info_level;

=head1 DESCRIPTION

This module retrieves the version numbers of various parts of the fink
installation.

=head2 Functions

These functions are exported on request.  You can export them all with

  use Fink::FinkVersion qw(:ALL);

=over 4

=item fink_version

  my $fink_version = fink_version;

Returns the version of the fink source code.

=cut

sub fink_version {
	return '0.29.21';
}


=item get_arch

    my $arch = get_arch;

Returns the architecture string to be used on this platform. For
example, "powerpc" for ppc.

=for private

Callers assume the value is all-lowercase, but some also assume it is
the canonical form. So we can't use lc() here without breaking the
latter if there are any cases of canonical forms that have upper-case
chars. If we find any, have to check our callers for incorrect
assumptions.

=cut

sub get_arch {
	return 'i386';
}

=item default_binary_version

   my $b_dist_version = default_binary_version($distribution);


Returns the most recent (binary) fink distribution version
corresponding to $distribution, or undef if there is no known binary
distro for the given $distribution.

=cut

sub default_binary_version {
	my $distribution = shift;
	my $architecture = get_arch();
	my %bindists = ("10.2-gcc3.3/powerpc" => "0.6.4", "10.3/powerpc" => "0.7.2", "10.4-transitional/powerpc" => "0.8.0", "10.4/powerpc" => "0.8.1", "10.4/i386" => "0.8.1", "10.5/powerpc" => "0.9.0", "10.5/i386" => "0.9.0");
	return $bindists{"$distribution/$architecture"};
}

=item max_info_level

  my $max_info_level = max_info_level;

Returns the highest level of package description file that this fink
can parse. If a .info is componsed of a 'InfoN: <<' ... '<<' block
where N is a larger integer than that returned by this function, the
entire .info file should be ignored.

=cut

sub max_info_level {
	# 1 is the original level (same as none specified)
	# 2 gives percent-expansion in Package: and multiple Type: syntax.
	# 3 gives leading-whitespace removal, removes RFC-822, adds comment support
	# in pkglist fields.
	# 4 allows %lib in ConfigureParams field, and adds %V
	return 4;
}

=back

=cut

1;
