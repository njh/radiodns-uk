require 'spec_helper'

describe Authority do
  let (:authority) { Authority.new(:fqdn => 'rdns.example.com') }

  describe '#fqdn' do
    it 'returns the FQDN' do
      expect(authority.to_s).to eql("rdns.example.com")
    end
  end

  describe '#name' do
    describe "an authority that has a name" do
      let (:authority) { Authority.new(:fqdn => 'rdns.example.com', :name => "Example Broadcaster") }
      it 'returns the name' do
        expect(authority.name).to eql("Example Broadcaster")
      end
    end

    describe "an authority that has no name" do
      let (:authority) { Authority.new(:fqdn => 'rdns.example.com') }
      it 'extracts the name from the domain name' do
        expect(authority.name).to eql("Example")
      end
    end
  end

  describe '#to_s' do
    it 'returns the FQDN' do
      expect(authority.to_s).to eql("rdns.example.com")
    end
  end

end
