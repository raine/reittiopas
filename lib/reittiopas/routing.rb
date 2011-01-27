class Reittiopas
  
  module Routing
  
    # Route between two Locations.  Returns an array of Routes that contain all sub elements
    
    def routing(from, to, opts)
      @from = from
      @to = to
      @options = opts
      
      params = { :a => @from.coordinates[:kkj].to_routing_string,
                 :b => @to.coordinates[:kkj].to_routing_string}.merge(@options)
      
      xml = @http.get(params)
      doc = Nokogiri::XML(xml)
    
      routes = []
      
      doc.search("ROUTE").each do |route|
        routes << Route.parse(route)
      end
    
      return routes
    end
  
  
    class Route
      
      attr_reader :time, :distance, :parts, :walks, :lines
      
      def initialize(opts)
        @time = opts[:time].to_f if opts[:time]
        @distance = opts[:distance].to_f if opts[:time]
        
        @parts, @walks, @lines = opts[:parts], opts[:walks], opts[:lines]      
      end
      
      
      # Parse the route and sub elements
      def self.parse(xml)
        length_element = xml.search("LENGTH").first
        
        time = length_element.get_attr_value "time"
        dist = length_element.get_attr_value "dist"
          
        parts, walks, lines = [], [], []
        
        xml.elements.each do |e|
          next if e.name == "LENGTH"
          case e.name
            when "POINT"
              parts << Point.parse(e)
            when "WALK"
              walk = Walk.parse(e)
              parts << walk
              walks << walk
            when "LINE"
              line = Line.parse(e)
              parts << line
              lines << line
          end

        end

        new(:time => time,
            :distance => dist,
            :parts => parts,
            :walks => walks,
            :lines => lines)
            
      end
      
    end
    
    
    # Points, MapLocations and Stops are Sections
    class Section
      attr_reader :x, :y, :arrival, :departure
      
      def initialize(opts)
        @x = opts[:x].to_f if opts[:x]
        @y = opts[:y].to_f if opts[:y]
        @arrival = opts[:arrival]
        @departure = opts[:departure]
      end

      def self.parse(xml)
        x = xml.get_attr_value "x"
        y = xml.get_attr_value "y"
        
        arrival_element = xml.search("ARRIVAL").first
        departure_element = xml.search("DEPARTURE").first
        
        arrival = Arrival.parse arrival_element
        departure = Departure.parse departure_element
        
        { :x => x,
          :y => y,
          :arrival => arrival,
          :departure => departure }
      end

    end
     
    class Point < Section
      
      attr_reader :uid
      
      def initialize(opts)
        super
        @uid = opts[:uid]
      end

      def self.parse(xml)
        opts = super
        
        uid = xml.get_attr_value "uid"
        
        opts.merge!( :uid => uid )
        new(opts)
      end
    end
    
    class MapLocation < Section
      
      attr_reader :location_type, :name
      
      def initialize(opts)
        super
        @location_type = opts[:location_type].to_i if opts[:location_type]
        @name = opts[:name]
      end
      
      def self.parse(xml)
        opts = super
        location_type = xml.get_attr_value "type"
        
        name_elements = xml.search("NAME")
        name = name_elements.first.get_attr_value "val" if name_elements.first
        
        opts.merge!(:location_type => location_type,
                    :name => name)
                    
        new(opts)
      end
    end
    
    class Stop < Section
      
      attr_reader :code, :stop_id,
                  :names
      
      def initialize(opts)
        super
        @code = opts[:code]
        @stop_id = opts[:stop_id]
        @names = opts[:names]
      end
      
      def self.parse(xml)
        opts = super
        
        code = xml.get_attr_value "code"
        stop_id = xml.get_attr_value "id"
        
        name_elements = xml.search("NAME")
        
        names = {}
        name_elements.each do |e|
          lang = e.get_attr_value "lang"
          val = e.get_attr_value "val"
          
          names[lang] = val
        end
        
        opts.merge!(:code => code,
                    :stop_id => stop_id,
                    :names => names)
        new(opts)
      end
      
    end
    
    # Each Section has Arrival and Departure times (and seems that those are always the same)
    
    class SectionTime
      
      attr_reader :date_time
      
      def initialize(opts)
        @date_time = DateTime.parse("#{opts[:date]} #{opts[:time]}")
      end
      
      def self.parse(xml)
        date = xml.get_attr_value "date"
        time = xml.get_attr_value "time"

        new(:date => date,
            :time => time)
      end
    end
    
    class Arrival < SectionTime ; end
    
    class Departure < SectionTime ; end
    
    
    # Part represents Walks and Lines.    
    class Part
  
      attr_reader :time, :distance,
                  :sections, :map_locations, :points, :stops
                  
      def initialize(opts)
        @time = opts[:time].to_f if opts[:time]
        @distance = opts[:distance].to_f if opts[:time]
        @sections, @map_locations, @points, @stops = opts[:sections], opts[:map_locations], opts[:points], opts[:stops]
      end

      def self.parse(xml)
        length_element = xml.search("LENGTH").first
        
        time = length_element.get_attr_value "time"
        distance = length_element.get_attr_value "dist"
        
        sections, map_locations, points, stops = [], [], [], []
        
        xml.elements.each do |e|
          next if e.name == "LENGTH"
          
          case e.name
            when "POINT"
              point = Point.parse(e)
              sections << point
              points << point
            when "MAPLOC"
              map_location = MapLocation.parse(e)
              sections << map_location
              map_locations << map_location
            when "STOP"
              stop = Stop.parse(e)
              sections << stop
              stops << stop
          end
        end
        
        { :time => time,
          :distance => distance,
          :sections => sections,
          :map_locations => map_locations,
          :points => points,
          :stops => stops }
      end

    end
    
    class Walk < Part
      
      def self.parse(xml)
        opts = super
        
        new opts
      end
    end
    
    class Line < Part
      attr_reader :line_id, :code, :line_type, :mobility
      
      def initialize(opts)
        super
        
        @line_id = opts[:line_id]
        @code = opts[:code]
        @line_type = opts[:line_type].to_i if opts[:line_type]
        @mobility = opts[:mobility].to_i if opts[:mobility]
        
        @stops = opts[:stops] || []
      end

      def self.parse(xml)
        opts = super
        
        line_id = xml.get_attr_value "id"
        code = xml.get_attr_value "code"
        line_type = xml.get_attr_value "type"
        mobility = xml.get_attr_value "mobility"
        
        stops = []
        
        opts[:sections].each do |section|
          stops << section if section.is_a? Stop
        end            
        
        opts.merge!(:line_id => line_id,
                    :code => code,
                    :line_type => line_type,
                    :mobility => mobility,
                    :stops => stops)
      
        new(opts)
      end
    end
    
    
  end
  
  
  
end