require 'rubygems'
require 'bundler'
Bundler.require

require_relative './config/settings'
require_relative './lib/mtrupdate'
require_relative './lib/tasks/migration'

namespace :db do
  desc "Create database"
  task :setup do
    database = Sequel.connect Settings.database.uri
    database.create_table :tweets do
      primary_key :id
      String :text
      Date :created_at
      TrueClass :reply_to
      String :lang
    end
  end

  desc "Import latest data"
  task :import do
    database = Sequel.connect Settings.database.uri
    twitter = Twitter::REST::Client.new do |config|
      config.consumer_key        = Settings.twitter.consumer_key
      config.consumer_secret     = Settings.twitter.consumer_secret
      config.access_token        = Settings.twitter.access_token
      config.access_token_secret = Settings.twitter.access_token_secret
    end

    tweets = database[:tweets]
    max_id = tweets.max(:id)
    
    importer = Mtrupdate::Importer.new(twitter, database)
    importer.save_all_tweets(max_id)
  end
end