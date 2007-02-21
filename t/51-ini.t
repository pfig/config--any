use Test::More tests => 9;

use Config::Any::INI;

my $config =       eval { Config::Any::INI->load( 't/conf/conf.ini' ) };
my $simpleconfig = eval { Config::Any::INI->load( 't/conf/conf2.ini' ) };

SKIP: {
    skip "Couldn't Load INI plugin", 6 if $@;
    ok( $config, "loaded INI config #1" );
    is( $config->{ name }, 'TestApp', "toplevel key lookup succeeded" );
    is( $config->{Component}->{Controller::Foo}->{foo}, 'bar', "nested hashref hack lookup succeeded");
    
    ok( $simpleconfig, "loaded INI config #1" );
    is( $simpleconfig->{ name }, 'TestApp', "toplevel key lookup succeeded" );
    is( $simpleconfig->{Controller::Foo}->{foo}, 'bar', "nested hashref hack lookup succeeded" );
}

$Config::Any::INI::MAP_SECTION_SPACE_TO_NESTED_KEY = 0;
my $unspaced_config = eval { Config::Any::INI->load( 't/conf/conf.ini' ); };
SKIP: {
    skip "Couldn't load INI plugin", 3 if $@;
    ok( $unspaced_config, "loaded INI config #1 in no-map-space mode" );
    is( $unspaced_config->{name}, 'TestApp', "toplevel key lookup succeeded" );
    is( $unspaced_config->{'Component Controller::Foo'}->{foo}, 'bar', "unnested key lookup succeeded");
}
