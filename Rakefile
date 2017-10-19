#!/usr/bin/env ruby

desc "Download the Library Index JSON file from Ofcom"
file 'TxParams.xslx' do |task|
  ruby 'bin/download-txparams.rb'
end

desc "Deleted all the generated files (based on .gitignore)"
task :clean do
  File.foreach('.gitignore') do |line|
    # For safety
    next unless line =~ /^\w+/
    sh 'rm', '-Rf', line.strip
  end
end
