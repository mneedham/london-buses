require 'rubygems'
require 'sinatra'
require 'json'
require 'neography'

def neo
	@neo ||= Neography::Rest.new
end

get '/' do
   "Not much happening here"
end

# get '/routes.json' do
# 	query =  " START current=node:stops(\"code:*\")"
# 	query << " MATCH current-[r:route]->otherStop"
# 	query << " RETURN current.code, current.lat, current.long, otherStop.code, otherStop.lat, otherStop.long, COUNT(otherStop) AS numberOfStops"
# 	query << " ORDER BY numberOfStops"

# 	initial_result = neo.execute_query(query)["data"]

# 	result = initial_result.map do |row|
# 		{ :from => { :lat => row[1], :long => row[2] }, :to => { :code => row[3], :lat => row[4], :long => row[5] }, :routes => row[6] }
# 	end

# 	result.to_json
# end