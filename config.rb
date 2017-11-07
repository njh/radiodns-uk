# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

page "services/*", :layout => :service_layout


activate :directory_indexes



activate :s3_sync do |s3_sync|
  s3_sync.bucket                = 'www.radiodns.uk'
  s3_sync.region                = 'eu-west-1'
  s3_sync.aws_access_key_id     = ENV['RADIODNS_UK_AWS_KEY']
  s3_sync.aws_secret_access_key = ENV['RADIODNS_UK_AWS_SECRET']
  s3_sync.prefer_gzip           = true
  s3_sync.path_style            = true
  s3_sync.acl                   = 'public-read'
  s3_sync.index_document        = 'index.html'
  s3_sync.error_document        = 'error.html'
end
