require "spec_helper"

describe "quakeapi" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe "GET /" do
    it "should do something more interesting" do
      get "/"
      last_response.body.should == "Earthquake API"
    end
  end

  describe "GET /earthquakes.json" do
    before(:all) do
      stub_request(:get, Earthquake::INFO_URL).to_return(:body => File.new(File.dirname(__FILE__) + "/fixtures/full_earthquake_info.txt"))
      Earthquake.fetch_new_earthquakes
    end

    after(:all) do
      Earthquake.all.destroy
    end

    def earthquakes
      JSON.parse(last_response.body)
    end

    def earthquake_ids
      earthquakes.map { |quake| quake["earthquake_id"] }
    end

    it "returns all earthquakes if no parameters are passed" do
      get "/earthquakes.json"
      earthquakes.size.should == 3
    end

    it "returns all earthquakes from a specific date if params['on'] is passed" do
      get "/earthquakes.json", :on => "1368582600" # Wed, 15 May 2013 01:50:00 GMT
      earthquakes.size.should == 2

      earthquake_ids.should include(1, 2)
      earthquake_ids.should_not include(3)
    end

    it "returns all earthquakes since a specific date if params['since'] is passed" do
      get "/earthquakes.json", :since => "1368582600" # Wed, 15 May 2013 01:50:00 GMT
      earthquakes.size.should == 2

      earthquake_ids.should include(1, 3)
      earthquake_ids.should_not include(2)
    end

    it "returns earthquakes from params['on'] starting from params['since'] if are both passed" do
      get "/earthquakes.json", :on => "1368582600", :since => "1368582600" # Wed, 15 May 2013 01:50:00 GMT
      earthquakes.size.should == 1

      earthquake_ids.should include(1)
      earthquake_ids.should_not include(2, 3)
    end

    it "returns all earthquakes over a certain magnitude if params['over'] is passed" do
      get "/earthquakes.json", :over => "2.0"
      earthquakes.size.should == 2

      earthquake_ids.should include(2, 3)
      earthquake_ids.should_not include(1)
    end

    it "returns all earthquakes within a 5 mile radius of latitude and longitude if those parameters are passed" do
      pending
    end
  end
end
