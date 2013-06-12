package Class::MOP::Deprecated;
BEGIN {
  $Class::MOP::Deprecated::AUTHORITY = 'cpan:STEVAN';
}
BEGIN {
  $Class::MOP::Deprecated::VERSION = '2.0010';
}

use strict;
use warnings;

use Package::DeprecationManager -deprecations => {
    'Class::MOP::HAVE_ISAREV'           => '0.93',
    'Class::MOP::subname'               => '0.93',
    'Class::MOP::in_global_destruction' => '0.93',

    'Class::MOP::Package::get_method_map' => '0.93',

    'Class::MOP::Class::construct_class_instance'          => '0.93',
    'Class::MOP::Class::check_metaclass_compatibility'     => '0.93',
    'Class::MOP::Class::create_meta_instance'              => '0.93',
    'Class::MOP::Class::clone_instance'                    => '0.93',
    'Class::MOP::Class::alias_method'                      => '0.93',
    'Class::MOP::Class::compute_all_applicable_methods'    => '0.93',
    'Class::MOP::Class::compute_all_applicable_attributes' => '0.93',
    'Class::MOP::Class::get_attribute_map'                 => '0.95',

    'Class::MOP::Instance::bless_instance_structure' => '0.93',

    'Class::MOP::Attribute::process_accessors' => '0.93',

    'Class::MOP::Method::Accessor::initialize_body'                 => '0.93',
    'Class::MOP::Method::Accessor::generate_accessor_method'        => '0.93',
    'Class::MOP::Method::Accessor::generate_reader_method'          => '0.93',
    'Class::MOP::Method::Accessor::generate_writer_method'          => '0.93',
    'Class::MOP::Method::Accessor::generate_predicate_method'       => '0.93',
    'Class::MOP::Method::Accessor::generate_clearer_method'         => '0.93',
    'Class::MOP::Method::Accessor::generate_accessor_method_inline' => '0.93',
    'Class::MOP::Method::Accessor::generate_reader_method_inline'   => '0.93',
    'Class::MOP::Method::Accessor::generate_writer_method_inline'   => '0.93',
    'Class::MOP::Method::Accessor::generate_clearer_method_inline'  => '0.93',
    'Class::MOP::Method::Accessor::generate_predicate_method_inline' =>
        '0.93',

    'Class::MOP::Method::Constructor::meta_instance'               => '0.93',
    'Class::MOP::Method::Constructor::attributes'                  => '0.93',
    'Class::MOP::Method::Constructor::initialize_body'             => '0.93',
    'Class::MOP::Method::Constructor::generate_constructor_method' => '0.93',
    'Class::MOP::Method::Constructor::generate_constructor_method_inline' =>
        '0.93',
};


package
    Class::MOP;

sub HAVE_ISAREV () {
    Class::MOP::Deprecated::deprecated(
        "Class::MOP::HAVE_ISAREV is deprecated and will be removed in a future release. It has always returned 1 anyway. This function will be removed in the Moose 2.0200 release."
    );
    return 1;
}

sub subname {
    Class::MOP::Deprecated::deprecated(
        "Class::MOP::subname is deprecated. Please use Sub::Name directly. This function will be removed in the Moose 2.0200 release.");
    require Sub::Name;
    goto \&Sub::Name::subname;
}

sub in_global_destruction {
    Class::MOP::Deprecated::deprecated(
        "Class::MOP::in_global_destruction is deprecated. Please use Devel::GlobalDestruction directly. This function will be removed in the Moose 2.0200 release."
    );
    require Devel::GlobalDestruction;
    goto \&Devel::GlobalDestruction::in_global_destruction;
}

package
    Class::MOP::Package;

use Scalar::Util qw( blessed );

sub get_method_map {
    Class::MOP::Deprecated::deprecated(
              'The get_method_map method has been made private.'
            . ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    my $self = shift;

    return { map { $_->name => $_ } $self->_get_local_methods };
}

package
    Class::MOP::Module;

package
    Class::MOP::Class;

sub construct_class_instance {
    Class::MOP::Deprecated::deprecated(
              'The construct_class_instance method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_construct_class_instance(@_);
}

sub check_metaclass_compatibility {
    Class::MOP::Deprecated::deprecated(
        'The check_metaclass_compatibility method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_check_metaclass_compatibility(@_);
}

sub construct_instance {
    Class::MOP::Deprecated::deprecated(
              'The construct_instance method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_construct_instance(@_);
}

sub create_meta_instance {
    Class::MOP::Deprecated::deprecated(
              'The create_meta_instance method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_create_meta_instance(@_);
}

sub clone_instance {
    Class::MOP::Deprecated::deprecated(
              'The clone_instance method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_clone_instance(@_);
}

sub alias_method {
    Class::MOP::Deprecated::deprecated(
        'The alias_method method is deprecated. Use add_method instead. This method will be removed in the Moose 2.0200 release.');

    shift->add_method(@_);
}

sub compute_all_applicable_methods {
    Class::MOP::Deprecated::deprecated(
              'The compute_all_applicable_methods method is deprecated.'
            . ' Use get_all_methods instead. This method will be removed in the Moose 2.0200 release.' );

    return map {
        {
            name  => $_->name,
            class => $_->package_name,
            code  => $_,                 # sigh, overloading
        },
    } shift->get_all_methods(@_);
}

sub compute_all_applicable_attributes {
    Class::MOP::Deprecated::deprecated(
        'The compute_all_applicable_attributes method has been deprecated.'
            . ' Use get_all_attributes instead. This method will be removed in the Moose 2.0200 release.' );

    shift->get_all_attributes(@_);
}

sub get_attribute_map {
    Class::MOP::Deprecated::deprecated(
        'The get_attribute_map method has been deprecated. This method will be removed in the Moose 2.0200 release.');

    shift->_attribute_map(@_);
}

package
    Class::MOP::Instance;

sub bless_instance_structure {
    Class::MOP::Deprecated::deprecated(
              'The bless_instance_structure method is deprecated.'
            . ' This method will be removed in the Moose 2.0200 release.' );

    my ( $self, $instance_structure ) = @_;
    bless $instance_structure, $self->_class_name;
}

package
    Class::MOP::Attribute;

sub process_accessors {
    Class::MOP::Deprecated::deprecated(
              'The process_accessors method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_process_accessors(@_);
}

package
    Class::MOP::Method::Accessor;

sub initialize_body {
    Class::MOP::Deprecated::deprecated(
              'The initialize_body method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_initialize_body;
}

sub generate_accessor_method {
    Class::MOP::Deprecated::deprecated(
              'The generate_accessor_method method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_generate_accessor_method;
}

sub generate_reader_method {
    Class::MOP::Deprecated::deprecated(
              'The generate_reader_method method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_generate_reader_method;
}

sub generate_writer_method {
    Class::MOP::Deprecated::deprecated(
              'The generate_writer_method method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_generate_writer_method;
}

sub generate_predicate_method {
    Class::MOP::Deprecated::deprecated(
              'The generate_predicate_method method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_generate_predicate_method;
}

sub generate_clearer_method {
    Class::MOP::Deprecated::deprecated(
              'The generate_clearer_method method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_generate_clearer_method;
}

sub generate_accessor_method_inline {
    Class::MOP::Deprecated::deprecated(
        'The generate_accessor_method_inline method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_generate_accessor_method_inline;
}

sub generate_reader_method_inline {
    Class::MOP::Deprecated::deprecated(
        'The generate_reader_method_inline method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_generate_reader_method_inline;
}

sub generate_writer_method_inline {
    Class::MOP::Deprecated::deprecated(
        'The generate_writer_method_inline method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_generate_writer_method_inline;
}

sub generate_predicate_method_inline {
    Class::MOP::Deprecated::deprecated(
        'The generate_predicate_method_inline method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_generate_predicate_method_inline;
}

sub generate_clearer_method_inline {
    Class::MOP::Deprecated::deprecated(
        'The generate_clearer_method_inline method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_generate_clearer_method_inline;
}

package
    Class::MOP::Method::Constructor;

sub meta_instance {
    Class::MOP::Deprecated::deprecated(
              'The meta_instance method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_meta_instance;
}

sub attributes {
    Class::MOP::Deprecated::deprecated(
              'The attributes method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );

    return shift->_attributes;
}

sub initialize_body {
    Class::MOP::Deprecated::deprecated(
              'The initialize_body method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_initialize_body;
}

sub generate_constructor_method {
    Class::MOP::Deprecated::deprecated(
              'The generate_constructor_method method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_generate_constructor_method;
}

sub generate_constructor_method_inline {
    Class::MOP::Deprecated::deprecated(
        'The generate_constructor_method_inline method has been made private.'
            .  ' The public version is deprecated. This method will be removed in the Moose 2.0200 release.'
    );
    shift->_generate_constructor_method_inline;
}

1;

__END__

=pod

=head1 NAME 

Class::MOP::Deprecated - Manages deprecation warnings for Class::MOP

=head1 DESCRIPTION

    use Class::MOP::Deprecated -api_version => $version;

=head1 FUNCTIONS

This module manages deprecation warnings for features that have been
deprecated in Class::MOP.

If you specify C<< -api_version => $version >>, you can use deprecated features
without warnings. Note that this special treatment is limited to the package
that loads C<Class::MOP::Deprecated>.

=cut
