package Config::Any::XML;

use strict;
use warnings;

=head1 NAME

Config::Any::XML - Load XML config files

=head1 DESCRIPTION

Loads XML files. Example:

    <config>
        <name>TestApp</name>
        <component name="Controller::Foo">
            <foo>bar</foo>
        </component>
        <model name="Baz">
            <qux>xyzzy</qux>
        </model>
    </config>

=head1 METHODS

=head2 extensions( )

return an array of valid extensions (C<xml>).

=cut

sub extensions {
    return qw( xml );
}

=head2 load( $file )

Attempts to load C<$file> as an XML file.

=cut

sub load {
    my $class = shift;
    my $file  = shift;

    require XML::Simple;
    XML::Simple->import;
    my $config = XMLin( $file, ForceArray => [ qw( component model view controller ) ] );

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

=item * L<XML::Simple>

=back

=cut

1;