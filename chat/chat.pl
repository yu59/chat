#!/usr/bin/env perl
use Mojolicious::Lite;
use Data::Dumper;
use DBI;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';


#-----------------------------------------------------------------------

## login page
get '/' => sub { 
  my $c = shift;
  
  $c->render('index');
};

#-----------------------------------------------------------------------

## post for login page
post '/' => sub {
  my $dbh = DBI->connect('dbi:Pg:dbname=chat',"yu","pass");
  my $c = shift;
  my $name = $c->param('name');
  my $sth = $dbh->prepare(
  "
    insert into users 
    (name, create_timestamp) 
    values(?, now())
  ");
  $sth->execute($name);

  $c->redirect_to('/');
};


#-----------------------------------------------------------------------


## This page is display chat list
get '/list' => sub {
  my $c = shift;
  
  $c->render('list');
};

#-----------------------------------------------------------------------

## post for index page
post '/list' => sub {
  my $c = shift;
  $c->redirect_to('/list');
};


#-----------------------------------------------------------------------

## chat room 
get '/chat' => sub {
  my $dbh = DBI->connect('dbi:Pg:dbname=chat',"yu","pass");
  my $c = shift;
  #my $name = $c->param('name');

  ## Take out massage for database
  my $sth = $dbh->prepare("select * from msg ");

  $sth->execute;

  ## store massage (use fetch)
  my @msg = ();
  while ( my $href = $sth->fetchrow_hashref) {
    push @msg, $href;
  }
print Dumper @msg;

  $c->stash(msg => \@msg);
  #$c->stash(room => $name);
  $c->render('chat');
};

#-----------------------------------------------------------------------

## post for chat room
post '/chat' => sub {
  my $dbh = DBI->connect('dbi:Pg:dbname=chat',"yu","pass");
  my $c = shift;
  my $name = $c->param('name');
  my $msg = $c->param('msg');
  my @msg;

  my $sth = $dbh->prepare(
  "
  insert into msg (name, msg, create_timestamp) values(?, ?, now());
  "
  );

  $sth->execute($name, $msg);

  $c->redirect_to('/chat');
};

#-----------------------------------------------------------------------


app->start;
__DATA__

@@index.html.ep
% layout 'default';
% title 'login page';
<h1><center>Login page</center><h1>
<Hr>
<center><font size = "3">Please input user ID and icon</font>
%= form_for "/list" => method => 'POST' => begin
  <font size = "4"><%= 'name:' %>
  %= text_field 'name'
  %= submit_button 'login'
  </center>
<Hr>
% end


%#-----------------------------------------------------------------------


@@ list.html.ep
% layout 'default';
% title 'list page';
<h1><center>Chat List</center></h1>
Let's choose kind of chat
<div align = "right"><%= link_to 'return' => '/' %></div>
<Hr>
<%= link_to 'First Chat' => '/chat' %>


%#-----------------------------------------------------------------------


@@ chat.html.ep
% layout 'default';
% title 'chat room';
<h1><center>This Page is Chat Room</center></h1>
%= form_for "/chat" => method => 'POST' => begin
  %= 'name:'
  %= text_field 'name'
  <br>
  %= 'msg:'
  %= text_field 'msg'
  %= submit_button 'done'
  <div align = "right"><%= link_to 'return' => '/list' %></div>
% end
<Hr>

%# 入力した内容を表示させる
% my $count;
% for my $msgs (@{$msg}) {
  % $count ++;
  <br style="Line-Height:3pt"><font size="2"><%= $msgs->{name} %>
  <br style="Line-Height:3pt"><div style="border:1px solid #0CF;padding:10px;border-radius:10px;" ><font size="5"><%= $msgs->{msg} %></div>
% }


%#-----------------------------------------------------------------------


