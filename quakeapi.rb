require "sinatra"
require File.join(File.dirname(__FILE__), "lib", "earthquake")

get "/" do
  File.read(File.join("public", "index.html"))
end

get "/earthquakes.json" do
  content_type "application/json"

  earthquakes = Earthquake.get_earthquakes(params)
  earthquakes.to_json
end
