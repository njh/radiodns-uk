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

    r.on 'multiplexes' do
      r.get do
        @multiplexes = Multiplex.order(:name).all
        view('multiplexes_index')
      end

    end
  end
end
