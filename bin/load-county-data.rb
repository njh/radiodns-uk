#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)

require_relative '../models'


# First import the list of Countries
CSV.foreach("counties/countries.csv", :headers => true, :header_converters => [:downcase, :symbol]) do |row|
  next if row[:name].nil?

  Country.update_or_create(:name => row[:name]) do |country|
    country.wikidata_id = row[:wikidata_id]
    country.osm_relation_id = row[:osm_relation_id]
  end
end

countries = Hash[
  Country.all.map {|c| [c.name, c]}
]


CSV.foreach("counties/counties.csv", :headers => true, :header_converters => [:downcase, :symbol]) do |row|
  next if row[:name].nil?

  County.update_or_create(:name => row[:name]) do |county|
    county.country = countries[row[:country]]
    $stderr.puts "Warning: failed to identify country for #{row[:name]}" if county.country.nil?

    county.wikidata_id = row[:wikidata_id]
    county.osm_relation_id = row[:osm_relation_id]
  end
end
