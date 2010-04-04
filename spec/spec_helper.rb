begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'reittiopas'

require 'webmock/rspec'
include WebMock

BASE_URI = "http://api.reittiopas.fi/public-ytv/fi/api/"

def parse_elem(xml)
  Nokogiri::XML(xml).children[0]
end