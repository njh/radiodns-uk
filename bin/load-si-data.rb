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

def process_logos(service, xml)
  logos = parse_logos(xml)
  logos.each do |size, properties|
    logo = Logo.find_or_create(:service => service, :size => size)
    logo.update(properties)
  end
end


def validate_bearers(authority, xml)
  bearers = {}
  xml.xpath("bearer").each do |xmlbearer|
    if xmlbearer['id']
      bearer_id = xmlbearer['id'].downcase

      # Ignore bearers that aren't UK DAB/FM for now
      next unless bearer_id =~ /^(fm|dab):ce1\./

      # Check for duplicates
      if bearers.has_key?(bearer_id)
        $stderr.puts "  => Warning: service has duplicate beaerer IDs"
        next
      end
      
      params = Bearer.parse_uri(bearer_id)
      if params.nil?
        $stderr.puts "  => Warning: invalid bearer: #{bearer_id}"
        next
      end

      # Find or initialise a new bearer
      bearer = Bearer.find(params) || Bearer.new(params)
      if bearer.authority_id.nil?
         $stderr.puts "  => Warning: not an Ofcom bearer #{bearer_id}"
      end

      # Check that the bearer matches
      fqdn = bearer.authority.fqdn
      if fqdn.nil?
        $stderr.puts "  => Unable to resolve bearer #{bearer_id}"
        next
      elsif fqdn != authority.fqdn
        $stderr.puts "  => FQDN does not match for bearer #{bearer_id} = #{authority.fqdn}"
        next
      end

      # Update/create the bearer
      bearer.bitrate = xmlbearer['bitrate'].to_i unless xmlbearer['bitrate'].nil?
      bearer.cost = xmlbearer['cost'].to_i unless xmlbearer['bitrate'].nil?
      bearer.offset = xmlbearer['offset'].to_i unless xmlbearer['offset'].nil?
      bearer.mime_type = xmlbearer['mimeValue'] unless xmlbearer['mimeValue'].nil?
      bearer.save

      # Keep in a hash to help checking for duplicates
      bearers[bearer_id] = bearer
    end
  end

  bearers.values
end


def process_service(authority, xml)
  puts "  #{xml.content_at('./longName') || xml.content_at('./mediumName')}"
  bearers = validate_bearers(authority, xml)
  if bearers.empty?
    $stderr.puts "  => Warning: service has no valid UK DAB or FM bearers"
    return
  end

  # FIXME: find a better way of choosing a default bearer
  default_bearer = bearers.sort_by { |b| b.uri }.first
  
  # Get the existing service or create a new one
  service = default_bearer.service || Service.new
  service.short_name = xml.content_at('./shortName')
  service.medium_name = xml.content_at('./mediumName')
  service.long_name = xml.content_at('./longName')
  service.short_description = xml.content_at('./mediaDescription/shortDescription')
  service.long_description = xml.content_at('./mediaDescription/longDescription')
  service.authority_id = authority.id
  service.default_bearer_id = default_bearer.id
  service.save
  
  process_logos(service, xml)

  # Update the service ID to each of the bearers
  bearers.each { |b| b.update(:service_id => service.id) }
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
  puts "Loading: #{authority}"
  filepath = authority.si_filepath
  unless File.exist?(filepath)
    puts "File does not exist: #{filepath}"
    next
  end 
  
  begin
    doc = File.open(filepath, 'rb') { |f| Nokogiri::XML(f) }
    doc.remove_namespaces!

    si = doc.at("/serviceInformation")
    if si
      sp = si.at("./services/serviceProvider")
      process_service_provider(authority, sp) unless sp.nil?

      si.xpath("./services/service").each do |service|
        begin
          process_service(authority, service)
        rescue => e
          $stderr.puts "Failed to process service: #{filepath}:line (#{e})"
          $stderr.puts e.backtrace.join("\n")
        end
      end
    else
      raise "SI file for #{authority.fqdn} does not contain serviceInformation element"
    end

  rescue => e
    $stderr.puts "Failed to parse file: #{filepath} (#{e})"
    $stderr.puts e.backtrace.join("\n")
    authority.update(:have_radioepg => false)
  end

  puts
end
