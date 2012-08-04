require 'rubygems'
require 'fastercsv'
require 'open-uri'
require 'json'

require 'neo4j'

data_dir = File.expand_path('data') + '/'

file_name = data_dir + "stops.csv"

stops = FasterCSV.read(file_name).drop(1)

stops_to_add = []
stops.each do |stop|
	code = stop[0]
	name = stop[3]
	easting = stop[4]
	northing = stop[5]

	stops_to_add << { :name => name, :code => code  }
end

Neo4j::Config[:storage_path] = File.expand_path('neo4j') + "/data/graph.db"

class StopsIndex
  extend Neo4j::Core::Index::ClassMethods
  include Neo4j::Core::Index

  self.node_indexer do
    index_names :exact => 'stops'
    trigger_on :type => "stop"
  end

  index :code
end

Neo4j::Transaction.run do
  stops_to_add.each do |stop|
	node = Neo4j::Node.new(:name => stop[:name], :code => stop[:code], :type => "stop")
  	puts "Code: #{stop[:code]}, Stop: #{stop[:name]}"
  end
end


routes_file = data_dir + "routes.csv"
routes = FasterCSV.read(routes_file).drop(1)

routes.group_by { |route| route[0] }.each_pair do |key, value|
	puts "Bus route: #{key}, #{value.size}"
  	stops = value.map { |route| route[3]  }
  	stop_combinations = stops.zip(stops.drop(1))
    p stop_combinations

	Neo4j::Transaction.run do
		stop_combinations.each do |stop_combination|
			p stop_combination[0]
			unless stop_combination[1].nil?
				puts "Adding stop #{stop_combination}"
				stop1 = StopsIndex.find("code: \"#{stop_combination[0]}\"").first
				stop2 = StopsIndex.find("code: \"#{stop_combination[1]}\"").first				
				Neo4j::Relationship.new(:route, stop1, stop2, { :bus_number => key })			
			end
		end
	end

end