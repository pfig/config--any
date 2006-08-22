use Test::More tests => 2;

use Config::Any::XML;

my $config = eval { Config::Any::XML->load( 't/conf/conf.xml' ) };

SKIP: {
    skip "Couldn't Load XML plugin", 2 if $@;
    ok( $config );
    is( $config->{ name }, 'TestApp' );
}
