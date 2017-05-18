use strict;
use warnings;

use Data::Dumper;
use Algorithm::NaiveBayes; 

my $nb = Algorithm::NaiveBayes->new;

#与えるデータ
$nb->add_instance(attributes => +{
    dog => 5,
    run => 3,
    outside => 1
  },
  label => 'dog'
);

$nb->add_instance(attributes => +{
    cat => 5,
    Bohemian => 3, 
    house => 1
  },
  label => 'cat'
);

$nb->train;

#予測
my $msg = "I like play outside";
my $data = +{ map { $_ => 1 } split /\s/, $msg };
my $result = $nb->predict(attributes => $data);

print Dumper $result; 

$msg = "I like play inside";
$data = +{ map { $_ => 1 } split /\s/, $msg };
$result = $nb->predict(attributes => $data);
print Dumper $result; 
