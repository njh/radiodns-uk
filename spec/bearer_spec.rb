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

    describe '#to_s' do
      it 'shoudl return the uri' do
        expect(bearer.to_s).to eql("fm:ce1.c6b1.10280")
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

    describe '#to_s' do
      it 'shoudl return the uri' do
        expect(bearer.to_s).to eql("dab:ce1.c19e.c0cb.0")
      end
    end
  end
end
