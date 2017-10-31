#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)

class Nokogiri::XML::Element

  def inner_text_at(path)
    node = at(path)
    node.inner_text unless node.nil?
  end

end


services = []

Dir.glob("si_files/*.xml").each do |filepath|
  puts "Parsing: #{filepath}"
  begin
    doc = File.open(filepath, 'rb') { |f| Nokogiri::XML(f) }
    doc.remove_namespaces!
    
    doc.xpath("/serviceInformation/services/service").each do |element|
      name = element.at('longName') || element.at('mediumName') || element.at('shortName')
      puts "  #{name.inner_text}"

      service = {
        :short_name => element.inner_text_at(:shortName),
        :medium_name => element.inner_text_at(:mediumName),
        :long_name => element.inner_text_at(:longName),
        :short_description => element.inner_text_at('mediaDescription/shortDescription'),
        :long_description => element.inner_text_at('mediaDescription/longDescription'),
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
          bearer = { :id => xmlbearer['id'] }
          bearer[:bitrate] = xmlbearer['bitrate'].to_i unless xmlbearer['bitrate'].nil?
          bearer[:cost] = xmlbearer['cost'].to_i unless xmlbearer['bitrate'].nil?
          bearer[:offset] = xmlbearer['offset'].to_i unless xmlbearer['offset'].nil?
          bearer[:mimeValue] = xmlbearer['mimeValue'] unless xmlbearer['mimeValue'].nil?
          service[:bearers] << bearer
        end
      end

      element.xpath("genre").each do |genre|
        if genre['href']
          service[:genres][genre['href']] = genre.inner_text
        end
      end
      
      services << service
    end
    
  rescue => e
    puts "Failed to parse: #{filepath} (#{e})"
  end

end


File.open('services.json', 'wb') do |file|
  file.write JSON.pretty_generate(services)
end
