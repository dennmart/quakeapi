require File.join(File.dirname(__FILE__), "lib", "earthquake")

namespace :quakeapi do
  desc "Fetch earthquakes from last seven days and insert new records in the database"
  task :fetch_new do
    puts "Fetching and inserting new earthquake info..."
    begin
      Earthquake.fetch_new_earthquakes
    # There are more Net/HTTP exceptions we can rescue from, but it's just too much...
    rescue Timeout::Error, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse => e
      puts "There was an error: #{e.class} - #{e.message}"
    end
    puts "Finished!"
  end
end
