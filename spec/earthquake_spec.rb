require "spec_helper"

describe Earthquake do
  describe ".fetch_new_earthquakes" do
    it "fetches earthquake information from the last 7 days and inserts them to the database" do
      stub_request(:get, Earthquake::INFO_URL).to_return(:body => File.new(File.dirname(__FILE__) + "/fixtures/partial_earthquake_info.txt"))

      expect {
        Earthquake.fetch_new_earthquakes
      }.to change(Earthquake, :count).by(2)
    end

    it "only creates new records for new earthquake information" do
      stub_request(:get, Earthquake::INFO_URL).to_return(:body => File.new(File.dirname(__FILE__) + "/fixtures/partial_earthquake_info.txt")).then.
                                               to_return(:body => File.new(File.dirname(__FILE__) + "/fixtures/full_earthquake_info.txt"))

      Earthquake.fetch_new_earthquakes

      expect {
        Earthquake.fetch_new_earthquakes
      }.to change(Earthquake, :count).by(1)
    end
  end

  describe ".get_earthquakes" do
    let(:earthquake) { Earthquake.new }

    before(:all) do
      stub_request(:get, Earthquake::INFO_URL).to_return(:body => File.new(File.dirname(__FILE__) + "/fixtures/full_earthquake_info.txt"))
      Earthquake.fetch_new_earthquakes
    end

    after(:all) do
      Earthquake.all.destroy
    end

    context "all earthquakes" do
      it "returns all earthquakes if params hash is empty" do
        earthquakes = earthquake.get_earthquakes({})
        earthquakes.size.should == 3
      end
    end

    context "'limit' parameter" do
      it "limits the number of records returned if the 'limit' parameter exists" do
        earthquakes = earthquake.get_earthquakes({ "limit" => "1" })
        earthquakes.size.should == 1
      end
    end

    context "'on' parameter" do
      it "returns all earthquakes from a specific date if the 'on' parameter exists" do
        earthquakes = earthquake.get_earthquakes({ "on" => "1368582600" }) # Wed, 15 May 2013 01:50:00 GMT
        earthquakes.size.should == 2

        earthquakes.map(&:earthquake_id).should include("1", "2")
        earthquakes.map(&:earthquake_id).should_not include("3")
      end

      it "should ignore the 'on' parameter if it's not a timestamp" do
        earthquakes = earthquake.get_earthquakes({ "on" => "12345678900000" })
        earthquakes.size.should == 3
      end
    end

    context "'since' parameter" do
      it "returns all earthquakes since a specific date if the 'since' parameter exists" do
        earthquakes = earthquake.get_earthquakes({ "since" => "1368582600" }) # Wed, 15 May 2013 01:50:00 GMT
        earthquakes.size.should == 2

        earthquakes.map(&:earthquake_id).should include("1", "3")
        earthquakes.map(&:earthquake_id).should_not include("2")
      end

      it "should ignore the 'since' parameter if it's not a timestamp" do
        earthquakes = earthquake.get_earthquakes({ "since" => "12345678900000" })
        earthquakes.size.should == 3
      end
    end

    context "'on' and 'since' parameters combined" do
      it "returns earthquakes from 'on', starting from 'since'" do
        earthquakes = earthquake.get_earthquakes({ "on" => "1368582600", "since" => "1368582600" }) # Wed, 15 May 2013 01:50:00 GMT
        earthquakes.size.should == 1

        earthquakes.map(&:earthquake_id).should include("1")
        earthquakes.map(&:earthquake_id).should_not include("2", "3")
      end
    end

    context "'over' parameter" do
      it "returns all earthquakes over a specific magnitude if the 'over' parameter exists" do
        earthquakes = earthquake.get_earthquakes({ "over" => "2.0" })
        earthquakes.size.should == 2

        earthquakes.map(&:earthquake_id).should include("2", "3")
        earthquakes.map(&:earthquake_id).should_not include("1")
      end

      it "should ignore the 'over' parameter if it's not a float between 0.0 and 9.9" do
        earthquakes = earthquake.get_earthquakes({ "over" => "15.0" })
        earthquakes.size.should == 3
      end
    end

    context "'near' parameter" do
      it "returns all earthquakes within 5 miles of a point if the 'near' parameter exists" do
        earthquakes = earthquake.get_earthquakes({ "near" => "35.50,-120.70" })
        earthquakes.size.should == 1

        earthquakes.map(&:earthquake_id).should include("3")
        earthquakes.map(&:earthquake_id).should_not include("1", "2")
      end

      it "should ignore the 'near' parameter if it's not 'latitude,longitude' formatted properly" do
        earthquakes = earthquake.get_earthquakes({ "near" => "35.50/-120.70" })
        earthquakes.size.should == 3
      end

      it "uses a specified distance if the 'distance' parameter exists" do
        Geocoder::Calculations.should_receive(:bounding_box).with(["35.50", "-120.70"], 25).and_call_original
        earthquake.get_earthquakes({ "near" => "35.50,-120.70", "distance" => "25" })
      end
    end
  end
end
