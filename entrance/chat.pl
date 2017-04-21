#!/usr/bin/env perl
use Mojolicious::Lite;
use DBI;
#use DATA::DUMPER;
# $c = DBI->connect("dbi:Pg:dbname=$dbname", "", "");

# our $DB_NAME = "postgres";
#my $c = DBI->connect("dbi:Pg:dbname=$DB_NAME) or die "$!\n Error: failed to connect to DB.\n";
# my $sth = $c->prepare("SELECT now();");
# $sth->execute();

#my $c = DBI->connect('dbi:Pg:dbname=finance;host=db.example.com','user','xyzzy',{AutoCommit=>1,RaiseError=>1,PrintError=>0});
#print "2+2=",$c->selectrow_array("SELECT 2+2"),"\n";

## Documentation browser under "/perldoc"
plugin 'PODRenderer';

my @entries = ();
my @names =();
get '/' => sub {
  our $c = shift;
  my $d = shift;

#  $dbh->do('INSERT INTO test_table(a) VALUES (1)');

 
#  my $dbh = DBI->connect("dbi:Pg:c=$c", "postgres", "1109yt");
#  my $sth = $dbh->prepare("SELECT * from pg_tables");      
#  $sth->execute();
##while (my $ary_ref = $sth->fetchrow_arrayref) {
##  my ($row) = @$ary_ref;
##  print $row , "\n";
##}
  
 # $sth = $dbh->prepare('INSERT INTO test_table(a) VALUES (?)');
 # $sth->execute();

#$sth->finish;
#$dbh->disconnect;

  $c->stash(entries => \@entries); #配列
 # $d->stash(names => \@names);
  $c->render('index');
 # $d->render('index');
};

post '/post' => sub {
  my $c = shift;
  #my $d = shift;
  my $entry = $c->param('body');
  #my $name = $d->('name_field');
  #if 
  unshift @entries, $entry; #配列に格納
  #unshift @names, $name;
  ##$c->stash(entry => $entry);
  $c->redirect_to('/');
  #$d->redirect_to('/');
};


#$dbh->disconnect;

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Input';  
  <h1>Chat</h1> 
  %= form_for '/post' => method => 'POST' => begin
    %= "name : "
    %= text_field 'name_field' 
    <br>
    %= 'address  :'
    %= text_field 'body'
    <br>    
    %= 'comment:'
    %= text_field 'body'
    %= submit_button '投稿する'
% end
% # 配列を用いている　ここをPostgreSQLに保存するように変更する
% #for my $name (@{$names}) {
%  #  <p><%= $name %></p>
% # }
% for my $entry (@{$entries}) {
    <p><%= $entry %></p>
% }



@@ post.html.ep
% layout 'default';
% title 'Output';
  <h1>Chat</h1> 
    %= form_for '/post' => method => 'POST' => begin
    %= "name : "
    %= text_field 'name_field' 
    %= 'address  :'
    %= text_field 'body'
    %= 'comment'
    %= text_field 'body'
    %= submit_button '投稿する'  
% end
<p><%= $entry %></p>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
