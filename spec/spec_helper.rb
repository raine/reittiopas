$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'reittiopas'
require 'webmock/rspec'
include WebMock

BASE_URI = "http://api.reittiopas.fi/public-ytv/fi/api/"

def parse_elem(xml)
  Nokogiri::XML(xml).children[0]
end
