package Config::Any::YAML;

use strict;
use warnings;

=head1 NAME

Config::Any::YAML - Load YAML config files

=head1 DESCRIPTION

Loads YAML files. Example:

    ---
    name: TestApp
    Controller::Foo:
        foo: bar
    Model::Baz:
        qux: xyzzy
    

=head1 METHODS

=head2 extensions( )

return an array of valid extensions (C<yml>, C<yaml>).

=cut

sub extensions {
    return qw( yml yaml );
}

=head2 load( $file )

Attempts to load C<$file> as a YAML file.

=cut

sub load {
    my $class = shift;
    my $file  = shift;

    eval { require YAML::Syck; YAML::Syck->VERSION( '0.70' ) };
    if ( $@ ) {
        require YAML;
        return YAML::LoadFile( $file );
    }
    else {
        open( my $fh, $file ) or die $!;
        my $content = do { local $/; <$fh> };
        close $fh;
        return YAML::Syck::Load( $content );
    }
}

=head2 is_supported( )

Returns true if either L<YAML::Syck> or L<YAML> is available.

=cut

sub is_supported {
    eval { require YAML::Syck; YAML::Syck->VERSION( '0.70' ) };
    return 1 unless $@;
    eval { require YAML; };
    return $@ ? 0 : 1;
}

=head1 AUTHOR

Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Brian Cassidy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=head1 SEE ALSO

=over 4 

=item * L<Catalyst>

=item * L<Config::Any>

=item * L<YAML>

=item * L<YAML::Syck>

=back

=cut

1;
