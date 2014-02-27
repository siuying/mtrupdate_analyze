require 'date'
require 'sequel'
require 'pry'

module Mtrupdate
  # Create a database and import all JSON files from raw data.
  #
  # By default, the db is a memory only sqlite database and will be discard once finished.
  class JsonDatabase
    attr_reader :database, :path

    def initialize(raw_path, db_uri="sqlite:/")
      @path = raw_path
      @database = Sequel.sqlite
      @database.create_table :tweets do
        primary_key :id
        String :text
        String :lang
        Datetime :created_at
        String :reply_to
      end
    end

    def import
      filenames = Dir["#{path}/*.json"]
      @database.transaction do
        filenames.each do |filename|
          data        = JSON(open(filename).read)
          id          = data["id"]
          text        = data["text"]
          lang        = data["lang"]
          reply_to    = data["reply_to"]
          created_at  = DateTime.parse(data["created_at"])
          tweets.insert(id: id, text: text, lang: lang, created_at: created_at, reply_to: reply_to)
        end
      end
    end

    def tweets
      @tweets ||= @database[:tweets]
    end
  end
end