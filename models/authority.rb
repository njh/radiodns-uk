class Authority < Sequel::Model
  one_to_many :bearers

  def to_s
    fqdn
  end
end

# Table: authorities
# Columns:
#  id   | integer      | PRIMARY KEY AUTOINCREMENT
#  fqdn | varchar(255) |
# Indexes:
#  sqlite_autoindex_authorities_1 | UNIQUE (fqdn)
