# $File: //member/autrijus/Lingua-ZH-TaBE/Makefile.PL $ $Author: autrijus $
# $Revision: #12 $ $Change: 9666 $ $DateTime: 2004/01/11 12:36:44 $

use 5.005;
use Cwd;
use ExtUtils::MakeMaker;

my @libs = grep defined, qw(
    /usr/local/lib
    /usr/lib
    /usr/X11R6/lib
    /usr/local/lib/tabe
    /usr/local/tabe/lib
    /usr/local/db/BerkeleyDB/lib
    /opt/local/lib
    /sw/local/lib
), Cwd::cwd(), $ENV{TABE_LIB};

die << '.' unless grep {<$_/tabe.*> or <$_/libtabe.*>} @libs;
This modules needs libtabe version 0.2.5 or above installed; please
install it from ftp://xcin.linux.org.tw/pub/xcin/libtabe/devel/ before
running Makefile.PL.

If you have installed LibTaBE but it is not under the current path,
try setting the TABE_LIB environment variable. 

.

my $db = 'db3';
if ($ARGV[0] =~ /^DB=(.+)/) {
    $db = $1;
    shift @ARGV;
}
else {
    print << '.';
Type "perl Makefile.PL DB=db2" if you want use DB2 (or DB=db4 for DB4),
Otherwise, TaBE.pm will be linked with DB3.

.
}

my $incs = join(" -I", @libs);
$incs =~ s!/lib\b!/include!g;

WriteMakefile(
    AUTHOR		=> 'Autrijus Tang <autrijus@autrijus.org>',
    ABSTRACT		=> 'Chinese processing via libtabe',
    NAME		=> 'Lingua::ZH::TaBE',
    VERSION_FROM	=> 'lib/Lingua/ZH/TaBE.pm',
    LIBS		=> [ join(' ', map("-L$_", @libs)) . " -ltabe -l$db" ],
    DEFINE		=> '',
    INC			=> $incs,
);

1;
