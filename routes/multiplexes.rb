class App
  route('multiplexes') do |r|
    r.get true do
      @multiplexes = Multiplex.order(:name).all
      view('multiplexes_index')
    end

    r.get String do |eid|
      @multiplex = Multiplex.first!(:eid => eid.upcase)
      view('multiplexes_show')
    end
  end
end
