package Config::Any::INI;

use strict;
use warnings;

our $MAP_SECTION_SPACE_TO_NESTED_KEY = 1;

=head1 NAME

Config::Any::INI - Load INI config files

=head1 DESCRIPTION

Loads INI files. Example:

    name=TestApp
    
    [Controller::Foo]
    foo=bar
    
    [Model::Baz]
    qux=xyzzy

=head1 METHODS

=head2 extensions( )

return an array of valid extensions (C<ini>).

=cut

sub extensions {
    return qw( ini );
}

=head2 load( $file )

Attempts to load C<$file> as an INI file.

=cut

sub load {
    my $class = shift;
    my $file  = shift;

    require Config::Tiny;
    my $config = Config::Tiny->read( $file );

    my $main   = delete $config->{ _ };
    my $out;
    $out->{$_} = $main->{$_} for keys %$main;

    for my $k (keys %$config) {
        my @keys = split /\s+/, $k if $MAP_SECTION_SPACE_TO_NESTED_KEY;
        my $ref = $config->{$k};

        if (@keys > 1) {
            my ($a, $b) = @keys[0,1];
            $out->{$a}->{$b} = $ref;
        } else {
            $out->{$k} = $ref;
        }
    }
    return $out;
}

=head1 PACKAGE VARIABLES

=over 4

=item $MAP_SECTION_SPACE_TO_NESTED_KEY (boolean)

This variable controls whether spaces in INI section headings will be expanded into nested hash keys.
e.g. it controls whether [Full Power] maps to $config->{'Full Power'} or $config->{'Full'}->{'Power'}

By default it is set to 1 (i.e. true). 

Set it to 0 to preserve literal spaces in section headings:

    use Config::Any;
    use Config::Any::INI;
    $Config::Any::INI::MAP_SECTION_SPACE_TO_NESTED_KEY = 0;

=back

=head1 AUTHOR

=over 4 

=item * Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=item * Joel Bernstein E<lt>rataxis@cpan.orgE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2006 by Brian Cassidy, portions copyright 2006, 2007 by Joel Bernstein

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=head1 SEE ALSO

=over 4 

=item * L<Catalyst>

=item * L<Config::Any>

=item * L<Config::Tiny>

=back

=cut

1;
