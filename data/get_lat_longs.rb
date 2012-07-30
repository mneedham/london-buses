require 'rubygems'
require 'csv'
require 'open-uri'
require 'json'

data_dir = File.expand_path('data') + '/'
file_name = data_dir + "stops.csv"

stops = CSV.read(file_name).drop(1)

out = CSV.open(data_dir + "stops_with_lat_longs.csv","w")

stops.each do |stop|
	code = stop[1]
	easting = stop[4]
	northing = stop[5]
	url  = "http://www.uk-postcodes.com/eastingnorthing.php?easting=#{easting}&northing=#{northing}"
	location = JSON.parse(open(url).read)

	puts "Processing #{stop[3]}: #{location['lat']}, #{location['lng']}"

	out << [code, location['lat'],location['lng']]
end

out.close

