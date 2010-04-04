require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Reittiopas()" do
  before { @account = {:username => 'foo', :password => 'bar'} }

  context "when called with an account hash as argument" do
    subject { Reittiopas(@account) }

    it "should return a Reittiopas object" do
      should be_a_kind_of(Reittiopas)
    end
  end
end

describe Reittiopas do
  before { @account = {:username => 'foo', :password => 'bar'} }

  context "when initialized with an account" do
    subject { Reittiopas.new(@account) }

    it { should respond_to(:location) }
  end

  describe "#location" do
    before  { @reittiopas = Reittiopas.new(@account) }

    context "when given key 'tee' that returns 18 locations from API" do
      before do
        response = File.read(File.dirname(__FILE__) + '/fixtures/key.xml')
        stub_request(:any, /.*key=tee.*/).to_return(:body => response, :status => 200)
      end

      subject { @reittiopas.location('tee') }

      it "should return 18 locations in an array" do
        should have(18).items

        subject.each do |obj|
          obj.should be_a Reittiopas::Location
        end
      end
    end

    context "when given KKJ coordinates that return one location from API" do
      before do
        response = File.read(File.dirname(__FILE__) + '/fixtures/reverse_geocoding.xml')
        stub_request(:any, /(?:x|y)=\d+&(?:x|y)=\d+/).to_return(:body => response, :status => 200)
      end

      subject { @reittiopas.location(:x => 2546445, :y => 6675512) }

      it "should return one result" do
        should have(1).item
      end

      it "should return a location" do
        subject.first.should be_a Reittiopas::Location
      end

      it "should return a location with KKJ coordinates" do
        subject.last.coordinates[:kkj].x.should eql 2546445
        subject.last.coordinates[:kkj].y.should eql 6675512
      end
    end
  end
end

describe Reittiopas::HTTP do
  it "should have the proper base API URI" do
    Reittiopas::HTTP::API_BASE_URI.should eql(BASE_URI)
  end

  before do
    @account = {:username => 'foo', :password => 'bar'}
    @http = Reittiopas::HTTP.new(@account)
  end

  context "when initialized with an account" do
    subject { Reittiopas::HTTP.new(@account) }
    it { should respond_to(:get) }

    it "should create an API URI with account details" do
      subject.api_uri.query_values.
        should eql('user' => @account[:username], 'pass' => @account[:password])
    end
  end

  describe "#get" do
    context "with empty hash as argument" do
      it { lambda { @http.get({}) }.should raise_error(ArgumentError) }
    end

    context "with proper hash as argument" do
      before do
        @opts = {'key' => 'Keihäänheittäjänkuja 12'}
        @uri  = @http.api_uri
        @uri.query_values = @uri.query_values.merge(@opts)
      end

      it "should create a request" do
        stub_request(:get, Regexp.new(BASE_URI))
        @http.get(@opts)
        request(:get, @uri.to_s).should have_been_made
      end

      it "should return response body on successful request" do
        stub_request(:get, @uri.to_s).to_return(:body => 'hello', :status => 200)
        @http.get(@opts).should eql('hello')
      end
    end
  end
end

describe Reittiopas::Location do
  it { should respond_to :name }
  it { should respond_to :city }
  it { should respond_to :type }

  describe "#parse" do
    context "when given LOC" do
      context "example 1" do
        xml = parse_elem '<LOC name1="Sello" number="" city="Espoo" code="2112201" address="Ratsukuja" type="10" category="stop" x="2545011" y="6678850" lon="24.80882" lat="60.21867"/>'
        subject { Reittiopas::Location.parse xml }

        it { subject.should be_a Reittiopas::Location::Stop }
        it { subject.address.should eql 'Ratsukuja' }
        it { subject.city.should eql 'Espoo' }
        it { subject.name.should eql 'Sello' }
        it { subject.type.should eql 10 }
        it { subject.code.should eql 2112201 }
        it { subject.coordinates[:kkj].x.should eql 2545011 }
        it { subject.coordinates[:kkj].y.should eql 6678850 }
        it { subject.coordinates[:wgs].longitude.should eql 24.80882 }
        it { subject.coordinates[:wgs].latitude.should  eql 60.21867 }
        it { subject.to_s.should eql 'Sello' }
      end

      context "example 2" do
        xml = parse_elem '<LOC name1="Kahisevantie" number="2" city="Espoo" code="" address="" type="900" category="street" x="2541494" y="6680344" lon="24.74568" lat="60.23245"/>'
        subject { Reittiopas::Location.parse xml }

        it { subject.should be_a Reittiopas::Location::Street }
        it { subject.should_not respond_to :address }
        it { subject.should_not respond_to :code }
        it { subject.city.should eql 'Espoo' }
        it { subject.name.should eql 'Kahisevantie' }
        it { subject.type.should eql 900 }
        it { subject.number.should eql 2 }
        it { subject.coordinates[:kkj].x.should eql 2541494 }
        it { subject.coordinates[:kkj].y.should eql 6680344 }
        it { subject.coordinates[:wgs].longitude.should eql 24.74568 }
        it { subject.coordinates[:wgs].latitude.should  eql 60.23245 }
        it { subject.to_s.should eql 'Kahisevantie 2'  }
      end

      context "example 3" do
        xml = parse_elem '<LOC name1="Teeripuisto" number="" city="Helsinki" code="1700" address="" type="3" category="poi" x="2556686" y="6682815" lon="25.02051" lat="60.2528" />'
        subject { Reittiopas::Location.parse xml }

        it { subject.should be_a Reittiopas::Location::PointOfInterest }
        it { subject.should_not respond_to :address }
        it { subject.city.should eql 'Helsinki' }
        it { subject.name.should eql 'Teeripuisto' }
        it { subject.type.should eql 3 }
        it { subject.coordinates[:kkj].x.should eql 2556686 }
        it { subject.coordinates[:kkj].y.should eql 6682815 }
        it { subject.coordinates[:wgs].longitude.should eql 25.02051 }
        it { subject.coordinates[:wgs].latitude.should  eql 60.2528 }
        it { subject.to_s.should eql 'Teeripuisto' }
      end

      context "example 4" do
        xml = parse_elem '<LOC name1="Otakaari" number="9" city="Espoo"  />'
        subject { Reittiopas::Location.parse xml }

        it { subject.should be_a Reittiopas::Location }
        it { subject.city.should eql 'Espoo' }
        it { subject.name.should eql 'Otakaari' }
        it { subject.number.should eql 9 }
        it { subject.should_not respond_to :address }
        it { subject.should_not respond_to :code }
        it { subject.type.should_not be }
        it { subject.coordinates.should_not be }
        it { subject.to_s.should eql 'Otakaari 9' }
      end
    end

    context "when given LOC has 'poi' as category" do
      xml = parse_elem '<LOC name1="Teeripuisto" number="" city="Helsinki" code="1700" address="" type="3" category="poi" x="2556686" y="6682815" lon="25.02051" lat="60.2528" />'
      subject { Reittiopas::Location.parse xml }

      it "should return a Location" do
        should be_a Reittiopas::Location::PointOfInterest
      end
    end

    context "when given LOC has 'stop' as category" do
      xml = parse_elem '<LOC name1="Teeritie" number="" city="Vantaa" code="4810204" address="Korsontie" type="10" category="stop" x="2559002" y="6694007" lon="25.06559" lat="60.35291" />'
      subject { Reittiopas::Location.parse xml }

      it "should return a Stop" do
        should be_a Reittiopas::Location::Stop
      end
    end

    context "when given LOC has 'street' as category" do
      xml = parse_elem '<LOC name1="Kahisevantie" number="2" city="Espoo" code="" address="" type="900" category="street" x="2541494" y="6680344" lon="24.74568" lat="60.23245"/>'
      subject { Reittiopas::Location.parse xml }

      it "should return a Street" do
        should be_a Reittiopas::Location::Street
      end
    end
  end
end

describe Reittiopas::Location::PointOfInterest do
  it { should respond_to :code }
end

describe Reittiopas::Location::Stop do
  it { should respond_to :address }
  it { should respond_to :code }
end

describe Reittiopas::Location::Street do
  it { should     respond_to :number }
  it { should_not respond_to :code }
end

describe Reittiopas::Location::Coordinates::KKJ do
  subject { Reittiopas::Location::Coordinates::KKJ.new(:x => 2541494, :y => 6680344) }

  it { should respond_to :x }
  it { should respond_to :y }
end

describe Reittiopas::Location::Coordinates::WGS do
  subject { Reittiopas::Location::Coordinates::WGS.new(:lon => 24.74568, :lat => 60.23245) }

  it { should respond_to :latitude }
  it { should respond_to :longitude }
  
  it { subject.to_s.should eql '60.23245, 24.74568' }
end
