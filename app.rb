require 'rubygems'
require 'bundler'
Bundler.require

get '/' do
  send_file 'index.html'
end