class Logo < Sequel::Model
  many_to_one :service
  
  def width
    size.split('x')[0].to_i
  end

  def height
    size.split('x')[1].to_i
  end
  
  def pixels
    width * height
  end
end

# Table: logos
# Columns:
#  id         | integer      | PRIMARY KEY AUTOINCREMENT
#  service_id | integer      |
#  size       | varchar(12)  |
#  url        | varchar(255) |
# Indexes:
#  logos_service_id_index      | (service_id)
#  logos_service_id_size_index | UNIQUE (service_id, size)
