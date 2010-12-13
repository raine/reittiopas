class Reittiopas
  
  module Routing
  
    def routing(from, to, opts)
      @from = from
      @to = to
      @options = opts

      params = { :a => @from.coordinates[:kkj].to_routing_string,
                 :b => @to.coordinates[:kkj].to_routing_string,
                 :opts => opts }
      
      Route.parse @http.get(params), opts
    end
        
  end
  
end