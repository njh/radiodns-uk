#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)

require 'net/https'
require 'uri'
require_relative '../models'
require_relative '../lib/osgb'

filename = 'TxParams.xlsx'

## FIXME: the must be a better way of contructing a new URI relative to an existing one
def parse_relative_uri(url, relative_to)
  uri = URI.parse(url)
  if uri.host.nil? and uri.path =~ %r|^/|
    http_uri = relative_to.clone
    http_uri.path = uri.path
    http_uri.query = uri.query
    return http_uri
  end

  return uri
end

def download_ofcom_data(filename)
  # First: download the Technical parameters HTML page from Ofcom
  uri = URI.parse('https://www.ofcom.org.uk/tv-radio-and-on-demand/coverage-and-transmitters/radio-tech-parameters')
  res = Net::HTTP.get_response(uri)
  unless res.is_a?(Net::HTTPSuccess)
    raise "Failed to get radio-tech-parameters: #{res}"
  end


  # Second: find the link to TxParams.xslx
  file_uri = nil
  html_doc = Nokogiri::HTML(res.body)
  html_doc.css("a").each do |a|
    href_uri = parse_relative_uri(a['href'], uri)
    next unless href_uri.path

    if href_uri.path =~ /(TxParams|Tx_Params|TechParams)-?\w*\.xlsx/i
      file_uri = href_uri
    end
  end

  if file_uri.nil?
    raise "Failed to find link to #{filename}"
  end


  # Third: download the file
  puts "Downloading: #{file_uri}"
  begin
    # FIXME: do we need to be able to follow redirects?
    Net::HTTP.get_response(file_uri) do |resp|
      raise "Failed to download TxParams: #{resp.message}" unless resp.code == '200'
      File.open(filename, 'wb') do |file|
        resp.read_body { |segment| file.write(segment) }
      end
    end
  rescue => exp
    File.delete(filename) if File.exist?(filename)
    raise exp
  end
end


def clean_column_names(sheet, header_column=1)
  sheet.row(header_column).map do |col|
    col.to_s.strip.downcase.gsub(/\W+/,'_').sub(/_$/,'').to_sym
  end
end

def titleize_if_caps(str)
  if str =~ /^[A-Z\W]+$/
    str.titleize
  else
    str
  end
end


def create_fm_bearer(label, frequency, pi_code, transmitter)
  bearer = Bearer.find_or_create(
    :type => Bearer::TYPE_FM,
    :frequency => frequency.to_f,
    :sid => pi_code.upcase
  )

  bearer.from_ofcom = true
  bearer.ofcom_label ||= label
  bearer.save

  # Link the bearer to the transmitter
  unless bearer.transmitters.include?(transmitter)
    bearer.add_transmitter(transmitter)
  end
end

def import_fm(xlsx, sheet_name)
  sheet = xlsx.sheet(sheet_name)
  column_names = clean_column_names(sheet)

  (2..sheet.last_row).each do |row_num|
    row = sheet.row(row_num)
    hash = Hash[column_names.zip(row)]

    next if hash[:station].nil? or hash[:frequency].nil? or hash[:rds_pi].nil?

    ngr = OSGB.normalise(hash[:ngr])
    next if ngr.nil?

    transmitter = Transmitter.find_or_create(:ngr => ngr)
    transmitter.name ||= titleize_if_caps(hash[:site])
    transmitter.area ||= titleize_if_caps(hash[:area])
    transmitter.lat ||= hash[:lat]
    transmitter.long ||= hash[:long]
    transmitter.site_height ||= hash[:site_ht]
    transmitter.total_power ||= 0
    # This is a bit lengthy due to Ofcom changing column names
    transmitter.total_power +=
      hash[:in_useerp_hp].to_f + hash[:in_useerp_vp].to_f +
      hash[:in_use_erp_hp].to_f + hash[:in_use_erp_vp].to_f
    transmitter.updated_at ||= hash[:date]
    transmitter.save

    create_fm_bearer(hash[:station], hash[:frequency], hash[:rds_pi], transmitter)

    unless hash[:switched_pi].nil?
      create_fm_bearer(hash[:station], hash[:frequency], hash[:switched_pi], transmitter)
    end
  end
end


def import_dab(xlsx, sheet_name)
  sheet = xlsx.sheet(sheet_name)
  column_names = clean_column_names(sheet)

  (2..sheet.last_row).each do |row_num|
    row = sheet.row(row_num)
    hash = Hash[column_names.zip(row)]

    ngr = OSGB.normalise(hash[:ngr])
    next if ngr.nil?

    transmitter = Transmitter.find_or_create(:ngr => ngr)
    transmitter.name ||= titleize_if_caps(hash[:site])
    transmitter.area ||= titleize_if_caps(hash[:transmitter_area])
    transmitter.lat ||= hash[:lat]
    transmitter.long ||= hash[:long]
    transmitter.site_height ||= hash[:site_height]
    transmitter.total_power ||= 0
    transmitter.total_power += hash[:in_use_erp_total].to_f
    transmitter.updated_at ||= hash[:date]
    transmitter.save

    next if hash[:eid].nil?
    multiplex = Multiplex.find_or_create(:eid => hash[:eid])
    multiplex.name ||= hash[:ensemble]
    multiplex.area ||= hash[:ensemble_area]
    multiplex.licence_number ||= hash[:licence]
    multiplex.frequency ||= hash[:freq]
    multiplex.block ||= hash[:block]
    multiplex.updated_at ||= hash[:date]
    multiplex.save

    # Link the transmitter to the multiplex
    unless multiplex.transmitters.include?(transmitter)
      multiplex.add_transmitter(transmitter)
    end

    # Go through each of the columns and look for services
    hash.each_pair do |key,sid|
      next unless key =~ /^sid_(\d+)_hex$/
      num = $1.to_i
      next unless sid =~ /^[0-9a-fA-Z]{4}$/

      bearer = Bearer.find_or_create(
        :type => Bearer::TYPE_DAB,
        :eid => hash[:eid].upcase,
        :sid => sid.upcase
      )

      bearer.from_ofcom = true
      bearer.ofcom_label ||= hash["serv_label#{num}".to_sym]
      bearer.multiplex_id = multiplex.id
      bearer.save
    end
  end
end



if File.exist?(filename)
  puts "#{filename} has already been downloaded"
else
  download_ofcom_data(filename)
end



xlsx = Roo::Spreadsheet.open('TxParams.xlsx')
puts "TxParams Sheets: #{xlsx.sheets.join(', ')}"

import_dab(xlsx, 'DAB')
import_fm(xlsx, 'VHF')

puts "   DAB Bearers: #{Bearer.where(:type => Bearer::TYPE_DAB).count}"
puts "    FM Bearers: #{Bearer.where(:type => Bearer::TYPE_FM).count}"
puts "  Transmitters: #{Transmitter.count}"
puts "   Multiplexes: #{Multiplex.count}"
