#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)

tx_params = JSON.parse(
  File.read('TxParams.json'),
  {:symbolize_names => true}
)


multiplexes = {}

tx_params[:dab].each do |service|
  eid = service[:eid].downcase
  multiplexes[eid] ||= {}
  multiplexes[eid][:name] ||= service[:ensemble_name]
  multiplexes[eid][:area] ||= service[:ensemble_area]
  multiplexes[eid][:updated_at] ||= service[:updated_at]
  multiplexes[eid][:block] ||= service[:transmitters].first[:block]
  multiplexes[eid][:frequency] ||= service[:transmitters].first[:frequency]
  multiplexes[eid][:transmitter_count] ||= service[:transmitters].count
  multiplexes[eid][:services] ||= []

  sid = service[:sid].downcase
  multiplexes[eid][:services] << {
    :name => service[:name],
    :sid => sid,
    :bearer_id => "dab:ce1.#{eid}.#{sid}.0"
  }
end


# Finally, write to back to disk
File.open('source/multiplexes.json', 'wb') do |file|
  file.write JSON.pretty_generate(multiplexes)
end
