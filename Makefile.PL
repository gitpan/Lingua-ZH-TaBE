# $File: //member/autrijus/Lingua-ZH-TaBE/Makefile.PL $ $Author: autrijus $
# $Revision: #9 $ $Change: 3647 $ $DateTime: 2003/01/19 14:24:23 $

use 5.005;
use ExtUtils::MakeMaker;

print << '.';
This modules needs libtabe version 0.2.5 or above installed; please
install it from ftp://xcin.linux.org.tw/pub/xcin/libtabe/devel/ before
running Makefile.PL.

.

my $db = 'db3';
if ($ARGV[0] =~ /^DB=(.+)/) {
    $db = $1;
    shift @ARGV;
}
else {
    print << '.';
Type "perl Makefile.PL DB=db2" if you want use DB2 (or DB4),
Otherwise, TaBE.pm will be linked with DB3.

.
}

WriteMakefile(
    AUTHOR		=> 'Autrijus Tang (autrijus@autrijus.org)',
    ABSTRACT		=> 'Chinese processing via libtabe',
    NAME		=> 'Lingua::ZH::TaBE',
    VERSION_FROM	=> 'TaBE.pm',
    LIBS		=> [ "-L/usr/local/lib -L/usr/lib -L/usr/X11R6/lib -L/usr/local/lib/tabe -L/usr/local/tabe/lib -L/usr/local/db/BerkeleyDB/lib -L/usr/local/lib/$db -ltabe -l$db" ],
    DEFINE		=> '',
    INC			=> '-I/usr/local/include/tabe -I/usr/local/tabe/include',
);

1;
