class Reittiopas

# This class represents a Location.
class Location

  # Get the name of the location.
  attr_accessor :name

  # Get the city of the location.
  attr_accessor :city

  # Get the type of the location.
  attr_accessor :type

  # Get coordinates of the location as a Hash containing Coordinates objects.
  attr_accessor :coordinates

  # Get the street number of the location.
  attr_accessor :number

  # Create a Location object from Nokogiri::XML::Element object containing
  # location data.
  def self.parse(xml)
    attr = xml.attributes

    category = xml.get_attr_value('category')

    loc = case category
      when "street" then Street.new
      when "stop"   then Stop.new
      when "poi"    then PointOfInterest.new
      else Location.new
    end

    loc.name = xml.get_attr_value 'name1'
    loc.city = xml.get_attr_value 'city'
    type     = xml.get_attr_value 'type'
    code     = xml.get_attr_value 'code'
    number   = xml.get_attr_value 'number'
    address  = xml.get_attr_value 'address'

    loc.type    = type.to_i   if type
    loc.code    = code.to_i   if code
    loc.number  = number.to_i if number
    loc.address = address     if address

    coordinates = {}

    if attr["x"] && attr["y"]
      coordinates[:kkj] = Coordinates::KKJ.new(Hash[*%w(x y).map { |e| [e.to_sym, attr[e].value.to_i] }.flatten])
    end

    if attr["lat"] && attr["lon"]
      coordinates[:wgs] = Coordinates::WGS.new(Hash[*%w(lat lon).map { |e| [e.to_sym, attr[e].value.to_f] }.flatten])
    end

    loc.coordinates = coordinates unless coordinates.empty?

    return loc
  end

  # Get the name and street number (if applicable) of the location.
  def to_s
    "#{name} #{number}".strip
  end

class PointOfInterest < Location
  # Get the code of the point of interest location.
  attr_accessor :code
end

class Stop < Location
  # Get the address of the bus stop.
  #
  # To follow the API's response format, only bus stops have an address. FIXME?
  attr_accessor :address

  # Get the code of the bus stop.
  attr_accessor :code
end

class Street < Location
  # Get the street number of the location.
  attr_accessor :number
end
end
end