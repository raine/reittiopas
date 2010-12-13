$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'reittiopas'

require 'webmock/rspec'
include WebMock::API

def parse_elem(xml)
  Nokogiri::XML(xml).children[0]
end


describe Reittiopas do

  before(:all) do
    account = {:username => 'foo', :password => 'bar'}
    @reittiopas = Reittiopas.new(account)

  end
  
  describe "#routing" do
    
    before do
      response = File.read(File.dirname(__FILE__) + '/fixtures/route_ulvilantie_19-kallion_kirjasto.xml')
      stub_request(:any, /.*/).to_return(:body => response, :status => 200)   

      @ulvilantie = Reittiopas::Location.parse(parse_elem(File.read(File.dirname(__FILE__) + '/fixtures/ulvilantie_19_helsinki.xml')))
      @kallion_kirjasto = Reittiopas::Location.parse(parse_elem(File.read(File.dirname(__FILE__) + '/fixtures/kallion_kirjasto.xml')))
    end
    
    it "should require from and to locations with options" do
      
      options = {}
      
      @reittiopas.routing(@ulvilantie, @kallion_kirjasto, options).should == []
    end

  end


  describe Reittiopas::Location::Coordinates::KKJ do
    before(:all) do
      @coordinates = Reittiopas::Location::Coordinates::KKJ.new(:x => 2541494, :y => 6680344)
    end
    
    it "should format a routing coordinate string" do
      @coordinates.to_routing_string.should == "2541494,6680344"
    end
  end
end

