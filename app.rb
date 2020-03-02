require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

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