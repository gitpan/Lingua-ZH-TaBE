#!/usr/bin/perl
# $File: //member/autrijus/Lingua-ZH-TaBE/t/1-basic.t $ $Author: autrijus $
# $Revision: #4 $ $Change: 3607 $ $DateTime: 2003/01/18 14:59:26 $

use blib;
use Test::More qw(no_plan);

BEGIN { use_ok( 'Lingua::ZH::TaBE' ) }

my $tabe = Lingua::ZH::TaBE->new(
    tsidb => '/usr/local/share/tabe/tsiyin/tsi.db'
);

isa_ok($tabe, 'Lingua::ZH::TaBE');

my $tsi = $tabe->Tsi("車");

is( "$tsi", "車", 'Tsi stringification' );

is(
    join(',', $tsi->yins),
    "ㄔㄜ,ㄐㄩ",
    'PossibleTsiYin()',
);

is(
    $tsi->yins->[0] * 1,
    8216,
    'yins() overload',
);

my $chu = $tabe->Chu("蜀道之難，難於上青天。");
is(
    join(",", $chu->chunks),
    "蜀道之難,，,難於上青天,。",
    'PossibleTsiYin()',
);

my $chunk = $chu->chunks->[0];
is(
    join(",", $chunk->tsis),
    "蜀道,之,難",
    'Segmentation',
);

is(
    $tabe->Chu("道可道，非常道。")
	->chunks->[2]	    # 非常道
	->tsis->[0]	    # 非常
	->zhis->[1]	    # 常
	->yins->[0]	    # ㄔㄤˊ
	->zuyins->[0],	    # ㄔ
    "ㄔ",
    'tsis->zhis',
);


my @words = $tabe->split(
    "當我們在電腦中處理中文資訊時,相信其中最惱人的狀況之一,".
    "莫過於想打的字打不出來了."
);

# 自動斷詞
is(
    join(",", @words),
    "當,我們,在,電腦,中,處理,中文,資訊,時,相信,其中,最,惱人,的,狀況,之一,莫過於,想打,的,字,打,不出來,了",
    "split()"
);

# 可用數字或文字建立 Zhi 物件
is(
    $tabe->Zhi(42056),
    $tabe->Zhi('人'),
    "Zhi() dualvar"
);

# 找 "漢" 的同音字
is(
    join(",", $tabe->Zhi('漢')->yins->[0]->zhis),
    "和,漢,汗,旱,焊,憾,翰,撼,悍,頷,扞,瀚,閈,捍,暵,熯,晥,犴,睅,菡,豻,銲,釬,駻,哻,涆,淊,馯,蜭,頜,螒,顄,雗,攌,譀,鋎,鶾",
    "Zhi->yins->zhis()"
);

is(
    $tabe->ZuYin('ㄕ')->zhi->yins->[0]->zhis->[0],
    '失',
    "Yin->zhis"
);

1;
