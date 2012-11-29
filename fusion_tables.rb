require 'rubygems'
require 'nokogiri'
require 'neography'

query =  " START current=node:stops(\"code:*\")"
query << " MATCH current-[r:route]->otherStop"
query << " RETURN current.code, current.lat, current.long, otherStop.code, otherStop.lat, otherStop.long, COUNT(otherStop) AS numberOfStops"
query << " ORDER BY numberOfStops"

def neo
	@neo ||= Neography::Rest.new
end

initial_result = neo.execute_query(query)["data"]

result = initial_result.map do |row|
	{ :from => { :code => row[0], :lat => row[1], :long => row[2] }, :to => { :code => row[3], :lat => row[4], :long => row[5] }, :routes => row[6] }
end

builder = Nokogiri::XML::Builder.new do |xml|
	xml.kml(:xmlns => "http://earth.google.com/kml/2.1") {
		xml.Document {
			xml.Style(:id => "style1") {
				xml.LineStyle {
					xml.color "385E0F" 
					xml.width "3"
				}
			}

			result.each do |row|
				xml.Placemark {
					xml.name row[:routes]
					xml.styleUrl "#style1"
					xml.LineString {
						xml.altitudeMode "relative"
						xml.coordinates "\n#{row[:from][:long]},#{row[:from][:lat]}\n#{row[:to][:long]},#{row[:to][:lat]}\n"
					}
				}
			end
		}
	}
end

puts builder.to_xml