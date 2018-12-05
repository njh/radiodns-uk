class App
  route('authorities') do |r|
    r.get true do
      @authorities = Authority.valid.sort_by(&:to_s)

      r.html { view('authorities_index') }
      r.json { render('authorities_index', :engine => 'yajl') }
      "Unsupported format"
    end

    r.get String do |fqdn|
      @authority = Authority.first!(:fqdn => fqdn)
      @services = Service.where(:authority => @authority)
                         .order(:sort_name)
                         .eager_graph(:default_bearer).all

      r.html { view('authorities_show') }
      r.json { render('authorities_show', :engine => 'yajl') }
      "Unsupported format"
    end
  end
end
