require 'maintain/state'

module Maintain
  class Aggregate < State

    def define_boolean_methods!(definition)
      define_with_alias(definition, "#{name}?", %{
        #{value.inspect}.any? do |value|
          #{definition.attribute} == value
        end
      })
    end

  end
end
