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
          @output[current_date] = worst_delay_severity(groups[current_date])
        else
          @output[current_date] = 0
        end
        current_date = current_date + 1
      end

      @output
    end

    # Find the worst delay from the records of a day
    # records - array of records
    # return maximum delay severity level, in number
    def worst_delay_severity(records)
      records.collect{|r| DELAY_SEVERITY[r[:delay]] || 0 }.max || 0
    end
  end
end