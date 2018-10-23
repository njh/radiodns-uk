require 'radiodns'

class Bearer < Sequel::Model
  UK_GCC = 'ce1'
  RADIODNS_ROOT = 'radiodns.org'

  TYPE_DAB = 1
  TYPE_FM = 2

  many_to_one :multiplex      # DAB
  many_to_many :transmitters  # FM
  many_to_one :authority
  many_to_one :service
  
  def self.parse_uri(str)
    if str =~ /^dab:(\w{3}).(\w{4}).(\w{4})\.(\w)$/
      {
        :type => TYPE_DAB,
        :eid => $2.upcase,
        :sid => $3.upcase,
        :scids => $4.upcase
      }
    elsif str =~ /^fm:(\w{3})\.(\w{4})\.(\d{5})$/
      {
        :type => TYPE_FM,
        :sid => $2.upcase,
        :frequency => $3.to_f / 100
      }
    else
      nil
    end
  end

  def initialize(values)
    super(values)
    if type == TYPE_DAB
      self.scids ||= '0'
    end
  end

  def resolve_fqdn
    begin
      result = RadioDNS::Resolver.resolve(fqdn)
      if result && result.cname
        # Force encoding to UTF-8 to fix database problem with ASCII 8-BIT
        result.cname.force_encoding('UTF-8')
      end
    rescue Resolv::ResolvError
    end
  end

  def resolve!
    update(
      :authority => Authority.find_or_create(:fqdn => resolve_fqdn)
    )
  end

  def authority
    resolve! if self.authority_id.nil?
    super
  end

  def fqdn
    uri.split(/\W+/).reverse.push(RADIODNS_ROOT).join('.')
  end
  
  def path
    '/' + uri.split(/\W+/).unshift('services').join('/')
  end

  def uri
    case type
    when TYPE_DAB
      format("dab:%s.%s.%s.%s", UK_GCC, eid.downcase, sid.downcase, scids.downcase)
    when TYPE_FM
      format("fm:%s.%s.%5.5d", UK_GCC, sid.downcase, frequency.to_f * 100)
    else
      raise "Unknown bearer type: #{type}"
    end
  end

  def to_s
    uri
  end
end

# Table: bearers
# Columns:
#  id           | integer          | PRIMARY KEY AUTOINCREMENT
#  type         | integer          |
#  frequency    | double precision |
#  sid          | varchar(4)       |
#  eid          | varchar(4)       |
#  scids        | varchar(1)       | DEFAULT '0'
#  multiplex_id | integer          |
#  authority_id | integer          |
#  service_id   | integer          |
#  bitrate      | integer          |
#  cost         | integer          |
#  offset       | integer          |
#  mime_type    | varchar(255)     |
#  from_ofcom   | boolean          | DEFAULT 0
#  ofcom_label  | varchar(255)     |
# Indexes:
#  bearers_authority_id_index | (authority_id)
#  bearers_eid_index          | (eid)
#  bearers_multiplex_id_index | (multiplex_id)
#  bearers_scids_index        | (scids)
#  bearers_service_id_index   | (service_id)
#  bearers_sid_index          | (sid)
#  bearers_type_index         | (type)
