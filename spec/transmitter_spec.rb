require 'spec_helper'

describe Transmitter do
  let (:transmitter) {
    Transmitter.new(
      :ngr => 'SE222281',
      :name => 'Emley Moor',
      :area => 'Yorkshire',
      :lat => 53.611359,
      :long => -1.665774,
      :site_height => 256
    )
  }

  describe '#name' do
    it 'returns the name of the transmitter' do
      expect(transmitter.name).to eq("Emley Moor")
    end
  end

  describe '#path' do
    it 'returns website path, including the NGR' do
      expect(transmitter.path).to eq("/transmitters/se222281")
    end
  end

  describe '#uri' do
    it 'returns website URI, including the NGR' do
      expect(transmitter.uri).to eq("https://www.radiodns.uk/transmitters/se222281")
    end
  end
end
