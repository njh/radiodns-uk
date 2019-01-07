class App
  route('transmitters') do |r|
    r.get true do
      @transmitters = Transmitter.order(:name).all

      @alternatives = ['geojson', 'json', 'csv']
      r.html { view('transmitters_index') }
      r.geojson { render('transmitters_index.geojson', :engine => 'yajl') }
      r.json { render('transmitters_index', :engine => 'yajl') }
      r.csv { render('transmitters_index', :engine => 'rcsv') }
      "Unsupported format"
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
