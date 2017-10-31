#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)

RADIODNS_ECC = 'ce1'


tx_params = JSON.parse(
  File.read('TxParams.json'),
  {:symbolize_names => true}
)


authoritative_fqdns = []

tx_params[:fm].each do |service|

  begin
    frequency = service[:transmitters].first[:frequency]
    puts "#{service[:name]} on #{frequency} / #{service[:rds_pi]}"

    result = RadioDNS::Resolver.resolve(
      :bearer => 'fm',
      :ecc => RADIODNS_ECC,
      :freq => sprintf("%05d", frequency * 100),
      :pi => service[:rds_pi].downcase
    )

    puts " => #{result.cname}"
    authoritative_fqdns << result.cname

  rescue Resolv::ResolvError
    puts " => No RadioDNS entry"
  end
end


tx_params[:dab].each do |service|
  begin
    puts "#{service[:name]} on #{service[:eid]} / #{service[:sid]}"

    result = RadioDNS::Resolver.resolve(
      :bearer => 'dab',
      :ecc => RADIODNS_ECC,
      :eid => service[:eid].downcase,
      :sid => service[:sid].downcase,
      :scids => 0
    )

    puts " => #{result.cname}"
    authoritative_fqdns << result.cname

  rescue Resolv::ResolvError
    puts " => No RadioDNS entry"
  end
end


# Finally, write to back to disk
File.open('authoritative-fqdns.json', 'wb') do |file|
  file.write JSON.pretty_generate(authoritative_fqdns.uniq)
end
