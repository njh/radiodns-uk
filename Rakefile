#!/usr/bin/env ruby

require 'rake'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

Dir.glob('tasks/*.rake').each { |r| import r }

desc "Publish the local SQLite database to the web server"
task :publish do
  raise "Not publishing empty database" if File.size('database.sqlite') < 1024
  sh 'scp database.sqlite radiodns-uk@skypi.aelius.com:/srv/www/radiodns-uk'
end

desc "Deleted all the generated files (based on .gitignore)"
task :clean do
  File.foreach('.gitignore') do |line|
    # For safety
    next unless line =~ /^\w+/
    sh 'rm', '-Rf', line.strip
  end
end
