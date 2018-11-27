require 'spec_helper'

describe Authority do
  let (:authority) { Authority.new(:fqdn => 'rdns.example.com') }

  describe '#fqdn' do
    it 'returns the FQDN' do
      expect(authority.fqdn).to eql("rdns.example.com")
    end
  end

  describe '#path' do
    it 'returns website path, including the FQDN' do
      expect(authority.path).to eq("/authorities/rdns.example.com")
    end
  end

  describe '#name' do
    describe "an authority that has a name" do
      let (:authority) { Authority.new(:fqdn => 'rdns.example.com', :name => "Example Broadcaster") }
      it 'returns the name' do
        expect(authority.name).to eq("Example Broadcaster")
      end
    end

    describe "an authority that has no name" do
      let (:authority) { Authority.new(:fqdn => 'rdns.example.com') }
      it 'returns the FQDN' do
        expect(authority.name).to eq("rdns.example.com")
      end
    end
  end

  describe '.si_dir' do
    it 'returns the full path for local storage of SI files' do
      expect(Authority.si_dir).to match(%r|^/\w+/.+/si_files$|)
    end
  end

  describe '#si_filepath' do
    it 'returns local SI file path, including the FQDN' do
      expect(authority.si_filepath).to match(%r|^/\w+/.+/si_files/rdns.example.com.xml$|)
    end
  end

  describe '#si_uri' do
    describe "an authority with a radioepg server" do
      let (:authority) { Authority.new(:fqdn => 'rdns.example.com', :radioepg_server => "epg.example.com:80") }
      it 'should be true' do
        expect(authority.si_uri).to eq(URI('http://epg.example.com/radiodns/spi/3.1/SI.xml'))
      end
    end

    describe "an authority that has no radioepg server" do
      let (:authority) { Authority.new(:fqdn => 'rdns.example.com') }
      it 'should be false' do
        expect(authority.si_uri).to be_nil
      end
    end
  end

  describe '#have_radioepg?' do
    describe "an authority with a radioepg server" do
      let (:authority) { Authority.new(:fqdn => 'rdns.example.com', :radioepg_server => "epg.example.com:80") }
      it 'should be true' do
        expect(authority.have_radioepg?).to be_truthy
      end
    end

    describe "an authority that has no radioepg server" do
      let (:authority) { Authority.new(:fqdn => 'rdns.example.com') }
      it 'should be false' do
        expect(authority.have_radioepg?).to be_falsy
      end
    end
  end

  describe '#have_radiovis?' do
    describe "an authority with a radiovis server" do
      let (:authority) { Authority.new(:fqdn => 'rdns.example.com', :radiovis_server => "vis.example.com:61613") }
      it 'should be true' do
        expect(authority.have_radiovis?).to be_truthy
      end
    end

    describe "an authority that has no radiovis server" do
      let (:authority) { Authority.new(:fqdn => 'rdns.example.com') }
      it 'should be false' do
        expect(authority.have_radiovis?).to be_falsy
      end
    end
  end

  describe '#have_radiotag?' do
    describe "an authority with a radiotag server" do
      let (:authority) { Authority.new(:fqdn => 'rdns.example.com', :radiotag_server => "tag.example.com:80") }
      it 'should be true' do
        expect(authority.have_radiotag?).to be_truthy
      end
    end

    describe "an authority that has no radiotag server" do
      let (:authority) { Authority.new(:fqdn => 'rdns.example.com') }
      it 'should be false' do
        expect(authority.have_radiotag?).to be_falsy
      end
    end
  end

  describe '#to_s' do
    it 'returns the FQDN' do
      expect(authority.to_s).to eq("rdns.example.com")
    end
  end

end
