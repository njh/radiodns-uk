class App
  route('transmitters') do |r|
    r.get true do
      @transmitters = Transmitter.order(:name).all

      r.html { view('transmitters_index') }
      r.json { render('transmitters_index', :engine => 'yajl') }
      "Unsupported format"
    end

    r.get String do |ngr|
      @transmitter = Transmitter.first!(:ngr => ngr.upcase)
      view('transmitters_show')
    end
  end
end
