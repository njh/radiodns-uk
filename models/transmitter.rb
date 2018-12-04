require 'digest'

class Transmitter < Sequel::Model
  many_to_many :multiplexes, :order => :name  # DAB
  many_to_many :bearers      # FM

  def path
    "/transmitters/#{ngr.downcase}"
  end

  def uri
    RADIODNS_UK_BASE + path
  end
end

# Table: transmitters
# Columns:
#  id          | integer          | PRIMARY KEY AUTOINCREMENT
#  ngr         | varchar(8)       |
#  name        | varchar(255)     |
#  area        | varchar(255)     |
#  lat         | double precision |
#  long        | double precision |
#  site_height | integer          |
#  updated_at  | date             |
# Indexes:
#  sqlite_autoindex_transmitters_1 | UNIQUE (ngr)
