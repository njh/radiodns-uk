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
  
  describe '.letters_to_metres' do
    it 'returns the northing and easting for the false origin' do
      expect(OSGB.letters_to_metres('SV')).to eq([0,0])
    end

    it 'returns the northing and easting for the furthest south-west point' do
      expect(OSGB.letters_to_metres('VV')).to eq([-1000000, -500000])
    end

    it 'returns the northing and easting for the furthest north-east point' do
      expect(OSGB.letters_to_metres('EE')).to eq([1400000, 1900000])
    end

    it 'returns the northing and easting for "HP"' do
      expect(OSGB.letters_to_metres('HP')).to eq([400000,1200000])
    end

    it 'returns the northing and easting for "TQ"' do
      expect(OSGB.letters_to_metres('TQ')).to eq([500000,100000])
    end

    it 'returns the northing and easting for "NO"' do
      expect(OSGB.letters_to_metres('NO')).to eq([300000,700000])
    end
  end

  describe '.osgb_to_metres' do
    it 'returns the northing and easting for HU396753 (Sullom Voe oil terminal)' do
      expect(OSGB.osgb_to_metres('HU396753')).to eq([439600,1175300])
    end

    it 'returns the northing and easting for NN166712 (Ben Nevis)' do
      expect(OSGB.osgb_to_metres('NN166712')).to eq([216600,771200])
    end

    it 'returns the northing and easting for TQ299804 (Trafalgar Square)' do
      expect(OSGB.osgb_to_metres('TQ299804')).to eq([529900,180400])
    end

    it 'returns the northing and easting for SV911124 (Isles of Scilly)' do
      expect(OSGB.osgb_to_metres('SV911124')).to eq([91100,12400])
    end

    it 'returns the northing and easting for TQ595604 (Wrotham Transmitter Station)' do
      expect(OSGB.osgb_to_metres('TQ595604')).to eq([559500,160400])
    end

    it 'returns the northing and easting for NO39484078 (Angus Transmitter Station)' do
      expect(OSGB.osgb_to_metres('NO39484078')).to eq([339480,740780])
    end

    it 'returns the northing and easting for TR1964035775 (Shornecliffe Camp)' do
      expect(OSGB.osgb_to_metres('TR1964035775')).to eq([619640,135775])
    end
  end

  describe '.distance' do
    it 'returns 0 for the same grid reference with different accuracies' do
      expect(OSGB.distance('SU37301550', 'SU373155')).to eq(0)
    end
  
    it 'returns 78 for two grid references for the same place with different accuracies' do
      expect(OSGB.distance('SD66051446', 'SD660144')).to eq(78)
    end

    it 'returns 10 for a grid ref 10 metres east' do
      expect(OSGB.distance('SU 3730 1550', 'SU 3731 1550')).to eq(10)
    end

    it 'returns 1 for a grid ref 1 metres east' do
      expect(OSGB.distance('SU 37300 15500', 'SU 37301 15500')).to eq(1)
    end

    it "returns the distance from Land's End to John o' Groats" do
      expect(OSGB.distance('SW 34177 25339', 'ND380734')).to eq(969723)
    end
  end
end
