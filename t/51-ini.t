use Test::More tests => 2;

use Config::Any::INI;

my $config = eval { Config::Any::INI->load( 't/conf/conf.ini' ) };

SKIP: {
    skip "Couldn't Load INI plugin", 2 if $@;
    ok( $config );
    is( $config->{ name }, 'TestApp' );
}
