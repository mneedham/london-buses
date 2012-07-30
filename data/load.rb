require 'rubygems'
require 'neography'
require 'fastercsv'
require 'open-uri'
require 'json'


neo = Neography::Rest.new

data_dir = File.expand_path('data') + '/'

file_name = data_dir + "stops.csv"

stops = FasterCSV.read(file_name).drop(1)

stops.each do |stop|
	code = stop[1]
	name = stop[3]
	easting = stop[4]
	northing = stop[5]

  neo.create_node(:name => name, :type => "stop", :code => code).tap do |node|
    neo.add_node_to_index("stops", "name", name, node)
    neo.add_node_to_index("stops", "code", code, node)
  end	
  puts "Code: #{code}, Stop: #{name}"
end