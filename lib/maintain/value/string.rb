module Maintain
  module Value
    class String < DelegateClass(String)
      include Maintain::Value

    end
  end
end
