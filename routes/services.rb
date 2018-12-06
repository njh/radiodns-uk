class App
  route('services') do |r|
    r.get true do
      @services = Service.valid.order(:sort_name).
                  eager(:default_bearer, :logo_colour_rectangle).all

      r.html { view('services_index') }
      r.json { render('services_index', :engine => 'yajl') }
      r.csv { render('services_index', :engine => 'rcsv') }
      "Unsupported format"
    end

    # FIXME: there must be a nicer way of passing 'r'
    def services_show(r)
      @service = @bearer.service
      raise Sequel::NoMatchingRow.new(Service) if @service.nil?
      if @bearer.path != @service.path
        r.redirect(@service.path, 301)
      else
        r.html { view('services_show') }
        r.json { render('services_show', :engine => 'yajl') }
        "Unsupported format"
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
end
