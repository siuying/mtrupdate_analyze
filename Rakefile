require 'rubygems'
require 'bundler'
Bundler.require :default, :development
require 'fileutils'

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

  desc "Process raw data, group them by date and export to data/by_date"
  task :process do
    FileUtils.mkdir_p("data/by_date")
    FileUtils.mkdir_p("public")
    FileUtils.rm(Dir["data/by_date/*.json"])

    importer = Jsonsql::Importer.new
    importer.import(Dir["data/raw/*.json"])
    records = importer.table.all

    processor = Mtrupdate::Processor.new("data/by_date", records)
    processor.process
    processor.export

    heatmap = Mtrupdate::Heatmap.new("public", processor.group)
    heatmap.process
    heatmap.export
  end
end

task :build do 
  env = Sprockets::Environment.new
  env.append_path 'app/coffeescripts'
  env.append_path 'app/styles'
  env.append_path 'app/vendor'
  env.js_compressor  = :yui
  env.css_compressor  = :yui

  js = env['app.coffee'].to_s
  File.open("public/js/app.js", 'w+')  { |f| f << js }

  css = env['app.scss'].to_s
  File.open("public/styles/app.css", 'w+')  { |f| f << css }

end

task :default => [:'data:import', :'data:process']