require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'blog.db'
  @db.results_as_hash = true
end

def output_error validate, params
  validate.select {|key,_| params[key] == ''}.values.join(", ")
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Anonim'
  end
end

before do
  init_db
end

configure do
  enable :sessions

    init_db
    @db.execute 'CREATE TABLE IF NOT EXISTS "Posts" (
                "Id"	INTEGER PRIMARY KEY AUTOINCREMENT,
                "created_date"	DATE,
                "title"	TEXT,
                "post"	TEXT,
                "username" TEXT
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

get '/login' do
  erb :login
end

post '/login' do

  validate = {
    :login => "Login is not empty"    
  }

  @login = params[:login]

  @error = output_error(validate, params)

  if !@error.empty?
    return erb :login
  end

  session[:identity] = @login
  redirect to '/new'

end

get '/new' do
  if !session[:identity] 
    @error = "Log in to add a post"
    return erb :login
  end

  erb :new
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
  
  @db.execute 'INSERT INTO Posts (created_date, title, post, username) VALUES (datetime(), ?, ?, ?)', [@title, @post, username]

  redirect to '/'

end

get '/post/:id' do
  id = params[:id]

  result = @db.execute 'SELECT * FROM Posts WHERE Id = ?', [id]
  
  @post = result[0]

  @comments = @db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY id', [id]

  if params[:error].to_i == 1
    @error = params[:comment] 
  end
 
  erb :post
end

post '/post/:id' do

  validate = {
    :comment => "Type comment text"    
  }

  id = params[:id]
  @comment = params[:comment]

  @error = output_error(validate, params)

  if !@error.empty?
    redirect to "/post/#{id}?error=1&comment=Type comment text"
  end
  
  @error = nil

  @db.execute 'INSERT INTO Comments (created_date, comment, post_id) VALUES (datetime(), ?, ?)', [@comment, id]
  
  redirect to "/post/#{id}"
end