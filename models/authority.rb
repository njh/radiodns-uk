require 'radiodns'
require 'public_suffix'
require 'titleize'
require 'net/https'
require 'uri'

class Authority < Sequel::Model
  one_to_many :bearers
  
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

  def download_si_file
    begin
      service = RadioDNS::Service.new(fqdn)
      app = service.radioepg
      raise Resolv::ResolvError if app.nil?

      uri = URI::HTTP.build(
        :host => app.host,
        :port => app.port,
        :path => '/radiodns/spi/3.1/SI.xml'
      )

      res = Net::HTTP.get_response(uri)
      if res.is_a?(Net::HTTPSuccess)
        File.open(si_filepath, 'wb') do |file|
          file.write res.body
        end
        set(:have_radioepg => true)
      else
        DB.log_info("No SI file for #{fqdn} : #{res.message}")
        set(:have_radioepg => false)
      end

    rescue Resolv::ResolvError
      DB.log_info("No RadioEPG DNS entry for #{fqdn}")
      set(:have_radioepg => false)
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
