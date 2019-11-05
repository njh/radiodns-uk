#!/usr/bin/env ruby

namespace :load do
  desc "Load TVA genre data into the database"
  task :genres do
    ruby "bin/load-genre-data.rb"
  end

  desc "Load Ofcom data into the database"
  task :ofcom do
    ruby "bin/load-ofcom-data.rb"
  end

  desc "Set counties for each transmitter"
  task :counties do
    ruby "bin/load-county-data.rb"
    sh "python bin/set-transmitters-county.py"
  end

  desc "Load authority information for each bearer from radiodns.org"
  task :authorities do
    ruby "bin/load-radiodns-data.rb"
  end

  desc "Load SI files into the database"
  task :si do
    ruby "bin/load-si-data.rb"
  end

  desc "Check which services have PI files"
  task :pi do
    ruby "bin/check-pi-data.rb"
  end

  desc "Load all data into the database"
  task :all => [:genres, :ofcom, :counties, :authorities, :si, :pi]
end
