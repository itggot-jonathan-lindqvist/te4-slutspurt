require 'sinatra'
class App < Sinatra::Base

  get '/' do
    "HEllo world"
    # @posts = Post.all
  end

  get '/about' do
  end

end