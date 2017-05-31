#!/usr/bin/env perl
use Mojolicious::Lite;
use Mojo::Util qw/md5_sum/;
use Data::Dumper;
use DBI;
#use File::Basename 'basename';
#use File::Path 'mkpath';
use Mojo::Upload;

## 画像を保存するディレクトリがなければ作る
my $image_base = '/image';
my $image_dir = app->home->rel_file('/public') . $image_base;
unless (-d $image_dir) {
  mkpath $image_dir or die "cannot create dirctory: $image_dir";
}
my $path = '/home/image';
mkdir $path;
chmod 0777, $path;



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
  my $c = shift;
  my $dbh = DBI->connect('dbi:Pg:dbname=chat',"yu","pass");
  my $name = $c->param('name');

  ## 入力したpassをハッシュ化する
  my $pass = md5_sum $c->param('pass');

  my $sth = $dbh->prepare("select id,name,icon from users where name = ? and pass = ?");
  $sth->execute($name, $pass); 
 
  my $href = $sth->fetchrow_hashref;
#  print Dumper $href;

  ## データの保存
  $c->session($href);

  # KEY が存在するなら /list へ遷移する
  if (exists($href->{id})){  
  $c->redirect_to('/list');
  }else{
  $c->redirect_to('/');
  }
};


#-----------------------------------------------------------------------

get '/user' => sub {
  my $c = shift;
  my $dbh = DBI->connect('dbi:Pg:dbname=chat',"yu","pass"); 
  $c->render('user');  
};

#-----------------------------------------------------------------------

post '/user' => sub {
  my $c = shift;
  my $dbh = DBI->connect('dbi:Pg:dbname=chat',"yu","pass"); 
  my $name = $c->param('name');
  my $icon = $c->param('icon');

  ## 入力したpassをハッシュ化する
  my $pass = md5_sum $c->param('pass');
  
  ## users の table に新しいuserを追加
  my $sth = $dbh->prepare(
  "
    insert into users (name, pass, icon, create_timestamp)
    values(?, ?, ?, now())
  "
  );
  $sth->execute($name, $pass, $icon);
  
#  my $filename = $c->tx->req->upload('icon')->filename;
#  $c->tx->req->upload('icon')->move_to($path. $filename);

#  my $image file_get_contents($icon);
#  file_put_contents($path,$image); 

#  push @{$c->static->paths}, $c->upload_dir;
#  my $r = $c->routes;

# https://github.com/yuki-kimoto/mojolicious-guides-japanese/wiki/Mojo::Upload
#  my $upload = Mojo::Upload->new;
#  print Dumper $upload->filename;
#  $upload->move_to("/home/sri/");

  
  $c->redirect_to('/');
  
};
#-----------------------------------------------------------------------


## This page is display chat list
get '/list' => sub {
  my $c = shift;
  my $dbh = DBI->connect('dbi:Pg:dbname=chat',"yu","pass");

  my $sth = $dbh->prepare("select room from list");
  $sth->execute;
  my @list = ();
  while ( my $href = $sth->fetchrow_hashref) {
    push @list, $href;
  }
  print Dumper @list;

  ## 保存したデータの取得
  my $user = $c->session('name');
  print Dumper $user;

  
  $c->stash(list => \@list);
  $c->stash(user => $user);
  $c->render('list');
};

#-----------------------------------------------------------------------

## post for index page
post '/list' => sub {
  my $c = shift;
  my $dbh = DBI->connect('dbi:Pg:dbname=chat',"yu","pass");
  my $room = $c->param('room');

  if($room ne ''){
    my $sth = $dbh->prepare(
    "
      insert into list (room, create_timestamp) 
      values (?, now()) 
    ");
  $sth->execute($room);
  }else{
  };

    $c->redirect_to('/list');
  
};


#-----------------------------------------------------------------------

## chat room 
get '/:room' => sub {
  my $c = shift;
  my $dbh = DBI->connect('dbi:Pg:dbname=chat',"yu","pass");

  my $room = $c->param('room');
  ## 保存したデータを取り出す
  my $user = $c->session('name');
  my $icon = $c->session('icon');
 
  ## Take out massage for database
  my $sth = $dbh->prepare("select * from msg ");

  $sth->execute;

  ## store massage (use fetch)
  my @msg = ();
  while ( my $href = $sth->fetchrow_hashref) {
    unshift @msg, $href;
  }
  print Dumper @msg;
  
  $c->stash(user => $user); 
  $c->stash(room => $room);
  $c->stash(icon => $icon);
  $c->stash(msg => \@msg);
  #$c->stash(room => $name);
  $c->render('chat');
};

#-----------------------------------------------------------------------

## post for chat room
post '/:room' => sub {
  my $c = shift;
  my $dbh = DBI->connect('dbi:Pg:dbname=chat',"yu","pass");
  my $name = $c->param('name');
  my $user = $c->session('name');
  my $msg = $c->param('msg');
  my @msg;
  my $room = $c->param('room');
 
  ## massageが入力されてない時にinsertを行わないようにする
  if ($msg ne '' ){
  my $sth = $dbh->prepare(
  "
  insert into msg (name, msg, create_timestamp) values(?, ?, now());
  "
  );

  $sth->execute($user, $msg);
  }else{};

  $c->redirect_to("/$room");
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

%# ここを form_for "/list" にするとpostが実行されない
%# ページ遷移は post のredirect_to で行う
%= form_for "/" => method => 'POST' => begin  
  <font size = "4"><%= 'name:' %>
  %= text_field 'name'
  <br>
  <font size = "4"><%= 'pass:' %>
  %= text_field 'pass'
  %= submit_button 'login'
<Hr>
% end
<%= link_to 'create new user' => '/user' %> 
</center>

%#-----------------------------------------------------------------------

@@user.html.ep
% layout 'default';
% title 'create user page';

<h1><center>Create user page</center></h1>
<p align = "right"><%= link_to 'return' => '/' %></p>
<Hr>
%= form_for "/user" => method => 'POST' => begin
  <center>
  %= 'icon:'
  %= file_field 'icon'
  <br>
  %= 'name:'
  %= text_field 'name'
  <br>
  %= 'pass:'
  %= text_field 'pass'
  %= submit_button 'create'
  </center>
<Hr>
% end


%#-----------------------------------------------------------------------


@@ list.html.ep
% layout 'default';
% title 'list page';
<h1><center>Chat List</center></h1>
  Hey
  <font color = "blue"><%= $user %></font>,
  <br>
  Let's choose kind of chat
  <div align = "right">
    <%= link_to 'return' => '/' %>
  </div>
%= form_for "/list" => method => 'POST' => begin
  <center>
    %= 'new room:'
    %= text_field 'room'
    %= submit_button 'create'
  </center>
% end
  <Hr>

% for my $list (@{$list}) {
  <a href="/<%= $list->{room}%>"><%= $list->{room} %> 
  <br>
% }
<Hr>
  

%#-----------------------------------------------------------------------


@@ chat.html.ep
% layout 'default';
% title 'chat room';
<h1><center><%= $room %></center></h1>
<p align = "right"><a href="#smoothplay">bottom</a></p>

<p align = "right"><%= link_to 'return' => '/list' %></p>

%= form_for "/$room" => method => 'POST' => begin
  <center>
    %= 'msg:'
    %= text_field 'msg'
    %= submit_button 'done'
  </center>
% end
<Hr>

%# 入力した内容を表示させる
<div class="length">
% my $count;
% for my $msgs (@{$msg}) {
  % $count ++;
  %# name がUなら右に書く
  % if ($msgs->{name} eq $user){
    <p align = "right">
      <br style="Line-Height:3pt">
      <font size="2">
      <%= $msgs->{name} %>
      <%= $icon %>
    </p>
      <br style="Line-Height:3pt">
        <div style="border:1px solid #0CF;padding:10px;border-radius:10px;" >
          <font size="5">
          <p align = "right"><%= $msgs->{msg} %></p>
        </div>
  % }else{
    <br style="Line-Height:3pt"><font size="2"><%= $msgs->{name} %>
    <br style="Line-Height:3pt"><div style="border:1px solid #0CF;padding:10px;border-radius:10px;" ><font size="5"><%= $msgs->{msg} %></div>
  % }
% }
<div id="smoothplay"></div>
</div>
%#-----------------------------------------------------------------------

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
