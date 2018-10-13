class Multiplex < Sequel::Model

end

# Table: multiplexes
# Columns:
#  id             | integer      | PRIMARY KEY AUTOINCREMENT
#  eid            | varchar(4)   |
#  name           | varchar(255) |
#  area           | varchar(255) |
#  block          | varchar(255) |
#  frequency      | varchar(255) |
#  licence_number | varchar(255) |
#  updated_at     | timestamp    |
# Indexes:
#  sqlite_autoindex_multiplexes_1 | UNIQUE (eid)
