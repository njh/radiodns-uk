class App
  route('transmitters') do |r|
    r.get true do
      @transmitters = Transmitter.order(:name).all
      view('transmitters_index')
    end

    r.get String do |ngr|
      @transmitter = Transmitter.first!(:ngr => ngr.upcase)
      view('transmitters_show')
    end
  end
end
