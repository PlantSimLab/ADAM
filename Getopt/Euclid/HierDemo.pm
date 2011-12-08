package Getopt::Euclid::HierDemo;

use Getopt::Euclid;

1;

=head1 REQUIRED ARGUMENTS

=over

=item  -i[nfile]  [=]<file>    

Specify input file

=for Euclid:
    file.type:    readable
    file.default: '-'

=item  -o[ut][file]= <file>    

Specify output file

=for Euclid:
    file.type:    writable
    file.default: '-'

=back
