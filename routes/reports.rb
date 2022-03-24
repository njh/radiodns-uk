class App
  route('reports') do |r|
    r.get 'unknown-to-ofcom' do
      @bearers = Bearer.where(:from_ofcom => false).
                        eager({:service => :default_bearer}, :authority).all

      # Filter out DAB bearers where SCIdS is not 0
      # Ofcom does not control/have any knowledge of these
      @bearers.reject! {|b| b.type == Bearer::TYPE_DAB && b.scids != '0'}

      view('reports_unknown-to-ofcom')
    end

    r.get 'no-radiodns' do
      @dab_bearers = Bearer.where(
        :type => Bearer::TYPE_DAB
      ).where(
        :authority_id => 1
      ).order(
        :ofcom_label
      ).eager(
        :multiplex
      ).all

      @fm_bearers = Bearer.where(
        :type => Bearer::TYPE_FM
      ).where(
        :authority_id => 1
      ).order(
        :ofcom_label
      ).eager(
        :transmitters
      ).all
      view('reports_no-radiodns')
    end

    r.get 'no-si-xml' do
      @bearers = Bearer.where(
        Sequel.lit('authority_id > 1')
      ).where(
        :service_id => nil
      ).eager(
        :authority
      ).all
      view('reports_no-si-xml')
    end

    r.get 'non-authoritative-in-si' do
      @errors = {}
      NonAuthorativeError.eager(:authority).each do |err|
        @errors[err.authority.fqdn] ||= []
        @errors[err.authority.fqdn] << err
      end

      view('reports_non-authoritative-in-si')
    end
  end
end
