class Reittiopas
  
  module Routing
  
    def routing(from, to, opts)
      @from = from
      @to = to
      @options = opts

      params = { :a => @from.coordinates[:kkj].to_routing_string,
                 :b => @to.coordinates[:kkj].to_routing_string,
                 :opts => opts }
      
      parse @http.get(params), opts
      
    end

    private
    
    def parse(response, opts)
      puts response
    end
        
  end
  
end