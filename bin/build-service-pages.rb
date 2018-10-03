#!/usr/bin/env ruby

require 'fileutils'
require 'bundler/setup'
Bundler.require(:default)

def id_to_path(id)
  File.join(['services'] + id.split(/\W+/))
end

services = JSON.parse(
  File.read('source/services.json'),
  {:symbolize_names => true}
)

services.each do |service|
  # Write JSON file for each service
  service_json_filepath = File.join('source', id_to_path(service[:id]) + '.json')
  FileUtils.mkdir_p(File.dirname(service_json_filepath))
  File.open(service_json_filepath, 'wb') do |file|
    file.write JSON.pretty_generate(service)
  end

  # Alias is used by Middleman to create redirects
  ids = service[:bearers].keys.map {|id| id.to_s }
  ids.delete_if {|id| id == service[:id]}
  service[:alias] = ids.map {|id| id_to_path(id) + '/'}

  # Write HTML ERB file for Middleman
  service_html_filepath = File.join('source', id_to_path(service[:id]) + '.html.erb')
  File.open(service_html_filepath, 'wb') do |file|
    file.puts service.to_yaml
    file.puts "---"
  end
end
