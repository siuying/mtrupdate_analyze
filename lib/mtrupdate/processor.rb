module Mtrupdate
  class Processor
    KEYWORDS_TAGGER = {
      :delay => ["稍有阻延", "顯著受阻", "嚴重受阻", "限度服務", "全綫暫停", "回復正常"],
      :line => ["輕鐵綫", "荃灣綫", "港島綫", "觀塘綫", "東涌綫", "荃灣綫", "東鐵綫", "西鐵綫", "馬鞍山綫", "迪士尼綫", "機場快綫", "將軍澳綫", "輕鐵", "東鐵"]
    }

    attr_reader :records, :export_path

    # create an analyzer
    def initialize(export_path, records)
      @records = records
      @export_path = export_path
    end

    # process the records
    def process
      pre_filter
      cleanup
      tags
      post_filter
    end

    # export data, grouped by date, to export_path
    def export
      group.each do |date, records|
        save_date(date.strftime("%Y%m%d"), records)
      end
    end

    def save_date(date_string, data)
      fullpath = File.join(export_path, "#{date_string}.json")
      json     = JSON.pretty_generate(data)
      File.open(fullpath, 'w') { |file| file.write(json) }
    end

    protected

    # filter any unrelated records
    def pre_filter
      @records = records
        .select {|event| event[:lang] != "en" }
        .select {|event| event[:reply_to].nil? }
        .select {|event| event[:text] =~ /^[0-9]{4}/ }
    end

    # cleanup the dataset
    def cleanup
      records.each do |record|
        record[:text] = record[:text].gsub("線", "綫")

        # convert created_at to string
        record[:created_at] = DateTime.parse(record[:created_at]) if record[:created_at].is_a?(String) 

        # find the create time
        match = record[:text].match(/^([0-9]{4})[ \t]*(.+)$/)
        record[:time] = match[1].to_i
        record[:text] = match[2]

        # find the event date, because the service hour start at 06:00,
        # any events before 06:00 is assumed to grouped to previous date
        record[:date] = record[:time] < 600 ? (record[:created_at].to_date - 1) : record[:created_at].to_date

        record.delete(:reply_to)
        record.delete(:lang)
      end
    end

    # tagging events by KEYWORDS_TAGGER
    def tags
      records.each do |record|
        KEYWORDS_TAGGER.each do |name, keywords|
          record[name] = keywords.find {|keyword| record[:text].include?(keyword) }
        end
      end
    end
    
    # another round of filter after cleanup and tagging
    def post_filter
      @records = records.select {|event| event[:delay] }
    end

    # group the records by event date
    # return Hash of records, with key be the date and values be arrays of records
    def group
      records.group_by{|r| r[:date]}
    end
  end
end