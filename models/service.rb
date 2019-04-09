class Service < Sequel::Model
  one_to_many :bearers
  many_to_one :authority
  many_to_one :default_bearer, :class => :Bearer
  one_to_many :links
  one_to_many :logos, :order => :pixels
  many_to_many :genres, :order => :name
  one_to_many :dab_bearers, :class => :Bearer do |ds|
    ds.where(:type => Bearer::TYPE_DAB).
       eager(:multiplex)
  end
  one_to_many :fm_bearers, :class => :Bearer do |ds|
    ds.where(:type => Bearer::TYPE_FM).
       eager(:transmitters).
       order(:frequency)
  end
  one_to_one :logo_colour_square, :class => :Logo do |ds|
    ds.where(:size => '32x32')
  end
  one_to_one :logo_colour_rectangle, :class => :Logo do |ds|
    ds.where(:size => '112x32')
  end

  dataset_module do
    def valid
      exclude({:default_bearer_id => nil})
    end
  end

  def before_save
    self.sort_name = name.
      sub(/^[\d\.]+(fm)?\s+/i, '').
      sub(/^the\s+/i, '').
      downcase
  end

  def pi_uri(date=nil)
    date = Date.today if date.nil?
    unless authority.nil?
      yyyymmdd = date.strftime('%Y%m%d')
      if fqdn && service_identifier
        authority.construct_spi_uri("id/#{fqdn}/#{service_identifier}/#{yyyymmdd}_PI.xml")
      else
        path = default_bearer.uri.gsub(/[:.]/, '/')
        authority.construct_spi_uri("#{path}/#{yyyymmdd}_PI.xml")
      end
    end
  end

  def authority_fqdn
    authority.fqdn unless authority.nil?
  end

  def name
    long_name || medium_name || short_name
  end

  def description
    long_description || short_description
  end

  def path
    default_bearer.path unless default_bearer.nil?
  end

  def uri
    RADIODNS_UK_BASE + path unless path.nil?
  end

  def logo_600
    @logo_600 ||= logos.find {|l| l.size == '600x600'}
  end

  def to_s
    name
  end

  def updated_at
    authority.updated_at
  end
end

# Table: services
# Columns:
#  id                 | integer      | PRIMARY KEY AUTOINCREMENT
#  default_bearer_id  | integer      |
#  service_identifier | varchar(255) |
#  fqdn               | varchar(255) |
#  authority_id       | integer      |
#  sort_name          | varchar(255) |
#  short_name         | varchar(255) |
#  medium_name        | varchar(255) |
#  long_name          | varchar(255) |
#  short_description  | varchar(255) |
#  long_description   | text         |
#  have_pi            | boolean      |
