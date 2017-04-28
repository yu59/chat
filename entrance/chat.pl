#!/usr/bin/env perl
use Mojolicious::Lite;
use DBI;
use Data::Dumper;

my @entries = ();
my @names =();
my @name_field = ();
my $thread_id = 5;
my @data=();

# top画面を作成
get '/' => sub {
  my $c = shift;
  $c->stash(entries => \@entries); #配列
  $c->render('index');

my $dbh = DBI->connect('dbi:Pg:dbname=bbs',"yu","1109yt");



## select でデータを取り出す
our $sql = $dbh->prepare(
"
  select * from thread_table
"
);
$sql->execute();

## fetch をつかってselectで取り出したデータを出力
while($dbh = $sql->fetchrow_hashref){
    print $sql;
};

};


# localhost/post を作成
post '/post' => sub {
  my $c = shift;
  my $entry = $c->param('body');
  my $data = $c->param('body');
  my $params = $c->req->params->to_hash;
  say $c->dumper($params);
  my $name_field = $c->param('name_field');
  my $address_field = $c->param('address_field');
  my $body = $c->param('body');
  unshift @entries, $entry; #配列に格納
  $c->redirect_to('/');

my $dbh = DBI->connect('dbi:Pg:dbname=bbs',"yu","1109yt");
my $sth = $dbh->prepare(
"
insert into 
  thread_table (name_field,address_field,body,create_timestamp)
  values( ?, ?, ?, now())
"
);  

$sth->execute($name_field,$address_field,$body);



## select でデータを取り出す
my $sql = $dbh->prepare(
"
  select * from thread_table
"
);
$sql->execute();

## fetch をつかってselectで取り出したデータを出力
while($dbh = $sql->fetchrow_hashref){
    print $sql;
};

#print Dumper \@data;
#print Dumper \@entries;

}; 




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
    %= text_field 'address_field'
    <br>    
    %= 'comment:'
    %= text_field 'body'
    %= submit_button '投稿する'
% end
% # 配列を用いている　ここをPostgreSQLに保存するように変更する
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
    %= text_field 'address_field'
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


@@ not_found.development.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
