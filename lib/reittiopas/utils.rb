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

class Hash
  def assert_valid_keys(*valid_keys)
    unknown_keys = keys - [valid_keys].flatten
    raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty?
  end
end
