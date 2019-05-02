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

  get '/show' do
    oii = Post.show
    p "title is:::::"
    p oii.first[:title]
  end

end