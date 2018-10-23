class Multiplex < Sequel::Model
  one_to_many :bearers, :order => :sid
  many_to_many :transmitters, :order => :name

  def path
    "/multiplexes/#{eid.downcase}"
  end
end

# Table: multiplexes
# Columns:
#  id             | integer          | PRIMARY KEY AUTOINCREMENT
#  eid            | varchar(4)       |
#  name           | varchar(255)     |
#  area           | varchar(255)     |
#  block          | varchar(255)     |
#  frequency      | double precision |
#  licence_number | varchar(255)     |
#  updated_at     | date             |
# Indexes:
#  sqlite_autoindex_multiplexes_1 | UNIQUE (eid)
