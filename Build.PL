use Module::Build;

my $build = Module::Build->new
  (
   module_name => 'Cwd',
   dist_version_from => 'Cwd.pm',
   license => 'perl',
   installdirs => 'core',
   create_makefile_pl => 'traditional',
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
  );

$build->create_build_script;
