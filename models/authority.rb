require 'radiodns'
require 'public_suffix'
require 'titleize'
require 'net/https'
require 'uri'

class Authority < Sequel::Model
  one_to_many :bearers
  one_to_many :services, :order => :sort_name

  dataset_module do
    def valid
      exclude({:fqdn => nil})
    end
  end
  
  def name
    unless self[:name].nil?
      self[:name]
    else
      domain = PublicSuffix.parse(fqdn)
      domain.sld.titleize
    end
  end

  def to_s
    fqdn
  end

  def self.si_dir
    path = File.join(__dir__, '..', 'si_files')
    Dir.mkdir(path) unless File.exist?(path)
    File.realpath(path)
  end

  def si_filepath
    File.join(Authority.si_dir, fqdn + '.xml')
  end
  
  def si_uri
    begin
      service = RadioDNS::Service.new(fqdn)
      app = service.radioepg
      URI::HTTP.build(
        :host => app.host,
        :port => app.port,
        :path => '/radiodns/spi/3.1/SI.xml'
      )
    rescue Resolv::ResolvError
    end
  end

  def download_si_file
    uri = si_uri
    if uri.nil?
      DB.log_info("No RadioEPG DNS entry for #{fqdn}")
      update(:have_radioepg => false)
    else
      res = Net::HTTP.get_response(uri)
      if res.is_a?(Net::HTTPSuccess)
        File.open(si_filepath, 'wb') do |file|
          file.write res.body
        end
        update(:have_radioepg => true)
      else
        DB.log_info("No SI file for #{fqdn} : #{res.message}")
        update(:have_radioepg => false)
      end
    end
  end

end

# Table: authorities
# Columns:
#  id            | integer      | PRIMARY KEY AUTOINCREMENT
#  fqdn          | varchar(255) |
#  name          | varchar(255) |
#  description   | varchar(255) |
#  link          | varchar(255) |
#  logo          | varchar(255) |
#  have_radioepg | boolean      |
#  have_radiotag | boolean      |
#  have_radiovis | boolean      |
#  have_radioweb | boolean      |
# Indexes:
#  sqlite_autoindex_authorities_1 | UNIQUE (fqdn)
