class App
  route('authorities') do |r|
    r.get true do
      @authorities = Authority.valid.sort_by(&:to_s)

      @alternatives = ['json', 'csv']
      r.html { view('authorities_index') }
      r.json { render('authorities_index', :engine => 'yajl') }
      r.csv { render('authorities_index', :engine => 'rcsv') }
      "Unsupported format"
    end

    r.get String do |fqdn|
      @authority = Authority.first!(:fqdn => fqdn)
      @services = Service.where(:authority => @authority)
                         .order(:sort_name)
                         .eager_graph(:default_bearer).all

      @alternatives = ['json', 'json-ld']
      r.html { view('authorities_show') }
      r.json { render('authorities_show', :engine => 'yajl') }
      r.jsonld { render('authorities_show.jsonld', :engine => 'yajl') }
      "Unsupported format"
    end
  end
end
