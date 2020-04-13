
# A module to perform operations on Ordnance Survey National Grid co-ordinates
module OSGB
  # Parse National Grid Reference (OSGB36)
  # Copes with spaces and different levels of accuracy
  def self.parse(ngr)
    if ngr =~ /^([A-Z]{2})\s*(\d{3})\s*(\d{3})$/i
      # 6-digit
      [$1.upcase, $2.to_i * 100,  $3.to_i * 100]
    elsif ngr =~ /^([A-Z]{2})\s*(\d{4})\s*(\d{4})$/
      # 8-digit
      [$1.upcase, $2.to_i * 10,  $3.to_i * 10]
    elsif ngr =~ /^([A-Z]{2})\s*(\d{5})\s*(\d{5})$/
      # 10-digit
      [$1.upcase, $2.to_i,  $3.to_i]
    else
      raise "Failed to parse National Grid Reference: #{ngr}"
    end
  end

  # Normalise National Grid Reference (OSGB36) - we only use 6-digits
  def self.normalise(ngr)
    parts = parse(ngr)
    parts[1] /= 100
    parts[2] /= 100
    "#{parts[0]}#{parts[1]}#{parts[2]}"
  end
end
