require 'radiodns'
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

  def path
    "/authorities/#{fqdn}" unless fqdn.nil?
  end

  def uri
    RADIODNS_UK_BASE + path unless path.nil?
  end

  def to_s
    name || fqdn
  end
  
  def construct_spi_uri(subpath)
    if have_radioepg?
      host, port = radioepg_server.split(':')
      URI::HTTP.build(
        :host => host,
        :port => port,
        :path => '/radiodns/spi/3.1/' + subpath
      )
    end
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
    construct_spi_uri('SI.xml')
  end

  def lookup_applications!
    service = RadioDNS::Service.new(fqdn)
    [:radiotag, :radioepg, :radiovis, :radioweb].each do |type|
      key = "#{type}_server".to_sym
      begin
        service = RadioDNS::Service.new(fqdn)
        app = service.application(type)
        update(key => "#{app.host}:#{app.port}")
      rescue Resolv::ResolvError
        update(key => nil)
      end
    end
  end

  def download_si_file
    uri = si_uri
    if uri.nil?
      DB.log_info("No RadioEPG DNS entry for #{fqdn}")
    elsif File.exist?(si_filepath)
      DB.log_info("Already download SI file for #{fqdn}")
    else
      res = Net::HTTP.get_response(uri)
      if res.is_a?(Net::HTTPSuccess)
        File.open(si_filepath, 'wb') do |file|
          file.write res.body
        end
      else
        DB.log_info("No SI file for #{fqdn} : #{res.message}")
        update(:radioepg_server => nil)
      end
    end
  end

  def have_radioepg?
    !radioepg_server.nil?
  end

  def have_radiotag?
    !radiotag_server.nil?
  end

  def have_radiovis?
    !radiovis_server.nil?
  end

end

# Table: authorities
# Columns:
#  id              | integer      | PRIMARY KEY AUTOINCREMENT
#  fqdn            | varchar(255) |
#  name            | varchar(255) |
#  description     | varchar(255) |
#  link            | varchar(255) |
#  logo            | varchar(255) |
#  radioepg_server | varchar(255) |
#  radiotag_server | varchar(255) |
#  radiovis_server | varchar(255) |
#  radioweb_server | varchar(255) |
#  updated_at      | timestamp    |
# Indexes:
#  sqlite_autoindex_authorities_1 | UNIQUE (fqdn)
