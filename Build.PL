use Module::Build;

# See https://rt.cpan.org/Ticket/Display.html?id=4681 for why we add
# this to the Makefile.PL:
my $class = Module::Build->subclass(code => <<'EOF');
  sub do_create_makefile_pl {
    my $self = shift;
    my $fh = IO::File->new('> Makefile.PL') or die $!;
    print $fh "\nBEGIN { \@INC = grep {!/blib/} \@INC }\n\n";
    $self->SUPER::do_create_makefile_pl(fh => $fh);
  }
EOF

my $build = $class->new
  (
   module_name => 'Cwd',
   dist_version_from => 'Cwd.pm',
   license => 'perl',
   installdirs => 'core',
#   create_makefile_pl => 'traditional',
   requires       => {
		      'XSLoader' => 0,
		      'Carp' => 0,
		      'File::Spec' => 0,
		     },
   build_requires => {
		      'File::Path' => 0,
		      'Test::More' => 0,
		      'Scalar::Util' => 0,
		      'Module::Build' => '0.19',
		     },
   xs_files       => { 'Cwd.xs' => 'lib/Cwd.xs' },
   pm_files       => { 'Cwd.pm' => 'lib/Cwd.pm' },
   sign => 1,
  );

$build->create_build_script;
