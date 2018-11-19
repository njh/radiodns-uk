#!/usr/bin/env ruby

namespace :build do
  desc "Load Zip files containing station logos"
  task :logopacks do
    ruby "bin/build-logopacks.rb"
  end
end
