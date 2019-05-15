require 'sinatra'
class App < Sinatra::Base

  get '/' do
    @posts = Post.all
    @fruits = Fruit.all
    erb :index
    # slim :test
  end

  post '/' do
    Post.create(params)
    redirect '/'
  end

  post '/createfruit' do
    Fruit.create(params)
    redirect '/'
  end

  get '/about' do
    erb :about
  end

  post '/change' do
    if I18n.locale == :se
      I18n.locale = :en
    else
      I18n.locale = :se
    end
    redirect '/about'
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