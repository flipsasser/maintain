# encoding: UTF-8
module Maintain
  module Value

    autoload(:Bitmask, 'maintain/value/bitmask')
    autoload(:Integer, 'maintain/value/integer')
    autoload(:String, 'maintain/value/string')

    attr_reader :definition, :state

    def initialize(states, definition, instance)
      value = cast(states)
      super(value)
      @definition = definition
      @states = Array(states)
      @instance = instance
      @value = value
    end

    def >(comparison_value)
      @value > detect_value(comparison_value)
    end

    def >=(comparison_value)
      @value >= detect_value(comparison_value)
    end

    def <(comparison_value)
      @value < detect_value(comparison_value)
    end

    def <=(comparison_value)
      @value <= detect_value(comparison_value)
    end

    def ==(comparison_value)
      @states.any? do |state|
        state.name == comparison_value ||
          state.value == comparison_value
      end
    end

    def ===(comparison_value)
      raise @value.inspect
      (compare_value == compare_value_for(value)) || super
    end

    def name
      state && state.name.to_s
    end

    private

    def cast(state)
      state.value
    end

    def detect_value(value)
      @definition.detect_value(value)
    end

    def __setobj__(value)
      super value
      if @instance
        @instance.send("#{definition.attribute}=", value)
      end
    end

  end
end
