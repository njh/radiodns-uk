#!/usr/bin/env ruby
#
# Load extra information about multiplexes from Wikidata
#

require 'bundler/setup'
Bundler.require(:default)

require_relative '../models'
require 'sparql/client'

sparql = SPARQL::Client.new(
  "https://query.wikidata.org/sparql",
  headers: {'User-Agent' => 'radiodns.uk/1.0'}
)


query = <<END
SELECT *
WHERE 
{
  ?item wdt:P31 wd:Q5204199 .   # instance of: DAB Ensemble
  ?item wdt:P17 wd:Q145 .       # country: United Kingdom
  OPTIONAL { ?item wdt:P127 ?owner . }
  OPTIONAL { ?item wdt:P571 ?inception . }
  OPTIONAL { ?item wdt:P856 ?homepage . }
  OPTIONAL { ?item wdt:P2002 ?twitter . }
  OPTIONAL { ?item wdt:P7576 ?bearer . }

  FILTER NOT EXISTS {
    ?item wdt:P576 ?abolished .
  }

  OPTIONAL { 
    ?article schema:about ?item .
    ?article schema:isPartOf <https://en.wikipedia.org/>.
  }
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
}
END


result = sparql.query(query)

result.each do |row|
  unless row[:bearer].to_s =~ /^dab:([0-9a-f]{3})\.([0-9a-f]{4})$/
    $stderr.puts "Error: invalid bearer ID for #{row[:item]}"
    next 
  end

  gcc = $1.upcase
  eid = $2.upcase
  if gcc != 'CE1'
    $stderr.puts "Error: GCC for #{row[:item]} is not 'CE1'"
    next
  end

  multiplex = Multiplex.find(:eid => eid)
  if multiplex.nil?
    $stderr.puts "Error: multiplex #{row[:item]} not found"
    next
  end

  # Store in database
  multiplex.name = row[:itemLabel]
  multiplex.launch_date = row[:inception].to_s
  multiplex.homepage = row[:homepage]
  multiplex.twitter_username = row[:twitter]
  multiplex.wikidata_id = File.basename(row[:item].path)
  multiplex.wikipedia_url = row[:article]
  multiplex.save
end
