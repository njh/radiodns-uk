require 'roda'
require 'erubi'
require './models'

class App < Roda
  plugin :render, :escape => true
  plugin :partials
  plugin :public
  plugin :content_for
  plugin :multi_route
  plugin :type_routing, :types => {
    :csv => 'text/csv'
  }

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

  if ENV['RACK_ENV'] == 'production'
    plugin :default_headers,
      'Cache-Control' => 'public,max-age=3600',
      'Strict-Transport-Security' => 'max-age=16070400; includeSubDomains',
      'X-Frame-Options' => 'deny'
  end


  Dir["routes/*.rb"].each {|file| require_relative file }

  route do |r|
    r.public
    r.multi_route

    r.root do
      # 70 logos is enough for 23 * 3 rows
      @logos = Logo.where(:size => '128x128')
                   .order(Sequel.lit('RANDOM()'))
                   .limit(70)
                   .eager_graph(:service => :default_bearer).all
      view('homepage')
    end

    r.get 'logos' do
      view('logos')
    end

    r.get 'sitemap.xml' do
      models = [Authority, Multiplex, Service, Transmitter]
      @paths = ['/', '/logos']
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

  require './helpers'
end
