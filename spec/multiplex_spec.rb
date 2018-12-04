require 'spec_helper'

describe Multiplex do
  let (:multiplex) { Multiplex.new(:eid => 'CE15') }

  describe '#path' do
    it 'returns website path, including the EID' do
      expect(multiplex.path).to eq("/multiplexes/ce15")
    end
  end

  describe '#uri' do
    it 'returns website URI, including the EID' do
      expect(multiplex.uri).to eq("https://www.radiodns.uk/multiplexes/ce15")
    end
  end
end
