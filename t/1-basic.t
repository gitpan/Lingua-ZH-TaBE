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

my $tsi = $tabe->Tsi("��");

is( "$tsi", "��", 'Tsi stringification' );

is(
    join(',', $tsi->yins),
    "����,����",
    'PossibleTsiYin()',
);

is(
    $tsi->yins->[0] * 1,
    8216,
    'yins() overload',
);

my $chu = $tabe->Chu("���D�����A����W�C�ѡC");
is(
    join(",", $chu->chunks),
    "���D����,�A,����W�C��,�C",
    'PossibleTsiYin()',
);

my $chunk = $chu->chunks->[0];
is(
    join(",", $chunk->tsis),
    "���D,��,��",
    'Segmentation',
);

is(
    $tabe->Chu("�D�i�D�A�D�`�D�C")
	->chunks->[2]	    # �D�`�D
	->tsis->[0]	    # �D�`
	->zhis->[1]	    # �`
	->yins->[0]	    # ������
	->zuyins->[0],	    # ��
    "��",
    'tsis->zhis',
);


my @words = $tabe->split(
    "��ڭ̦b�q�����B�z�����T��,�۫H�䤤�̴o�H�����p���@,".
    "���L��Q�����r�����X�ӤF."
);

# �۰��_��
is(
    join(",", @words),
    "��,�ڭ�,�b,�q��,��,�B�z,����,��T,��,�۫H,�䤤,��,�o�H,��,���p,���@,���L��,�Q��,��,�r,��,���X��,�F",
    "split()"
);

# �i�μƦr�Τ�r�إ� Zhi ����
is(
    $tabe->Zhi(42056),
    $tabe->Zhi('�H'),
    "Zhi() dualvar"
);

# �� "�~" ���P���r
is(
    join(",", $tabe->Zhi('�~')->yins->[0]->zhis),
    "�M,�~,��,��,�k,��,��,��,��,�X,��,�v,�F,��,��,�c,թ,�C,ھ,�r,��,�Z,��,�_,�A,�T,��,��,��,�g,�_,�F,�p,�F,��,�u,��",
    "Zhi->yins->zhis()"
);

is(
    $tabe->ZuYin('��')->zhi->yins->[0]->zhis->[0],
    '��',
    "Yin->zhis"
);

1;
