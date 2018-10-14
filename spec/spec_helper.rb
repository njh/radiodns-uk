$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'bundler'
require 'rspec/matchers'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

require_relative '../models'
