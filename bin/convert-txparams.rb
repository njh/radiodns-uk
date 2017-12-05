#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)


class String
  def titleize_if_caps
    if self =~ /^[A-Z\W]+$/
      self.titleize
    else
      self
    end
  end
end

def clean_column_names(sheet, header_column=1)
  sheet.row(header_column).map do |col|
    col.to_s.strip.downcase.gsub(/\W+/,'_').sub(/_$/,'')
  end
end


def generate_fm(xlsx, sheet_name)
  services = {}

  sheet = xlsx.sheet(sheet_name)
  column_names = clean_column_names(sheet)

  (2..sheet.last_row).each do |row_num|
    row = sheet.row(row_num)
    hash = Hash[column_names.zip(row)]

    next if hash['station'].nil? or hash['frequency'].nil? or hash['rds_pi'].nil?

    key = hash['station'] + '#' + hash['rds_pi']
    services[key] ||= {
      :name => hash['station'],
      :rds_ps => hash['rds_ps'],
      :rds_pi => hash['rds_pi'],
      :transmitters => [],
    }

    services[key][:transmitters] << {
      :frequency => hash['frequency'],
      :site => hash['site'].titleize_if_caps,
      :area => hash['area'],
      :lat => hash['lat'],
      :long => hash['long'],
      :updated_at => hash['date']
    }
  end

  return services.values
end


def generate_dab(xlsx, sheet_name)
  services = {}

  sheet = xlsx.sheet(sheet_name)
  column_names = clean_column_names(sheet)

  (2..sheet.last_row).each do |row_num|
    row = sheet.row(row_num)
    hash = Hash[column_names.zip(row)]

    eid = hash['eid']
    next if eid.nil?
    services[eid] ||= {}


    # There can be up to 20 services per ensemble
    (1..20).each do |num|
      sid = hash["sid_#{num}_hex"]
      next if sid.nil?

      services[eid][sid] ||= {
        :name => hash["serv_label#{num}"],
        :eid => eid,
        :sid => sid,
        :ensemble_name => hash['ensemble'],
        :ensemble_area => hash['ensemble_area'],
        :transmitters => [],
        :updated_at => hash['date']
      }

      services[eid][sid][:transmitters] << {
        :name => hash['site'].titleize_if_caps,
        :frequency => hash['freq'],
        :block => hash['block'],
        :area => hash['transmitter_area'],
        :lat => hash['lat'],
        :long => hash['long'],
      }
    end

  end

  services.values.map {|services| services.values}.flatten
end




xlsx = Roo::Spreadsheet.open('TxParams.xlsx')
puts "TxParams Sheets: #{xlsx.sheets.join(', ')}"

data = {}
data[:fm] = generate_fm(xlsx, 'VHF')
data[:dab] = generate_dab(xlsx, 'DAB')

puts "FM services: #{data[:fm].count}"
puts "DAB services: #{data[:dab].count}"


# Finally, write to back to disk
File.open('TxParams.json', 'wb') do |file|
  file.write JSON.pretty_generate(data)
end
