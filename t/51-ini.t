use Test::More tests => 6;

use Config::Any::INI;

my $config =       eval { Config::Any::INI->load( 't/conf/conf.ini' ) };
my $simpleconfig = eval { Config::Any::INI->load( 't/conf/conf2.ini' ) };

SKIP: {
    skip "Couldn't Load INI plugin", 6 if $@;
    ok( $config );
    is( $config->{ name }, 'TestApp' );
	is( $config->{Component}->{Controller::Foo}->{foo}, 'bar');
	
	ok( $simpleconfig );
    is( $simpleconfig->{ name }, 'TestApp' );
    is( $simpleconfig->{Controller::Foo}->{foo}, 'bar' );
}
