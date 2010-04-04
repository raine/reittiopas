class Reittiopas

# Reittiopas::HTTP is initialized with account details upon initialization
# of a Reittiopas object.
#
# Since Reittiopas API is to be queried using
# GET requests with appropriate query parameters, Reittiopas::HTTP exists
# to simplify the process by offering a +get+ method that accepts a hash
# containing the query parameters as an argument.
#
class HTTP
  # Base URI for the Reittiopas API service.
  API_BASE_URI = "http://api.reittiopas.fi/public-ytv/fi/api/"

  # Addressable::URI instance of the API URI with account details set as
  # query parameters.
  attr_reader :api_uri

  # Create a new Reittiopas::HTTP object.
  #
  # +account+ should be a hash containing +:username+ and +:password+.
  def initialize(account)
    @api_uri = Addressable::URI.parse(API_BASE_URI)
    @api_uri.query_values = {:user => account[:username], :pass => account[:password]}
  end

  # Send a GET request to the API with account details and +opts+ as query
  # parameters.
  #
  # * +opts+ — A hash containing query parameters. Values are automatically
  # encoded by Addressable::URI.
  def get(opts)
    raise ArgumentError if opts.empty?
    uri = @api_uri.dup
    opts.merge!(opts){ |k,ov| ov.to_s } # Coordinates to string
    uri.query_values = uri.query_values.merge(opts)
    return Net::HTTP.get(uri)
  end
end
end
