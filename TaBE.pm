# $File: //member/autrijus/Lingua-ZH-TaBE/TaBE.pm $ $Author: autrijus $
# $Revision: #5 $ $Change: 3607 $ $DateTime: 2003/01/18 14:59:26 $

package Lingua::ZH::TaBE;
$VERSION = '0.01';

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);
@EXPORT_OK = qw(
    TsiDBOpen
    TsiInfoLookupPossibleTsiYin
    TsiYinDBOpen
    ChuInfoToChunkInfo
    ChunkSegmentationSimplex
    ChunkSegmentationComplex
    ChunkSegmentationBackward
    TsiInfoLookupZhiYin
    YinLookupZhiList
    YinToZuYinSymbolSequence
    ZuYinSymbolSequenceToYin
    ZuYinIndexToZuYinSymbol
    ZuYinSymbolToZuYinIndex
    ZozyKeyToZuYinIndex
    ZhiIsBig5Code
    ZhiToZhiCode
    ZhiCodeToZhi
    ZhiCodeToPackedBig5Code
    ZhiCodeLookupRefCount
    DB_TYPE_DB
    DB_TYPE_LAST
    DB_FLAG_OVERWRITE
    DB_FLAG_CREATEDB
    DB_FLAG_READONLY
    DB_FLAG_NOSYNC
    DB_FLAG_SHARED
    DB_FLAG_NOUNPACK_YIN
);
$VERSION = '0.01';

require '_h2ph_pre.ph';

unless(defined(&__TABE_H__)) {
    eval 'sub __TABE_H__ () {1;}' unless defined(&__TABE_H__);
    if(defined(&__cplusplus)) {
    }
    eval("sub DB_TYPE_DB () { 0; }") unless defined(&DB_TYPE_DB);
    eval("sub DB_TYPE_LAST () { 1; }") unless defined(&DB_TYPE_LAST);
    eval 'sub DB_FLAG_OVERWRITE () {0x01;}' unless defined(&DB_FLAG_OVERWRITE);
    eval 'sub DB_FLAG_CREATEDB () {0x02;}' unless defined(&DB_FLAG_CREATEDB);
    eval 'sub DB_FLAG_READONLY () {0x04;}' unless defined(&DB_FLAG_READONLY);
    eval 'sub DB_FLAG_NOSYNC () {0x08;}' unless defined(&DB_FLAG_NOSYNC);
    eval 'sub DB_FLAG_SHARED () {0x10;}' unless defined(&DB_FLAG_SHARED);
    eval 'sub DB_FLAG_NOUNPACK_YIN () {0x20;}' unless defined(&DB_FLAG_NOUNPACK_YIN);
    unless(defined(&TRUE)) {
	eval 'sub TRUE () {1;}' unless defined(&TRUE);
	eval 'sub FALSE () {0;}' unless defined(&FALSE);
    }
    if(defined(&__cplusplus)) {
    }
}

bootstrap Lingua::ZH::TaBE $VERSION;

my %cache;

sub new {
    my ($class, %args) = @_;
    $args{tsi_db} ||= '/usr/local/share/tabe/tsiyin/tsi.db',
    # $args{tsiyin_db} ||= '/usr/local/share/tabe/tsiyin/yin.db',

    my $self = {};

    $self->{tsi_db} = (
	$cache{join($;, %args)} ||= Lingua::ZH::TaBE::TsiDB->new(
	    Lingua::ZH::TaBE::DB_TYPE_DB(),
	    $args{tsi_db},
	    Lingua::ZH::TaBE::DB_FLAG_READONLY() |
	    Lingua::ZH::TaBE::DB_FLAG_SHARED(),
	)
    ) if -e $args{tsi_db};

    $self->{tsiyin_db} = (
	$cache{join($;, %args)} ||= Lingua::ZH::TaBE::TsiYinDB->new(
	    Lingua::ZH::TaBE::DB_TYPE_DB(),
	    $args{tsiyin_db},
	    Lingua::ZH::TaBE::DB_FLAG_READONLY() |
	    Lingua::ZH::TaBE::DB_FLAG_SHARED(),
	)
    ) if -e $args{tsiyin_db};

    return bless($self, $class);
}

sub split {
    map $_->tsi,
    map $_->tsis,
    shift->Chu($_[0])->chunks;
}

sub Chu {
    my $class = shift;
    return Lingua::ZH::TaBE::Chu->new(
	join('，', $_[-1] =~ m/((?:[\xa1-\xf9][\x40-\x7e\xa1-\xfe])+)/g)
    );
}

sub Chunk {
    my $class = shift;
    return Lingua::ZH::TaBE::Chunk->new(
	join('', $_[-1] =~ m/((?:[\xa1-\xf9][\x40-\x7e\xa1-\xfe])+)/g)
    );
}

sub Tsi {
    my $class = shift;
    return Lingua::ZH::TaBE::Tsi->new(
	$_[0] =~ m/((?:[\xa1-\xf9][\x40-\x7e\xa1-\xfe])+)/
    );
}

sub Zhi {
    my $class = shift;
    return Lingua::ZH::TaBE::Zhi->new(
	$_[0] =~ /^\d+$/
	    ? Lingua::ZH::TaBE::ZhiCodeToZhi($_[0])
	    : $_[0] =~ m/((?:[\xa1-\xf9][\x40-\x7e\xa1-\xfe]))/
    );
}

sub Yin {
    my $class = shift;
    return Lingua::ZH::TaBE::Yin->new(
	$_[0] =~ /^\d+$/
	    ? $_[0]
	    : Lingua::ZH::TaBE::ZuYinSymbolSequenceToYin($_[0])
    );
}

sub ZuYin {
    my $class = shift;
    return Lingua::ZH::TaBE::ZuYin->new(
	$_[0] =~ /^\d+$/
	    ? $_[0]
	    : Lingua::ZH::TaBE::ZuYinSymbolToZuYinIndex($_[0])
    );
}

sub ZozyKey {
    my $class = shift;
    return Lingua::ZH::TaBE::ZuYin->new(
	ZozyKeyToZuYinIndex($_[0])
    );
}

package Lingua::ZH::TaBE::Chu;
use overload '""' => sub { shift->chu }, fallback => 1;

sub chunks {
    my $chu = shift;
    $chu->ToChunkInfo if $chu->num_chunk <= 0;
    return unless defined wantarray;
    wantarray ? $chu->chunk : [ $chu->chunk ];
}

package Lingua::ZH::TaBE::Chunk;
use overload '""' => sub { shift->chunk }, fallback => 1;

my %methods = (
    s  => 'SegmentationSimplex',
    c  => 'SegmentationComplex',
    b  => 'SegmentationBackward',
);

sub tsis {
    my $chunk = shift;
    $chunk->Segmentation if $chunk->num_tsi <= 0;
    return unless defined wantarray;
    wantarray ? $chunk->tsi : [ $chunk->tsi ];
}

sub Segmentation {
    my $chunk = shift;

    if ($chunk->chunk =~ /^[\xa4-\xf9]/) {
	my $method = shift || 's';

	my $func = $methods{lc(substr($method, 0, 1))}
	    or die "Unknown segmentation method: $method";

	$chunk->$func(@_);
    }
}

package Lingua::ZH::TaBE::Tsi;
use overload '""' => sub { shift->tsi }, fallback => 1;

sub zhis {
    my $tsi = shift;
    return unless defined wantarray;
    wantarray ? (
	map Lingua::ZH::TaBE->Zhi($_),
	$tsi->tsi =~ m/([\xa1-\xf9][\x40-\x7e\xa1-\xfe])/g
    ) : [
	map Lingua::ZH::TaBE->Zhi($_),
	$tsi->tsi =~ m/([\xa1-\xf9][\x40-\x7e\xa1-\xfe])/g
    ];
}

sub yins {
    my $tsi = shift;
    $tsi->LookupPossibleTsiYin(@_) unless $tsi->yinnum;
    return unless defined wantarray;
    wantarray ? $tsi->yindata : [ $tsi->yindata ];
};

package Lingua::ZH::TaBE::Zhi;
use overload '0+' => sub { shift->ToZhiCode },
	     '""' => sub { shift->zhi },
	     fallback => 1;

sub yins {
    my $tsi = Lingua::ZH::TaBE->Tsi(shift->zhi);
    $tsi->LookupZhiYin(@_);
    return unless defined wantarray;
    wantarray ? $tsi->yindata : [ $tsi->yindata ];
}

sub zhi { ${+shift} }
sub new {
    bless(\$_[1], $_[0]);
}

sub IsBig5Code {
    Lingua::ZH::TaBE::ZhiIsBig5Code(shift->zhi)
}
sub ToZhiCode {
    Lingua::ZH::TaBE::ZhiToZhiCode(shift->zhi)
}
sub ToZhi {
    shift->zhi
}
sub ToPackedBig5Code {
    Lingua::ZH::TaBE::ZhiCodeToPackedBig5Code(shift->ToZhiCode)
}
sub LookupRefCount {
    Lingua::ZH::TaBE::ZhiCodeLookupRefCount(shift->ToZhiCode)
}

package Lingua::ZH::TaBE::Yin;
use overload '0+' => sub { shift->yin },
	     '""' => sub { shift->ToZuYinSymbolSequence },
	     fallback => 1;

sub yin { ${+shift} }
sub ToZuYinSymbolSequence { 
    Lingua::ZH::TaBE::YinToZuYinSymbolSequence(shift->yin)
}
sub new { bless(\$_[1], $_[0]) }
sub zuyins {
    return unless defined wantarray;
    wantarray ? (
	map Lingua::ZH::TaBE->ZuYin($_),
	shift->ToZuYinSymbolSequence =~ m/([\xa1-\xf9][\x40-\x7e\xa1-\xfe])/g
    ) : [
	map Lingua::ZH::TaBE->ZuYin($_),
	shift->ToZuYinSymbolSequence =~ m/([\xa1-\xf9][\x40-\x7e\xa1-\xfe])/g
    ];
}

sub zhis {
    return unless defined wantarray;
    wantarray ? (
	map Lingua::ZH::TaBE->Zhi($_),
	shift->LookupZhiList =~ m/([\xa1-\xf9][\x40-\x7e\xa1-\xfe])/g
    ) : [
	map Lingua::ZH::TaBE->Zhi($_),
	shift->LookupZhiList =~ m/([\xa1-\xf9][\x40-\x7e\xa1-\xfe])/g
    ];
}
sub LookupZhiList {
    return Lingua::ZH::TaBE::YinLookupZhiList(shift->yin);
}
sub ToYin {
    shift->yin
}

package Lingua::ZH::TaBE::ZuYin;
use overload '0+' => sub { shift->zuyin },
	     '""' => sub { shift->zhi },
	     fallback => 1;

sub zuyin { ${+shift} }
sub yin {
    Lingua::ZH::TaBE->Yin(
	shift->ToZuYinSymbol->zhi
    );
}
sub new {
    bless(\$_[1], $_[0]);
}

sub zhi {
    Lingua::ZH::TaBE->Zhi(
	Lingua::ZH::TaBE::ZuYinIndexToZuYinSymbol(shift->zuyin)
    );
}

sub ToZuYinSymbol {
    shift->zhi
}
sub ToZuYinIndex {
    shift->zuyin
}

1;

__END__

=head1 NAME

Lingua::ZH::TaBE - Chinese processing via libtabe

=head1 SYNOPSIS

    use Lingua::ZH::TaBE;

    my $tabe = Lingua::ZH::TaBE->new(
	tsi_db => '/usr/local/share/tabe/tsiyin/tsi.db'
    );

    # Phrase splitter
    my @words = $tabe->split(
	"當我們在電腦中處理中文資訊時，相信其中最惱人的".
	"狀況之一，莫過於想打的字打不出來了。"
    );

    # Chaining various components
    print $tabe->Chu("道可道，非常道。")    # sentence
	->chunks->[2]	    # 非常道	    # chunk
	->tsis->[0]	    # 非常	    # phrase
	->zhis->[1]	    # 常	    # character
	->yins->[0]	    # ㄔㄤˊ	    # pronounciation
	->zuyins->[0],	    # ㄔ	    # phonetic symbols

=head1 DESCRIPTION

This module is a Perl interface to the B<TaBE> (Taiwan and Big5 Encoding)
library, an unified interface and library dealing with Chinese words,
phrases, sentences, and phonetic symbols; it is intended to be used as the
foundation of Chinese text processing.

B<Lingua::ZH::TaBE> provides an object-oriented interface (preferred),
as well as a procedural interface consisting of all C functions in C<tabe.h>.

=head1 Object-Oriented Interface

=head2 Lingua::ZH::TaBE

=head3 new( tsi_db => $file )

Creates a LibTaBE handle and opens databases.

=head3 split( $string [, $method] )

Split the text in C<$string>; returns a list of strings representing
the words obtained.  You may specify C<Complex> or C<Backward> as
C<$method> to use an alternate segmentation algorithm.

=head3 Chu(), Chunk(), Tsi(), Zhi(), Yin(), ZuYin()

Constructors for various level of objects, each taking one argument
for initialization.

=head2 Lingua::ZH::TaBE::Chu

=head3 chunks()

=head2 Lingua::ZH::TaBE::Chunk

=head3 tsis([$method])

=head2 Lingua::ZH::TaBE::Tsi

=head3 zhis()

=head3 yins()

=head2 Lingua::ZH::TaBE::Zhi

=head3 yins()

=head3 ToZhi()

=head3 ToZhiCode()

=head3 IsBig5Code()

=head3 ToPackedBig5Code()

=head3 LookupRefCount()

=head2 Lingua::ZH::TaBE::Yin

=head3 zuyins()

=head3 zhis()

=head3 ToYin()

=head3 ToZuYinSymbolSequence()

=head2 Lingua::ZH::TaBE::ZuYin

=head3 yin()

=head3 zhi()

=head1 Procedural Interface

  struct TsiDB       *TsiDBOpen(int type, const char *db_name, int flags);
  int                 TsiInfoLookupPossibleTsiYin(struct TsiDB *tsidb,
                                                    struct TsiInfo *tsi);
  struct TsiYinDB    *TsiYinDBOpen(int type, const char *db_name,
				     int flags);
  int                 ChuInfoToChunkInfo(struct ChuInfo *chu);
  int                 ChunkSegmentationSimplex(struct TsiDB *tsidb,
						 struct ChunkInfo *chunk);
  int                 ChunkSegmentationComplex(struct TsiDB *tsidb,
						 struct ChunkInfo *chunk);
  int                 ChunkSegmentationBackward(struct TsiDB *tsidb,
						  struct ChunkInfo *chunk);
  int                 TsiInfoLookupZhiYin(struct TsiDB *tsidb,
                                            struct TsiInfo *z);
  ZhiStr              YinLookupZhiList(Yin yin);
  ZuYinSymbolSequence YinToZuYinSymbolSequence(Yin yin);
  Yin                 ZuYinSymbolSequenceToYin(ZuYinSymbolSequence str);
  const Zhi           ZuYinIndexToZuYinSymbol(ZuYinIndex idx);
  ZuYinIndex          ZuYinSymbolToZuYinIndex(ZuYinSymbol sym);
  ZuYinIndex          ZozyKeyToZuYinIndex(int key);
  int                 ZhiIsBig5Code(Zhi zhi);
  ZhiCode             ZhiToZhiCode(Zhi zhi);
  Zhi                 ZhiCodeToZhi(ZhiCode code);
  int                 ZhiCodeToPackedBig5Code(ZhiCode code);
  unsigned long int   ZhiCodeLookupRefCount(ZhiCode code);

=head1 CAVEATS

The B<TsiYin> family of fucntions is yet imcomplete.

=head1 SEE ALSO

L<ftp://xcin.linux.org.tw/pub/xcin/libtabe/devel/>

L<http://libtabe.sourceforge.net/>

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2003 by Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
