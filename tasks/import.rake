#!/usr/bin/env ruby

namespace :import do
  desc "Import TVA genre data into the database"
  task :genres do
    ruby "bin/load-genre-data.rb"
  end

  desc "Import Ofcom data into the database"
  task :ofcom do
    ruby "bin/load-ofcom-data.rb"
  end

  desc "Lookup Authorative FQDNs for each bearer"
  task :fqdns do
    ruby "bin/lookup-authoritative-fqdns.rb"
  end

  desc "Import SI files into the database"
  task :si do
    ruby "bin/load-si-data.rb"
  end

  desc "Import all data into the database"
  task :all => [:genres, :ofcom, :fqdns, :si]
end
