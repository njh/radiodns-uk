#!/usr/bin/env ruby

require_relative '../models'

# Make sure the 'null' database entry exists
Authority.find_or_create(:fqdn => nil)

Bearer.all.each do |bearer|
  puts "#{bearer.fqdn} (#{bearer[:ofcom_label]})"

  bearer.resolve!

  if bearer.authority.fqdn.nil?
    puts " => No RadioDNS entry"
  else
    puts " => #{bearer.authority.fqdn}"
  end
end
