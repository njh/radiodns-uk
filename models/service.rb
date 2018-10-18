class Service < Sequel::Model
  one_to_many :bearers
  one_to_one :default_bearer, :class => :Bearer

  def before_save
    self.sort_name = name.
      sub(/^[\d\.]+(fm)?\s+/i, '').
      sub(/^the\s+/i, '').
      downcase
  end

  def name
    long_name || medium_name || short_name
  end

  def description
    long_description || short_description
  end

  def path
    default_bearer.path
  end

  def authority
    default_bearer.authority
  end

  def to_s
    name
  end
end

# Table: services
# Columns:
#  id                | integer      | PRIMARY KEY AUTOINCREMENT
#  default_bearer_id | integer      |
#  sort_name         | varchar(255) |
#  short_name        | varchar(255) |
#  medium_name       | varchar(255) |
#  long_name         | varchar(255) |
#  short_description | varchar(255) |
#  long_description  | text         |
