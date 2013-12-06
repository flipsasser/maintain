module Maintain
  module Value
    class Integer < DelegateClass(Fixnum)
      include Maintain::Value
    end
  end
end
