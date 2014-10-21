#!/usr/bin/perl
# $File: //member/autrijus/Lingua-ZH-TaBE/t/1-basic.t $ $Author: autrijus $
# $Revision: #9 $ $Change: 3645 $ $DateTime: 2003/01/19 14:15:31 $

use Test;

BEGIN { plan tests => 12 }

require Lingua::ZH::TaBE;
ok($Lingua::ZH::TaBE::VERSION) if $Lingua::ZH::TaBE::VERSION or 1;

my $tabe = Lingua::ZH::TaBE->new(
    tsidb => '/usr/local/share/tabe/tsiyin/tsi.db'
);

ok(ref($tabe), 'Lingua::ZH::TaBE', 'blessing TaBE object');

my $tsi = $tabe->Tsi("��");

ok( "$tsi", "��", 'Tsi stringification' );

ok(
    join(',', $tsi->yins),
    "����,����",
    'PossibleTsiYin()',
);

ok(
    $tsi->yins->[0] * 1,
    8216,
    'yins() overload',
);

my $chu = $tabe->Chu("���D�����A����W�C�ѡC");
ok(
    join(",", $chu->chunks),
    "���D����,�A,����W�C��,�C",
    'PossibleTsiYin()',
);

my $chunk = $chu->chunks->[0];
ok(
    join(",", $chunk->tsis),
    "���D,��,��",
    'Segmentation',
);

ok(
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
ok(
    join(",", @words),
    "��,�ڭ�,�b,�q��,��,�B�z,����,��T,��,�۫H,�䤤,��,�o�H,��,���p,���@,���L��,�Q��,��,�r,��,���X��,�F",
    "split()"
);

# �i�μƦr�Τ�r�إ� Zhi ����
ok(
    $tabe->Zhi(42056),
    $tabe->Zhi('�H'),
    "Zhi() dualvar"
);

# �� "�~" ���P���r
ok(
    join(",", $tabe->Zhi('�~')->yins->[0]->zhis),
    "�M,�~,��,��,�k,��,��,��,��,�X,��,�v,�F,��,��,�c,թ,�C,ھ,�r,��,�Z,��,�_,�A,�T,��,��,��,�g,�_,�F,�p,�F,��,�u,��",
    "Zhi->yins->zhis()"
);

ok(
    $tabe->ZuYin('��')->zhi->yins->[0]->zhis->[0],
    '��',
    "Yin->zhis"
);

1;
