# $File: //member/autrijus/Lingua-ZH-TaBE/Makefile.PL $ $Author: autrijus $
# $Revision: #4 $ $Change: 3613 $ $DateTime: 2003/01/18 16:03:19 $

use ExtUtils::MakeMaker;

print << '.';
This modules needs libtabe version 0.2.3 or above installed; please
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
    LIBS		=> "-ltabe -l$db -L/usr/local/lib/tabe -L/usr/local/tabe/lib -L/usr/local/db/BerkeleyDB/lib -L/usr/local/lib/$db",
    DEFINE		=> '',
    INC			=> '-I/usr/local/include/tabe -I/usr/local/tabe/include',
    PREREQ_PM		=> {
	'Test::More'	=> '0.01',
    },
);

1;
