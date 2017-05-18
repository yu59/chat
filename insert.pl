#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite;
use DBI;
use Data::Dumper;



get '/error' => sub{
  my $c = shift;
  $c->render('error');
};

###################################################

##top画面を作成
get '/' => sub{
  my @threads=();
  my $dbh = DBI->connect('dbi:Pg:dbname=bbs',"yu","pass");
  my $comment = shift;

## select でデータを取り出す
  my $sth = $dbh->prepare(
  "
    select * from thread_list order by update_timestamp desc
  "
  );

  $sth->execute;
#  $sth->finish;
## fetch をつかってselectで取り出したデータを格納
  while(my $href = $sth->fetchrow_hashref){
    push @threads,$href;
  };

  $comment->stash(threads => \@threads); #配列のリファンレンスをテンプレートに渡す
  $comment->render('index');
};  

###################################################

#topのpostを作成
post '/post' =>sub{
  my $c = shift;
  my $q = shift;
  my $thread_field = $c->param('thread_field');

  my $dbh = DBI->connect('dbi:Pg:dbname=bbs',"yu","pass");

## thread_listに作ったthreadをinsert
  my $sth = $dbh->prepare(
  "
    insert into
    thread_list (thread_name, create_timestamp)
    values(?,now())
  "
  );  
  $sth->execute($thread_field);

## select でデータを取り出す
  $sth = $dbh->prepare("select * from thread_list");
  $sth->execute;
  
  my @threads=();
  
## fetch をつかってselectで取り出したデータを配列に格納
  while(my $href = $sth-> fetchrow_hashref){
    push @threads,$href;
  };
  print Dumper @threads;
  $c->redirect_to('/');
};

###################################################

get "/:name" => sub { 
my $dbh = DBI->connect('dbi:Pg:dbname=bbs',"yu","pass");
  my $c= shift;
  my $name = $c->param('name');

  ## select でデータを取り出す
  my $sth = $dbh->prepare("select * from thread_table where thread_name = ?");

  $sth->execute($name); 
  my @datas=();

  ## fetch をつかってselectで取り出したデータを格納
  while(my $href = $sth->fetchrow_hashref){
     push  @datas,$href;
  }
print Dumper @datas;

  $c->stash(datas => \@datas); #配列のリファンレンスをテンプレートに渡す
  $c->stash(thread_name => $name);
  $c->render('thread_page'); 
     
};

###################################################

post "/:name" => sub { 
  my $c= shift;
  my $name_field = $c->param('name_field');
  my $address_field = $c->param('address_field');
  my $body = $c->param('body');
  my $thread_name = $c->param('thread_name');
  my $name = $c->param('name');
  my @datas;
  my $dbh = DBI->connect('dbi:Pg:dbname=bbs',"yu","pass");


  ## threadのレコード数を調べる
  my $sth = $dbh->prepare(
  "
    select count(thread_name) from thread_table
    where (thread_name = ?)
  "
  );
  $sth->execute($name);

  while(my $href = $sth->fetchrow_hashref){
     push  @datas,$href;
  }
  my $count = $datas[0]->{count};
  print Dumper $count;
    
my $max_count = 1000;
  if ($count > $max_count) {
   #$c->redirect_to('/error');
   $c->stash(max_count => $max_count);
   $c->render(template => 'error');
   return;
  }else{
     ## thread_tableにレコードを追加
    $sth = $dbh->prepare(<<"SQL");
insert into
thread_table 
(name_field,address_field,body,create_timestamp,thread_name)
values(?, ?, ?, now(), ?)
SQL

    $sth->execute($name_field,$address_field,$body,$name);

    if ($address_field ne "sage"){
    $sth = $dbh->prepare(
    "
      update thread_list set update_timestamp = now() 
      where thread_name = ?
    "
    );
    $sth->execute($name);
    }
    $c->redirect_to("/$name"); 
 
  }
};



###################################################

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Input';
<h1><center>Thread List</center></h1>

  %= form_for '/post'=>method=>'POST'=>begin 
  <center>
    %= text_field 'thread_field'
    %= submit_button 'create Thread' 
  </center>
  %end

  <Hr>
  %for my $thread (@{$threads}){
    <br><font size="6"><a href="/<%= $thread->{thread_name}%>"><%= $thread->{thread_name}%></font></br>
  %}
  <Hr>
  
%###################################################

%#postを作成
@@ post.html.ep
% layout 'default';
% title 'Output';
    %= form_for '/post' => method => 'POST' => begin
% end

%###################################################

@@ thread_page.html.ep
% layout 'default';
% title 'Input';
<a href="/"><font size = "5">Thread List</font></a>  


%# thread 名とtext_field を作成
  <h1><%= $thread_name %></h1> 
  %= form_for "/$thread_name" => method => 'POST' => begin
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
% my $count;
% for my $data (@{$datas}) {
      % $count ++;
      <nobr><font size="5"><%= $count %></font></nobr>
      &nbsp; 
      <nobr><%="name:".$data->{name_field} %></nobr> 
      <p><font size = "5"><%= $data->{body} %></font></p> 
      <p><font size="2"><%= $data->{create_timestamp} %></font></p> 
      <Hr>
%}


%###################################################

%#thread_postを作成
@@ thread_post.html.ep
% layout 'default';
% title 'Output';
  <h1>First Thread</h1> 
    %= form_for '/thread_post' => method => 'POST' => begin
% end

%###################################################

@@ error.html.ep
% layout 'default';
% title 'Input';
  <h1>Records is Full, please create new Thread</h1>

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
