#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)
require_relative '../models'


Authority.valid.each do |authority|
  puts "Downloading SI for: #{authority.fqdn}"

  authority.download_si_file
end
