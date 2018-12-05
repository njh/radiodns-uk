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

      r.html { view('multiplexes_show') }
      r.json { render('multiplexes_show', :engine => 'yajl') }
      "Unsupported format"
    end
  end
end
