#!perl

# For some odd reason, PERL_DL_NONLAZY=1 causes problems.
BEGIN { $ENV{PERL_DL_NONLAZY} = 0 }

use Config;
use Cwd;
use strict;
use warnings;

print "1..14\n";

# check imports
print +(defined(&cwd) && 
	defined(&getcwd) &&
	defined(&fastcwd) &&
	defined(&fastgetcwd) ?
        "" : "not "), "ok 1\n";
print +(!defined(&chdir) &&
	!defined(&abs_path) &&
	!defined(&fast_abs_path) ?
	"" : "not "), "ok 2\n";

# XXX force Cwd to bootsrap its XSUBs since we have set @INC = "../lib"
# XXX and subsequent chdir()s can make them impossible to find
eval { fastcwd };

# Must find an external pwd (or equivalent) command.

my $pwd_cmd =
    ($^O eq "MSWin32" || $^O eq "NetWare") ? "cd" : (grep { -x && -f } map { "$_/pwd" }
			       split m/$Config{path_sep}/, $ENV{PATH})[0];

if ($^O eq 'VMS') { $pwd_cmd = 'SHOW DEFAULT'; }

if (defined $pwd_cmd) {
    chomp(my $start = `$pwd_cmd`);
    # Win32's cd returns native C:\ style
    $start =~ s,\\,/,g if ($^O eq 'MSWin32' || $^O eq "NetWare");
    # DCL SHOW DEFAULT has leading spaces
    $start =~ s/^\s+// if $^O eq 'VMS';
    if ($?) {
	for (3..6) {
	    print "ok $_ # Skip: '$pwd_cmd' failed\n";
	}
    } else {
	my $cwd        = cwd;
	my $getcwd     = getcwd;
	my $fastcwd    = fastcwd;
	my $fastgetcwd = fastgetcwd;
	print +($cwd        eq $start ? "" : "not "), "ok 3\n";
	print +($getcwd     eq $start ? "" : "not "), "ok 4\n";
	print +($fastcwd    eq $start ? "" : "not "), "ok 5\n";
	print +($fastgetcwd eq $start ? "" : "not "), "ok 6\n";
    }
} else {
    for (3..6) {
	print "ok $_ # Skip: no pwd command found\n";
    }
}

mkdir "pteerslt", 0777;
mkdir "pteerslt/path", 0777;
mkdir "pteerslt/path/to", 0777;
mkdir "pteerslt/path/to/a", 0777;
mkdir "pteerslt/path/to/a/dir", 0777;
Cwd::chdir "pteerslt/path/to/a/dir";
my $cwd        = cwd;
my $getcwd     = getcwd;
my $fastcwd    = fastcwd;
my $fastgetcwd = fastgetcwd;
my $want = "pteerslt/path/to/a/dir";
print "# cwd        = '$cwd'\n";
print "# getcwd     = '$getcwd'\n";
print "# fastcwd    = '$fastcwd'\n";
print "# fastgetcwd = '$fastgetcwd'\n";
# This checked out OK on ODS-2 and ODS-5:
$want = "PTEERSLT\.PATH\.TO\.A\.DIR\]" if $^O eq 'VMS';
print +($cwd        =~ m|$want$| ? "" : "not "), "ok 7\n";
print +($getcwd     =~ m|$want$| ? "" : "not "), "ok 8\n";
print +($fastcwd    =~ m|$want$| ? "" : "not "), "ok 9\n";
print +($fastgetcwd =~ m|$want$| ? "" : "not "), "ok 10\n";

# Cwd::chdir should also update $ENV{PWD}
print "#$ENV{PWD}\n";
print +($ENV{PWD} =~ m|$want$| ? "" : "not "), "ok 11\n";
Cwd::chdir ".."; rmdir "dir";
print "#$ENV{PWD}\n";
Cwd::chdir ".."; rmdir "a";
print "#$ENV{PWD}\n";
Cwd::chdir ".."; rmdir "to";
print "#$ENV{PWD}\n";
Cwd::chdir ".."; rmdir "path";
print "#$ENV{PWD}\n";
if ($^O eq 'VMS') {
    # This checked out OK on ODS-2 and ODS-5:
    print +($ENV{PWD}  =~ m|\bPTEERSLT\]$| ? "" : "not "), "ok 12\n";
}
else {
    print +($ENV{PWD}  =~ m|\bpteerslt$| ? "" : "not "), "ok 12\n";
}
Cwd::chdir ".."; rmdir "pteerslt";
print "#$ENV{PWD}\n";


if ($Config{d_symlink}) {
    mkdir "pteerslt", 0777;
    mkdir "pteerslt/path", 0777;
    mkdir "pteerslt/path/to", 0777;
    mkdir "pteerslt/path/to/a", 0777;
    mkdir "pteerslt/path/to/a/dir", 0777;
    symlink "pteerslt/path/to/a/dir" => "linktest";

    my $abs_path      =  Cwd::abs_path("linktest");
    my $fast_abs_path =  Cwd::fast_abs_path("linktest");
    my $want          = "pteerslt/path/to/a/dir";

    print "# abs_path      $abs_path\n";
    print "# fast_abs_path $fast_abs_path\n";
    print "# want          $want\n";
    print +($abs_path      =~ m|$want$| ? "" : "not "), "ok 13\n";
    print +($fast_abs_path =~ m|$want$| ? "" : "not "), "ok 14\n";

    rmdir "pteerslt/path/to/a/dir";
    rmdir "pteerslt/path/to/a";
    rmdir "pteerslt/path/to";
    rmdir "pteerslt/path";
    rmdir "pteerslt";
    unlink "linktest";
} else {
    print "ok 13 # skipped\n";
    print "ok 14 # skipped\n";
}