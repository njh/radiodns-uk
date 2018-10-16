#!/usr/bin/env ruby

require_relative '../models'

Bearer.all.each do |bearer|
  puts "#{bearer.fqdn} (#{bearer[:ofcom_label]})"

  bearer.resolve!

  if bearer.authority.fqdn.nil?
    puts " => No RadioDNS entry"
  else
    puts " => #{bearer.authority.fqdn}"
  end
end
