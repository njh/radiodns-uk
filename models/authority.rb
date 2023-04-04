require 'radiodns'
require 'titleize'
require 'net/https'
require 'uri'

require_relative '../lib/fqdn'

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
        if app.nil?
          update(key => nil)
        else
          if !FQDN.valid?(app.host)
            raise "Invalid hostname: #{app.host}"
          elsif app.port < 1 or app.port > 65535
            raise "Invalid port: #{app.port}"
          else
            update(key => "#{app.host}:#{app.port}")
          end
        end
        puts self.send(key)
      rescue Resolv::ResolvError => e
        puts "ResolvError: #{e.message}"
        update(key => nil)
      rescue StandardError => e
        puts "StandardError: #{e.message}"
        update(key => nil)
      end
    end
  end

  def get_recursive(url, limit=10)
    raise "Too many redirects" if limit < 1

    uri = URI.parse(url.to_s)
    res = Net::HTTP.get_response(uri)
    if res.code =~ /^3/ and res['Location']
      return get_recursive(res['Location'], limit - 1)
    else
      return res
    end
  end

  def download_si_file
    uri = si_uri
    if uri.nil?
      puts "  No RadioEPG DNS entry for #{fqdn}"
    elsif File.exist?(si_filepath)
      puts "  Already download SI file for #{fqdn}"
    else
      res = get_recursive(uri)
      if res.is_a?(Net::HTTPSuccess)
        File.open(si_filepath, 'wb') do |file|
          file.write res.body
        end
      else
        puts "  No SI file for #{fqdn} : #{res.message}"
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
