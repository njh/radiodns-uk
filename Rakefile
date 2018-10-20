#!/usr/bin/env ruby

require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

Dir.glob('tasks/*.rake').each { |r| import r }


desc "Deleted all the generated files (based on .gitignore)"
task :clean do
  File.foreach('.gitignore') do |line|
    # For safety
    next unless line =~ /^\w+/
    sh 'rm', '-Rf', line.strip
  end
end
