require "sinatra"
require File.join(File.dirname(__FILE__), "lib", "earthquake")

get "/" do
  "Earthquake API"
end

get "/earthquakes.json" do
  content_type "application/json"

  earthquakes = Earthquake.get_earthquakes(params)
  earthquakes.to_json
end
