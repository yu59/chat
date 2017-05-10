#!/usr/bin/env perl
use Mojolicious::Lite;
use DBI;
use Data::Dumper;


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


## fetch をつかってselectで取り出したデータを格納
  while(my $href = $sth->fetchrow_hashref){
#    if({addres_field}="sage"){
#    push @datas,$href;
#    }else{
    unshift @datas,$href;
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
    -- case 
    -- select count(*) from thread_table
    --  when id <= '10' then
      
      insert into
      thread_table (name_field,address_field,body,create_timestamp)
      values( ?, ?, ?, now())
      
   -- else null end
  "
  );  

  $sth->execute($name_field,$address_field,$body);

  $sth = $dbh->prepare(
  "
    delete from thread_table where id > 1000 
  "
  );  
  $sth->execute();


## select でデータを取り出す
  $sth = $dbh->prepare(
  "
    select * from thread_table order by body desc 
  "
  );
  $sth->execute();
 
  my @datas=();

## fetch をつかってselectで取り出したデータを配列に格納
  
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
  
%# thread 名とtext_field を作成
  <h1>First Thread</h1> 
  %= form_for '/post' => method => 'POST' => begin
    %= "name : "
    %= text_field 'name_field' 
    <br>
    %= 'mail address  :'
    %= text_field 'address_field'
    <br>    
    %= 'text:'
    %= text_field 'body'
    %= submit_button '投稿する'
% end
  
  <Hr>

%# 入力した内容を表示させる 
% for my $data (@{$datas}) {
    <nobr><font size="5"><%= $data->{id}%></font></nobr>
    &nbsp; 
    <nobr><%="name:".$data->{name_field} %></nobr> 
    <p><font size = "5"><%= $data->{body} %></font></p> 
    <p><font size="2"><%= $data->{create_timestamp} %></font></p> 
    <Hr>
%}


@@ post.html.ep
% layout 'default';
% title 'Output';
  <h1>First Thread</h1> 
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
