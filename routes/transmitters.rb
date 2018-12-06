class App
  route('transmitters') do |r|
    r.get true do
      @transmitters = Transmitter.order(:name).all

      r.html { view('transmitters_index') }
      r.json { render('transmitters_index', :engine => 'yajl') }
      r.csv { render('transmitters_index', :engine => 'rcsv') }
      "Unsupported format"
    end

    r.get String do |ngr|
      @transmitter = Transmitter.first!(:ngr => ngr.upcase)

      r.html { view('transmitters_show') }
      r.json { render('transmitters_show', :engine => 'yajl') }
      "Unsupported format"
    end
  end
end
