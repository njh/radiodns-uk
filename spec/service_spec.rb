require 'spec_helper'

describe Service do
  let(:service) {
    Service.new(
      :sort_name => 'bbc radio 6 music',
      :short_name => 'BBC 6Mus',
      :medium_name => 'BBC 6 Music',
      :long_name => 'BBC Radio 6 Music',
      :short_description => 'Where extraordinary Music plays',
      :long_description => 'The place for the best Alternative Music.'
    )
  }

  describe "#name" do
    it 'returns the long name by default' do
      expect(service.name).to eql('BBC Radio 6 Music')
    end

    describe "a service that only has a short name" do
      let(:service) { Service.new(:short_name => 'BBC 6Mus') }
      it 'returns the short name' do
        expect(service.name).to eql('BBC 6Mus')
      end
    end

    describe "a service that only has a medium name" do
      let(:service) { Service.new(:long_name => 'BBC 6 Music') }
      it 'returns the medium name' do
        expect(service.name).to eql('BBC 6 Music')
      end
    end

    describe "a service that only has a long name" do
      let(:service) { Service.new(:long_name => 'BBC Radio 6 Music') }
      it 'returns the long name' do
        expect(service.name).to eql('BBC Radio 6 Music')
      end
    end
  end

  describe "#description" do
    it 'returns the long description by default' do
      expect(service.description).to eql('The place for the best Alternative Music.')
    end

    describe "a service that only has a short description" do
      let(:service) { Service.new(:short_description => 'Where extraordinary Music plays') }
      it 'returns the short description' do
        expect(service.description).to eql('Where extraordinary Music plays')
      end
    end

    describe "a service that only has a long description" do
      let(:service) { Service.new(:long_description => 'The place for the best Alternative Music.') }
      it 'returns the long description' do
        expect(service.description).to eql('The place for the best Alternative Music.')
      end
    end
  end

  describe "#to_s" do
    it 'returns the name of the service' do
      expect(service.to_s).to eql('BBC Radio 6 Music')
    end
  end

end
