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
      @response = File.read(File.dirname(__FILE__) + '/fixtures/route_ulvilantie_19-kallion_kirjasto.xml')
      stub_request(:any, /.*/).to_return(:body => @response, :status => 200)   

      @ulvilantie = Reittiopas::Location.parse(parse_elem(File.read(File.dirname(__FILE__) + '/fixtures/ulvilantie_19_helsinki.xml')))
      @kallion_kirjasto = Reittiopas::Location.parse(parse_elem(File.read(File.dirname(__FILE__) + '/fixtures/kallion_kirjasto.xml')))
    end
    
    it "should require from and to locations with options and return an array of routes" do  
      options = {}
      @reittiopas.routing(@ulvilantie, @kallion_kirjasto, options).should be_a Array
    end
  
    it "should pass options to reittiopas" do
      options = { :option1 => "value1",
                  :option2 => 2 }
      
      @reittiopas.routing(@ulvilantie, @kallion_kirjasto, options)
      
      a_request(:get, /.*option1=value1&option2=2.*/).should have_been_made.once
    end
    
    
  end
  
  describe Reittiopas::Routing::Route do
      
    before(:all) do
      xml = File.read(File.dirname(__FILE__) + '/fixtures/route_ulvilantie_19-kallion_kirjasto.xml')
      doc = Nokogiri::XML(xml).search("ROUTE").first
      
      @route = Reittiopas::Routing::Route.parse(doc) 
    end
    
    specify { @route.time.should == 34.605 }
    specify { @route.distance.should == 8150.277 }    
    specify { @route.parts.should be_a(Array) }
    specify { @route.walks.should be_a(Array) }
    specify { @route.lines.should be_a(Array) }
    
    specify { @route.parts.last.should be_a(Reittiopas::Routing::Point)}
    specify { @route.parts.first.should be_a(Reittiopas::Routing::Point)}

    specify { @route.parts[1].should be_a(Reittiopas::Routing::Walk)}
    specify { @route.parts[2].should be_a(Reittiopas::Routing::Line)}
    specify { @route.parts[3].should be_a(Reittiopas::Routing::Walk)}
    specify { @route.parts[4].should be_a(Reittiopas::Routing::Line)}

    specify { @route.walks[0].should be_a(Reittiopas::Routing::Walk)}
    specify { @route.walks[1].should be_a(Reittiopas::Routing::Walk)}
    specify { @route.walks[2].should be_a(Reittiopas::Routing::Walk)}

    specify { @route.lines[0].should be_a(Reittiopas::Routing::Line)}
    specify { @route.lines[1].should be_a(Reittiopas::Routing::Line)}
        
  end
  
  describe Reittiopas::Routing::Point do
    
    before(:all) do
      doc = Nokogiri::XML(%{<POINT uid="start" x="2548199.0" y="6677769.0">
  			<ARRIVAL date="20101213" time="2102"/>
  			<DEPARTURE date="20101213" time="2102"/>
  		</POINT>})
  		
  		element = doc.elements.first
      @point = Reittiopas::Routing::Point.parse(element)
    end
    
    specify { @point.uid.should == "start" }
    specify { @point.x.should == 2548199.0 }
    specify { @point.y.should == 6677769.0 }
    specify { @point.arrival.should be_a Reittiopas::Routing::Arrival }
    specify { @point.departure.should be_a Reittiopas::Routing::Departure }
    
    specify { @point.arrival.date_time.should == DateTime.new(2010,12,13,21,02)}
    specify { @point.departure.date_time.should == DateTime.new(2010,12,13,21,02)}

  end

  describe Reittiopas::Routing::MapLocation do
    
    before(:all) do
      doc = Nokogiri::XML(%{<MAPLOC x="2548250.4" y="6677834.0" type="0">
				<ARRIVAL date="20101213" time="2104"/>
				<DEPARTURE date="20101214" time="2105"/>
				<NAME lang="1" val="Fleminginkatu"/>
			</MAPLOC>})
  		
  		element = doc.elements.first
      @map_location = Reittiopas::Routing::MapLocation.parse(element)
    end
    
    specify { @map_location.x.should == 2548250.4 }
    specify { @map_location.y.should == 6677834.0 }
    specify { @map_location.location_type.should == 0 }
    specify { @map_location.arrival.should be_a Reittiopas::Routing::Arrival }
    specify { @map_location.departure.should be_a Reittiopas::Routing::Departure }

    specify { @map_location.arrival.date_time.should == DateTime.new(2010,12,13,21,04)}
    specify { @map_location.departure.date_time.should == DateTime.new(2010,12,14,21,05)}
    
    specify { @map_location.name.should == "Fleminginkatu" }
  end



  describe Reittiopas::Routing::Arrival do
    
    before(:all) do
      doc = Nokogiri::XML(%{<ARRIVAL date="20101213" time="2102"/>})
  		
  		element = doc.elements.first
      @arrival = Reittiopas::Routing::Arrival.parse(element)
    end
    
    specify { @arrival.date_time.should == DateTime.new(2010,12,13,21,02) }    
  end

  describe Reittiopas::Routing::Departure do
    
    before(:all) do
      doc = Nokogiri::XML(%{<DEPARTURE date="20101214" time="2103"/>})
  		
  		element = doc.elements.first
      @arrival = Reittiopas::Routing::Departure.parse(element)
    end
    
    specify { @arrival.date_time.should == DateTime.new(2010,12,14,21,03) }    
  end


  describe Reittiopas::Routing::Walk do
    
    before(:all) do
      doc = Nokogiri::XML(%{<WALK>
  			<LENGTH time="1.257" dist="132.387"/>

  			<POINT uid="start" x="2548199.0" y="6677769.0">
  				<ARRIVAL date="20101213" time="2102"/>
  				<DEPARTURE date="20101213" time="2102"/>
  			</POINT>
  			<MAPLOC x="2548250.4" y="6677834.0" type="0">
  				<ARRIVAL date="20101213" time="2104"/>
  				<DEPARTURE date="20101213" time="2104"/>
  			</MAPLOC>
  			<STOP code="6:1304133" x="2548265.0" y="6677828.0" id="1335">

  				<ARRIVAL date="20101213" time="2104"/>
  				<DEPARTURE date="20101213" time="2104"/>
  				<NAME lang="1" val="Ulvilantie 21"/>
  				<NAME lang="2" val="Ulfsbyvägen 21"/>
  			</STOP>
  		</WALK>})
  		element = doc.elements.first
  		
      @walk = Reittiopas::Routing::Walk.parse(element)
    end
    
    specify { @walk.time.should == 1.257 }
    specify { @walk.distance.should == 132.387 }
    specify { @walk.sections.should be_a(Array)}
    specify { @walk.sections.first.should be_a(Reittiopas::Routing::Point)}
    specify { @walk.sections[1].should be_a(Reittiopas::Routing::MapLocation)}
    specify { @walk.sections[2].should be_a(Reittiopas::Routing::Stop)}
    
    specify { @walk.stops.first.arrival.date_time.should == DateTime.new(2010, 12, 13, 21, 04)}
    specify { @walk.map_locations.first.arrival.date_time.should == DateTime.new(2010, 12, 13, 21, 04)}
    specify { @walk.points.first.arrival.date_time.should == DateTime.new(2010, 12, 13, 21, 02)}
    
  end

  describe Reittiopas::Routing::Line do
    
    before(:all) do
      doc = Nokogiri::XML(%{<LINE id="138" code="1018  2" type="1" mobility="3">
  			<LENGTH time="13.000" dist="5557.353"/>
  			<STOP code="6:1304133" x="2548265.0" y="6677828.0" id="1335" ord="7">

  				<ARRIVAL date="20101213" time="2104"/>
  				<DEPARTURE date="20101213" time="2104"/>
  				<NAME lang="1" val="Ulvilantie 21"/>
  				<NAME lang="2" val="Ulfsbyvägen 21"/>
  			</STOP>
  			<STOP code="6:1304134" x="2548692.0" y="6677805.0" id="1336">
  				<ARRIVAL date="20101213" time="2105"/>
  				<DEPARTURE date="20101213" time="2105"/>
  				<NAME lang="1" val="Ulvilantie 27"/>

  				<NAME lang="2" val="Ulfsbyvägen 27"/>
  			</STOP>
  			<STOP code="6:1304135" x="2548854.0" y="6677629.0" id="1337">
  				<ARRIVAL date="20101213" time="2106"/>
  				<DEPARTURE date="20101213" time="2106"/>
  				<NAME lang="1" val="Naantalintie"/>
  				<NAME lang="2" val="Nådendalsvägen"/>
  			</STOP>
  			<STOP code="6:1304137" x="2548967.0" y="6677478.0" id="1339">

  				<ARRIVAL date="20101213" time="2106"/>
  				<DEPARTURE date="20101213" time="2106"/>
  				<NAME lang="1" val="Munkkivuori"/>
  				<NAME lang="2" val="Munkshöjden"/>
  			</STOP>
  			<STOP code="6:1301158" x="2549077.0" y="6677036.0" id="1303">
  				<ARRIVAL date="20101213" time="2108"/>
  				<DEPARTURE date="20101213" time="2108"/>
  				<NAME lang="1" val="Niemenmäki"/>

  				<NAME lang="2" val="Näshöjden"/>
  			</STOP>
  			<STOP code="6:1301126" x="2549163.0" y="6676754.0" id="1296">
  				<ARRIVAL date="20101213" time="2109"/>
  				<DEPARTURE date="20101213" time="2109"/>
  				<NAME lang="1" val="Lokkalantie"/>
  				<NAME lang="2" val="Locklaisvägen"/>
  			</STOP>
  			<STOP code="6:1301124" x="2549280.0" y="6676400.0" id="1294">

  				<ARRIVAL date="20101213" time="2110"/>
  				<DEPARTURE date="20101213" time="2110"/>
  				<NAME lang="1" val="Munkkiniemen aukio"/>
  				<NAME lang="2" val="Munksnäsplatsen"/>
  			</STOP>
  			<STOP code="6:1150114" x="2549570.0" y="6676265.0" id="544">
  				<ARRIVAL date="20101213" time="2111"/>
  				<DEPARTURE date="20101213" time="2111"/>
  				<NAME lang="1" val="Paciuksenkaari"/>

  				<NAME lang="2" val="Paciussvängen"/>
  			</STOP>
  			<STOP code="6:1150112" x="2549875.0" y="6676008.0" id="542">
  				<ARRIVAL date="20101213" time="2112"/>
  				<DEPARTURE date="20101213" time="2112"/>
  				<NAME lang="1" val="Meilahdentie"/>
  				<NAME lang="2" val="Mejlansvägen"/>
  			</STOP>
  			<STOP code="6:1150132" x="2550190.0" y="6675858.0" id="559">

  				<ARRIVAL date="20101213" time="2113"/>
  				<DEPARTURE date="20101213" time="2113"/>
  				<NAME lang="1" val="Mäntytie"/>
  				<NAME lang="2" val="Tallvägen"/>
  			</STOP>
  			<STOP code="6:1150110" x="2550509.0" y="6675806.0" id="540">
  				<ARRIVAL date="20101213" time="2114"/>
  				<DEPARTURE date="20101213" time="2114"/>
  				<NAME lang="1" val="Haartmaninkatu"/>

  				<NAME lang="2" val="Haartmansgatan"/>
  			</STOP>
  			<STOP code="6:1150108" x="2550696.0" y="6675654.0" id="538">
  				<ARRIVAL date="20101213" time="2114"/>
  				<DEPARTURE date="20101213" time="2114"/>
  				<NAME lang="1" val="Naistenklinikka"/>
  				<NAME lang="2" val="Kvinnokliniken"/>
  			</STOP>
  			<STOP code="6:1140105" x="2551068.0" y="6675103.0" id="476">

  				<ARRIVAL date="20101213" time="2116"/>
  				<DEPARTURE date="20101213" time="2116"/>
  				<NAME lang="1" val="Linnankoskenkatu"/>
  				<NAME lang="2" val="Linnankoskigatan"/>
  			</STOP>
  			<STOP code="6:1140130" x="2551252.0" y="6674769.0" id="496">
  				<ARRIVAL date="20101213" time="2117"/>
  				<DEPARTURE date="20101213" time="2117"/>
  				<NAME lang="1" val="Töölön sairaala"/>

  				<NAME lang="2" val="Tölö sjukhus"/>
  			</STOP>
  			<STOP code="6:1140103" x="2551355.0" y="6674571.0" id="474" ord="21">
  				<ARRIVAL date="20101213" time="2117"/>
  				<DEPARTURE date="20101213" time="2117"/>
  				<NAME lang="1" val="Töölöntori"/>
  				<NAME lang="2" val="Tölötorg"/>
  			</STOP>
  		</LINE>
  		})
  		element = doc.elements.first
  		
      @line = Reittiopas::Routing::Line.parse(element)
    end
    
    
    specify { @line.line_id.should == "138" }
    specify { @line.code.should == "1018  2" }
    specify { @line.line_type.should == 1 }
    specify { @line.mobility.should == 3 }

    specify { @line.time.should == 13.000 }
    specify { @line.distance.should == 5557.353 }
    
    specify { @line.sections.should be_a(Array) }
    specify { @line.stops.should be_a(Array) }

    specify { @line.stops.first.arrival.date_time.should == DateTime.new(2010, 12, 13, 21, 04)}
    specify { @line.stops.first.names["1"].should == "Ulvilantie 21" }
    specify { @line.stops.last.names["1"].should == "Töölöntori" }
    
    specify { @line.stops.size.should == 15}
    specify { @line.sections.size.should == 15}
  
  
    describe "creation" do
      specify { Reittiopas::Routing::Line.new({}).stops.should == [] }
    end
  
  end


  describe Reittiopas::Routing::Stop do
    
    before(:all) do
      doc = Nokogiri::XML(%{<STOP code="6:1304133" x="2548265.0" y="6677828.0" id="1335">

				<ARRIVAL date="20101213" time="2104"/>
				<DEPARTURE date="20101213" time="2104"/>
				<NAME lang="1" val="Ulvilantie 21"/>
				<NAME lang="2" val="Ulfsbyvägen 21"/>
			</STOP>})
  		element = doc.elements.first
  		
      @stop = Reittiopas::Routing::Stop.parse(element)
    end
    
    specify { @stop.code.should == "6:1304133" }
    specify { @stop.x.should == 2548265.0 }
    specify { @stop.y.should == 6677828.0 }
    specify { @stop.stop_id.should == "1335" }
    
    specify { @stop.arrival.should be_a(Reittiopas::Routing::Arrival)}
    specify { @stop.departure.should be_a(Reittiopas::Routing::Departure)}

    specify { @stop.names.should == { "1" => "Ulvilantie 21",
                                      "2" => "Ulfsbyvägen 21"}}
    
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

