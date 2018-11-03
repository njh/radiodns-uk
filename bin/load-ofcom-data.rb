#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)

require 'net/https'
require 'uri'
require_relative '../models'

filename = 'TxParams.xlsx'


def download_ofcom_data(filename)
  # First: download the Technical parameters HTML page from Ofcom
  uri = URI.parse('https://www.ofcom.org.uk/spectrum/information/radio-tech-parameters')
  res = Net::HTTP.get_response(uri)
  unless res.is_a?(Net::HTTPSuccess)
    raise "Failed to get radio-tech-parameters: #{res}"
  end


  # Second: find the link to TxParams.xslx
  file_uri = nil
  html_doc = Nokogiri::HTML(res.body)
  html_doc.css("a").each do |a|
    href_uri = URI.parse(a['href'])
    if File.basename(href_uri.path) =~ /(TxParams|TechParams)\.xlsx/
      file_uri = href_uri
    end
  end

  if file_uri.nil?
    raise "Failed to find link to #{filename}"
  end


  # Third: download the file
  puts "Downloading: #{file_uri}"
  File.open(filename, 'wb') do |file|
    begin
      Net::HTTP.get_response(file_uri) do |resp|
        resp.read_body do |segment|
          file.write(segment)
        end
      end
    rescue => exp
      File.delete(filename)
      raise exp
    end
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

# Parse National Grid Reference (OSGB36) - we only use 6-digits
def parse_ngr(ngr)
  if ngr =~ /^([A-Z]{2})\s*(\d{3,5})\s*(\d{3,5})$/
    $1 + $2[0,3] + $3[0,3]
  else
    $stderr.puts "Failed to parse National Grid Reference: #{ngr}"
  end
end


def create_fm_bearer(label, frequency, pi_code, transmitter)
  bearer = Bearer.find_or_create(
    :type => Bearer::TYPE_FM,
    :frequency => frequency.to_f,
    :sid => pi_code
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

    ngr = parse_ngr(hash[:ngr])
    next if ngr.nil?

    transmitter = Transmitter.find_or_create(:ngr => ngr)
    transmitter.name ||= titleize_if_caps(hash[:site])
    transmitter.area ||= titleize_if_caps(hash[:area])
    transmitter.lat ||= hash[:lat]
    transmitter.long ||= hash[:long]
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

    ngr = parse_ngr(hash[:ngr])
    next if ngr.nil?

    transmitter = Transmitter.find_or_create(:ngr => ngr)
    transmitter.name ||= titleize_if_caps(hash[:site])
    transmitter.area ||= titleize_if_caps(hash[:transmitter_area])
    transmitter.lat ||= hash[:lat]
    transmitter.long ||= hash[:long]
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


    # There can be up to 20 services per ensemble
    (1..20).each do |num|
      sid = hash["sid_#{num}_hex".to_sym]
      next if sid.nil?

      bearer = Bearer.find_or_create(
        :type => Bearer::TYPE_DAB,
        :eid => hash[:eid],
        :sid => sid
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
