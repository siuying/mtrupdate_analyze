require 'spec_helpers'

describe Mtrupdate::RawImporter do
  context "last_tweet_id" do
    it "should return the last id of the files" do
      importer = Mtrupdate::RawImporter.new(double(:twitter), "data/raw")
      allow(Dir).to receive(:[]) { ["data/raw/2.json", "data/raw/10.json", "data/raw/11.json"] }
      last_id = importer.last_tweet_id
      expect(last_id).to eq("11")
    end

    it "should return nil when no files found" do
      importer = Mtrupdate::RawImporter.new(double(:twitter), "data/raw")
      allow(Dir).to receive(:[]) { [] }
      last_id = importer.last_tweet_id
      expect(last_id).to be_nil
    end
  end

  context "save_all_tweets" do
    it "should find all tweets from mtrupdate user timeline" do
      tweet = double(:tweet)
      expect(tweet).to receive(:id) { 100 }
      twitter = double(:twitter)
      user = double(:user)

      importer = Mtrupdate::RawImporter.new(twitter, "data/raw")
      expect(importer).to receive(:save_tweet).with(tweet)
      expect(twitter).to receive(:user).with("mtrupdate") { user }
      expect(twitter).to receive(:user_timeline).with(user, {:count => 200, :include_rts => false}) { [tweet] }
      expect(twitter).to receive(:user_timeline).with(user, {:count => 200, :include_rts => false, :max_id => 99}) { [] }

      importer.save_all_tweets
    end

    it "should find all tweets after since_id" do
      tweet = double(:tweet)
      expect(tweet).to receive(:id) { 1200 }
      twitter = double(:twitter)
      user = double(:user)

      importer = Mtrupdate::RawImporter.new(twitter, "data/raw")
      expect(importer).to receive(:save_tweet).with(tweet)
      expect(twitter).to receive(:user).with("mtrupdate") { user }
      expect(twitter).to receive(:user_timeline).with(user, {:count => 200, :include_rts => false, :since_id => 1000}) { [tweet] }
      expect(twitter).to receive(:user_timeline).with(user, {:count => 200, :include_rts => false, :max_id => 1199, :since_id => 1000}) { [] }

      importer.save_all_tweets(1000)
    end
  end
end