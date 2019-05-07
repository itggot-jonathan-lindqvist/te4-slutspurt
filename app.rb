require 'sinatra'
class App < Sinatra::Base

  get '/' do
    @posts = Post.all
    erb :index
  end

  post '/' do
    title = params[:title]
    content = params[:content]
    Post.create(title, content)
    redirect '/'
  end

  get '/about' do
  end

  get '/drop' do
    Post.drop
  end

  get '/:post_id' do
    post_id = params[:post_id]
    @post = Post.find(post_id)
    erb :show
  end

  post '/update' do
    id = params[:id]
    Post.update(params)
    redirect "/#{id}"
  end

end