#!/usr/bin/env ruby

require 'fileutils'
require 'bundler/setup'
Bundler.require(:default)
require './lib/genres'
require './lib/bearer_resolver'


class Nokogiri::XML::Element

  def inner_text_at(path)
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

def id_to_path(id)
  File.join(['services'] + id.split(/\W+/))
end


def process_service(element, fqdn)
  name = element.inner_text_at('longName') || element.inner_text_at('mediumName') || element.inner_text_at('shortName')
  return if name.nil?
  puts "  #{name}"

  service = {
    :id => nil,
    :name => name,
    :sort_name => name.sub(/^[\d\.]+(fm)?\s+/i, '').sub(/^the\s+/i, '').downcase,
    :short_name => element.inner_text_at(:shortName),
    :medium_name => element.inner_text_at(:mediumName),
    :long_name => element.inner_text_at(:longName),
    :short_description => element.inner_text_at('mediaDescription/shortDescription'),
    :long_description => element.inner_text_at('mediaDescription/longDescription'),
    :fqdn => fqdn,
    :logos => {},
    :links => [],
    :bearers => [],
    :genres => {}
  }

  element.xpath("mediaDescription/multimedia").each do |multimedia|
    if multimedia['width'] && multimedia['height'] && multimedia['url']
      key = multimedia['width'] + 'x' + multimedia['height']
      service[:logos][key] = multimedia['url']
    elsif multimedia['type'] == 'logo_colour_square'
      service[:logos]['32x32'] = multimedia['url']
    elsif multimedia['type'] == 'logo_colour_rectangle'
      service[:logos]['112x32'] = multimedia['url']
    end
  end

  element.xpath("link").each do |link|
    begin
      next unless link['uri']
      if link['uri'] =~ /^(\w+):/
        uri = URI.parse(link['uri'])
      else
        uri = URI.parse("http://#{link['uri']}")
      end
      if !uri.opaque and uri.path.empty?
        uri.path = '/'
      end
      service[:links] << uri.to_s
    rescue URI::InvalidURIError => e
      $stderr.puts "Invalid Link: #{link} (#{e})"
    end
  end

  element.xpath("bearer").each do |xmlbearer|
    if xmlbearer['id']
      bearer_id = xmlbearer['id'].downcase

      # Ignore bearers that aren't UK DAB/FM for now
      next unless bearer_id =~ /^(fm|dab):(gb|ce1)/

      bearer_fdqn = resolve_bearer_id(bearer_id)
      if bearer_fdqn.nil?
        $stderr.puts "  => Unable to resolve bearer #{bearer_id}"
        next
      elsif bearer_fdqn != fqdn
        $stderr.puts "  => FQDN does not match for bearer #{bearer_id} = #{bearer_fdqn}"
        next
      end

      bearer = { :id => bearer_id }
      bearer[:bitrate] = xmlbearer['bitrate'].to_i unless xmlbearer['bitrate'].nil?
      bearer[:cost] = xmlbearer['cost'].to_i unless xmlbearer['bitrate'].nil?
      bearer[:offset] = xmlbearer['offset'].to_i unless xmlbearer['offset'].nil?
      bearer[:mimeValue] = xmlbearer['mimeValue'] unless xmlbearer['mimeValue'].nil?
      service[:bearers] << bearer
    end
  end

  ids = service[:bearers].map {|b| b[:id] }.sort
  if ids.empty?
    $stderr.puts "  => Warning: service has no valid bearers"
    return
  end

  service[:id] = ids.shift
  service[:alias] = ids.map { |id| id_to_path(id) + '/' }

  element.xpath("genre").each do |genre|
    if genre['href']
      label = genre.inner_text
      if label.empty?
        label = Genres.lookup(genre['href'])
        if label.nil?
          $stderr.puts "WARNING: unknown genre: #{genre['href']}"
          label = "Unknown (#{genre['href']})"
        end
      end
      service[:genres][genre['href']] = label
    end
  end

  service_file = File.join('source', id_to_path(service[:id]) + '.html.erb')
  FileUtils.mkdir_p(File.dirname(service_file))
  File.open(service_file, 'wb') do |file|
    file.puts service.to_yaml
    file.puts "---"
  end
end


Dir.glob("si_files/*.xml").each do |filepath|
  puts "Parsing: #{filepath}"
  begin
    doc = File.open(filepath, 'rb') { |f| Nokogiri::XML(f) }
    doc.remove_namespaces!

    fqdn = File.basename(filepath, '.xml')
    doc.xpath("/serviceInformation/services/service").each do |element|
      begin
        process_service(element, fqdn)
      rescue => e
        $stderr.puts "Failed to process service: #{filepath}:line (#{e})"
      end
    end

  rescue => e
    $stderr.puts "Failed to parse file: #{filepath} (#{e})"
  end

  puts
end
