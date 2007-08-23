use Test::More tests => 4;

use Config::Any::General;

my $config = eval { Config::Any::General->load( 't/conf/conf.conf' ) };

SKIP: {
    skip "Couldn't Load Config::General plugin", 4 if $@;
    ok( $config );
    is( $config->{ name }, 'TestApp' );
    ok( exists $config->{ Component } );

    $config = eval { Config::Any::General->load( 't/conf/conf.conf', { -LowerCaseNames => 1 } ) };

    ok( exists $config->{ component } );
}
