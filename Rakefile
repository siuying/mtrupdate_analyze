require 'rubygems'
require 'bundler'
Bundler.require

require_relative './config/settings'
require_relative './lib/mtrupdate'

namespace :data do
  desc "Import latest data"
  task :import do
    twitter = Twitter::REST::Client.new do |config|
      config.consumer_key        = Settings.twitter.consumer_key
      config.consumer_secret     = Settings.twitter.consumer_secret
      config.access_token        = Settings.twitter.access_token
      config.access_token_secret = Settings.twitter.access_token_secret
    end

    importer  = Mtrupdate::RawImporter.new(twitter, "data/raw")
    max_id    = importer.last_tweet_id
    if max_id
      puts "Fetch tweets from mtrupdate, last tweet id = #{max_id}"
    else
      puts "Fetch all tweets from mtrupdate"
    end
    importer.save_all_tweets(max_id)
  end
end