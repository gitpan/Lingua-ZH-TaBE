#!/usr/bin/perl
use Test;

BEGIN { plan tests => 14 }

require Lingua::ZH::TaBE;
ok($Lingua::ZH::TaBE::VERSION) if $Lingua::ZH::TaBE::VERSION or 1;

my $tabe = Lingua::ZH::TaBE->new;

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
        ->chunks->[2]       # �D�`�D
        ->tsis->[0]         # �D�`
        ->zhis->[1]         # �`
        ->yins->[0]         # ������
        ->zuyins->[0],      # ��
    "��",
    'tsis->zhis',
);


# �۰��_��
my @words = $tabe->split(
    "��ڭ̦b�q�����B�z�����T��,�۫H�䤤�̴o�H�����p���@,".
    "���L��Q�����r�����X�ӤF."
);

ok(
    join(",", @words),
    "��,�ڭ�,�b,�q��,��,�B�z,����,��T,��,�۫H,�䤤,��,�o�H,��,���p,���@,���L��,�Q��,��,�r,��,���X��,�F",
    'split($string)'
);

# �����_��
@words = $tabe->split(
    "��ڭ̦b�q�����B�z�����T��,�۫H�䤤�̴o�H�����p���@,".
    "���L��Q�����r�����X�ӤF.", "Complex"
);

ok(
    join(",", @words),
    "��,�ڭ�,�b,�q��,��,�B�z,����,��T,��,�۫H,�䤤,��,�o�H,��,���p,���@,���L��,�Q��,��,�r,��,���X,�ӤF",
    'split($string, "Complex")'
);

# �f�V�_��
@words = $tabe->split(
    "��ڭ̦b�q�����B�z�����T��,�۫H�䤤�̴o�H�����p���@,".
    "���L��Q�����r�����X�ӤF.", "Backward"
);

ok(
    join(",", @words),
    "��,�ڭ�,�b,�q,����,�B�z,����,��T,��,�۫H,�䤤,��,�o�H,��,���p,���@,���L��,�Q,����,�r,��,���X,�ӤF",
    'split($string, "Backward")'
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
