#!/usr/bin/env ruby

namespace :import do
  desc "Import Ofcom data into the database"
  task :ofcom do
    ruby "bin/load-ofcom-data.rb"
  end

  desc "Import all data into the database"
  task :all => [:ofcom]
end
