# -*- mode: Perl; tab-width: 4; -*-
#
# Fink package
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

package Fink;

require 5.008_001;  # perl 5.8.1 or newer required

use strict;
use warnings;

=head1 NAME

Fink - Compile and install UNIX applications for Mac OS X

=head1 SYNOPSIS

  use Fink;

  # Do something with the other Fink modules

=head1 DESCRIPTION

This module allows other scripts to easily initialize Fink.

=cut

# Fink->_safe()
#
# Make sure Fink is safe to use

{
	my $basepath = "/sw";
	my $inited = 0;
	
	sub _safe {
		# set useful umask
		umask oct("022");
		
		# set PATH so we find dpkg and *-config scripts
		$ENV{PATH} = "$basepath/sbin:$basepath/bin:/usr/sbin:/sbin:/usr/X11R6/bin:/usr/X11/bin:"
			. $ENV{PATH};
		
		# get rid of CDPATH
		delete $ENV{CDPATH};
	}
	
	sub import {
		my $class = shift;
		
		# Only do it once
		return if $inited++;
		
		# Setup the configuration
		my $configpath = "$basepath/etc/fink.conf";
		unless (-f $configpath) {
			print "ERROR: Configuration file \"$configpath\" not found.\n";
			exit 1;
		}	
		require Fink::Config;
		Fink::Config->new_with_path($configpath, { Basepath => $basepath });
		
		# Make sure we're safe
		$class->_safe();
	}
}

1;
