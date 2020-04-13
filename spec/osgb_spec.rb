require 'spec_helper'
require_relative '../lib/osgb'

describe OSGB do
  describe '.parse' do
    it 'returns the parts of a 6-digit NGR' do
      expect(OSGB.parse('SE222281')).to eq(['SE', 22200, 28100])
    end

    it 'returns the parts of a 8 digit NGR' do
      expect(OSGB.parse('SO65831396')).to eq(['SO', 65830, 13960])
    end

    it 'returns the parts of a 10 digit NGR' do
      expect(OSGB.parse('TR1964035775')).to eq(['TR', 19640, 35775])
    end

    it 'returns the parts of a NGR when there are spaces' do
      expect(OSGB.parse('TQ 7905 8671')).to eq(['TQ', 79050, 86710])
    end
  end

  describe '.normalise' do
    it 'returns the 6-digit NGR when given 6 digit NGR' do
      expect(OSGB.normalise('SE222281')).to eq('SE222281')
    end

    it 'returns the 6-digit NGR when given 8 digit NGR' do
      expect(OSGB.normalise('SO65831396')).to eq('SO658139')
    end

    it 'returns the 6-digit NGR when given 10 digit NGR' do
      expect(OSGB.normalise('TR1964035775')).to eq('TR196357')
    end

    it 'returns the 6-digit NGR when given NGR with spaces' do
      expect(OSGB.normalise('TQ 7905 8671')).to eq('TQ790867')
    end
  end
end
