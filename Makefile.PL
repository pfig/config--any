use inc::Module::Install 0.65;

name 'Config-Any';
all_from 'lib/Config/Any.pm';

requires 'Module::Pluggable' => '3.01';
requires 'version';

requires 'Test::More';

auto_install;
WriteAll;
