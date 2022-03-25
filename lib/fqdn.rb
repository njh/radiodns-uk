
module FQDN
  # Validate a FQDN
  def self.valid?(fqdn)
    # Regex taken from: https://stackoverflow.com/questions/11809631
    !!(fqdn =~ /(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)/)
  end
end
