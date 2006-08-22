use Test::More tests => 2;

use Config::Any::Perl;

my $config = eval { Config::Any::Perl->load( 't/conf/conf.pl' ) };

SKIP: {
    skip "Couldn't Load Perl plugin", 2 if $@;
    ok( $config );
    is( $config->{ name }, 'TestApp' );
}
