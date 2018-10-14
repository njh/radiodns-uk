require 'roda'
require 'erubi'
require './models'

class App < Roda
  plugin :render, :escape => true
  plugin :partials
  plugin :public
  plugin :content_for

  route do |r|
    r.public

    r.root do
      r.redirect '/multiplexes'
    end

    r.get 'multiplexes' do
      @multiplexes = Multiplex.order(:name).all
      view('multiplexes_index')
    end

    r.get 'multiplexes', String do |eid|
      @multiplex = Multiplex.find(:eid => eid.upcase)
      view('multiplexes_show')
    end

    r.get 'transmitters' do
      @transmitters = Transmitter.order(:name).all
      view('transmitters_index')
    end

    r.get 'transmitters', String do |ngr|
      @transmitter = Transmitter.find(:ngr => ngr.upcase)
      view('transmitters_show')
    end
  end
end
