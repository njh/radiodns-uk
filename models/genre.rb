class Genre < Sequel::Model

end

# Table: genres
# Columns:
#  id   | integer      | PRIMARY KEY AUTOINCREMENT
#  urn  | varchar(255) |
#  name | varchar(255) |
# Indexes:
#  genres_urn_index | (urn)
