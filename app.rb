require 'roda'
require 'erubi'
require './models'

class App < Roda
  plugin :render, :escape => true
  plugin :partials
  plugin :public
  plugin :content_for

  plugin :not_found do
    view("error_page")
  end

  route do |r|
    r.public

    r.root do
      r.redirect '/services'
    end

    r.get 'authorities' do
      @authorities = Authority.valid.order(:name)
      view('authorities_index')
    end

    r.get 'authorities', String do |fqdn|
      @authority = Authority.find(:fqdn => fqdn)
      view('authorities_show')
    end

    r.get 'multiplexes' do
      @multiplexes = Multiplex.order(:name).all
      view('multiplexes_index')
    end

    r.get 'multiplexes', String do |eid|
      @multiplex = Multiplex.find(:eid => eid.upcase)
      view('multiplexes_show')
    end

    r.get 'services' do
      @services = Service.eager(:default_bearer, :logo_colour_rectangle).
                  exclude(:default_bearer_id => nil).
                  order(:sort_name).all
      view('services_index')
    end

    r.on 'services' do
      # FIXME: there must be a nicer way of passing 'r'
      def services_show(r)
        @service = @bearer.service
        if @bearer.path != @service.path
          r.redirect(@service.path, 301)
        else
          view('services_show')
        end
      end

      r.get 'dab', String, String, String, String do |gcc, eid, sid, scids|
        @bearer = Bearer.find(
          :type => Bearer::TYPE_DAB,
          :eid => eid.upcase,
          :sid => sid.upcase,
          :scids => scids.upcase
        )
        services_show(r)
      end
      
      r.get 'fm', String, String, String do |gcc, sid, frequency|
        @bearer = Bearer.find(
          :type => Bearer::TYPE_FM,
          :frequency => frequency.to_f / 100,
          :sid => sid.upcase
        )
        services_show(r)
      end
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
