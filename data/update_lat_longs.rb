require 'rubygems'
require 'csv'
require 'open-uri'
require 'json'
require 'fastercsv'

def data_dir 
	File.expand_path('data') + '/'
end

file_name = data_dir + "stops.csv"

stops = CSV.read(file_name).drop(1)

def lat_longs
	@lat_longs ||= FasterCSV.read(data_dir + "stops_with_lat_longs.csv")
end

def find_lat_long(code)
	matching_row = lat_longs.find { |x| x[0] == code }
	{ :lat => matching_row[1], :long => matching_row[2] }
end

out = CSV.open(data_dir + "stops_with_lat_longs2.csv","w")

stops.each do |stop|
	lsbl_code = stop[0]
	code = stop[1]	
	location = find_lat_long(code)

	out << [lsbl_code, location[:lat],location[:long]]
end

out.close