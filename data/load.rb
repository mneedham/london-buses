require 'rubygems'
require 'neography'
require 'fastercsv'
require 'open-uri'
require 'json'

require 'neo4j'

class Stop
  include Neo4j::NodeMixin
  index :code
  property :code
  property :name
end

neo = Neography::Rest.new

data_dir = File.expand_path('data') + '/'

file_name = data_dir + "stops.csv"

stops = FasterCSV.read(file_name).drop(1)

stops_to_add = []
stops.each do |stop|
	code = stop[1]
	name = stop[3]
	easting = stop[4]
	northing = stop[5]

	stops_to_add << { :name => name, :code => code  }
	puts "Code: #{code}, Stop: #{name}"
end

Neo4j::Config[:storage_path] = File.expand_path('neo4j') + "/data/graph.db"

Neo4j::Transaction.run do
  stops_to_add.each do |stop|
  	Stop.new(:name => stop[:name], :code => stop[:code])
  end
end

p Stop.find(:code => 91532).first.name