class Link < Sequel::Model
  many_to_one :service
end

# Table: links
# Columns:
#  id          | integer      | PRIMARY KEY AUTOINCREMENT
#  service_id  | integer      |
#  uri         | varchar(255) |
#  description | varchar(255) |
#  mime_type   | varchar(255) |
# Indexes:
#  links_service_id_index | (service_id)
#  links_uri_index        | (uri)
