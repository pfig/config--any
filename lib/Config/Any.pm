package Config::Any;
# $Id: $
use warnings;
use strict;
use Carp;
use Module::Pluggable::Object ();
use English qw(-no_match_vars);

our $VERSION = '0.06';

=head1 NAME

Config::Any - Load configuration from different file formats, transparently

=head1 VERSION

This document describes Config::Any version 0.0.5

=head1 SYNOPSIS

    use Config::Any;

	my $cfg = Config::Any->load_stems({stems => \@filepath_stems, ... });
	# or
	my $cfg = Config::Any->load_files({files => \@filepaths, ... });

	for (@$cfg) {
		my ($filename, $config) = each %$_;
		$class->config($config);
		warn "loaded config from file: $filename";
	}

=head1 DESCRIPTION

L<Config::Any|Config::Any> provides a facility for Perl applications and libraries
to load configuration data from multiple different file formats. It supports XML, YAML,
JSON, Apache-style configuration, Windows INI files, and even Perl code.

The rationale for this module is as follows: Perl programs are deployed on many different
platforms and integrated with many different systems. Systems administrators and end 
users may prefer different configuration formats than the developers. The flexibility
inherent in a multiple format configuration loader allows different users to make 
different choices, without generating extra work for the developers. As a developer
you only need to learn a single interface to be able to use the power of different
configuration formats.

=head1 INTERFACE 

=cut

=head2 load_files( )

    Config::Any->load_files({files => \@files]});
    Config::Any->load_files({files => \@files, filter  => \&filter});
    Config::Any->load_files({files => \@files, use_ext => 1});

C<load_files()> attempts to load configuration from the list of files passed in
the C<files> parameter, if the file exists.

If the C<filter> parameter is set, it is used as a callback to modify the configuration 
data before it is returned. It will be passed a single hash-reference parameter which 
it should modify in-place.

If the C<use_ext> parameter is defined, the loader will attempt to parse the file
extension from each filename and will skip the file unless it matches a standard
extension for the loading plugins. Only plugins whose standard extensions match the
file extension will be used. For efficiency reasons, its use is encouraged, but
be aware that you will lose flexibility -- for example, a file called C<myapp.cfg> 
containing YAML data will not be offered to the YAML plugin, whereas C<myapp.yml>
or C<myapp.yaml> would be.

C<load_files()> also supports a 'force_plugins' parameter, whose value should be an
arrayref of plugin names like C<Config::Any::INI>. Its intended use is to allow the use 
of a non-standard file extension while forcing it to be offered to a particular parser.
It is not compatible with 'use_ext'. 

=cut

sub load_files {
    my ($class, $args) = @_;
    return unless defined $args;
    unless (exists $args->{files}) {
        warn "no files specified";
        return;
    }

    my %load_args = map { $_ => defined $args->{$_} ? $args->{$_} : undef } 
        qw(filter use_ext force_plugins);
    $load_args{files} = [ grep { -f $_ } @{$args->{files}} ];
    return $class->_load(\%load_args);
}

=head2 load_stems( )

    Config::Any->load_stems({stems => \@stems]});
    Config::Any->load_stems({stems => \@stems, filter  => \&filter});
    Config::Any->load_stems({stems => \@stems, use_ext => 1});

C<load_stems()> attempts to load configuration from a list of files which it generates
by combining the filename stems list passed in the C<stems> parameter with the 
potential filename extensions from each loader, which you can check with the
C<extensions()> classmethod described below. Once this list of possible filenames is
built it is treated exactly as in C<load_files()> above, as which it takes the same
parameters. Please read the C<load_files()> documentation before using this method.

=cut

sub load_stems {
    my ($class, $args) = @_;
    return unless defined $args;
    unless (exists $args->{stems}) {
        warn "no stems specified";
        return;
    }
        
    my %load_args = map { $_ => defined $args->{$_} ? $args->{$_} : undef } 
        qw(filter use_ext force_plugins);

    my $filenames = $class->_stems_to_files($args->{stems});
    $load_args{files} = [ grep { -f $_ } @{$filenames} ];
    return $class->_load(\%load_args);
}

sub _stems_to_files {
    my ($class, $stems) = @_;
    return unless defined $stems;

    my @files;
    STEM:
    for my $s (@$stems) {
        EXT:
        for my $ext ($class->extensions) {
            my $file = "$s.$ext";
            next EXT unless -f $file;
            push @files, $file;
            last EXT;
        }
    }
    \@files;
}

sub _maphash (@) { map { $_ => 1 } @_ } # sugar

# this is where we do the real work
# it's a private class-method because users should use the interface described
# in the POD.
sub _load {
    my ($class, $args) = @_;
    my ($files_ref, $filter_cb, $use_ext, $force_plugins_ref) = 
        @{$args}{qw(files filter use_ext force_plugins)};
    croak "_load requires a arrayref of file paths" unless defined $files_ref;

	my %files           = _maphash @$files_ref;
    my %force_plugins   = _maphash @$force_plugins_ref;
    my $enforcing       = keys %force_plugins ? 1 : 0;

    my $final_configs       = [];
    my $originally_loaded   = {};

    # perform a separate file loop for each loader
    for my $loader ( $class->plugins ) {
        next if $enforcing && not defined $force_plugins{$loader};
		last unless keys %files;
        my %ext = _maphash $loader->extensions;

        FILE:
        for my $filename (keys %files) {
            # use file extension to decide whether this loader should try this file
            # use_ext => 1 hits this block
            if (defined $use_ext && !$enforcing) {
				my $matched_ext = 0;
                EXT:
                for my $e (keys %ext) {
                    next EXT  unless $filename =~ m{ \. $e \z }xms; 
                    next FILE unless exists $ext{$e};
					$matched_ext = 1;
                }

				next FILE unless $matched_ext;
            }

            my $config;
			eval {
				$config = $loader->load( $filename );
			};

			next if $EVAL_ERROR; # if it croaked or warned, we can't use it
            next if !$config;
			delete $files{$filename};

            # post-process config with a filter callback, if we got one
            $filter_cb->( $config ) if defined $filter_cb;

            push @$final_configs, { $filename => $config };
        }
    }
    $final_configs;
}

=head2 finder( )

The C<finder()> classmethod returns the 
L<Module::Pluggable::Object|Module::Pluggable::Object>
object which is used to load the plugins. See the documentation for that module for
more information.

=cut

sub finder {
    my $class = shift;
    my $finder = Module::Pluggable::Object->new(
        search_path => [ __PACKAGE__ ],
        require     => 1
    );
    $finder;
}

=head2 plugins( )

The C<plugins()> classmethod returns the names of configuration loading plugins as 
found by L<Module::Pluggable::Object|Module::Pluggable::Object>.

=cut

sub plugins {
    my $class = shift;
    return $class->finder->plugins;
}

=head2 extensions( )

The C<extensions()> classmethod returns the possible file extensions which can be loaded
by C<load_stems()> and C<load_files()>. This may be useful if you set the C<use_ext>
parameter to those methods.

=cut

sub extensions {
    my $class = shift;
    my @ext = map { $_->extensions } $class->plugins;
	return wantarray ? @ext : [@ext];
}

=head1 DIAGNOSTICS

=over

=item C<no files specified> or C<no stems specified>

The C<load_files()> and C<load_stems()> methods will issue this warning if
called with an empty list of files/stems to load.

=item C<_load requires a arrayref of file paths>

This fatal error will be thrown by the internal C<_load> method. It should not occur
but is specified here for completeness. If your code dies with this error, please
email a failing test case to the authors below.

=back

=head1 CONFIGURATION AND ENVIRONMENT

Config::Any requires no configuration files or environment variables.

=head1 DEPENDENCIES

L<Module::Pluggable|Module::Pluggable>

And at least one of the following:
L<Config::General|Config::General>
L<Config::Tiny|Config::Tiny>
L<JSON|JSON>
L<YAML|YAML>
L<JSON::Syck|JSON::Syck>
L<YAML::Syck|YAML::Syck>
L<XML::Simple|XML::Simple>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-config-any@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Joel Bernstein  C<< <rataxis@cpan.org> >>

=head1 CONTRIBUTORS

This module was based on the original 
L<Catalyst::Plugin::ConfigLoader|Catalyst::Plugin::ConfigLoader>
module by Brian Cassidy C<< <bricas@cpan.org> >>.

With ideas and support from Matt S Trout C<< <mst@shadowcatsystems.co.uk> >>.

Further enhancements suggested by Evan Kaufman C<< <evank@cpan.org> >>.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2006, Portugal Telecom C<< http://www.sapo.pt/ >>. All rights reserved.
Portions copyright 2007, Joel Bernstein C<< <rataxis@cpan.org> >>.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=head1 SEE ALSO

L<Catalyst::Plugin::ConfigLoader|Catalyst::Plugin::ConfigLoader> 
-- now a wrapper around this module.

=cut

"Drink more beer";
