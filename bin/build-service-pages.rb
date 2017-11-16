#!/usr/bin/env ruby

require 'fileutils'
require 'bundler/setup'
Bundler.require(:default)
require './lib/genres'


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


Dir.glob("si_files/*.xml").each do |filepath|
  puts "Parsing: #{filepath}"
  begin
    doc = File.open(filepath, 'rb') { |f| Nokogiri::XML(f) }
    doc.remove_namespaces!

    doc.xpath("/serviceInformation/services/service").each do |element|
      name = element.inner_text_at('longName') || element.inner_text_at('mediumName') || element.inner_text_at('shortName')
      next if name.nil?
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
        :fqdn => File.basename(filepath, '.xml'),
        :logos => {},
        :links => [],
        :bearers => [],
        :genres => {}
      }

      element.xpath("mediaDescription/multimedia").each do |multimedia|
        if multimedia['width'] && multimedia['height']
          key = multimedia['width'] + 'x' + multimedia['height']
          service[:logos][key] = multimedia['url']
        elsif multimedia['type'] == 'logo_colour_square'
          service[:logos]['32x32'] = multimedia['url']
        elsif multimedia['type'] == 'logo_colour_rectangle'
          service[:logos]['112x32'] = multimedia['url']
        end
      end

      element.xpath("link").each do |link|
        if link['uri']
          service[:links] << link['uri']
        end
      end

      element.xpath("bearer").each do |xmlbearer|
        if xmlbearer['id']
          bearer = { :id => xmlbearer['id'].downcase }
          bearer[:bitrate] = xmlbearer['bitrate'].to_i unless xmlbearer['bitrate'].nil?
          bearer[:cost] = xmlbearer['cost'].to_i unless xmlbearer['bitrate'].nil?
          bearer[:offset] = xmlbearer['offset'].to_i unless xmlbearer['offset'].nil?
          bearer[:mimeValue] = xmlbearer['mimeValue'] unless xmlbearer['mimeValue'].nil?
          service[:bearers] << bearer
        end
      end

      ids = service[:bearers].map {|b| b[:id] }.select {|b| b.match(/^(fm|dab)/)}.sort
      next if ids.empty?
      service[:id] = ids.shift
      service[:alias] = ids.map { |id| id_to_path(id) + '/' }

      element.xpath("genre").each do |genre|
        if genre['href']
          label = genre.inner_text
          if label.empty?
            label = Genres.lookup(genre['href'])
            if label.nil?
              puts "WARNING: unknown genre: #{genre['href']}"
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

  rescue => e
    puts "Failed to process: #{filepath} (#{e})"
  end

end
