require 'spec_helpers'

describe Mtrupdate::Heatmap do
  subject { Mtrupdate::Heatmap.new(double(:path), {})}

  context "#worst_delay_severity" do
    it "should return worse severity level" do
      events = [{:delay => "服務受阻", :time => 2100}, {:delay => "嚴重受阻", :time => 1100}]
      expect(subject.worst_delay_severity(events)).to eq(4)
    end

    it "should return 0 on empty input" do
      expect(subject.worst_delay_severity([])).to eq(0)
    end
  end

  context "#process" do
    it "should return worse severity level" do
      date1 = Date.parse("2013-01-02")
      date2 = Date.parse("2013-01-05")
      today = Date.parse("2013-01-07")

      groups  = {
        date1 => [{:delay => "嚴重受阻", :time => 100, :text => "TEST"}], 
        date2 => [{:delay => "服務受阻", :time => 1200, :text => "TEST2"}]
      }
      subject = Mtrupdate::Heatmap.new(double(:path), groups)
      output  = subject.process(today)

      expect(output.count).to eq(6)
      expect(output[Date.parse("2013-01-02")][:severity]).to eq(4)
      expect(output[Date.parse("2013-01-03")][:severity]).to eq(0)
      expect(output[Date.parse("2013-01-04")][:severity]).to eq(0)
      expect(output[Date.parse("2013-01-05")][:severity]).to eq(1)
      expect(output[Date.parse("2013-01-06")][:severity]).to eq(0)
      expect(output[Date.parse("2013-01-07")][:severity]).to eq(0)

      expect(output[Date.parse("2013-01-02")][:events]).to eq([{:time => "0100", :text => "TEST"}])
      expect(output[Date.parse("2013-01-05")][:events]).to eq([{:time => "1200", :text => "TEST2"}])
    end
  end
end