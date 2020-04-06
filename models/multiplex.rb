class Multiplex < Sequel::Model
  one_to_many :bearers, :order => :sid
  many_to_many :transmitters, :order => :name

  def path
    "/multiplexes/#{eid.downcase}"
  end

  def uri
    RADIODNS_UK_BASE + path
  end
  
  def twitter_url
    "https://twitter.com/#{twitter_username}" unless twitter_username.nil?
  end
  
  def wikidata_url
    "https://www.wikidata.org/wiki/#{wikidata_id}" unless wikidata_id.nil?
  end
end

# Table: multiplexes
# Columns:
#  id               | integer          | PRIMARY KEY AUTOINCREMENT
#  eid              | varchar(4)       |
#  name             | varchar(255)     |
#  area             | varchar(255)     |
#  block            | varchar(255)     |
#  frequency        | double precision |
#  licence_number   | varchar(255)     |
#  homepage         | varchar(255)     |
#  twitter_username | varchar(255)     |
#  wikidata_id      | varchar(255)     |
#  wikipedia_url    | varchar(255)     |
#  owner            | varchar(255)     |
#  launch_date      | date             |
#  updated_at       | date             |
# Indexes:
#  sqlite_autoindex_multiplexes_1 | UNIQUE (eid)
