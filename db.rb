require "sqlite3"

# データベースをオープンする
db = SQLite3::Database.new("app.db", results_as_hash: true)

# テーブルを作成する (Rubyのヒアドキュメント構文)
db.execute <<-SQL
  create table users (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name varchar(50) NOT NULL,
    email varchar(50) NOT NULL ,
    password varchar(50) NOT NULL 
  );
SQL

db.execute <<-SQL
  create table posts (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    content varchar(50) NOT NULL,
    created_at TIMESTAMP DEFAULT(DATETIME('now','localtime')),
    user_id INTEGER NOT NULL
  );
SQL

# データを用意する
users = [
  { name: "太郎", email: "tarou@example.com", password: "password" },
  { name: "花子", email: "hanako@example.com", password: "password" },
  { name: "ボブ", email: "bob@example.com", password: "password" }
]

posts = [
  { content: "今日はいい天気だ", user_id: 1 },
  { content: "今日はご飯が美味しい", user_id: 1 },
  { content: "昨日の講義は難しかった", user_id: 1 },
  { content: "Ruby書きやすい", user_id: 1 },
  { content: "今日は天気が悪い", user_id: 2 },
  { content: "父のカレーはうまい", user_id: 2 },
  { content: "楽しいバスケット", user_id: 3 },
  { content: "難しい言語", user_id: 3 }
]

# データをインサートする
users.each do |user|
  db.execute("INSERT INTO users (name, email, password) VALUES (?, ?, ?)", [user[:name], user[:email], user[:password]])
end

posts.each do |post|
  db.execute("INSERT INTO posts (content, user_id) VALUES (?, ?)", [post[:content], post[:user_id]])
end