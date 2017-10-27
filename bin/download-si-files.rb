#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)
require 'net/https'
require 'uri'


fqdns = JSON.parse(
  File.read('authoritative-fqdns.json'),
  {:symbolize_names => true}
)

si_dir = 'si_files'
Dir.mkdir(si_dir) unless File.exist?(si_dir)


fqdns.each do |fqdn|
  puts "Looking up #{fqdn}"

  begin
    service = RadioDNS::Service.new(fqdn)
    app = service.radioepg

    filepath = File.join(si_dir, fqdn + '.xml')

    uri = URI::HTTP.build(
      :host => app.host,
      :port => app.port,
      :path => '/radiodns/spi/3.1/SI.xml'
    )

    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      File.open(filepath, 'wb') do |file|
        file.write res.body
      end

      puts " => OK"
    else
      puts " => No SI file for #{fqdn} : #{res.message}"
    end

  rescue Resolv::ResolvError
    puts " => No RadioEPG for #{fqdn}"
  end

end

