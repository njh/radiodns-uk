class App
  route('multiplexes') do |r|
    r.get true do
      @multiplexes = Multiplex.order(:name).all

      r.html { view('multiplexes_index') }
      r.json { render('multiplexes_index', :engine => 'yajl') }
      "Unsupported format"
    end

    r.get String do |eid|
      @multiplex = Multiplex.first!(:eid => eid.upcase)
      view('multiplexes_show')
    end
  end
end
