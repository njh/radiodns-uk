#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)

require_relative '../models'

Dir.glob(File.dirname(__FILE__) + '/../genres/*.json').each do |filename|
  File.open(filename, 'rb') do |file|
    data = JSON.parse(file.read)
    data.each_pair do |urn,name|
      Genre.update_or_create(:urn => urn) do |genre|
        genre.name = name
      end
    end
  end
end
