class Reittiopas

# Module implementing the geocoding features of the Reittiopas API
# documented at http://developer.reittiopas.fi/pages/fi/http-get-interface.php
module Geocoding

  # Send a geocode location query to the API.
  # Both geocoding, and reverse geocoding data is accessed through this method.
  #
  # Returns results as an array containing Reittiopas::Location objects.
  #
  # === Examples:
  # * Search for location by keyword _tee_.
  #  reittiopas.location('tee')
  #
  # * Search for location by KKJ coordinates x: _2546445_, y: _6675512_.
  #  reittiopas.location(:x => 2546445, :y => 6675512)
  #
  def location(opts)
    params = if opts.is_a? String
      {:key => opts}
    elsif opts.is_a? Hash
      opts
    end

    parse @http.get(params), opts
  end

private
  # Parse XML received from a geocoding API query.
  def parse(xml, opts)
    doc = Nokogiri::XML(xml)

    locations = doc.search('LOC').map do |loc|
      Reittiopas::Location.parse(loc)
    end

    # Add KKJ coordinates from REVERSE tag to each Location returned
    # in case it was a reverse geocoding query
    if opts.is_a? Hash
      reverse = doc.search('REVERSE').last
      x = reverse.get_attr_value('x').to_i
      y = reverse.get_attr_value('y').to_i

      locations.each do |loc|
        loc.coordinates = { :kkj => Reittiopas::Location::Coordinates::KKJ.new(:x => x, :y => y) }
      end
    end

    return locations
  end
end
end
