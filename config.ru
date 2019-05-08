#Load models
require_relative "models/baseClass.rb"
require_relative "models/post.rb"
require_relative "models/fruit.rb"

#Use bundler to load gems
require 'bundler'

#Load gems from Gemfile
Bundler.require

#Load the app
require_relative 'app.rb'



#Run the application
run App