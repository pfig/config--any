use Test::More tests => 3;

use Config::Any::Perl;

my $file = 't/conf/conf.pl';
my $config = eval { Config::Any::Perl->load( $file ) };

SKIP: {
    skip "Couldn't Load Perl plugin", 3 if $@;

    ok( $config );
    is( $config->{ name }, 'TestApp' );

    my $config_2 = eval { Config::Any::Perl->load( $file ) };

    is_deeply( $config_2, $config, 'multiple loads of perl configs' );
}
