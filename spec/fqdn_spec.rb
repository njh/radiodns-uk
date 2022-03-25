require 'spec_helper'
require_relative '../lib/fqdn'

describe FQDN do
  describe '.valid?' do
    it "expects '911.gov' to be valid" do
      expect(FQDN.valid?('911.gov')).to be true
    end

    it "expects '911' to be invalid - no TLD" do
      expect(FQDN.valid?('911')).to be false
    end

    it "expects 'a-.com' to be invalid" do
      expect(FQDN.valid?('a-.com')).to be false
    end

    it "expects '-a.com' to be invalid" do
      expect(FQDN.valid?('-a.com')).to be false
    end

    it "expects 'a.com' to be valid" do
      expect(FQDN.valid?('a.com')).to be true
    end

    it "expects 'a.66' to be invalid" do
      expect(FQDN.valid?('a.66')).to be false
    end

    it "expects 'my_host.com' to be invalid" do
      expect(FQDN.valid?('my_host.com')).to be false
    end

    it "expects 'typical-hostname33.whatever.co.uk' to be valid" do
      expect(FQDN.valid?('typical-hostname33.whatever.co.uk')).to be true
    end

    it "expects '_dc-srv.824a1a5b89d2._radioepg._tcp.c826.radioplayer.org' to be invalid - underscore" do
      expect(FQDN.valid?('_dc-srv.824a1a5b89d2._radioepg._tcp.c826.radioplayer.org')).to be false
    end
  end
end
