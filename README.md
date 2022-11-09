# NAME

MooseX::Role::Registry

# SYNOPSYS

    package Foo::Registry;
    use Moose;
    with 'MooseX::Role::Registry';

    sub config_file {
        return '/foo_objects.yml';
    }

    sub build_registry_object {
        my $self   = shift;
        my $name   = shift;
        my $values = shift || {};

        return Foo->new({
            name                   => $name,
            %$values
        });
    }

    package main;
    my $registry = Foo::Registry->instance;
    my $foo = $registry->get('bar');

# DESCRIPTION

This role watches a file which describes a hashref of objects in yml format.
This hashref is called a "registry" because the objects in the hashref can be
requested by name using _get_.

Implementations should be singletons! In other words, when using a class that is
derived from MooseX::Role::Registry, you shouldn't call _new_. Instead,
just get the singelton object using the _instance_ method and call _get_ on
the result.

# REQUIRED SUBCLASS METHODS

## config\_filename

Returns the filesystem path of the default location of the configuration file
that is watched by a given consumer of MooseX::Role::Registry

## build\_registry\_object

A function to create an object of the registy entry

# METHODS

## get($name)

Returns the registered entity called $name, or undef if none exists.

## all

Returns all of the objects stored in the registry. Useful for generic grep() calls.

## keys

Returns a list of all of the (lookup) keys of objects currently registered in $self.

## registry\_fixup

A callback which allows subclasses to modify the hashref of loaded objects before
they are stored in memory as part of _$self_.

# DEPENDENCIES

- [Moose::Role](https://metacpan.org/pod/Moose%3A%3ARole)
- [namespace::autoclean](https://metacpan.org/pod/namespace%3A%3Aautoclean)
- [Syntax::Keyword::Try](https://metacpan.org/pod/Syntax%3A%3AKeyword%3A%3ATry)
- [YAML::XS](https://metacpan.org/pod/YAML%3A%3AXS)

# SOURCE CODE

[GitHub](https://github.com/binary-com/perl-MooseX-Role-Registry)

# AUTHOR

binary.com, `<perl at binary.com>`

# BUGS

Please report any bugs or feature requests to
`bug-moosex-role-registry at rt.cpan.org`, or through the web
interface at
[http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MooseX-Role-Registry](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MooseX-Role-Registry).
We will be notified, and then you'll automatically be notified of progress on
your bug as we make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MooseX::Role::Registry

You can also look for information at:

- RT: CPAN's request tracker (report bugs here)

    [http://rt.cpan.org/NoAuth/Bugs.html?Dist=MooseX-Role-Registry](http://rt.cpan.org/NoAuth/Bugs.html?Dist=MooseX-Role-Registry)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/MooseX-Role-Registry](http://annocpan.org/dist/MooseX-Role-Registry)

- CPAN Ratings

    [http://cpanratings.perl.org/d/MooseX-Role-Registry](http://cpanratings.perl.org/d/MooseX-Role-Registry)

- Search CPAN

    [http://search.cpan.org/dist/MooseX-Role-Registry/](http://search.cpan.org/dist/MooseX-Role-Registry/)
