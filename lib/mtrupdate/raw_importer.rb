require 'twitter'

module Mtrupdate
  # Import raw mtrupdate data from twitter
  class RawImporter
    attr_reader :twitter, :path
    attr_reader :username

    def initialize(twitter, path, username="mtrupdate")
      @twitter = twitter
      @path = path
      @username = username
    end

    # Find the maximum tweet id in the path
    def last_tweet_id
      filename = Dir["#{path}/*.json"].sort.last
      filename.match(%r{^data/raw/([0-9])+\.json$})[1] rescue nil
    end

    # Find all tweets from user timeline
    # 
    # since_id - only update tweets after specific twitter id
    def save_all_tweets(since_id=nil)
      user = twitter.user(username)
      collect_with_max_id do |max_id|
        options             = {:count => 200, :include_rts => false}
        options[:max_id]    = max_id unless max_id.nil?
        options[:since_id]  = since_id unless since_id.nil?

        tweets = twitter.user_timeline(user, options)
        tweets.each do |tweet|
          save_tweet(tweet)
        end        
      end
    end

    # Save a tweet to disk, using the tweet id + .json as filename, to the path of the importer
    def save_tweet(tweet)
      data = {
        :id => tweet.id, 
        :text => tweet.text, 
        :created_at => tweet.created_at,
        :lang => tweet.lang,
        :reply_to => tweet.in_reply_to_screen_name
      }

      fullpath = File.join(path, "#{tweet.id}.json")
      json     = JSON.pretty_generate(data)
      File.open(fullpath, 'w') { |file| file.write(json) }
    end

    private
    def collect_with_max_id(collection=[], max_id=nil, &block)
      response = yield max_id
      collection += response
      response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
    end
  end
end