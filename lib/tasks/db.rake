#!/usr/bin/env ruby

namespace :db do
  desc "Migrate database to latest version"
  task :migrate do
    require_relative '../../db'
    require 'logger'
    Sequel.extension :migration
    DB.loggers << Logger.new($stdout) if DB.loggers.empty?
    Sequel::Migrator.apply(DB, 'migrate')
  end

  desc "Annotate Sequel models"
  task "annotate" do
    ENV['RACK_ENV'] = 'development'
    require_relative '../../models'
    DB.loggers.clear
    require 'sequel/annotate'
    Sequel::Annotate.annotate(Dir['models/*.rb'])
  end
end
