# Reittiopas is a Ruby library for accessing the
# {Reittiopas Developer API}[http://developer.reittiopas.fi/pages/fi/reittiopas-api.php].
#
class Reittiopas
  include Geocoding

  # Instantiate a Reittiopas object.
  #
  # [account] A hash containing the keys +:username+ and +:password+ with
  #           their respective values.
  #
  #   Reittiopas.new(:username => 'exampleuser', :password => 'lolcat')
  def initialize(account)
    @http = Reittiopas::HTTP.new(account)
  end
end
