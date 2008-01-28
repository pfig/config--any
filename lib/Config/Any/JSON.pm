package Config::Any::JSON;

use strict;
use warnings;

=head1 NAME

Config::Any::JSON - Load JSON config files

=head1 DESCRIPTION

Loads JSON files. Example:

    {
        "name": "TestApp",
        "Controller::Foo": {
            "foo": "bar"
        },
        "Model::Baz": {
            "qux": "xyzzy"
        }
    }

=head1 METHODS

=head2 extensions( )

return an array of valid extensions (C<json>, C<jsn>).

=cut

sub extensions {
    return qw( json jsn );
}

=head2 load( $file )

Attempts to load C<$file> as a JSON file.

=cut

sub load {
    my $class = shift;
    my $file  = shift;

    open( my $fh, $file ) or die $!;
    my $content = do { local $/; <$fh> };
    close $fh;

    eval { require JSON::Syck; };
    if ( $@ ) {
        require JSON;
        eval { JSON->VERSION( 2 ); };
        return $@ ? JSON::jsonToObj( $content ) : JSON::from_json( $content );
    }
    else {
        return JSON::Syck::Load( $content );
    }
}

=head2 is_supported( )

Returns true if either L<JSON::Syck> or L<JSON> is available.

=cut

sub is_supported {
    eval { require JSON::Syck; };
    return 1 unless $@;
    eval { require JSON; };
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

=item * L<JSON>

=item * L<JSON::Syck>

=back

=cut

1;
