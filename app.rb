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

  plugin :error_handler do |e|
    case e
    when Sequel::NoMatchingRow
      if e.dataset
        @page_title = "#{e.dataset.model} Not Found"
      else
        @page_title = "Database Entry Not Found"
      end
      response.status = 404
      view("error_page")
    else
      next super(e) if ENV['RACK_ENV'] == 'development'
      @page_title = "Internal Server Error"
      response.status = 500
      view("error_page")
    end
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
      @authority = Authority.first!(:fqdn => fqdn)
      view('authorities_show')
    end

    r.get 'multiplexes' do
      @multiplexes = Multiplex.order(:name).all
      view('multiplexes_index')
    end

    r.get 'multiplexes', String do |eid|
      @multiplex = Multiplex.first!(:eid => eid.upcase)
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
        raise Sequel::NoMatchingRow.new(Service) if @service.nil?
        if @bearer.path != @service.path
          r.redirect(@service.path, 301)
        else
          view('services_show')
        end
      end

      r.get 'dab', String, String, String, String do |gcc, eid, sid, scids|
        @bearer = Bearer.first!(
          :type => Bearer::TYPE_DAB,
          :eid => eid.upcase,
          :sid => sid.upcase,
          :scids => scids.upcase
        )
        services_show(r)
      end

      r.get 'fm', String, String, String do |gcc, sid, frequency|
        @bearer = Bearer.first!(
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
      @transmitter = Transmitter.first!(:ngr => ngr.upcase)
      view('transmitters_show')
    end

    r.get 'sitemap.xml' do
      models = [Authority, Multiplex, Service, Transmitter]
      @paths = ['/']
      @paths += models.map {|m| "/#{m.table_name}"}
      @paths += models.map {|m| m.all.map {|a| a.path} }.flatten
      response['Content-Type'] = 'application/xml'
      render('sitemap')
    end

    r.get 'gems' do
      @specs = Gem::loaded_specs.values.sort_by(&:name)
      view('gems')
    end
  end


  ## Helpers
  def tick_cross(bool)
    if bool
      '<span style="margin-right: 0.5em; color: green; font-weight: bolder">✓</span>'
    else
      '<span style="margin-right: 0.5em; color: red; font-weight: bolder">✗</span>'
    end
  end

  def link_to_authority(authority)
    if authority && authority.fqdn
      "<a href=\"#{authority.path}\">#{authority.fqdn}</a>"
    else
      tick_cross(false) + ' No RadioDNS'
    end
  end

end
