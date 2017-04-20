#!/usr/bin/env perl
use Mojolicious::Lite;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';

my @entries = ();
get '/' => sub {
  my $c = shift;
  $c->stash(entries => \@entries); #配列
  $c->render('index');
};

post '/post' => sub {
  my $c = shift;
  my $entry = $c->param('body');
  push @entries, $entry; #配列に格納
  #$c->stash(entry => $entry);
  $c->redirect_to('/');
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Input';  
  <h1>Chat</h1> 
  %= form_for '/post' => method => 'POST' => begin
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
