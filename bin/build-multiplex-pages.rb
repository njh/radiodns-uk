#!/usr/bin/env ruby

require 'fileutils'
require 'bundler/setup'
Bundler.require(:default)

multiplexes = JSON.parse(
  File.read('source/multiplexes.json'),
  {:symbolize_names => true}
)

multiplexes.each_pair do |eid,multiplex|
  # Write JSON file for each multiplex
  multiplex_json_filepath = "source/multiplexes/#{eid}.json"
  FileUtils.mkdir_p(File.dirname(multiplex_json_filepath))
  File.open(multiplex_json_filepath, 'wb') do |file|
    file.write JSON.pretty_generate(multiplex)
  end

  # Write HTML ERB file for Middleman
  multiplex[:id] = eid
  multiplex[:layout] = :multiplex_layout
  multiplex_html_filepath = "source/multiplexes/#{eid}.html.erb"
  File.open(multiplex_html_filepath, 'wb') do |file|
    file.puts multiplex.to_yaml
    file.puts "---"
  end
end
