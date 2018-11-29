#!/usr/bin/env ruby

require 'bundler/setup'
require('zip')

require_relative '../models'

IMAGE_SIZES = ['32x32', '112x32', '128x128']
ZIPFILE_DIR = 'public/logos'

unless Dir.exist?(ZIPFILE_DIR)
  Dir.mkdir(ZIPFILE_DIR)
end


def download_to_io(url, io, depth=0)
  if depth > 10
    raise "Too many redirects"
  end

  uri = URI.parse(url)
  Net::HTTP.get_response(uri) do |resp|
    if resp.code =~ /^3/
      download_to_io(resp['Location'], io, depth + 1)
    elsif resp.code =~ /^2/
      resp.read_body do |segment|
        io.write(segment)
      end
    else
      # This raises an exception
      resp.value
    end
  end

end

def logo_filename(logo)
  name = logo.service.medium_name || logo.service.short_name || logo.service.long_name
  name.gsub!(/[^a-zA-Z0-9]+/, '-')

  if logo.url =~ /(\.\w+)$/
    name + $1
  else
    name + '.png'
  end
end

def create_logopack_zip(zip_filepath, dirname, logos)
  Zip::File.open(zip_filepath, Zip::File::CREATE) do |zip|
    if zip.find_entry(dirname).nil?
      zip.mkdir(dirname)
    end

    logos.each do |logo|
      filename = logo_filename(logo)
      filepath = File.join(dirname, filename)

      if zip.find_entry(filepath).nil?
        puts "  Downloading logo: #{filename}"
        begin
          zip.get_output_stream(filepath) do |io|
            download_to_io(logo.url, io)
          end
        rescue => exp
          $stderr.puts "  => Failed to download: #{exp}"
          zip.remove(filepath)
        end
      end
    end
  end

end



IMAGE_SIZES.each do |size|
  logos = Logo.where(:size => size).eager_graph(:service).order(:sort_name).all

  dirname = "RadioStationLogos_#{size}_#{Date.today.iso8601}"
  zip_filepath = File.join(ZIPFILE_DIR, "RadioStationLogos_#{size}.zip")

  puts "Creating logopack zip file: #{zip_filepath}"
  create_logopack_zip(zip_filepath, dirname, logos)
  puts
end
