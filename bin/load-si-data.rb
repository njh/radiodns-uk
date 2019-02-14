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

def process_links(service, xml)
  xml.xpath("./link").each do |element|
    begin
      next unless element['uri']
      if element['uri'] =~ /^(\w+):/
        uri = URI.parse(element['uri'])
      else
        uri = URI.parse("http://#{element['uri']}")
      end
      if !uri.opaque and uri.path.empty?
        uri.path = '/'
      end

      link = Link.find_or_create(:uri => uri.to_s, :service => service)
      link.update(
        :mime_type => element['mimeValue'],
        :description => element['description']
      )
    rescue URI::InvalidURIError => e
      $stderr.puts "  => Warning: Invalid Link: #{link} (#{e})"
    end
  end
end

def parse_logos(element)
  logos = {}
  element.xpath("./mediaDescription/multimedia").each do |multimedia|
    if multimedia['type'] == 'logo_colour_square'
      key = '32x32'
      mime_type = 'image/png'
    elsif multimedia['type'] == 'logo_colour_rectangle'
      key = '112x32'
      mime_type = 'image/png'
    elsif multimedia['width'] && multimedia['height']
      unless multimedia['width'] =~ /^\d+$/ && multimedia['height'] =~ /^\d+$/
        $stderr.puts "  => Warning: Invalid logo dimensions"
        next
      end

      key = multimedia['width'] + 'x' + multimedia['height']
      mime_type = multimedia['mimeValue']
    end

    unless key.nil?
      logos[key] = { :url => multimedia['url'], :mime_type => mime_type }
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

def parse_genres(xml)
  genres = {}
  xml.xpath("./genre").each do |element|
    urn = element['href']
    if urn.nil?
      $stderr.puts "  => Warning: no href defined for genre"
    else
      if genres.has_key?(urn)
        $stderr.puts "  => Warning: duplicate genre: #{urn}"
      else
        genres[urn] = element.inner_text
      end
    end
  end
  return genres
end

def process_genres(service, xml)
  genres = parse_genres(xml)
  genres.keys.each do |urn|
    genre = Genre.find(:urn => urn)
    if genre.nil?
      $stderr.puts "  => Warning: unknown genre: #{urn}"
    else
      if service.genres_dataset.where(:genre_id => genre.id).empty?
        service.add_genre(genre)
      end
    end
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
        $stderr.puts "  => Warning: service has duplicate bearer IDs"
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

      # Set the DAB multiplex, if none set
      if bearer.type == Bearer::TYPE_DAB and bearer.multiplex_id.nil?
        bearer.multiplex = Multiplex.find(:eid => bearer.eid)
        if bearer.multiplex_id.nil?
          $stderr.puts "  => Warning: unknown multiplex for #{bearer_id}"
        end
        bearer.save
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

  radiodns = xml.at('./radiodns')
  unless radiodns.nil?
    service.fqdn = radiodns['fqdn']
    service.service_identifier = radiodns['serviceIdentifier']
  end

  service.save

  # Update the service ID to each of the bearers
  bearers.each { |b| b.update(:service_id => service.id) }

  process_links(service, xml)
  process_logos(service, xml)
  process_genres(service, xml)
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
  puts "Loading SI file for: #{authority}"

  begin
    authority.download_si_file
    if authority.si_uri.nil?
      puts " => No RadioEPG"
      next
    end

    filepath = authority.si_filepath
    unless File.exist?(filepath)
      puts "Error: file does not exist: #{filepath}"
      next
    end

    doc = File.open(filepath, 'rb') { |f| Nokogiri::XML(f) }
    doc.remove_namespaces!

    si = doc.at("/serviceInformation")
    if si
      # Set Creation Time on the Authority
      unless si['creationTime'].nil?
        authority.update(:updated_at => DateTime.parse(si['creationTime']))
      end

      # Load Service Provider information
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
  end

  puts
end
