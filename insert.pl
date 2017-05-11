#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite;
use DBI;
use Data::Dumper;



## thread_listを$threadに格納
my @threads=();
my $dbh = DBI->connect('dbi:Pg:dbname=bbs',"yu","1109yt");
my $comment = shift;

## select でデータを取り出す
our $sth = $dbh->prepare(
  "
    select * from thread_list
  "
);  
$sth->execute;
  
## fetch をつかってselectで取り出したデータを格納
while(my $href = $sth->fetchrow_hashref){
  unshift @threads,$href;
};
my $thread = \@threads;
print Dumper $thread;


##top画面を作成
get '/' => sub{
  my @threads=();
  my $dbh = DBI->connect('dbi:Pg:dbname=bbs',"yu","1109yt");
  my $comment = shift;

## select でデータを取り出す
  our $sth = $dbh->prepare(
  "
    select * from thread_list
  "
  );  
  $sth->execute;
  
## fetch をつかってselectで取り出したデータを格納
  while(my $href = $sth->fetchrow_hashref){
    unshift @threads,$href;
  };

  $comment->stash(threads => \@threads); #配列のリファンレンスをテンプレートに渡す
  $comment->render('index');
};  


#topのpostを作成
post '/post' =>sub{
  my $comment = shift;
  my $q = shift;
  my $thread_field = $comment->param('thread_field');
  $comment->redirect_to('/');

## 新しいthreadのtableを作成
  my $dbh = DBI->connect('dbi:Pg:dbname=bbs',"yu","1109yt");
  my $table_name_lit = $dbh->quote_identifier($thread_field);
  my $sth = $dbh->prepare(
  "
    create table $table_name_lit (id serial, name_field text, address_field text, body text, create_timestamp timestamp)
  "
  );  
  #$sth =~ s/'//g;
  $sth->execute;

 
## thread_listに作ったthreadをinsert
  $sth = $dbh->prepare(
  "
    insert into
    thread_list (thread_name, create_timestamp)
    values(?,now())
  "
  );  
  $sth->execute($thread_field);
  


## select でデータを取り出す
  $sth = $dbh->prepare(
  "
    select * from thread_list
  "
  );
  $sth->execute;
  
  my @threads=();
  
## fetch をつかってselectで取り出したデータを配列に格納
  while(my $href = $sth-> fetchrow_hashref){
    push @threads,$href;
  };
  print Dumper @threads;
};

## thread画面を作成
# thread_listを取り出す

## select でデータを取り出す
$sth = $dbh->prepare(
"
  select * from thread_list
"
);
$sth->execute;
while(my $href = $sth->fetchrow_hashref){
  my $name = $href->{thread_name};
  get "/$name" => sub { 
    my $dbh = DBI->connect('dbi:Pg:dbname=bbs',"yu","1109yt");
    my $comment = shift;

    ## select でデータを取り出す
    my $sth = $dbh->prepare("select * from $name");

    $sth->execute; 
    my @datas=();

    ## fetch をつかってselectで取り出したデータを格納
    while(my $href = $sth->fetchrow_hashref){
      # if({addres_field}="sage"){
      # push @datas,$href;
      # }else{
      unshift @datas,$href;
    }

    $comment->stash(datas => \@datas); #配列のリファンレンスをテンプレートに渡す
    $comment->stash(thread_name => $name);
    $comment->render('thread_page'); 
       
  };
  
  post "/$name" => sub { 
    my $comment = shift;
    my $name_field = $comment->param('name_field');
    my $address_field = $comment->param('address_field');
    my $body = $comment->param('body');
    $comment->redirect_to("/$thread");
  
    my $dbh = DBI->connect('dbi:Pg:dbname=bbs',"yu","1109yt");
    my $sth = $dbh->prepare(<<"SQL");
insert into
$name (name_field,address_field,body,create_timestamp)
values( ?, ?, ?, now())
SQL
  
    $sth->execute($name_field,$address_field,$body);
  
    # Thread数1000以上を削除
    $sth = $dbh->prepare("delete from $name where id > 1000");  
    $sth->execute();
    $sth->finish; 
  
    ## select でデータを取り出す
    $sth = $dbh->prepare("select * from $name");
    $sth->execute();
   
    my @datas=();
  
  ## fetch をつかってselectで取り出したデータを配列に格納
    
    while(my $href = $sth->fetchrow_hashref){
      push @datas,$href;
    }
    print Dumper \@datas;
  };
}




app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Input';
<h1><center>Thread List</center></h1>
  %for my $thread (@{$threads}){
    <br><font size="6"><a href="/<%= $thread->{thread_name}%>"><%= $thread->{thread_name}%></font></br>
  %}

  <Hr>
  %= form_for '/post'=>method=>'POST'=>begin 
  <center>
    %= text_field 'thread_field'
    %= submit_button 'create Thread' 
  </center>
  %end
  

%#postを作成
@@ post.html.ep
% layout 'default';
% title 'Output';
    %= form_for '/post' => method => 'POST' => begin
% end


@@ thread_page.html.ep
% layout 'default';
% title 'Input';
<a href="/"><font size = "5">Thread List</font></a>  


%# thread 名とtext_field を作成
  <h1><%= $thread_name %></h1> 
  %= form_for '/thread_post' => method => 'POST' => begin
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


%#thread_postを作成
@@ thread_post.html.ep
% layout 'default';
% title 'Output';
  <h1>First Thread</h1> 
    %= form_for '/thread_post' => method => 'POST' => begin
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
