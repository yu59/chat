#!/usr/bin/env perl
use Mojolicious::Lite;
use DBI;
use Data::Dumper;


#top画面を作成
get '/' => sub{
  my $self = shift;
  $self->render(template=> 'index');
};

# thread画面を作成
get '/thread_page' => sub {

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
  $comment->render('thread_page');
};


# localhost/post を作成
post '/post' => sub {
  my $comment = shift;
  my $data    = $comment->param('body');
  my $name_field = $comment->param('name_field');
  my $address_field = $comment->param('address_field');
  my $body = $comment->param('body');
  $comment->redirect_to('/thread_page');

  my $dbh = DBI->connect('dbi:Pg:dbname=bbs',"yu","1109yt");
  my $sth = $dbh->prepare(
  "
      insert into
      thread_table (name_field,address_field,body,create_timestamp)
      values( ?, ?, ?, now())
  "
  );  

  $sth->execute($name_field,$address_field,$body);

# Thread数1000以上を削除
  $sth = $dbh->prepare(
  "
    delete from thread_table where id > 1000 
  "
  );  
  $sth->execute();


## select でデータを取り出す
  $sth = $dbh->prepare(
  "
    select * from thread_table  
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
<h1><center>Thread List</center></h1>
<br><a href="/thread_page"><font size="5">First Thread</font></a>  </br>
  <Hr>
  <center><%= submit_button 'create Thread' %><center>


@@ thread_page.html.ep
% layout 'default';
% title 'Input';
<a href="/">top</a>  
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
