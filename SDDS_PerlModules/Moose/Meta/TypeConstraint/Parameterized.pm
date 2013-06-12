package Moose::Meta::TypeConstraint::Parameterized;
BEGIN {
  $Moose::Meta::TypeConstraint::Parameterized::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Moose::Meta::TypeConstraint::Parameterized::VERSION = '2.0010';
}

use strict;
use warnings;
use metaclass;

use Scalar::Util 'blessed';
use Moose::Util::TypeConstraints;
use Moose::Meta::TypeConstraint::Parameterizable;

use base 'Moose::Meta::TypeConstraint';

__PACKAGE__->meta->add_attribute('type_parameter' => (
    accessor  => 'type_parameter',
    predicate => 'has_type_parameter',
));

sub equals {
    my ( $self, $type_or_name ) = @_;

    my $other = Moose::Util::TypeConstraints::find_type_constraint($type_or_name);

    return unless $other->isa(__PACKAGE__);

    return (
        $self->type_parameter->equals( $other->type_parameter )
            and
        $self->parent->equals( $other->parent )
    );
}

sub compile_type_constraint {
    my $self = shift;

    unless ( $self->has_type_parameter ) {
        require Moose;
        Moose->throw_error("You cannot create a Higher Order type without a type parameter");
    }

    my $type_parameter = $self->type_parameter;

    unless ( blessed $type_parameter && $type_parameter->isa('Moose::Meta::TypeConstraint') ) {
        require Moose;
        Moose->throw_error("The type parameter must be a Moose meta type");
    }

    foreach my $type (Moose::Util::TypeConstraints::get_all_parameterizable_types()) {
        if (my $constraint = $type->generate_constraint_for($self)) {
            $self->_set_constraint($constraint);
            return $self->SUPER::compile_type_constraint;
        }
    }

    # if we get here, then we couldn't
    # find a way to parameterize this type
    require Moose;
    Moose->throw_error("The " . $self->name . " constraint cannot be used, because "
          . $self->parent->name . " doesn't subtype or coerce from a parameterizable type.");
}

sub create_child_type {
    my ($self, %opts) = @_;
    return Moose::Meta::TypeConstraint::Parameterizable->new(%opts, parent=>$self);
}

1;

# ABSTRACT: Type constraints with a bound parameter (ArrayRef[Int])



=pod

=head1 NAME

Moose::Meta::TypeConstraint::Parameterized - Type constraints with a bound parameter (ArrayRef[Int])

=head1 VERSION

version 2.0010

=head1 METHODS

This class is intentionally not documented because the API is
confusing and needs some work.

=head1 INHERITANCE

C<Moose::Meta::TypeConstraint::Parameterized> is a subclass of
L<Moose::Meta::TypeConstraint>.

=head1 BUGS

See L<Moose/BUGS> for details on reporting bugs.

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Infinity Interactive, Inc..

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__


