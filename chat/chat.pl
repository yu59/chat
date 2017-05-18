#!/usr/bin/env perl
use Mojolicious::Lite;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';

#-----------------------------------------------------------------------

get '/' => sub {
  my $c = shift;
  $c->render(template => 'index');
};

#-----------------------------------------------------------------------

post '/post' => sub {
  my $c = shift;
  $c->render(template => 'post');
};


#-----------------------------------------------------------------------


get '/chat' => sub {
  my $c = shift;
  $c->render(template => 'chat');
};

#-----------------------------------------------------------------------

post '/chat_post' => sub {
  my $c = shift;
  $c->render(template => 'chat_post');
};

#-----------------------------------------------------------------------


app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<h1><center>Chat List</center></h1>
Let's choose kind of chat
<Hr>
<%= link_to 'First Chat' => '/chat' %>

%#-----------------------------------------------------------------------

@@ post.html.ep
% layout 'default';
% title 'post to index page';


%#-----------------------------------------------------------------------


@@ chat.html.ep
% layout 'default';
% title 'chat room';
<h1><center>This Page is Chat Room</center></h1>

%#-----------------------------------------------------------------------

@@ chat_post.html.ep
% layout 'default';
% title 'post to chat page';


%#-----------------------------------------------------------------------


@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
