# encoding: UTF-8
module Maintain
  class IntegerValue < Value
    def value
      value_for(@value)
    end
  end
end