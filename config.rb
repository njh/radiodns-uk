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
