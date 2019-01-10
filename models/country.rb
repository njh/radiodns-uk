class Country < Sequel::Model
  one_to_many :counties
  one_to_many :transmitters

  def to_s
    name
  end
end

# Table: countries
# Columns:
#  id              | integer      | PRIMARY KEY AUTOINCREMENT
#  name            | varchar(255) |
#  wikidata_id     | varchar(255) |
#  osm_relation_id | integer      |
# Indexes:
#  countries_osm_relation_id_index | (osm_relation_id)
#  countries_wikidata_id_index     | (wikidata_id)
