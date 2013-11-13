# encoding: UTF-8
module Maintain
  module Value

    autoload(:Bitmask, 'maintain/value/bitmask')
    autoload(:Integer, 'maintain/value/integer')
    autoload(:String, 'maintain/value/string')

    attr_reader :definition, :state

    def initialize(value, definition)
      value = cast(value)
      super(value)
      @definition = definition
      @state = @definition.states.values.find do |state|
        state.value == value
      end
      @value = value
    end

    #def >(value)
      #compare_value > compare_value_for(value)
    #end

    #def >=(value)
      #compare_value >= compare_value_for(value)
    #end

    #def <(value)
      #compare_value < compare_value_for(value)
    #end

    #def <=(value)
      #compare_value <= compare_value_for(value)
    #end

    #def ==(value)
      #compare_value == compare_value_for(value)
    #end

    #def ===(value)
      #(compare_value == compare_value_for(value)) || super
    #end

    #def as_json(options = nil)
      #@value.to_s
    #end

    def name
      state && state.name
    end

  end
end
