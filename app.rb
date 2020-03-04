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

    @db.execute 'CREATE TABLE IF NOT EXISTS "Comments" (
            "Id"	INTEGER PRIMARY KEY AUTOINCREMENT,
            "created_date"	DATE,
            "comment"	TEXT,
            "post_id" INTEGER
          )'
end

get '/' do
  @result = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'
  
  erb :index
end

get '/new' do
  erb :new
end

def output_error validate, params
  validate.select {|key,_| params[key] == ''}.values.join(", ")
end

post '/new' do

  @error = nil

  validate = {
    :title => "Type title text",
    :post => "Type post text",
  }

  @title = params[:title]
  @post = params[:post]

  @error = output_error(validate, params)

  if !@error.empty?
    return erb :new
  end

  @error = nil
  
  @db.execute 'INSERT INTO Posts (created_date, title, post) VALUES (datetime(), ?, ?)', [@title, @post]

  redirect to '/'

end

get '/post/:id' do
  id = params[:id]

  result = @db.execute 'SELECT * FROM Posts WHERE Id = ?', [id]
  
  @post = result[0]

  erb :post
end

post '/post/:id' do
  id = params[:id]
  @comment = params[:comment]
  
  @db.execute 'INSERT INTO Comments (created_date, comment, post_id) VALUES (datetime(), ?, ?)', [@comment, id]

  redirect to "/post/#{id}"
end