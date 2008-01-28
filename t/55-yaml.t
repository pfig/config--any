use strict;
use warnings;

use Test::More;
use Config::Any::YAML;

if ( !Config::Any::YAML->is_supported ) {
    plan skip_all => 'YAML format not supported';
}
else {
    plan tests => 2;
}

{
    my $config = Config::Any::YAML->load( 't/conf/conf.yml' );
    ok( $config );
    is( $config->{ name }, 'TestApp' );
}
