class Reittiopas
class Location
  module Coordinates # :nodoc:
    class WGS
      attr_accessor :latitude, :longitude
      def initialize(opts)
        @latitude  = opts[:lat].to_f
        @longitude = opts[:lon].to_f
      end

      def to_s
        [@latitude, @longitude].join(', ')
      end
    end

    class KKJ
      attr_accessor :x, :y
      def initialize(opts)
        @x = opts[:x].to_i
        @y = opts[:y].to_i
      end
    end
  end
end
end
