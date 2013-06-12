package Chart::Gnuplot::Util;
use strict;
use vars qw(@ISA @EXPORT_OK);
use Exporter;

@ISA = qw(Exporter);
@EXPORT_OK = qw(_lineType _pointType _copy);

# Convert named line type to indexed line type of gnuplot
#
# XXX
# Assuming postscript terminal is used
# This may subjected to change when postscript/gnuplot changes its convention
sub _lineType
{
	my ($type) = @_;
	return($type) if ($type =~ /^\d+$/);

	# Indexed line type of postscript terminal of gnuplot
	my %type = (
		solid          => 1,
		longdash       => 2,
		dash           => 3,
		dot            => 4,
		'dot-longdash' => 5,
		'dot-dash'     => 6,
		'2dash'        => 7,
		'2dot-dash'    => 8,
		'4dash'        => 9,
	);
	return($type{$type});
}


# Convert named line type to indexed line type of gnuplot
#
# XXX
# Assuming postscript terminal is used
# This may subjected to change when postscript/gnuplot changes its convention
sub _pointType
{
	my ($type) = @_;
	return($type) if ($type =~ /^\d+$/);

	# Indexed line type of postscript terminal of gnuplot
	my %type = (
		dot               => 0,
		plus              => 1,
		cross             => 2,
		star              => 3,
		'dot-square'      => 4,
		'dot-circle'      => 6,
		'dot-triangle'    => 8,
		'dot-diamond'     => 12,
		'dot-pentagon'    => 14,
		'fill-square'     => 5,
		'fill-circle'     => 7,
		'fill-triangle'   => 9,
		'fill-diamond'    => 13,
		'fill-pentagon'   => 15,
		square            => 64,
		circle            => 65,
		triangle          => 66,
		diamond           => 68,
		pentagon          => 69,
		'opaque-square'   => 70,
		'opaque-circle'   => 71,
		'opaque-triangle' => 72,
		'opaque-diamond'  => 74,
		'opaque-pentagon' => 75,
	);
	return($type{$type});
}


# Copy object using dclone() of Storable
sub _copy
{
    my ($obj, $num) = @_;
    use Storable;

    my @clones = ();
    $num = 1 if (!defined $num);

    for (my $i = 0; $i < $num; $i++)
    {
        push(@clones, Storable::dclone($obj));
    }
    return(@clones);
}


1;

__END__
