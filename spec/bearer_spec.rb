require 'spec_helper'

describe Bearer do
  describe "FM radio station" do
    let(:bearer) {
      Bearer.new(
        :type => Bearer::TYPE_FM,
        :frequency => 102.8,
        :sid => 'C6B1'
      )
    }

    describe "parsing bearer URI" do
      let(:params) { Bearer.parse_uri("fm:ce1.c6b1.10280") }

      it 'returns the correct type, frequency and sid' do
        expect(params).to eql(
          :type => Bearer::TYPE_FM,
          :frequency => 102.8,
          :sid => 'C6B1'
        )
      end
    end

    describe '#uri' do
      it 'creates a FM bearer URI' do
        expect(bearer.uri).to eql("fm:ce1.c6b1.10280")
      end
    end

    describe '#fqdn' do
      it 'creates a FM bearer FQDN' do
        expect(bearer.fqdn).to eql("10280.c6b1.ce1.fm.radiodns.org")
      end
    end

    describe '#path' do
      it 'returns the website path' do
        expect(bearer.path).to eql("/services/fm/ce1/c6b1/10280")
      end
    end

    describe '#to_s' do
      it 'shoudl return the uri' do
        expect(bearer.to_s).to eql("fm:ce1.c6b1.10280")
      end
    end

    describe '#radiodns_test_url' do
      it 'should return a valid radiodns.org test URI' do
        expect(bearer.radiodns_test_url).to eql("https://radiodns.org/nwp/tools/?action=rdns&bearer=fm&country=ce1&pi=C6B1&freq=102.8")
      end
    end
  end

  describe "DAB radio station" do
    let(:bearer) {
      Bearer.new(
        :type => Bearer::TYPE_DAB,
        :eid => 'C19E',
        :sid => 'C0CB'
      )
    }

    describe "parsing bearer URI" do
      let(:params) { Bearer.parse_uri("dab:ce1.c19e.c0cb.0") }

      it 'returns the correct type, eid, sid and scids' do
        expect(params).to eql(
          :type => Bearer::TYPE_DAB,
          :eid => 'C19E',
          :sid => 'C0CB',
          :scids => '0'
        )
      end
    end

    describe '#uri' do
      it 'creates a DAB bearer URI' do
        expect(bearer.uri).to eql("dab:ce1.c19e.c0cb.0")
      end
    end

    describe '#fqdn' do
      it 'creates a DAB bearer FQDN' do
        expect(bearer.fqdn).to eql("0.c0cb.c19e.ce1.dab.radiodns.org")
      end
    end

    describe '#path' do
      it 'returns the website path' do
        expect(bearer.path).to eql("/services/dab/ce1/c19e/c0cb/0")
      end
    end

    describe '#to_s' do
      it 'should return the uri' do
        expect(bearer.to_s).to eql("dab:ce1.c19e.c0cb.0")
      end
    end

    describe '#radiodns_test_url' do
      it 'should return a valid radiodns.org test URI' do
        expect(bearer.radiodns_test_url).to eql("https://radiodns.org/nwp/tools/?action=rdns&bearer=dab&ecc=ce1&eid=C19E&sid=C0CB&scids=0")
      end
    end
  end
end
