use strict;
use warnings;

use Test::More tests => 6;

BEGIN {
    use_ok( 'Config::Any' );
    use_ok( 'Config::Any::INI' );
    use_ok( 'Config::Any::JSON' );
    use_ok( 'Config::Any::Perl' );
    use_ok( 'Config::Any::XML' );
    use_ok( 'Config::Any::YAML' );
}
