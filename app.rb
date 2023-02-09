require 'bundler'
Bundler.require

enable :sessions

client = PG::connect(
  :host => "localhost",
  :user => ENV.fetch("USER", ""), :password => "", #whoamiの結果を追加する
  :dbname => "", #作成したデータベースの名前を追加する
)

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

  client.exec_params("INSERT INTO users (name, email, password) VALUES ($1, $2, $3)", [name, email, password])

  user = client.exec_params("SELECT * from users WHERE email = $1 AND password = $2", [email, password]).to_a.first

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
  user = client.exec_params("SELECT * FROM users WHERE email = '#{email}' AND password = '#{password}'").to_a.first
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
  @posts = client.exec_params("SELECT * FROM posts ORDER BY id DESC;")
  erb :posts
end

post '/posts' do
  content = params[:content]

  client.exec_params("INSERT INTO posts (name, user_id, content) VALUES ($1, $2, $3)", [session[:user]["name"], session[:user]["id"].to_i, content])
  return redirect '/posts'
end