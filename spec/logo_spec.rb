require 'spec_helper'

describe Logo do
  let(:logo) {
    Logo.new(
      :size => '112x32',
      :url => 'http://logos.example.com/services/208/logo/32x32.png'
    )
  }

  describe '#width' do
    it 'returns the first part of the logo size' do
      expect(logo.width).to eql(112)
    end
  end

  describe '#height' do
    it 'returns the second part of the logo size' do
      expect(logo.height).to eql(32)
    end
  end

  describe '#pixels' do
    it 'returns the number of pixels in the logo' do
      logo.before_save
      expect(logo.pixels).to eql(3584)
    end
  end
end
