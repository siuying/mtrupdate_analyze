require 'pry'

module Mtrupdate
  class Heatmap
    DELAY_SEVERITY = {
      "服務受阻" => 1, "稍有阻延" => 2, "顯著受阻" => 3, "嚴重受阻" => 4, "限度服務" => 5, "全綫暫停" => 6, "回復正常" => 0
    }

    attr_reader :groups, :export_path, :output

    # create a heatmap data
    # export_path - path to export
    # groups - grouped records with key/value as date/array of records, created by Mtrupdate::Processor
    def initialize(export_path, groups)
      @groups = groups
      @export_path = export_path
    end

    # for each date until today, find the worse delay event
    def process(today=Date.now)
      @output = {}

      first_date = groups.keys.min
      current_date = first_date
      while current_date <= today
        if groups[current_date]
          worst_severity = worst_delay_severity(groups[current_date])
          events = event_with_records(groups[current_date])
          @output[current_date] = { :severity => worst_severity, :events => events }
        else
          @output[current_date] = { :severity => 0, :events => [] }
        end
        current_date = current_date + 1
      end

      @output
    end

    # export data, as a JSON file
    def export

    end

    # Find the worst delay from the records of a day
    # records - array of records
    # return maximum delay severity level, in number
    def worst_delay_severity(records)
      records.collect{|r| DELAY_SEVERITY[r[:delay]] || 0 }.max || 0
    end

    # Find events from records
    def event_with_records(records)
      records.collect {|r| {:time => "%04d" % [r[:time]], :text => r[:text]} }
    rescue StandardError => e
      puts "#{e}"
      binding.pry
    end
  end
end