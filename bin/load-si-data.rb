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

      fqdn = params.resolve_fqdn
      if fqdn.nil?
        $stderr.puts "  => Unable to resolve bearer #{bearer_id}"
        next
      elsif fqdn != authority.fqdn
        $stderr.puts "  => FQDN does not match for bearer #{bearer_id} = #{authority.fqdn}"
        next
      end

      bearer = Bearer.find_or_create(params.to_hash)
      bearer.authority = authority
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
  service = Service.new(
    :short_name => xml.content_at('./shortName'),
    :medium_name => xml.content_at('./mediumName'),
    :long_name => xml.content_at('./longName'),
    :short_description => xml.content_at('./mediaDescription/shortDescription'),
    :long_description => xml.content_at('./mediaDescription/longDescription')
  )
  
  if service.name.nil?
    $stderr.puts "Service has no name"
    return
  else
    $stderr.puts "  #{service.name}"
  end

  bearers = validate_bearers(authority, xml)
  if bearers.empty?
    $stderr.puts "  => Warning: service has no valid UK DAB or FM bearers"
    return
  end
  
  # Create the service
  service.save

  # Add the service ID to each of the bearers
  bearers.each { |b| b.update(:service_id => service.id) }
  
  # FIXME: do this better
  default_bearer = bearers.sort_by { |b| b.uri }.first
  service.update(:default_bearer_id => default_bearer.id)
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
