require "spec_helper"

describe Earthquake do
  describe ".fetch_new_earthquakes" do
    it "fetches earthquake information from the last 7 days and inserts them to the database" do
      stub_request(:get, Earthquake::INFO_URL).to_return(:body => File.new(File.dirname(__FILE__) + "/fixtures/earthquake_response.txt"))

      expect {
        Earthquake.fetch_new_earthquakes
      }.to change(Earthquake, :count).by(2)
    end

    it "only creates new records for new earthquake information" do
      stub_request(:get, Earthquake::INFO_URL).to_return(:body => File.new(File.dirname(__FILE__) + "/fixtures/earthquake_response.txt")).then.
                                               to_return(:body => File.new(File.dirname(__FILE__) + "/fixtures/additional_earthquake_response.txt"))

      Earthquake.fetch_new_earthquakes

      expect {
        Earthquake.fetch_new_earthquakes
      }.to change(Earthquake, :count).by(1)
    end
  end
end
