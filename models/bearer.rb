require 'radiodns'

class Bearer < Sequel::Model
  UK_GCC = 'ce1'
  RADIODNS_ROOT = 'radiodns.org'

  TYPE_DAB = 1
  TYPE_FM = 2

  many_to_one :multiplex      # DAB
  many_to_many :transmitters  # FM
  many_to_one :authority

  def initialize(values)
    super(values)
    self.scids ||= '0'
  end

  def resolve!
    begin
      result = RadioDNS::Resolver.resolve(fqdn)
      if result && result.cname
        # Force encoding to UTF-8 to fix database problem with ASCII 8-BIT
        cname = result.cname.force_encoding('UTF-8')
        self.authority = Authority.find_or_create(:fqdn => cname)
      end
    rescue Resolv::ResolvError
    end

    # Create a 'Not Found' authority, so we don't keep looking it up
    if self.authority_id.nil?
      self.authority = Authority.find_or_create(:fqdn => nil)
    end

    save
  end

  def authority
    resolve! if self.authority_id.nil?
    super
  end

  def fqdn
    uri.split(/\W+/).reverse.push(RADIODNS_ROOT).join('.')
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
#  id           | integer      | PRIMARY KEY AUTOINCREMENT
#  type         | integer      |
#  frequency    | varchar(6)   |
#  sid          | varchar(4)   |
#  eid          | varchar(4)   |
#  scids        | varchar(1)   | DEFAULT '0'
#  multiplex_id | integer      |
#  authority_id | integer      |
#  from_ofcom   | boolean      |
#  ofcom_label  | varchar(255) |
# Indexes:
#  bearers_authority_id_index | (authority_id)
#  bearers_eid_index          | (eid)
#  bearers_multiplex_id_index | (multiplex_id)
#  bearers_scids_index        | (scids)
#  bearers_sid_index          | (sid)
#  bearers_type_index         | (type)
