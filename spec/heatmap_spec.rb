require 'spec_helpers'

describe Mtrupdate::Heatmap do
  subject { Mtrupdate::Heatmap.new(double(:path), {})}

  context "#worst_delay_severity" do
    it "should return worse severity level" do
      events = [{:delay => "服務受阻"}, {:delay => "嚴重受阻"}]
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

      groups  = {date1 => [{:delay => "嚴重受阻"}], date2 => [{:delay => "服務受阻"}]}
      subject = Mtrupdate::Heatmap.new(double(:path), groups)
      output  = subject.process(today)

      expect(output.count).to eq(6)
      expect(output[Date.parse("2013-01-02")]).to eq(4)
      expect(output[Date.parse("2013-01-03")]).to eq(0)
      expect(output[Date.parse("2013-01-04")]).to eq(0)
      expect(output[Date.parse("2013-01-05")]).to eq(1)
      expect(output[Date.parse("2013-01-06")]).to eq(0)
      expect(output[Date.parse("2013-01-07")]).to eq(0)
    end
  end
end