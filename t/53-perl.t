use strict;
use warnings;

use Test::More tests => 3;

use Config::Any::Perl;

{
    my $file   = 't/conf/conf.pl';
    my $config = Config::Any::Perl->load( $file );

    ok( $config );
    is( $config->{ name }, 'TestApp' );

    my $config_load2 = Config::Any::Perl->load( $file );
    is_deeply( $config_load2, $config, 'multiple loads of the same file' );
}

