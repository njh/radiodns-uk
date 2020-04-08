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

  describe '.normalise_ngr' do
    it 'returns the 6-digit NGR when given 6 digit NGR' do
      expect(Transmitter.normalise_ngr('SE222281')).to eq("SE222281")
    end

    it 'returns the 6-digit NGR when given 8 digit NGR' do
      expect(Transmitter.normalise_ngr('SO65831396')).to eq("SO658139")
    end

    it 'returns the 6-digit NGR when given 10 digit NGR' do
      expect(Transmitter.normalise_ngr('TR1964035775')).to eq("TR196357")
    end

    it 'returns the 6-digit NGR when given NGR with spaces' do
      expect(Transmitter.normalise_ngr('TQ 7905 8671')).to eq("TQ790867")
    end
  end

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
