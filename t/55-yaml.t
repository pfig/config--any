use Test::More tests => 2;

use Config::Any::YAML;

my $config = eval { Config::Any::YAML->load( 't/conf/conf.yml' ) };

SKIP: {
    skip "Couldn't Load YAML plugin", 2 if $@;
    ok( $config );
    is( $config->{ name }, 'TestApp' );
}
