use strict;
use warnings;
use Text::MeCab;

my $m = Text::MeCab->new();
my $str_utf = "今日も明日も";
my $n = $m->parse($str_utf);
do{
  printf("%s\t%s\t%d\n",
    $n->surface,
    $n->feature,
    $n->cost
    );
}while($n = $n->next);
