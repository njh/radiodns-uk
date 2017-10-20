#!/usr/bin/env ruby

desc "Download the Transmitter Parameters file from Ofcom"
file 'TxParams.xslx' do |task|
  ruby 'bin/download-txparams.rb'
end

desc "Covert the Transmitter Parameters file to JSON"
file 'TxParams.json' => 'TxParams.xslx' do |task|
  ruby 'bin/convert-txparams.rb'
end

desc "Deleted all the generated files (based on .gitignore)"
task :clean do
  File.foreach('.gitignore') do |line|
    # For safety
    next unless line =~ /^\w+/
    sh 'rm', '-Rf', line.strip
  end
end
