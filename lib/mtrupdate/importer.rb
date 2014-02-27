require 'twitter'

module Mtrupdate
  class Importer
    attr_reader :twitter, :database
  
    def initialize(twitter, database)
      @twitter = twitter
      @database = database
    end

    # Find all tweets from user timeline
    # 
    # since_id - only update tweets after specific twitter id
    def save_all_tweets(since_id=nil)
      puts "Finding mtrupdate user ..."
      user = twitter.user("mtrupdate")

      puts "Saving all its tweets ..."
      collect_with_max_id do |max_id|
        options = {:count => 200, :include_rts => false}
        options[:max_id] = max_id unless max_id.nil?
        options[:since_id] = since_id unless since_id.nil?

        puts "  Fetching tweets since max_id = #{max_id}, since_id = #{since_id}"
        tweets = twitter.user_timeline(user, options)

        puts "  Saving tweets ...."
        save_tweets(tweets)
      end
    end

    def save_tweets(tweets)
      tweets_table = database[:tweets]
      database.transaction do
        tweets.each do |tweet|
          # correct langauge
          # twitter language  recognition some time think mtrupdate speak 
          # ja instead of zh so we have to correct it manually
          lang = (tweet.lang == "en") ? "en" : "zh"
          tweets_table.insert(:id => tweet.id, 
            :text => tweet.text, 
            :created_at => tweet.created_at,
            :lang => lang,
            :reply_to => tweet.in_reply_to_screen_name?)
        end
      end
    end

    private

    def collect_with_max_id(collection=[], max_id=nil, &block)
      response = yield max_id
      collection += response
      response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
    end
  end
end