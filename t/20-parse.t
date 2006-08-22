package MockApp;

use Test::More tests => 54;
use Scalar::Util qw(blessed reftype);
use Config::Any;

my @files = map { "t/conf/$_" } 
	qw(conf.conf conf.ini conf.json conf.pl conf.xml conf.yml);

for my $f (@files) {
	ok(my $c_arr = Config::Any->load_files({files=>[$f], use_ext=>1}), "load_files with use_ext works");
	ok(my $c = $c_arr->[0], "load_files returns an arrayref");
	ok(ref $c, "load_files arrayref contains a ref");
	my $ref = blessed $c ? reftype $c : ref $c;
	is(substr($ref,0,4), "HASH", "hashref");
	my ($name, $cfg) = each %$c;
	is($name, $f, "filename matches");
	my $cfgref = blessed $cfg ? reftype $cfg : ref $cfg;
	is(substr($cfgref,0,4), "HASH", "hashref cfg");

	is( $cfg->{name}, 'TestApp', "appname parses" );
	is( $cfg->{Component}{ "Controller::Foo" }->{ foo }, 'bar', 		  
		"component->cntrlr->foo = bar" );
	is( $cfg->{Model}{ "Model::Baz" }->{ qux }, 		 'xyzzy',		  
		"model->model::baz->qux = xyzzy" );
}

