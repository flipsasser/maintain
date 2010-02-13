module Maintain
  class IntegerStateValue < StateValue
    def value
      value_for(@value)
    end
  end
end