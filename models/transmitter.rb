require 'digest'

class Transmitter < Sequel::Model
  many_to_many :multiplexes, :order => :name  # DAB
  many_to_many :bearers      # FM
  many_to_one :county
  many_to_one :country

  def path
    "/transmitters/#{ngr.downcase}"
  end

  def uri
    RADIODNS_UK_BASE + path
  end

  # Normalise National Grid Reference (OSGB36) - we only use 6-digits
  def self.normalise_ngr(ngr)
    if ngr =~ /^([A-Z]{2})\s*(\d{3})\s*(\d{3})$/
      $1 + $2 + $3
    elsif ngr =~ /^([A-Z]{2})\s*(\d{4})\s*(\d{4})$/
      $1 + $2[0,3] + $3[0,3]
    elsif ngr =~ /^([A-Z]{2})\s*(\d{5})\s*(\d{5})$/
      $1 + $2[0,3] + $3[0,3]
    else
      $stderr.puts "Failed to parse National Grid Reference: #{ngr}"
    end
  end
end

# Table: transmitters
# Columns:
#  id          | integer          | PRIMARY KEY AUTOINCREMENT
#  ngr         | varchar(8)       |
#  name        | varchar(255)     |
#  area        | varchar(255)     |
#  county_id   | integer          |
#  country_id  | integer          |
#  lat         | double precision |
#  long        | double precision |
#  site_height | integer          |
#  total_power | double precision |
#  updated_at  | date             |
# Indexes:
#  sqlite_autoindex_transmitters_1 | UNIQUE (ngr)
#  transmitters_country_id_index   | (country_id)
#  transmitters_county_id_index    | (county_id)
