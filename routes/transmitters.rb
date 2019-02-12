class App
  route('transmitters') do |r|
    r.get true do
      @countries = Country.order(:name).all

      r.html { view('transmitters_index') }
      "Unsupported format"
    end

    def transmitter_list(r)
      @alternatives = ['geojson', 'json', 'csv']
      r.html { view('transmitters_list') }
      r.geojson { render('transmitters_list.geojson', :engine => 'yajl') }
      r.json { render('transmitters_list', :engine => 'yajl') }
      r.csv { render('transmitters_list', :engine => 'rcsv') }
      "Unsupported format"
    end

    r.get 'counties', String do |county|
      @county = County.first!(:url_key => county)
      @transmitters = Transmitter.where(:county_id => @county.id).
                      order(:name).
                      eager(:county)

      @page_title = "List of Radio Transmitters in #{@county.name}"
      transmitter_list(r)
    end

    r.get 'all' do
      @transmitters = Transmitter.order(:name).eager(:county).all

      @page_title = "List of Radio Transmitters in the UK"
      transmitter_list(r)
    end

    r.get String do |ngr|
      @transmitter = Transmitter.first!(:ngr => ngr.upcase)

      @alternatives = ['json', 'json-ld']
      r.html { view('transmitters_show') }
      r.json { render('transmitters_show', :engine => 'yajl') }
      r.jsonld { render('transmitters_show.jsonld', :engine => 'yajl') }
      "Unsupported format"
    end
  end
end
