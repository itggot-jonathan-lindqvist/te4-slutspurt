require 'sinatra'
class App < Sinatra::Base

  get '/' do
    @posts = Post.all
    erb :index
  end

  post '/' do
    Post.create(params)
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

  post '/delete' do
    Post.destroy(params)
    redirect '/'
  end

end