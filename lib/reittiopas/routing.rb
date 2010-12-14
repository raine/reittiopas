class Reittiopas
  
  module Routing
  
    def routing(from, to, opts)
      @from = from
      @to = to
      @options = opts

      params = { :a => @from.coordinates[:kkj].to_routing_string,
                 :b => @to.coordinates[:kkj].to_routing_string,
                 :opts => opts }
      
      xml = @http.get(params), opts
      
      doc = Nokogiri::XML(xml)
      Route.parse doc
    end
  
  
    class Route
    
      attr_reader :time, :distance
      attr_accessor :parts, :walks, :lines
      
      def initialize(opts)
        @time = opts[:time].to_f if opts[:time]
        @distance = opts[:distance].to_f if opts[:time]
        @parts, @walks, @lines = [], [], []
        
      end
      
      def self.parse(xml)
        length_element = xml.search("LENGTH").first
        
        time = length_element.get_attr_value "time"
        dist = length_element.get_attr_value "dist"
        
        route = new(:time => time,
                    :distance => dist)

        xml.elements.each do |e|
          next if e.name == "LENGTH"

          case e.name
            when "POINT"
              route.parts << Point.parse(e)
            when "WALK"
              walk = Walk.parse(e)
              route.parts << walk
              route.walks << walk
            when "LINE"
              line = Line.parse(e)
              route.parts << line
              route.lines << line
          end

        end
        #start_point_element = xml.search("POINT[@uid='start']").first
        
      #  puts start_point_element
        
        return route
      end
      
      def k
        start_point_arrival_element = start_point_element.search("ARRIVAL").first

        dest_point_element = xml.search("POINT[@uid='dest']").first
        dest_point_arrival_element = dest_point_element.search("ARRIVAL").first


        start_date = start_point_arrival_element.attribute("date").value
        start_time = start_point_arrival_element.attribute("time").value
        start_datetime = DateTime.parse("#{start_date} #{start_time}")

        dest_date = dest_point_arrival_element.attribute("date").value
        dest_time = dest_point_arrival_element.attribute("time").value
        dest_datetime = DateTime.parse("#{dest_date} #{dest_time}")
        # 
        # parts = []
        # 
        # xml.elements.each do |e|
        #   next if e.name == "LENGTH" || e.name == "POINT"
        # 
        #   if e.name == "WALK"        
        #     parts << ReittiopasAPI::Walk.parse(e)
        #   elsif e.name == "LINE"
        #     parts << ReittiopasAPI::Line.parse(e)        
        #   end
        # end
        # 
        # new(:time=>time,
        #     :dist=>dist,
        #     :start_datetime => start_datetime,
        #     :dest_datetime => dest_datetime,
        #     :parts => parts)
        
      end
      
    end
    
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
      
      attr_reader :location_type
      
      def initialize(opts)
        super
        @location_type = opts[:location_type].to_i if opts[:location_type]
      end
      
      def self.parse(xml)
        opts = super
        location_type = xml.get_attr_value "type"
        
        opts.merge!(:location_type => location_type)
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
    
    class Arrival < SectionTime
    
    end
    
    class Departure < SectionTime
    
    end
    
    class Part
  
      attr_reader :time, :distance,
                  :sections
                  
      def initialize(opts)
        @time = opts[:time].to_f if opts[:time]
        @distance = opts[:distance].to_f if opts[:time]
        @sections = opts[:sections]
      end

      def self.parse(xml)
        length_element = xml.search("LENGTH").first
        
        time = length_element.get_attr_value "time"
        distance = length_element.get_attr_value "dist"
        
        sections = []
        
        xml.elements.each do |e|
          next if e.name == "LENGTH"
          
          case e.name
            when "POINT"
              sections << Point.parse(e)
            when "MAPLOC"
              sections << MapLocation.parse(e)
            when "STOP"
              sections << Stop.parse(e)
          end
        end
        
        { :time => time,
          :distance => distance,
          :sections => sections }
      end

    end
    
    class Walk < Part
      
      def self.parse(xml)
        opts = super
        
        new opts
      end
    end
    
    class Line < Part
      attr_reader :line_id
      
      def initialize(opts)
        super
        
        @line_id = opts[:line_id]
      end

      def self.parse(xml)
        opts = super
        
        line_id = xml.get_attr_value "id"
        
        
        opts.merge!(:line_id => line_id)
      
        new(opts)
      end
    end
    
    
  end
  
  
  
end