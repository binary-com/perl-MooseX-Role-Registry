package MooseX::Role::Registry;
use strict;
use warnings;

our $VERSION = '1.00';

=head1 NAME

MooseX::Role::Registry

=head1 SYNOPSYS

    my $registry = Foo::Registry->instance;
    my $foo = $registry->get('bar');

=head1 DESCRIPTION

This role watches file which describes a hashref of objects. This hashref is
called a "registry" because the objects in the hashref can be requested by name
using I<get>.

Implementations should be singletons! In other words, when using a class that is
derived from BOM::System::Runtime::Registry, you shouldn't call I<new>. Instead,
just get the singelton object using the I<instance> method and call I<get> on
the result.

=cut

use Moose::Role;
use namespace::autoclean;

use Carp;
use Try::Tiny;
use YAML::XS qw(LoadFile);

=head1 REQUIRED SUBCLASS METHODS

=head2 config_filename

Returns the filesystem path of the default location of the configuration file
that is watched by a given consumer of MooseX::Role::Registry

=cut

requires 'config_file';

=head2 build_registry_object

A function to create an object of the registy entry

=cut

requires 'build_registry_object';

=head1 METHODS

=head2 get($name)

Returns the registered entity called $name, or undef if none exists.

=cut

sub get {
    my $self = shift;
    my $key  = shift;

    return unless ($key);
    return $self->_registry->{$key};
}

=head2 all

Returns all of the objects stored in the registry. Useful for generic grep() calls.

=cut

sub all {
    my $self = shift;
    return values %{ $self->_registry };
}

=head2 keys

Returns a list of all of the (lookup) keys of objects currently registered in $self.

=cut

sub keys    ## no critic (ProhibitBuiltinHomonyms)
{
    my $self = shift;
    my @result = sort { $a cmp $b } ( keys %{ $self->_registry } );
    return @result;
}

=head2 registry_fixup

A callback which allows subclasses to modify the hashref of loaded objects before
they are stored in memory as part of I<$self>.

=cut

sub registry_fixup {
    my $self     = shift;
    my $registry = shift;
    return
      $registry;   # Default implementation is to leave the loaded hashref alone
}

has _registry => (
    is         => 'rw',
    isa        => 'HashRef',
    lazy_build => 1
);

has _db => (
    is         => 'rw',
    isa        => 'HashRef',
    lazy_build => 1
);

sub _build__db {
    my $self = shift;

    return YAML::XS::LoadFile( $self->config_file );
}

sub _build__registry {
    my $self     = shift;
    my $registry = $self->_db;

    # If we've made it this far we no longer need this key
    delete $registry->{version};

    foreach my $key ( CORE::keys %$registry ) {

        # TOTALLY coding to the coverage tool here. This sucks.
        my $reg_defn      = $registry->{$key};
        my $reg_defn_type = ref $reg_defn;
        if ( not $reg_defn_type or ( $reg_defn_type eq 'HASH' ) ) {
            try {
                $registry->{$key} =
                  $self->build_registry_object( $key, $reg_defn );
            }
            catch {
                Carp::croak( "Unable to convert entry $key in "
                      . $self->config_file
                      . " into a registry entry : $_" );
            };
        }
        else {
            Carp::croak( "Invalid entry $key in "
                  . $self->config_file
                  . ", not a hash" );
        }
    }

    return $self->registry_fixup($registry);
}

sub BUILD {
    my $self = shift;
    $self->_registry;
    return;
}

1;
