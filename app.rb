require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

get '/' do
  erb "Hello, I'm Simple site!"
end

