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
      @multiplex = Multiplex.find(:eid => eid)
      view('multiplexes_show')
    end
  end
end
