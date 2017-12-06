#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)
require './lib/bearer_resolver'

tx_params = JSON.parse(
  File.read('TxParams.json'),
  {:symbolize_names => true}
)


authoritative_fqdns = []

tx_params[:fm].each do |service|
  frequency = service[:transmitters].first[:frequency]
  puts "#{service[:name]} on #{frequency} / #{service[:rds_pi]}"

  fdqn = resolve_bearer_id(
    :bearer => 'fm',
    :freq => sprintf("%05d", frequency.to_f * 100),
    :pi => service[:rds_pi].downcase
  )

  if fdqn.nil?
    puts " => No RadioDNS entry"
  else
    puts " => #{fdqn}"
    authoritative_fqdns << fdqn
  end
end


tx_params[:dab].each do |service|
  puts "#{service[:name]} on #{service[:eid]} / #{service[:sid]}"

  fdqn = resolve_bearer_id(
    :bearer => 'dab',
    :eid => service[:eid].downcase,
    :sid => service[:sid].downcase,
    :scids => 0
  )

  if fdqn.nil?
    puts " => No RadioDNS entry"
  else
    puts " => #{fdqn}"
    authoritative_fqdns << fdqn
  end
end


# Finally, write to back to disk
File.open('authoritative-fqdns.json', 'wb') do |file|
  file.write JSON.pretty_generate(authoritative_fqdns.uniq)
end
