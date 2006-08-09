package Config::Any::General;

use strict;
use warnings;

=head1 NAME

Config::Any::General - Load Config::General files

=head1 DESCRIPTION

Loads Config::General files. Example:

    name = TestApp
    <Component Controller::Foo>
        foo bar
    </Component>
    <Model Baz>
        qux xyzzy
    </Model>

=head1 METHODS

=head2 extensions( )

return an array of valid extensions (C<cnf>, C<conf>).

=cut

sub extensions {
    return qw( cnf conf );
}

=head2 load( $file )

Attempts to load C<$file> via Config::General.

=cut

sub load {
    my $class = shift;
    my $file  = shift;

    require Config::General;
    my $configfile = Config::General->new( $file );
    my $config     = { $configfile->getall };
    
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

=item * L<Config::General>

=back

=cut

1;