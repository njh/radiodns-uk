
# A module to perform operations on Ordnance Survey National Grid co-ordinates
module OSGB
  # This is how the letters map on to the 5x5 grid
  # Note that there is no letter 'I'
  LETTER_MAP = {
     :A => [0,4],
     :B => [1,4],
     :C => [2,4],
     :D => [3,4],
     :E => [4,4],
     :F => [0,3],
     :G => [1,3],
     :H => [2,3],
     :J => [3,3],
     :K => [4,3],
     :L => [0,2],
     :M => [1,2],
     :N => [2,2],
     :O => [3,2],
     :P => [4,2],
     :Q => [0,1],
     :R => [1,1],
     :S => [2,1],
     :T => [3,1],
     :U => [4,1],
     :V => [0,0],
     :W => [1,0],
     :X => [2,0],
     :Y => [3,0],
     :Z => [4,0],
  }.freeze

  # Location of false origin is the South-West of square 'SV'
  FALSE_OFFSET = [
    1_000_000,
    500_000
  ].freeze

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

  def self.letters_to_metres(code)
    # First letter represents 500km grid
    first = LETTER_MAP[code[0].upcase.to_sym]
    easting = (first[0] * 500_000) - FALSE_OFFSET[0]
    northing = (first[1] * 500_000) - FALSE_OFFSET[1]
    
    # Second letter represents 100km grid
    second = LETTER_MAP[code[1].upcase.to_sym]
    easting += second[0] * 100_000
    northing += second[1] * 100_000
    
    [easting, northing]
  end

  # Convert grid reference into northing and easting values (in metres)  
  def self.osgb_to_metres(ngr)
    parts = parse(ngr)
    metres = letters_to_metres(parts[0])
    metres[0] += parts[1]
    metres[1] += parts[2]
    metres
  end

  # Calculate the distance between two gird reference points
  def self.distance(ngr1, ngr2)
    e1, n1 = osgb_to_metres(ngr1)
    e2, n2 = osgb_to_metres(ngr2)
    a = e2 - e1
    b = n2 - n1
    Math.sqrt((a*a) + (b*b)).floor
  end
end
