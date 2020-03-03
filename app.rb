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