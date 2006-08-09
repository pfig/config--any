package Config::Any::INI;

use strict;
use warnings;

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
    
    $config->{ $_ } = $main->{ $_ } for keys %$main;

    return $config;
}

=head1 AUTHOR

=over 4 

=item * Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2006 by Brian Cassidy

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