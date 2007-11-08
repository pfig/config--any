use Test::More tests => 10;

use_ok( 'Config::Any' );

{
    my @warnings;
    local $SIG{ __WARN__ } = sub { push @warnings, @_ };

    Config::Any->load_files( );
    like(
        shift @warnings,
        qr/^No files specified!/,
        "load_files expects args"
    );

    Config::Any->load_files( {} );
    like(
        shift @warnings,
        qr/^No files specified!/,
        "load_files expects files"
    );

    Config::Any->load_stems( );
    like(
        shift @warnings,
        qr/^No stems specified!/,
        "load_stems expects args"
    );

    Config::Any->load_stems( {} );
    like(
        shift @warnings,
        qr/^No stems specified!/,
        "load_stems expects stems"
    );
}

my @files = glob( "t/conf/conf.*" );
my $filter = sub { return };
ok( Config::Any->load_files( { files => \@files, use_ext => 0 } ),
    "use_ext 0 works" );
ok( Config::Any->load_files( { files => \@files, use_ext => 1 } ),
    "use_ext 1 works" );

ok( Config::Any->load_files(
        { files => \@files, use_ext => 1, filter => \&$filter }
    ),
    "filter works"
);
eval {
    Config::Any->load_files(
        {   files   => \@files,
            use_ext => 1,
            filter  => sub { die }
        }
    );
};
ok( $@, "filter breaks" );

my @stems = qw(t/conf/conf);
ok( Config::Any->load_stems( { stems => \@stems, use_ext => 1 } ),
    "load_stems with stems works" );
