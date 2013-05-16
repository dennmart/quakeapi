require "data_mapper"
require "geocoder"
require "net/http"

class Earthquake
  INFO_URL = "http://earthquake.usgs.gov/earthquakes/catalogs/eqs7day-M1.txt"
  KEY_MAPPING =  { "Src"       => :source,
                   "Eqid"      => :earthquake_id,
                   "Version"   => :version,
                   "Datetime"  => :time_of_quake,
                   "Lat"       => :latitude,
                   "Lon"       => :longitude,
                   "Magnitude" => :magnitude,
                   "Depth"     => :depth,
                   "NST"       => :stations,
                   "Region"    => :region }

  include DataMapper::Resource

  property :id,            Serial
  property :source,        String
  property :earthquake_id, Integer
  property :version,       String
  property :time_of_quake, DateTime
  property :latitude,      Float
  property :longitude,     Float
  property :magnitude,     Float
  property :depth,         Float
  property :stations,      Integer
  property :region,        String

  # If deploying on Heroku, check DATABASE_URL first. If not use local Postgres instance.
  DataMapper.setup(:default, ENV["DATABASE_URL"] || "postgres://localhost/quakeapi_#{ENV['RACK_ENV'] || 'development'}")
  DataMapper.finalize
  DataMapper.auto_upgrade!

  def self.fetch_new_earthquakes
    uri = URI.parse(INFO_URL)

    http = Net::HTTP.new(uri.host, uri.port)
    # Set timeout to 30 seconds - This will be run again in the next minute.
    http.open_timeout = 30
    http.read_timeout = 30
    request = http.request(Net::HTTP::Get.new(uri.request_uri))
    parse_api_response(request.body)
  end

  def self.get_earthquakes(params)
    info = Earthquake.all

    if params["on"] && params["on"].match(/^\d{10}$/)
      on_time = Time.at(params["on"].to_i).utc
      start_date = on_time.to_date
      end_date = (start_date + 1).to_date
      info = info.all(:time_of_quake => (start_date..end_date))
    end

    if params["since"] && params["since"].match(/^\d{10}$/)
      since_time = Time.at(params["since"].to_i).utc
      info = info.all(:time_of_quake => (since_time..Time.now.utc))
    end

    if params["over"] && params["over"].match(/^[0-9]\.[0-9]$/)
      info = info.all(:magnitude.gte => params["over"].to_f)
    end

    if params["near"] && params["near"].match(/^(\-?\d+(\.\d+)?),\s*(\-?\d+(\.\d+)?)$/)
      lat, lng = params["near"].split(",")
      box = Geocoder::Calculations.bounding_box([lat, lng], 5)
      info = info.all(:latitude.lte => (box[2]), :latitude.gte => box[0])
      info = info.all(:longitude.lte => (box[3]), :longitude.gte => box[1])
    end

    if params["limit"] && params["limit"].match(/^[0-9]*$/)
      info = info.all(:limit => params["limit"].to_i)
    end

    info = info.all(:order => [:time_of_quake.desc])

    info
  end

  private

  def self.parse_api_response(response)
    CSV.parse(response, headers: true) do |row|
      earthquake = Hash[row.map { |k, v| [KEY_MAPPING[k], v] }]
      [:earthquake_id, :stations].each { |k| earthquake[k] = earthquake[k].to_i }
      [:latitude, :longitude, :magnitude, :depth].each { |k| earthquake[k] = earthquake[k].to_f }

      if Earthquake.count(:earthquake_id => earthquake[:earthquake_id], :time_of_quake => Time.parse(earthquake[:time_of_quake])) == 0
        Earthquake.create(earthquake)
      end
    end
  end
end
