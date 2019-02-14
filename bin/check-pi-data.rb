#!/usr/bin/env ruby
#
# Check if Programme Information file exists for each service
#

require 'bundler/setup'
Bundler.require(:default)

require_relative '../models'



def check_for_pi(uri)
  res = Net::HTTP.get_response(uri)
  if res.is_a?(Net::HTTPSuccess)
    if res['Content-Type'] !~ %r"^(application|text)/xml"
      puts " => Not XML"
      return false
    end

    begin
      doc = Nokogiri::XML(res.body)
      doc.remove_namespaces!
      if !doc.at('/epg')
        puts " => Doesn't contain top level <epg> XML tag"
        return false
      end
    rescue => e
      puts " => Failed to parse PI XML: #{e}"
      return false
    end
      
    puts " => OK"
    true
  else
    puts " => #{res.message}"
    false
  end
end


Service.valid.each do |service|
  puts "Checking PI file for: #{service}"

  service.have_pi = check_for_pi(service.pi_uri)
  service.save

  puts
end
