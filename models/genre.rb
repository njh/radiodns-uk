class Genre < Sequel::Model
  many_to_many :services, :order => :sort_name

end

# Table: genres
# Columns:
#  id   | integer      | PRIMARY KEY AUTOINCREMENT
#  urn  | varchar(255) |
#  name | varchar(255) |
# Indexes:
#  genres_urn_index | (urn)
