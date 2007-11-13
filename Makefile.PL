use inc::Module::Install 0.68;

if ( -e 'MANIFEST.SKIP' ) {
    system( 'pod2text lib/Config/Any.pm > README' );
}

name 'Config-Any';
all_from 'lib/Config/Any.pm';

requires 'Module::Pluggable' => '3.01';

test_requires 'Test::More';

auto_install;
WriteAll;
