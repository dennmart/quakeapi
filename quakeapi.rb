require "sinatra"
require File.join(File.dirname(__FILE__), "lib", "earthquake")

get "/" do
  "Earthquake API"
end
