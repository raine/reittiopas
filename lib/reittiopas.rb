$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'uri'
require 'cgi'
require 'net/http'
require 'nokogiri'
require 'addressable/uri'

require 'reittiopas/utils'
require 'reittiopas/coordinates'
require 'reittiopas/location'
require 'reittiopas/geocoding'
require 'reittiopas/reittiopas'
require 'reittiopas/http'

class Reittiopas
  # The version of Reittiopas you are using.
  VERSION = "0.0.1"
end

# Shorter way for Reittiopas instance creation.
# In actuality, this doesn't make much sense since it just hides
# the +new+ method. FIXME
def Reittiopas(account)
  return Reittiopas.new(account)
end
