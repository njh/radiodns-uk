module Genres
  Mapping = {}

  def self.load_data
    Dir.glob(File.dirname(__FILE__) + '/genres/*.json').each do |filename|
      File.open(filename, 'rb') do |file|
        data = JSON.parse(file.read)
        Mapping.merge!(data)
      end
    end
  end

  def self.lookup(key)
    load_data if Mapping.empty?
    Mapping[key]
  end

end
