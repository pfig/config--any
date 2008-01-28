use strict;
use warnings;

use Test::More;
use Config::Any::XML;

if ( !Config::Any::XML->is_supported ) {
    plan skip_all => 'XML format not supported';
}
else {
    plan tests => 2;
}

{
    my $config = Config::Any::XML->load( 't/conf/conf.xml' );
    ok( $config );
    is( $config->{ name }, 'TestApp' );
}
