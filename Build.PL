use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Config::Any',
    license             => 'perl',
    dist_author         => 'Joel Bernstein <rataxis@cpan.org>',
    dist_version_from   => 'lib/Config/Any.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
		'Module::Pluggable' => '3.01'
    },
    add_to_cleanup      => [ 'Config-Any-*' ],
	create_makefile_pl => 'traditional',
);

$builder->create_build_script();
