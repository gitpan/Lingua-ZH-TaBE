# $File: //member/autrijus/Lingua-ZH-TaBE/Makefile.PL $ $Author: autrijus $
# $Revision: #2 $ $Change: 3607 $ $DateTime: 2003/01/18 14:59:26 $

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
    LIBS		=> ["-ltabe -l$db"],
    DEFINE		=> '',
    INC			=> '',
);

1;
