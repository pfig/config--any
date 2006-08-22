use Test::More tests => 2;

use Config::Any::General;

my $config = eval { Config::Any::General->load( 't/conf/conf.conf' ) };

SKIP: {
    skip "Couldn't Load Config::General plugin", 2 if $@;
    ok( $config );
    is( $config->{ name }, 'TestApp' );
}
