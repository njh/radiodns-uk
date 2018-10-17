#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)

require_relative '../models'

class Nokogiri::XML::Element
  def content_at(path)
    node = at(path)
    if node.nil?
      nil
    elsif node.inner_text.empty?
      nil
    else
      node.inner_text
    end
  end
end

def parse_logos(element)
  logos = {}
  element.xpath("./mediaDescription/multimedia").each do |multimedia|
    key = if multimedia['type'] == 'logo_colour_square'
      '32x32'
    elsif multimedia['type'] == 'logo_colour_rectangle'
      '112x32'
    elsif multimedia['width'] && multimedia['height']
      multimedia['width'] + 'x' + multimedia['height']
    end

    unless key.nil?
      logos[key] = { :url => multimedia['url'] }
    end
  end
  return logos
end


def process_service_provider(authority, xml)
  authority.name = xml.content_at('./longName') ||
                   xml.content_at('./mediumName') ||
                   xml.content_at('./shortName')
  authority.description = xml.content_at('./mediaDescription/longDescription') ||
                          xml.content_at('./mediaDescription/shortDescription')

  link = xml.at('./link')
  authority.link = link['uri'] unless link.nil?

  logo = parse_logos(xml)['320x240']
  authority.logo = logo[:url] unless logo.nil?
  authority.save
end


Authority.valid.each do |authority|
  filepath = authority.si_filepath
  unless File.exist?(filepath)
    $stderr.puts "File does not exist: #{filepath}"
    next
  end

  begin
    doc = File.open(filepath, 'rb') { |f| Nokogiri::XML(f) }
    doc.remove_namespaces!

    si = doc.at("/serviceInformation")
    if si
      sp = si.at("./services/serviceProvider")
      process_service_provider(authority, sp) unless sp.nil?
    end

  rescue => e
    $stderr.puts "Failed to parse file: #{filepath} (#{e})"
    $stderr.puts e.backtrace.join("\n")
    authority.set(:have_radioepg => false)
  end

end
