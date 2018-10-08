# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false


activate :directory_indexes
set :trailing_slash, false

## Search Engine Optimisation
set :url_root, 'https://www.radiodns.uk'
activate :search_engine_sitemap, default_change_frequency: "weekly"

# Redirects from old URLs
activate :alias



helpers do
  def path_for_bearer(bearer_id)
    '/services/' + bearer_id.split(/\W+/).join('/')
  end

  def find_resource_by_bearer_id(bearer_id)
    path = path_for_bearer(bearer_id) + '/index.html'
    app.sitemap.find_resource_by_destination_path(path)
  end
end
