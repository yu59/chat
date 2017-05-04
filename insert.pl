#!/usr/bin/env perl
use Mojolicious::Lite;
use DBI;
use Data::Dumper;

#my @entries = ();
my @names =();
my @name_field = ();
my $thread_id = 5;
my $dbi;

# top画面を作成
get '/' => sub {

my $dbh = DBI->connect('dbi:Pg:dbname=bbs',"yu","1109yt");
  my $comment = shift;




## select でデータを取り出す
our $sth = $dbh->prepare(
"
  select * from thread_table
"
);

$sth->execute;

my @datas=();
## fetch をつかってselectで取り出したデータを出力
while(my $href = $sth->fetchrow_hashref){
    push @datas,$href;
};

  $comment->stash(datas => \@datas); #配列のリファンレンスをテンプレートに渡す
  $comment->render('index');



};


# localhost/post を作成
post '/post' => sub {
  my $comment = shift;
  my $data    = $comment->param('body');
  
  my $name_field = $comment->param('name_field');
  my $address_field = $comment->param('address_field');
  my $body = $comment->param('body');
 $comment->redirect_to('/');

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
 $sth = $dbh->prepare(
"
  select * from thread_table
"
);
$sth->execute();


my @datas=();
## fetch をつかってselectで取り出したデータを出力
while(my $href = $sth->fetchrow_hashref){
    push @datas,$href;
};


print Dumper \@datas;

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
    %= 'addr  :'
    %= text_field 'address_field'
    <br>    
    %= 'comm:'
    %= text_field 'body'
    %= submit_button '投稿する'
% end
% # 配列を用いている　ここをPostgreSQLに保存するように変更する
 
% for my $data (@{$datas}) {
    <p><%= "name:".$data->{name_field} %></p> 
    <p><%= "addr:".$data->{address_field} %></p> 
    <p><%= "comm:".$data->{body} %></p> 
%}

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
