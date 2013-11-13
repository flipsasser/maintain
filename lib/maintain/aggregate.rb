require 'maintain/state'

module Maintain
  class Aggregate < State

    def define_boolean_methods!(definition)
      define_with_alias(definition, "#{name}?", %{
        #{value.inspect}.include?(#{definition.attribute}.name)
      })
    end

  end
end
