require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, {adapter: "sqlite3", database: "blog.db"}

class Post < ActiveRecord::Base
  validates :title, presence: true, length: {minimum: 2}
  validates :post, presence: true

  has_many :comments, dependent: :destroy
end

class Comment < ActiveRecord::Base
  validates :comment, presence: true

  belongs_to :post
end

def output_error validate, params
  validate.select {|key,_| params[key] == ''}.values.join(", ")
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Anonim'
  end
end


configure do
  enable :sessions
end

get '/' do
  @result = Post.order('created_at DESC')
  
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

  @p = Post.new

  if !session[:identity] 
    @error = "Log in to add a post"
    return erb :login
  end

  erb :new
end

post '/new' do
  params['post']['username'] = session[:identity]

  @p = Post.new params[:post]
  if @p.save
    redirect to '/'
  else
    @error = @p.errors.full_messages.uniq.join(", ")
    erb :new
  end
end

get '/post/:id' do
  id = params[:id]

  @post = Post.find(id)

  @comments = @post.comments

  if params[:error].to_i == 1
    @error = params[:comment] 
  end
  
  erb :post
end

post '/post/:id' do

  id = params[:id]

  post = Post.find(id)

  c = post.comments
  c = c.new params[:comment]

  if c.save
    redirect to "/post/#{id}"
  else 
    redirect to "/post/#{id}?error=1&comment=Type comment text"
  end
  
end