class County < Sequel::Model
  many_to_one :country

end

# Table: counties
# Columns:
#  id              | integer      | PRIMARY KEY AUTOINCREMENT
#  name            | varchar(255) |
#  country_id      | integer      |
#  wikidata_id     | varchar(255) |
#  osm_relation_id | integer      |
# Indexes:
#  counties_country_id_index      | (country_id)
#  counties_osm_relation_id_index | (osm_relation_id)
#  counties_wikidata_id_index     | (wikidata_id)
