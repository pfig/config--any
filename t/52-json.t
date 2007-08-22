use Test::More tests => 2;

use Config::Any::JSON;

my $config = eval { Config::Any::JSON->load( 't/conf/conf.json' ) };

SKIP: {
    skip "Couldn't Load JSON plugin", 2 if $@;
    ok( $config );
    is( $config->{ name }, 'TestApp' );
}
