class App
  route('authorities') do |r|
    r.get true do
      @authorities = Authority.valid.sort_by(&:name)
      view('authorities_index')
    end

    r.get String do |fqdn|
      @authority = Authority.first!(:fqdn => fqdn)
      @services = Service.where(:authority => @authority)
                         .order(:sort_name)
                         .eager_graph(:default_bearer).all
      view('authorities_show')
    end
  end
end
