require 'bundler'
Bundler.require

require 'sinatra/reloader'

enable :sessions

client = SQLite3::Database.new("app.db", results_as_hash: true)

# トップページ
get '/' do
  erb :top
end

# 新規登録
get '/signup' do
  if session[:user]
    return redirect '/'
  end
  erb :signup
end

post "/signup" do
  name = params[:name]
  email = params[:email]
  password = params[:password]

  client.execute("INSERT INTO users (name, email, password) VALUES ($1, $2, $3)", [name, email, password])

  user = client.execute("SELECT * from users WHERE email = $1 AND password = $2", [email, password]).to_a.first

  session[:user] = user

  return redirect "/"
end

# ログイン
get '/signin' do
  return redirect '/' if session[:user]
  erb :signin
end

post "/signin" do
  email = params[:email]
  password = params[:password]

  user = client.execute("SELECT * FROM users WHERE email = $1 AND password = $2", [email, password]).to_a.first

  if user.nil?
    return erb :signin
  else
    session[:user] = user

    return redirect "/"
  end
end

# ログアウト
delete "/signout" do
  session[:user] = nil

  return redirect "/"
end

# 投稿
get '/posts' do
  unless session[:user]
    return redirect '/signin'
  end
  @posts = client.execute("SELECT * FROM posts inner join users user on user.id = posts.user_id order by created_at DESC;")
  erb :posts
end

post '/posts' do
  content = params[:content]

  client.execute("INSERT INTO posts (content, user_id) VALUES ($1, $2)", [content, session[:user]["id"].to_i])
  return redirect '/posts'
end