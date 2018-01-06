#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)
require 'net/https'
require 'uri'

filename = 'TxParams.xlsx'


# First: download the Technical parameters HTML page from Ofcom
uri = URI.parse('https://www.ofcom.org.uk/spectrum/information/radio-tech-parameters')
res = Net::HTTP.get_response(uri)
unless res.is_a?(Net::HTTPSuccess)
  raise "Failed to get radio-tech-parameters: #{res}"
end


# Second: find the link to TxParams.xslx
file_uri = nil
html_doc = Nokogiri::HTML(res.body)
html_doc.css("a").each do |a|
  href_uri = URI.parse(a['href'])
  if File.basename(href_uri.path).match?(/(TxParams|TechParams)\.xlsx/)
    file_uri = href_uri
  end
end

if file_uri.nil?
  raise "Failed to find link to #{filename}"
end


# Third: download the file
puts "Downloading: #{file_uri}"
file = open(filename, 'wb')
begin
  Net::HTTP.get_response(file_uri) do |resp|
    resp.read_body do |segment|
      file.write(segment)
    end
  end
ensure
  file.close()
end
