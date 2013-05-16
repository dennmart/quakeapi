require "sinatra"
require File.join(File.dirname(__FILE__), "lib", "earthquake")

get "/" do
  "Earthquake API"
end

get "/earthquakes.json" do
  info = Earthquake.all

  if params["on"]
    on_time = Time.at(params["on"].to_i).utc
    start_date = on_time.to_date
    end_date = (start_date + 1).to_date
    info = info.all(:time_of_quake => (start_date..end_date))
  end

  if params["since"]
    since_time = Time.at(params["since"].to_i).utc
    info = info.all(:time_of_quake => (since_time..Time.now.utc))
  end

  info = info.all(:magnitude.gte => params["over"].to_f) if params["over"]

  info.to_json
end
