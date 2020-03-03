require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'blog.db'
  @db.results_as_hash = true
end

before do
  init_db
end

configure do

    init_db
    @db.execute 'CREATE TABLE IF NOT EXISTS "Posts" (
                "Id"	INTEGER PRIMARY KEY AUTOINCREMENT,
                "created_date"	DATE,
                "title"	TEXT,
                "post"	TEXT
              )'

end

get '/' do
  erb "Hello, I'm Simple site!"
end

get '/new' do
  erb :new
end

post '/new' do
  @title = params[:title]
  @post = params[:post]

  erb "Add new post | #{@title} | text: #{@post}"
end