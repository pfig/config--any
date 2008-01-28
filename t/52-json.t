use strict;
use warnings;

use Test::More;
use Config::Any::JSON;

if ( !Config::Any::JSON->is_supported ) {
    plan skip_all => 'JSON format not supported';
}
else {
    plan tests => 2;
}

{
    my $config = Config::Any::JSON->load( 't/conf/conf.json' );
    ok( $config );
    is( $config->{ name }, 'TestApp' );
}
