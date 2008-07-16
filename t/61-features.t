package MockApp;
use strict;
use warnings;

$|++;

use Test::More tests => 14;
use Scalar::Util qw(blessed reftype);

use Config::Any;
use Config::Any::INI;

our $cfg_file = 't/conf/conf.foo';

eval { Config::Any::INI->load( $cfg_file ); };
SKIP: {
    skip "File loading backend for INI not found", 10 if $@;

    ok( my $c_arr = Config::Any->load_files(
            {   files         => [ $cfg_file ],
                force_plugins => [ qw(Config::Any::INI) ]
            }
        ),
        "load file with parser forced"
    );
    ok( my $c_hash = Config::Any->load_files(
            {   files           => [ $cfg_file ],
                force_plugins   => [ qw(Config::Any::INI) ],
                flatten_to_hash => 1
            }
        ),
        "load file with parser forced, flatten to hash"
    );
    
    ok( my $c = $c_arr->[ 0 ], "load_files returns an arrayref" );
    ok( my $h = $c_hash, "load_files return an hashref (flatten_to_hash)" );

    ok( ref $c, "load_files arrayref contains a ref" );
    ok( ref $h, "load_files hashref contains a ref" );
    my $ref = blessed $c ? reftype $c : ref $c;
    is( substr( $ref, 0, 4 ), "HASH", "hashref" );
    $ref = blessed $h ? reftype $h : ref $h;
    is( substr( $ref, 0, 4 ), "HASH", "hashref" );

    my ( $name, $cfg ) = each %$c;
    is( $name, $cfg_file, "filename matches" );

    my $cfgref = blessed $cfg ? reftype $cfg : ref $cfg;
    is( substr( $cfgref, 0, 4 ), "HASH", "hashref cfg" );

    is( $cfg->{ name }, 'TestApp', "appname parses" );
    is( $cfg->{ Component }{ "Controller::Foo" }->{ foo },
        'bar', "component->cntrlr->foo = bar" );
    is( $cfg->{ Model }{ "Model::Baz" }->{ qux },
        'xyzzy', "model->model::baz->qux = xyzzy" );

    ok( my $c_arr_2 = Config::Any->load_files(
            {   files         => [ $cfg_file ],
                force_plugins => [ qw(Config::Any::INI) ],
                use_ext       => 1
            }
        ),
        "load file with parser forced"
    );
}

