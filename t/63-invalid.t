use strict;
use warnings;

use Test::More tests => 2;

use Config::Any::Perl;

{
    my $file   = 't/conf/conf_invalid.pl';
    my $config = eval { Config::Any::Perl->load( $file ) };

    ok( !$config, 'config load failed' );
    ok( $@, "error thrown ($@)" ); 
}
