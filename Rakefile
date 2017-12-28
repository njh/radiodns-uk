#!/usr/bin/env ruby

desc "Download the Transmitter Parameters file from Ofcom"
file 'TxParams.xslx' do |task|
  ruby 'bin/download-txparams.rb'
end

desc "Convert the Transmitter Parameters file to JSON"
file 'TxParams.json' => 'TxParams.xslx' do |task|
  ruby 'bin/convert-txparams.rb'
end

desc "Looking authoritative FQDNs for each of the radio stations"
file 'authoritative-fqdns.json' => 'TxParams.json' do |task|
  ruby 'bin/lookup-authoritative-fqdns.rb'
end

desc "Download SI.xml files for each of the authoritative FQDNs"
directory 'si_files' => 'authoritative-fqdns.json' do |task|
  ruby 'bin/download-si-files.rb'
end

desc "Build Service Page files"
directory 'source/services' => 'si_files' do |task|
  ruby 'bin/build-service-pages.rb'
end

desc "Re-build the HTML site using Middleman"
task :build => ['source/services'] do |task|
  system 'bundle exec middleman build'
end

desc "Start Middleman Web Server"
task :server => ['source/services'] do |task|
  system 'bundle exec middleman server'
end

desc "Upload site to Amazon S3"
task :publish => :build do |task|
  ruby 'bin/update-to-s3.rb'
end

task :default => :build


desc "Deleted all the generated files (based on .gitignore)"
task :clean do
  File.foreach('.gitignore') do |line|
    # For safety
    next unless line =~ /^\w+/
    sh 'rm', '-Rf', line.strip
  end
end
