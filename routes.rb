require 'rubygems'
require 'neography'
require 'json'

query =  " START current=node:stops(\"code:*\")"
query << " MATCH current-[r:route]->otherStop"
query << " RETURN current.code, current.lat, current.long, otherStop.code, otherStop.lat, otherStop.long, COUNT(otherStop) AS numberOfStops"
query << " ORDER BY numberOfStops"

def neo
	@neo ||= Neography::Rest.new
end

# query =  " START n1=node:stops(code = '3178'), n2 = node:stops(code = '20462')"
# query << " MATCH n1-[r:route]->n2"
# query << " RETURN n1.code,n2.code"

initial_result = neo.execute_query(query)["data"]

result = initial_result.map do |row|
	{ :from => { :code => row[0], :lat => row[1], :long => row[2] }, :to => { :code => row[3], :lat => row[4], :long => row[5] }, :routes => row[6] }
end

p result.to_json
