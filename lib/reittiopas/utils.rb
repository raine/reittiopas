# Ugly, get rid of
module Nokogiri #:nodoc: all
module XML
class Element
  def get_attr_value(attr)
    # Might be better to just discard empty attributes
    (a = attribute(attr); a && !a.value.empty? ? a.value : nil)
  end
end
end
end
